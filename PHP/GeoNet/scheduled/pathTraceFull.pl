#!/usr/bin/perl 

use DBI;
use Net::SNMP;
use POSIX;
use Data::Dumper;
use Carp;
use strict;
open(ERRFILE, ">>errfile.out");

my $dbh = DBI->connect("dbi:Pg:dbname=opus2", 'postgres', '') || print "$DBI::errstr\n";
my $traceConn = '1.3.6.1.4.1.353.5.9.2.1.1.2.1.1';
my $traceConnResults = '1.3.6.1.4.1.353.5.9.2.1.1.5.2.1';
my $fullSnapshot = 1;
my $verbose = 2;
my $rootDir = '/usr/local/apache/htdocs/develOpus';

my $host = shift(@ARGV);

my $sql = "select nsap, clli
           from clliconversion";
my $sth = $dbh->prepare($sql);
$sth->execute or croak $dbh->errstr;
my %clliLookup;
while (my ($nsap, $clli) = ($sth->fetchrow_array)){
  $clliLookup{$nsap} = $clli;
}
$sth->finish;

$sql = "select asxport, engport, clli, fmscircuitid, nsap
           from dyn_portconversion";
$sth = $dbh->prepare($sql);
$sth->execute or croak $dbh->errstr;
my %engPortLookup;
my %inPortLookup;
my %asxPortLookup;
my %termPortLookup;
while (my ($asxport, $engPort, $clli, $circuitID, $portnsap) = ($sth->fetchrow_array)){
  $engPortLookup{$asxport}{$clli} = [$engPort, $circuitID];
  push (@{$inPortLookup{$circuitID}}, $engPort) if $circuitID;
  $asxPortLookup{$engPort}{$clli} = [$asxport, $circuitID];
  $termPortLookup{$portnsap} = [$engPort, $circuitID];
}
$sth->finish;

$sql = "select nvcid, ip, asxport, vp, vc, customer, clli, nsap, engport, connectiontype, endvp, endvc, global_index
           from switchinfo ";
$sql .= "where ip = '$host'";

$sth = $dbh->prepare($sql);
$sth->execute or croak $dbh->errstr;
my %sessionLookup;
my %processQueue;
my $groupNum = 1;
my $groupSize = 5;
my %hostCountLookup;
my %destNsapLookup;
my %ctypeLookup;
my %nvcidLookup;
while (my @switchInfo = $sth->fetchrow_array){
  my ($nvcID, $host, $asxPort, $vp, $vc, $customer, $clli, $destnsap, $engPort,
$ctype, $zvp, $zvc, $global_index) = (@switchInfo);
  $destNsapLookup{$nvcID} = $destnsap;
  $ctypeLookup{$nvcID} = $ctype;
  $nvcidLookup{$nvcID} = $global_index;
  my $num;
  if (exists $hostCountLookup{$host}){
    $hostCountLookup{$host}++;
    $num = $hostCountLookup{$host};
  }else{
    $hostCountLookup{$host} = 1;
    $num = 1;
  }
  my $groupNum = ceil(($num / $groupSize));
  $customer =~ s/\'/\\'/g;
  my @info = ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap, $global_index);

  push (@{$processQueue{$groupNum}{$host}}, \@info);
  next if exists $sessionLookup{$host};
  my ($session, $error) = Net::SNMP->session(
        -version     => 'snmpv2c',
        -hostname    => "$host",
        -community   => 'private'
          );
  $sessionLookup{$host} = $session;
  $clliLookup{$destnsap} = $clli;
}
my %hostStatus;

my ($Sec, $Min, $Hr, $Day, $Month, $Year) = (localtime)[1,1,2,3,4,5];
$Month = $Month + 1;
$Year = $Year + 1900;
my $timeStamp .= sprintf("%02d%02d%02d%02d%02d%02d", $Year, $Month, $Day, $Hr, $Min, $Sec);

&createTraces();
&getResults();
&parseResults();

if($fullSnapshot){
  my $infile = "$rootDir/inputFiles/curr/$host\.reghop\.input";
  `/usr/local/pgsql/bin/psql -c "COPY currentpath (customer, nvcid, hop, outport, invp, invc, nsap, timechanged, timeupdated, currentpath, connection, tracenum, clli, fmscircuitid, outvp, outvc, inport, connectiontype, pathindex, host) from '$infile' WITH NULL AS 'YoLala'" opus2 postgres`;
}else{
  &checkDiffs;
} 

