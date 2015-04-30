#!/usr/local/bin/perl

use SNMPWrapper;
use DBWrapper::OCI_DBWrapper;
use ConfigFileReader;
use Date::Manip;
use strict;
use DBI qw(:sql_types);

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = $config->getAttribute("DebugLevel");

# get the parameter for the database
my $dbhost = ($debug >= 5 ? "broadband.oss.sprint.com" : $config->getAttribute("DBhost"));
my $sid = ($debug >= 5 ? "ORCL" : $config->getAttribute("DatabaseSID"));
my $user = ($debug >= 5 ? "geonet" : $config->getAttribute("DBusername"));
my $pass = ($debug >= 5 ? "tenoeg" : $config->getAttribute("DBpassword"));

if (0) {
print("host: $dbhost\n") if $debug;
# connect to the database
my $dbi = DBI->connect( "dbi:Oracle:host=$dbhost;sid=$sid", $user, $pass)
      or die "Can't connect to Oracle database: $DBI::errstr\n";
if (!$dbi) { print "not connected to oracle\n"; exit; }
#$dbi->{ShowErrorStatement} = "on";
$dbi->{PrintError} = "on";
$dbi->{RaiseError} = "off";


# PRECOMPILED SQL STATEMENTS
############################

my %statements;

$statements{"GetConnectInfo"} = {
  "select" => 1,
  "datatypes" => [],
  "statement" =>
    "SELECT t.ipaddress as ip, i.e2 as portnum, i.e3 as bandwidth, "
  . " p.name as protocol"
  . " to_char(timeentered, 'MM/DD/YYYY HH24:MI:SS') as last_date,"
  . " to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') as now"
  . " FROM tids t, facilities f, interfaces i, tid_facility_map tfm, "
  . " interface_types it, protocols p"
  . " WHERE t.id = tfm.tid_id and f.id = tfm.facility_id"
  . " and i.id = tfm.interface_id"
  . " and i.interface_type_id = it.id"
  . " and it.protocol_id = p.id"};
$statements{"GetConnectInfo"}->{"handle"} = $dbi->prepare($statements{"GetConnectInfo"}->{"statement"});

print "Checking GetConnectInfo: " . $statements{GetConnectInfo}->{handle} . "\n" if($debug >= 1);


$statements{"UpdatePMs"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "UPDATE pm_info "
  . "SET timeentered = SYSDATE, c9 = ?, c10 = ? "
  . "WHERE tid_id = ? and interface_id = ? "};
$statements{"UpdatePMs"}->{"handle"} = $dbi->prepare($statements{"UpdatePMs"}->{"statement"});

print "Checking UpdatePMs: " . $statements{UpdatePMs}->{handle} . "\n" if($debug >= 1);
}

# MAIN
###########################

my $debug = 0;
my $ip = '10.252.156.22';
my $port = '1B2';
$ip = "172.20.198.107";
my $port_num = 2060;
my $if_type;

#my $ip = '172.20.244.15';
#my $port = '3B1[2,2]';

#print(unpack("C*", 'A') . "\n");
#print(acquireNumByPort("1A22") . "\n");
#print(acquireNumByPort("1A2[3,1]") . "\n");
#print(acquireNumByPort("1A2[3](7,4)") . "\n");
#print(acquireNumByPort("1B2[4,1]") . "\n");

#exit;

my $sess = SNMPWrapper->new($ip, $debug, "public");

if (0) {
$if_type = &_guess_if_type($sess, $port);
print("if_type: $if_type \n");

$port_num = &_lookup_port_num($sess, $port);
print("port_num: $port_num \n");

print "Port ID: " . &_build_port_oid($port) . "\n";
}

my %hop;

@hop{("port_xmit","port_rcvd","hw_loc")} = &_lookup_port_info($sess, $port_num);
print "port_xmit: " . $hop{"port_xmit"} . "\nport_rcvd:" . $hop{"port_rcvd"} . "\nhw_loc:" . $hop{"hw_loc"} . "\n";