$dbh->do("update currentpath set timechanged='$timeStamp' where host='$host' and timechanged IS NULL or timechanged = 0");
$dbh->do("update historical set timechanged='$timeStamp' where host='$host' and timechanged IS NULL or timechanged = 0");

sub createTraces{
  foreach my $groupNum (sort keys %processQueue){
    foreach my $host (sort keys %{$processQueue{$groupNum}}){
      my $session = $sessionLookup{$host};
      my @snmpSets;
      my @nvcIDList = @{$processQueue{$groupNum}{$host}};
      my @statusOIDs;
      my @newOIDList;
      my $rootVPOID = '1.3.6.1.4.1.326.2.2.2.1.3.2.1.1';
      my $rootVCOID = '1.3.6.1.4.1.326.2.2.2.1.4.2.1.1';
      foreach my $entry (@nvcIDList){
        my @nvcInfo = @{$entry};
        my @switchInfo = @{$entry};
        my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap, $global_index) = (@nvcInfo);
        my $traceID = $nvcidLookup{$nvcID};

        next unless ($nvcID && $host && defined($asxPort) && defined($vp));
        if (exists $hostStatus{$host}){
          $hostStatus{$host}++;
        }else{
          $hostStatus{$host} = $traceID;
        }
        my $newOID;
        if (!$vc){
          $newOID = "$rootVPOID.$asxPort.$vp";
        }else{
          $newOID = "$rootVCOID.$asxPort.$vp.$vc";
        }
        push (@newOIDList, $newOID);
      }
      my $result = $session->get_next_request(
               -varbindlist      => \@newOIDList
      );
      my %keyLookupTable;
      foreach my $entry (@nvcIDList){
        my %result = %{$result};
        my @nvcInfo = @{$entry};
        my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap, $global_index) = (@nvcInfo);
        my $traceID = $nvcidLookup{$nvcID};
        my $statusOid = $traceConn . ".19.$traceID";
        my $ifOid = $traceConn . ".3.$traceID";
        my $typeOid = $traceConn . ".4.$traceID";
        my $vpiOid = $traceConn . ".5.$traceID";
        my $vciOid = $traceConn . ".6.$traceID";
        my $directionOid = $traceConn . ".10.$traceID";
        my $idOid = $traceConn . ".11.$traceID";
        my $ageOid = $traceConn . ".15.$traceID";
  
        foreach my $key (sort keys %{$result}){
          if ($vc){
            next unless $key =~ /$rootVCOID\.$asxPort\.$vp\.$vc\./;
          }else{
            next unless $key =~ /$rootVPOID\.$asxPort\.$vp\./;
          }
          my ($ifValue, $vpiValue, $vciValue);
          my $flag = 0;
          if (!$vc){
            $key =~ /$rootVPOID\.$asxPort\.$vp\.(\d+)\.(\d+)/;
            $ifValue = $1;
            $vpiValue = $2;
          }else{
            $key =~ /$rootVCOID\.$asxPort\.$vp\.$vc\.(\d+)\.(\d+)\.(\d+)/;
            $ifValue = $1;
            $vpiValue = $2;
            $vciValue = $3;
            if(!(defined $vpiValue) or !(defined $vciValue)){
              print ERRFILE "Didnt get $nvcID : $vpiValue or $vciValue for $asxPort $vp $vc key is $key\n\n";
              $flag = 1;
            }
          }
          if (!$vc){
            next unless ((defined $ifValue) && (defined $vpiValue));
            push (@snmpSets, $statusOid, INTEGER, '4');
            push (@snmpSets, $ifOid, INTEGER, "$ifValue");
            push (@snmpSets, $vpiOid, INTEGER, "$vpiValue");
            push (@snmpSets, $typeOid, INTEGER, '3');
            push (@snmpSets, $directionOid, INTEGER, '2');
            push (@snmpSets, $idOid, INTEGER, '1');
            push (@snmpSets, $ageOid, INTEGER, '300');
          }else{
            next unless ((defined $ifValue) && (defined $vpiValue) && (defined $vciValue));
            push (@snmpSets, $statusOid, INTEGER, '4');
            push (@snmpSets, $ifOid, INTEGER, "$ifValue");
            push (@snmpSets, $vpiOid, INTEGER, "$vpiValue");
            push (@snmpSets, $vciOid, INTEGER, "$vciValue");
            push (@snmpSets, $directionOid, INTEGER, '2');
            push (@snmpSets, $idOid, INTEGER, '1');
            push (@snmpSets, $ageOid, INTEGER, '300');
          }
        }
      }
      $result = $session->set_request(
        -varbindlist => \@snmpSets
      );
      my $newError = $session->error;
  
      if ($newError){
        foreach my $entry (@nvcIDList){
          my @nvcInfo = @{$entry};
          my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap) = (@nvcInfo);
          #print ERRFILE "Trace SET Didn't work for either\nVC: $vc\nHOST: $host\nNVCID: $nvcID\nACTUAL ERROR: $newError\n\n";
        }
      }else{
        foreach my $entry(@nvcIDList){
          my @nvcInfo = @{$entry};
          my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap) = (@nvcInfo);
          my $traceID = $nvcidLookup{$nvcID};
          #print ERRFILE "Didn't get a traceID for $nvcID\n\n" unless $traceID;
        }
      }
    }
  }
}

sub getResults{
  my $successfulls = 0;
  open(OUTFILE, ">$rootDir/inputFiles/outfiles/$host\.current.out");
  
  foreach my $groupNum (sort keys %processQueue){
    foreach my $host (sort keys %{$processQueue{$groupNum}}){
      my $session = $sessionLookup{$host};
      my @snmpSets;
      my @nvcIDList = @{$processQueue{$groupNum}{$host}};
      my @statusOIDs;
      foreach my $entry (@nvcIDList){
        my @switchInfo = @{$entry};
        @switchInfo = @{$entry};
        my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap) = (@switchInfo);
        my $traceID = $nvcidLookup{$nvcID};
        my @columns;
        my $traceInfoNodeID = $traceConnResults . ".2.$traceID";
        my $traceOutGoingPortID = $traceConnResults . ".3.$traceID";
        my $traceIncomingVPI = $traceConnResults . ".4.$traceID";
        my $traceIncomingVCI = $traceConnResults . ".5.$traceID";
  
        next unless ($nvcID && $host && defined($asxPort) && defined($vp));
        my $session = $sessionLookup{$host};
  
        my $oid .="$traceInfoNodeID";
        my $result = $session->get_entries(
          -columns  => [$traceInfoNodeID]
        );
        my $flag = 0;
        my %results;
        foreach my $entry (keys %{$result}){
          $flag = 1;
          $entry =~ /\.(\d+)$/;
          my $index = $1;
          $results{$index} = $result->{$entry};
        }
        #next unless $flag;
        print OUTFILE "$nvcID\@$customer\@$engPort\@$vp\@$vc\@" if ($vc);
        print OUTFILE "$nvcID\@$customer\@$engPort\@$vp\@\@" unless ($vc);
        foreach my $entry (sort { $a <=> $b } keys %results){
          my $nodeID = $results{$entry};
          $nodeID =~ s/0x44a0//;
          my $clli = $clliLookup{$nodeID};
          print OUTFILE "$nodeID,$clli#";
        }
        print OUTFILE "@";
  
        $result = $session->get_entries(
          -columns  => [$traceOutGoingPortID]
        );
  
        my $newError = $session->error;
        #print ERRFILE "get_entries $nvcID : I see $newError\n" if $newError;
        $flag = 0;
        foreach my $entry (keys %{$result}){
          $entry =~ /\.(\d+)$/;
          my $index = $1;
          $results{$index} = $result->{$entry};
        }
        foreach my $entry (sort { $a <=> $b } keys %results){
          $flag = 1;
          print OUTFILE "$results{$entry}#";
        }
        print OUTFILE "@";
  
        $result = $session->get_entries(
          -columns  => [$traceIncomingVPI]
        );
        $newError = $session->error;
        #print ERRFILE "get_entries $nvcID : I see $newError\n" if $newError;
        $flag = 0;
  
        foreach my $entry (keys %{$result}){
          $entry =~ /\.(\d+)$/;
          my $index = $1;
          $results{$index} = $result->{$entry};
        }
        foreach my $entry (sort { $a <=> $b } keys %results){
          $flag = 1;
          print OUTFILE "$results{$entry}#";
        }
        print OUTFILE "@";
  
       $result = $session->get_entries(
          -columns  => [$traceIncomingVCI]
        );
        $newError = $session->error;
        #print ERRFILE "get_entries $nvcID : I see $newError\n" if $newError;
        $flag = 0;
        foreach my $entry (keys %{$result}){
          $entry =~ /\.(\d+)$/;
          my $index = $1;
          $results{$index} = $result->{$entry};
        }
        foreach my $entry (sort { $a <=> $b } keys %results){
          $flag = 1;
          print OUTFILE "$results{$entry}#";
        }
        print OUTFILE "\n";
  
        $successfulls++ if $flag;
        print "Error on $nvcID\n" unless $flag;
        $newError = $session->error;
        #print ERRFILE "get_entries $nvcID : I see $newError\n" if $newError;
  
        my $traceRowStatus = ".19.$traceID";
        $oid = $traceConn;
        $oid .= "$traceRowStatus";
        $result = $session->set_request(
           -varbindlist => [$oid, INTEGER, '6']
        );
        $newError = $session->error;
        print ERRFILE "get clear  $nvcID : I see $newError\n" if $newError;
      }
    }
  }
  close OUTFILE;
  print "We traced $successfulls paths successfully for $host\n" if $verbose > 1;
}