if (0) {
if ($if_type == 30)
{
  my $if_num = &_lookup_if_num($sess,$port);
  print("if_num: $if_num \n");

    my $statements;
    my $tidid = { "port" => $port, "if_num" => $if_num };
    &_check_if_num($statements,$sess,$tidid);
    $hop{"if_status"} = &_lookup_ds3_status($sess, $if_num);
    print "if_status: " . $hop{"if_status"} . "\n";

  } elsif ($if_type == 50) {
    @hop{("section_status", "line_status", "path_status")} = &_lookup_sonet_status($sess, $hop{"hw_loc"});
    print "section_status: " . $hop{"section_status"} . "\nline_status:" . $hop{"line_status"} . "\npath_status:" . $hop{"path_status"} . "\n";


  }
}

$sess->Close();

exit;





my $example = "
1.3.6.1.4.1.326.2.2.2.1.20.1.1.2.9.82.51.66.49.91.50.44.50.93
select h.inport, i.ip, i.fabric
from pnni.historical h, pnni.ipconversion i 
where h.clli = i.clli
and h.clli = 'KSCYMOECBBU' and currentpath = 1
and nvcid = 'N00000635654' and rownum < 5;

CLLI              TRACENUM  PATHINDEX        HOP INPORT     NVCID
--------------- ---------- ---------- ---------- ---------- ---------------
KSCYMOECBBU          13365       9414          0 3B1[2,2]   N00000635654
KSCYMOECBC9          13365       9414          1 1B2        N00000635654
FTWOTX52BE6          13365       9414          2 1D1        N00000635654
FTWOTX52BC3          13365       9414          3 3B1        N00000635654

same tid, different nvcid
KSCYMOECBC9          12337       8360          2 3B1        N00000698942
KSCYMOECBC9          13356       9404          2 3B1        N00000695673
KSCYMOECBC9          13355       9403          1 1B2        N00000638076

select clli, ip from ipconversion where clli = 'KSCYMOECBBU' and rownum < 5;

CLLI                      IP
------------------------- ---------------
KSCYMOECBBU               172.20.244.15
KSCYMOECBC9               10.252.156.22
FTWOTX52BE6               10.252.136.19
FTWOTX52BC3               10.252.136.89";

sub _guess_if_type
{
  my ($sess, $port) = @_;

  my $type;

  if($port =~ /,.*,/) {
    $type = 32;
  } elsif($port =~ /,/) {
    $type = 30;
  } else {
    $type = 50;
  }

  print "$port type - $type\n" if($debug >= 1);

  return $type;
}

sub _lookup_port_num
{
  my ($sess, $port) = @_;

  my $myoid = "1.3.6.1.4.1.326.2.2.2.1.20.1.1.2." . &_build_port_oid($port);
  print("oid: $myoid\n");
  
  #my ($port_num) =  $sess->Get("1.3.6.1.4.1.326.2.2.2.1.20.1.1.2." . &_build_port_oid($port));
  my ($port_num) =  $sess->Get($myoid);

  print "Port Num: $port_num\n" if($debug >= 1);

  return $port_num;
}


sub _build_port_oid
{
  my ($port) = @_;

  $port = "R$port" unless ($port =~ /^R/);

  my $val = length($port);

  $val .= "." . join(".", unpack("C*", $port));

  return $val;
}


sub _lookup_if_num
{
  my ($sess, $port) = @_;

  my $vals = $sess->GetNext("1.3.6.1.2.1.31.1.1.1.1");

  my @if_nums;

  foreach my $x (keys %{$vals}) {
    foreach my $y (keys %{$vals->{$x}}) {
      print "$x $y " . $vals->{$x}{$y} . " -- $port\n" if($debug >= 3);

      print $vals->{$x}{$y} . " -- $port --- We should match.\n" if ($vals->{$x}{$y} eq $port && $debug >= 3);
      push @if_nums, $y if($vals->{$x}{$y} eq $port);
    }
  }

  print "IFs - ", join(",", @if_nums), "\n" if($debug >= 3);

  return unless @if_nums;

  foreach my $iff (@if_nums) {
    my ($cx) = $sess->Get("1.3.6.1.2.1.2.2.1.3.$iff");
    return $iff if($cx == 30);
  }

  return;
}