sub parseResults{

  open(INFILE, "<$rootDir/inputFiles/outfiles/$host\.current.out");
  open(REGHOP, ">$rootDir/inputFiles/curr/$host\.reghop\.input") if $fullSnapshot;
  my $count = 0;
  my $writeCount = 0;

  while (<INFILE>){
    my @info = split(/@/);
    my $nvcID = shift @info;
    `cp $rootDir/inputFiles/curr/$nvcID\.reghop\.input $rootDir/inputFiles/prev/$nvcID\.reghop\.input` unless $fullSnapshot;
    open(REGHOP, ">$rootDir/inputFiles/curr/$nvcID\.reghop\.input") unless $fullSnapshot;
    my $customer = shift @info;
    my $aPort= shift @info;
    my $aVP = shift @info;
    my $aVC = shift @info;
    $aVC = undef unless $aVC;
    my ($pathIndex, $traceNum);
  
    my $nsapList = shift @info;
    my @nsapList = split (/\#/,$nsapList);
  
    my $outPortList = shift @info;
    my @outPortList = split (/\#/, $outPortList);
    my $inVPList = shift @info;
    my @inVPList = split (/\#/, $inVPList);
    my $sql = "select nextval('historical_tracenum_seq')";
    my $sth = $dbh->prepare($sql) if $fullSnapshot;
    $sth->execute or croak $dbh->errstr if $fullSnapshot;
    $traceNum = $sth->fetchrow if $fullSnapshot;
    $sth->finish if $fullSnapshot;
  
    my $inVCList = shift @info;
    my @inVCList = split (/\#/, $inVCList);
    my $hop = 0;
    my $prevclli;
    my $prevCircuitID;
    my $fmsid;
    my $PPPprevCircuitID;
    my $hops = 0;
  
  #count how many hops for this trace so that we know when the lasthop comes up
    foreach my $nsap (@nsapList){
      $hops++;
    }
    foreach my $nsap (@nsapList){
      my ($nsap, $clli) = split(/,/, $nsap);
      my ($outPort, $inVP, $inVC, $outVP, $outVC) = (undef, undef, undef, undef, undef);
      $outPort = $outPortList[$hop] unless !$outPortList[$hop];
      my $pathindex = 0;
      my $decOutPort;
      if (defined($outPort)){
        my $hexOutPort = sprintf("%X",$outPort);
        my $newHexPort = substr($hexOutPort, 4, 8);
        $decOutPort = hex($newHexPort);
      }else{
        $decOutPort = 0;
      }
      print ERRFILE "dec $decOutPort or clli $clli is missing from engPortLookup\n" unless exists $engPortLookup{$decOutPort}{$clli};
      my ($engPort, $circuitID) = @{$engPortLookup{$decOutPort}{$clli}} if exists $engPortLookup{$decOutPort}{$clli};
      #my ($engPort, $circuitID) = (undef, undef) unless exists $engPortLookup{$decOutPort}{$clli};
  #grabbing circuitID for output port, but front end program uses it for input port.
      my $nextHop = ($hop + 1);
      my $prevHop = ($hop - 1);
      my $lastHop = ($hops - 1);
  
      $inVP = $inVPList[$hop] if $inVPList[$hop];
      $inVC = $inVCList[$hop] if $inVCList[$hop];
      $outVP = $inVPList[$nextHop] if $inVPList[$nextHop];
      $outVC = $inVCList[$nextHop] if $inVCList[$nextHop];
      my $inPort;
      unless($hop == '0'){
        $outPort = $outPortList[$prevHop];
        my $prevDecOutPort;
        if (defined($outPort)){
          my $hexOutPort = sprintf("%X",$outPort);
          my $newHexPort = substr($hexOutPort, 4, 8);
          $prevDecOutPort = hex($newHexPort);
        }else{
          $prevDecOutPort = 0;
        }
        my ($prevEngPort, $PPPprevCircuitID) = @{$engPortLookup{$prevDecOutPort}{$prevclli}} if exists $engPortLookup{$prevDecOutPort}{$prevclli};
        my ($prevEngPort, $PPPprevCircuitID) = (undef, undef) unless exists $engPortLookup{$prevDecOutPort}{$prevclli};
        $PPPprevCircuitID = 'Unknown' unless $PPPprevCircuitID;
        my ($firstPort, $secondPort) = @{$inPortLookup{$PPPprevCircuitID}} if $inPortLookup{$PPPprevCircuitID};
        $fmsid = $PPPprevCircuitID;
        if ($firstPort eq  $prevEngPort){
          $inPort = $secondPort;
        }else{
          $inPort = $firstPort;
        }
      }else{
        $inPort = $aPort;
        $inVP = $aVP;
        $inVC = $aVC;
        my $trashPort;
        $fmsid = 0 unless $asxPortLookup{$inPort}{$clli};
        ($trashPort, $fmsid) = @{$asxPortLookup{$inPort}{$clli}} if $asxPortLookup{$inPort}{$clli}; #grab fmsid for first input port
      }
      my $connectionType = $ctypeLookup{$nvcID};
  #take inPort in eng, convert to dec, lookup in existing array
      $fmsid = 0 unless defined $fmsid;
      unless ($fmsid > 1) {
        $fmsid = 0;
      }
     $outVP = 0 unless defined $outVP;
     $inVP = 0 unless defined $inVP;
     $outVC = 0 unless defined $outVC;
     $inVC = 0 unless defined $inVC;
  
     if ($hop == $lastHop) { #LAST HOP
        my $destnsap = $destNsapLookup{$nvcID};
        my $termfmsid;
        next unless $termPortLookup{$destnsap};
        ($engPort, $termfmsid) = @{$termPortLookup{$destnsap}} if @{$termPortLookup{$destnsap}};
        $engPort = 'YoLala' unless defined ($engPort);
        $termfmsid = 'YoLala' unless defined ($termfmsid);
        my $penultimateHop = ($hop+1);
        if ($fullSnapshot){
          my $row = join("\t",
                     $customer,$nvcID,$penultimateHop, 'YoLala', 'YoLala', 'YoLala', $destnsap, 'YoLala', 'YoLala', 1,$nvcID,$traceNum, 'YoLala', $termfmsid, 'YoLala', 'YoLala', 'YoLala', $connectionType, $traceNum, $host);
          print REGHOP "$row\n"; 
        }else{
          my $row = join("\t",
                     $customer,$nvcID,$penultimateHop, 'YoLala', 'YoLala', 'YoLala', $destnsap, 'YoLala', 'YoLala', 1,$nvcID,'YoLala', 'YoLala', $termfmsid, 'YoLala', 'YoLala', 'YoLala', $connectionType, 'YoLala', $host);
          print REGHOP "$row\n"; 
        }
        $writeCount++;
      }
     if ($fullSnapshot){
       my $row = join("\t",
                   $customer, $nvcID, $hop, $engPort, $inVP, $inVC, 0, 'YoLala', 'YoLala', 1, $nvcID, $traceNum, $clli,
                   $fmsid, $outVP, $outVC, $inPort, $connectionType, $traceNum, $host);
       print REGHOP "$row\n";
     }else{
       my $row = join("\t",
                   $customer, $nvcID, $hop, $engPort, $inVP, $inVC, 0, 'YoLala', 'YoLala', 1, $nvcID, 'YoLala', $clli,
                   $fmsid, $outVP, $outVC, $inPort, $connectionType, 'YoLala', $host);
       print REGHOP "$row\n";
     }
     $writeCount++;
     $hop++;
     $prevclli = $clli;
     $prevCircuitID = $fmsid;
    }
    $count++;
  }
}

sub checkDiffs {
  my $newCP = "$rootDir/inputFiles/diffs/$host\.diffcp.input";
  my $newHist = "$rootDir/inputFiles/diffs/$host\.diffhist.input";
  `rm $newCP`;
  `rm $newHist`;
  foreach my $groupNum (sort keys %processQueue){
    foreach my $host (sort keys %{$processQueue{$groupNum}}){
      my $session = $sessionLookup{$host};
      my @snmpSets;
      my @nvcIDList = @{$processQueue{$groupNum}{$host}};
      my @statusOIDs;
      foreach my $entry (@nvcIDList){
        my @nvcInfo = @{$entry};
        my ($nvcID, $asxPort, $vp, $vc, $customer, $engPort, $destnsap, $global_index) = (@nvcInfo);
        next unless -e "$rootDir/inputFiles/curr/$nvcID\.reghop.input";
        `diff $rootDir/inputFiles/curr/$nvcID\.reghop.input $rootDir/inputFiles/prev/$nvcID\.reghop.input > $rootDir/inputFiles/diffs/$nvcID\.reghop.input`;
        next unless -e "$rootDir/inputFiles/diffs/$nvcID\.reghop.input";
        open (DIFF, "<$rootDir/inputFiles/diffs/$nvcID.reghop.input");
        my %oldValues;
        my %newValues;
      
        while (<DIFF>){
          chomp $_;
          if ($_ =~ /^\>/){
            my $line = $_;
            $line =~ s/\>\s+//;
            my (@info) = split(/\t/, $line);
            push (@{$oldValues{$info[1]}}, \@info);
      
          }elsif ($_ =~ /^\</){
            my $line = $_;
            $line =~ s/\<\s+//;
            my (@info) = split(/\t/, $line);
            push (@{$newValues{$info[1]}}, \@info);
          }
        }
        open (NEWCP, ">>$newCP");
        open (NEWHIST, ">>$newHist");
        foreach my $nvcID (keys %newValues){
          if (exists $oldValues{$nvcID}){
            my $sql = "select nextval('historical_tracenum_seq')";
            my $sth = $dbh->prepare($sql);
            $sth->execute or croak $dbh->errstr;
            my $traceNum = $sth->fetchrow;
            $sth->finish;
      
            my @newTrace = @{$newValues{$nvcID}};
            my @oldTrace = @{$oldValues{$nvcID}};
            foreach my $currentPath (@newTrace){
              my @currentPath = @{$currentPath};
              my ($customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, $timechanged,  $timeupdated, $currentpath, $name, $tracenum, 
              $clli, $fmsid, $outVP, $outVC, $inPort, $connectionType, $pathindex, $host) = (@currentPath);
              $clli = undef unless $clli;
              my $row = join("\t",
                       $customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, 'YoLala', 'YoLala', 1, $nvcID, $traceNum, $clli,
                       $fmsid, $outVP, $outVC, $inPort, $connectionType, $traceNum, $host);
              print NEWCP "$row\n";
            }
            foreach my $histPath (@oldTrace){
              my @histPath = @{$histPath};
              my ($customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, $timechanged,  $timeupdated, $currentpath, $name, $oldTracenum, 
              $clli, $fmsid, $outVP, $outVC, $inPort, $connectionType, $pathindex, $host) = (@histPath);
              $clli = undef unless $clli;
              my $row = join("\t",
                       $customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, 'YoLala', 'YoLala', 1, $nvcID, $traceNum, $clli, 
                       $fmsid, $outVP, $outVC, $inPort, $connectionType, $traceNum, $host);
              print NEWHIST "$row\n";
            }
          }else{
            
            my $checkSql = "select customer, nvcid, hop, outport, invp, invc, nsap, timechanged, timeupdated, currentpath, connection, tracenum, clli, fmscircuitid, outvp, outvc, inport, connectiontype, pathindex, host from currentpath where nvcid = '$nvcID' order by hop";
            my $sth = $dbh->prepare($checkSql);
            $sth->execute or croak $dbh->errstr;
            my (@pathInfo) = $sth->fetchrow_array;
            if (!@pathInfo){
              my $sql = "select nextval('historical_tracenum_seq')";
              my $sth = $dbh->prepare($sql);
              $sth->execute or croak $dbh->errstr;
              my $traceNum = $sth->fetchrow;
              $sth->finish;
              my @newTrace = @{$newValues{$nvcID}};
              #my @oldTrace = @{$oldValues{$nvcID}};
              foreach my $currentPath (@newTrace){
                my @currentPath = @{$currentPath};
                my ($customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, $timechanged,  $timeupdated, $currentpath, $name, $oldTracenum, 
                $clli, $fmsid, $outVP, $outVC, $inPort, $connectionType, $pathindex, $host) = (@currentPath);
                my $row = join("\t",
                         $customer, $nvcID, $hop, $engPort, $inVP, $inVC, $nsap, 'YoLala', 'YoLala', 1, $nvcID, $traceNum, $clli,
                         $fmsid, $outVP, $outVC, $inPort, $connectionType, $traceNum, $host);
                print NEWCP "$row\n";
              }
            }
          }
        }
      }
    }
  }
  if (-e $newCP){
    `/usr/local/pgsql/bin/psql -c "COPY currentpath (customer, nvcid, hop, outport, invp, invc, nsap, timechanged, timeupdated, currentpath, connection, tracenum, clli, fmscircuitid, outvp, outvc, inport, connectiontype, pathindex, host) from '$newCP' WITH NULL AS 'YoLala'" opus2 postgres`;
  }
  if (-e $newHist){
    `/usr/local/pgsql/bin/psql -c "COPY historical (customer, nvcid, hop, outport, invp, invc, nsap, timechanged, timeupdated, currentpath, connection, tracenum, clli, fmscircuitid, outvp, outvc, inport, connectiontype, pathindex, host) from '$newHist' WITH NULL AS 'YoLala'" opus2 postgres`;
  }
  $dbh->do("update currentpath set timechanged='$timeStamp' where host='$host' and timechanged IS NULL or timechanged = 0");
  $dbh->do("update historical set timechanged='$timeStamp' where host='$host' and timechanged IS NULL or timechanged = 0");

  $sql = "select distinct(nvcid), tracenum 
          from currentpath 
          where host='$host' 
          group by nvcid, tracenum 
          order by nvcid, tracenum asc";
  $sth = $dbh->prepare($sql);
  $sth->execute or croak $dbh->errstr;
  my %nvcids;
  my %deleteTimes;
  while (my ($nvcid, $timechanged) = ($sth->fetchrow_array)){
    push(@{$nvcids{$nvcid}}, $timechanged);
  }
  foreach my $nvcid (keys %nvcids){
    my @timechangedList = @{$nvcids{$nvcid}};
    my $count = $#timechangedList;
    if (exists $timechangedList[1]){
      my $deleteTime = $timechangedList[0];
      if (exists $deleteTimes{$deleteTime}){
        push (@{$deleteTimes{$deleteTime}}, ",'$nvcid'");
      }else{
        push (@{$deleteTimes{$deleteTime}}, "'$nvcid'");
      }
    }  
    if (exists $timechangedList[2]){
      my $deleteTime = $timechangedList[1];
      if (exists $deleteTimes{$deleteTime}){
        push (@{$deleteTimes{$deleteTime}}, ",'$nvcid'");
      }else{
        push (@{$deleteTimes{$deleteTime}}, "'$nvcid'");
      }
    }
  }
  foreach my $deleteTime (keys %deleteTimes){
    my @deleteNvcids = @{$deleteTimes{$deleteTime}};
    my $sql = "delete from currentpath where nvcid in (@deleteNvcids) and tracenum = '$deleteTime'";
    $dbh->do($sql);
  }
}