sub _check_if_num
{
  my ($statements, $sess, $tidid) = @_;

  my ($port) = $sess->Get("1.3.6.1.2.1.31.1.1.1.1." . $tidid->{"if_num"});

  if($port eq $tidid->{"port"}) {
    return;
  }

  print("In _check_if_num: need to update if num.\n");
  if (0) {
    my %insert_fields;
  
    print "About to UpdateIFNum\n" if($debug >= 4);
    &execute_SQL($statements->{UpdateIFNum}, &_lookup_if_num($sess, $tidid->{"port"}), $tidid->{"tidid"});
    print "Done with UpdateIFNum\n" if($debug >= 4);
  }
}

sub _lookup_port_info
{
  my ($sess, $port_num) = @_;

  my ($rcvd, $xmit, $brd, $mod, $prt) = $sess->Get(map {"1.3.6.1.4.1.326.2.2.2.1.2.2.1.$_.$port_num"} (12,18,19,20,21));

  print "$port_num: XMit - $xmit, Rcvd - $rcvd\n" if($debug >= 1);
  print "$port_num: Board - $brd, Module - $mod, Port - $prt\n" if($debug >= 1);

  return ($xmit, $rcvd, "$brd.$mod.$prt");
}

sub acquireNumByPort
  {
    my ($port) = @_;
    
    my $number = 0;
    my $first = substr($port, 0, 1);

    $first--;

    $number = $first << 10;

    print("port: $port \nnumber: $number, first: $first\n") if ($debug );

    my $second = unpack("C*", substr($port, 1, 1)) - unpack("C*", 'A');

    print(substr($port, 1, 1). " second: $second\n") if ($debug);
    $number += $second << 8;

    print("number: $number, second: $second\n") if ($debug);
    
    # exple 1A2
    if (index($port, '[') <= -1) 
    {
       $number += substr($port, 2) - 1;

    } 
    
    # exple 1A2[1,3]
    elsif (index($port, '(') <= -1) 
    {
      $number += (substr($port, 2, 1) - 1) * 12;
      $number += (substr($port, 4, 1) - 1);
      $number += (substr($port, 6, 1) - 1) * 4;

    } 
    
    # exple 1A2[2](1,4) --> 115
    else {
      $number += (substr($port, 2, 1) - 1) * 84;
      $number += (substr($port, 4, 1) - 1) * 28;
      $number += (substr($port, 7, 1) - 1) * 7;
      $number += (substr($port, 9, 1) - 1);

    }

    print("number: $number\n") if ($debug);

    return $number;
  }

sub _lookup_sonet_status
{
  my ($sess, $hw_loc) = @_;

  my ($sec, $line, $path) = $sess->Get(map {"1.3.6.1.4.1.326.2.2.1.1.4.1.1.1.$_.$hw_loc"} (13,14,15));

  print "$hw_loc: Section - $sec, Line - $line, Path - $path\n" if($debug >= 1);

  return ($sec, $line, $path);
}


sub _lookup_ds1_status
{
  my ($sess, $hw_loc) = @_;

  return;
}


sub _lookup_port_info
{
  my ($sess, $port_num) = @_;

  my ($rcvd, $xmit, $brd, $mod, $prt) = $sess->Get(map {"1.3.6.1.4.1.326.2.2.2.1.2.2.1.$_.$port_num"} (12,18,19,20,21));

  print "$port_num: XMit - $xmit, Rcvd - $rcvd\n" if($debug >= 1);
  print "$port_num: Board - $brd, Module - $mod, Port - $prt\n" if($debug >= 1);

  return ($xmit, $rcvd, "$brd.$mod.$prt");
}

sub _lookup_ds3_status
{
  my ($sess, $if_num) = @_;

  my ($status) = $sess->Get("1.3.6.1.4.1.326.2.2.1.1.15.1.1.3.$if_num");

  print "$if_num status - $status\n" if($debug >= 1);

  return $status;
}


