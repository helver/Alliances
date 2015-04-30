package PM_Collector;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use SubmittorSockWrapper;
use RequestorSockWrapper;
use ConfigFileReader;
use IO::File;


# Modules should almost always "use strict".  This forces
# you to use variable declarations and ensure that variables
# are not globally scoped.
use strict;

# This stuff is needed for modules.
use vars qw(@ISA @EXPORT $VERSION);
@ISA = ('Exporter');
@EXPORT = qw();
$VERSION = 1.0;


###############################################################
#
# Function: new
#
# new is the module constructor.  It doesn't do much be create
# the object.  It invokes _init, which actually does some object
# initialization.
#
# $class is a reference to the object class
# $query is a reference to the CGI object we're using.
# @vars is a list of other variables passed to the constructor.
sub new {
  my ($class, $sock, $reqsock, $config, $debug) = @_;

  print "In PM_Collector::new\n" if $debug >= 5;
  
  my $this = {
    "class" => $class,
    "debug" => $debug,
    "config" => $config,
    "sock" => $sock,
    "reqsock" => $reqsock,
  };

  bless($this, $class);

  print "Returning from PM_Collector::new\n" if $debug >= 5;
  
  # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}






sub __open_logfile
{
  my ($this, $file) = @_;
  
  rename($file, $file . ".old") if (-e $file);
  (my $ext = $file) =~ s/.*\.//;
  $this->{$ext . "handle"} = new IO::File ">> $file";
}



  
sub __open_logfiles
{
  my ($this) = @_;
  
  my $filebase = $this->{config}->getAttribute("LogDir") . "/tid" . $this->{tid_id};
  my $pidfile = $filebase . ".pid";
  open FH, "> $pidfile" or die "Can't open tid" . $this->{tid_id} . ".pid file: $!\n";
  print FH "$$\n" . time() . "\n";
  close FH;
  
  $this->__open_logfile($filebase . ".log");
  $this->__open_logfile($filebase . ".err");
}



sub __close_logfiles
{
  my ($this) = @_;
  
  $this->{"loghandle"}->close();
  $this->{"errhandle"}->close();
}

  
sub __drop_message
{
  my ($this, $msg, $err, $out) = @_;
  
  print $msg if ($this->{debug} >= 1);
  print { $this->{errhandle} } $msg if $err;
  print { $this->{loghandle} } $msg if $out;
}





sub __start_timer
{
  my ($this) = @_;
  
  $this->{start_time} = time();
  $this->__drop_message("Current time: " . localtime($this->{start_time}) . "\n", 1, 1);
}





sub __stop_timer
{
  my ($this) = @_;
  
  my $end_time = time();
  my $elapse_time = $end_time - $this->{start_time};
  
  $this->__drop_message("Elapsed time: $elapse_time seconds\n", 1, 1);

  my $timeToWait = $this->{config}->getAttribute("Collector_CycleTime");
  
  if ($elapse_time < $timeToWait) {
    $this->__drop_message("Sleeping for ". ($timeToWait - $elapse_time) . " seconds more.\n", 1, 1);
    sleep ($timeToWait - $elapse_time) if($this->{debug} <= 2);
  }
}






sub __pull_interface_type_info
{
  my ($this, $iftype) = @_;
  
  $this->{reqsock}->send("GetInterfaceTypeInfo|" . $iftype . "\n", 10);
  my $dat = $this->{reqsock}->receive_data();

  my @cols = ("interface_type", "protocol_id", "protocol", 
              "e1name", "e2name", "e3name", "e4name", "e5name", "ifname", 
              "c1name", "c2name", "c3name", "c4name", "c5name", 
              "c6name", "c7name", "c8name", "c9name", "c10name", "speed", "use_accumulators",
              );
  
  foreach my $line (split /\n/, $dat) {
    my @ifinfo = split /\|/, $line;
    my $ifid = $ifinfo[0];
    
    my %if;
    @if{@cols} = @ifinfo;
    
    $this->{interface_types}->{$ifid} = \%if;
  }
  
  return $this->{interface_types}->{$iftype};
}




sub __get_interface_type_info
{
  my ($this, $if) = @_;

  if(!defined($this->{interface_types}->{$if->{interface_type}})) {
    $this->{interface_types}->{$if->{interface_type}} = $this->__pull_interface_type_info($if->{interface_type});
  }
  my $thisif = $this->{interface_types}->{$if->{interface_type}};
  
  $if->{$thisif->{e1name}} = $if->{e1};
  $if->{$thisif->{e2name}} = $if->{e2};
  $if->{$thisif->{e3name}} = $if->{e3};
  $if->{$thisif->{e4name}} = $if->{e4};
  $if->{$thisif->{e5name}} = $if->{e5};
  $if->{$thisif->{ifname}} = $if->{interface};
}



sub __get_pm_totals
{
  my ($this, $if) = @_;

  # get the pm totals from the database
  $this->{reqsock}->send("GetTotals|" . $if->{tid_id} . "|" . $if->{interface_id}. "\n", 10);
  my $dat = $this->{reqsock}->receive_data();

  my @cols = ("interface_id", "tid_id", "a1", "a2", "a3", "a4", "a5", "a6", 
              "a7", "a8", "a9", "a10", "timeentered", "currenttime",
              "cause", "c9",
             );
    
  my ($line) = split /\n/, $dat;
  my @pminfo = split /\|/, $line;
    
  my %pms;
  @pms{@cols} = @pminfo;
  
  $if->{"pm_totals"} = \%pms;
}





sub __get_interface_info
{
  my ($this) = @_;
  
  $this->{reqsock}->send("GetInterfaceInfoByTID|" . $this->{tid_id} . "|" . $this->{tid_id} . "\n", 10);
  my $dat = $this->{reqsock}->receive_data();

  my @cols = ("interface_id", "tid_id", "tid", "ipaddress", "element_type_id", "directionality",
              "e1", "e2", "e3", "e4", "e5", "interface", "interface_type", 
              "protocol", "trans_seq", "recv_seq", "port", "ring_id");
  
  delete $this->{protocol_list};
  delete $this->{interfaces};
  
  foreach my $line (split /\n/, $dat) {
    my @ifinfo = split /\|/, $line;
    my $ifid = $ifinfo[0] . "_" . $ifinfo[1];
    
    my %if;
    @if{@cols} = @ifinfo;
    
    $this->__get_interface_type_info(\%if);
    
    if($this->{interface_types}->{$if{interface_type}}->{"use_accumulators"} eq "t") {
	    $this->__get_pm_totals(\%if);
	  }
    
    $this->{interfaces}->{$ifid} = \%if;
    $this->{ipaddress} = $this->{interfaces}->{$ifid}->{ipaddress};
    $this->{port} = $this->{interfaces}->{$ifid}->{port};
    
    my $protocol = $this->{interfaces}->{$ifid}->{protocol};
    
    $this->__drop_message("Pushing interface $ifid onto list for protocol $protocol\n") if($this->{debug} >= 4);
    
    if(exists $this->{protocol_list}->{$protocol}) {
      push @{$this->{protocol_list}->{$protocol}}, $ifid;
    } else {
      $this->{protocol_list}->{$protocol} = [$ifid];
    }
  }
}

  



sub __load_protocol
{
  my ($this, $protocol) = @_;

  $this->__drop_message("In __load_protocol - protocol: $protocol\n") if($this->{debug} >= 4);
  
  unless(defined($this->{loaded_protocols}->{$protocol})) {
    eval "use Collectors::Collector_" . $protocol . ";";
      
    if($@) {
      $this->__drop_message("Use Error on Protocol: $protocol: $@\n", 1, 1);
      delete $this->{protocol_list}->{$protocol};
      exit if ($this->{debug} >= 3);
      return 0;
    }
    
    my $collector;
    eval "\$collector = new Collectors::Collector_" . $protocol . "(\$this->{sock}, \$this->{loghandle}, \$this->{errhandle}, \$this->{config}, \$this->{debug});";
    if($@) {
      $this->__drop_message("New Instance on Protocol: $protocol: $@\n", 1, 1);
      delete $this->{protocol_list}->{$protocol};
      exit if ($this->{debug} >= 3);
      return 0;
    }
    
    $this->{loaded_protocols}->{$protocol} = $collector;
  }
  return 1;
}


  

sub __getNextTID
{
  my ($this) = @_;

  $this->{reqsock}->send("GetNextTID\n", 10);
  my $dat = $this->{reqsock}->receive_data();

  my @lines = split /\n/, $dat;
  my @tids =  split /,/, $lines[0];


  return $tids[0];
}



sub __shiftPreviousTID
{
  my ($this, $tid) = @_;

  $this->{reqsock}->send("ShiftPreviousTID|$tid\n", 10);
  my $dat = $this->{reqsock}->receive_data();
}



sub collector_loop
{
  my ($this, $keep_processing, $tid) = @_;
  
  $this->{tid_id} = $tid;
  
  if (!$keep_processing) { $keep_processing = 0; }  
  my $pass = 0;
  
  $this->__open_logfiles;

  $this->__drop_message("We should keep_processing: $keep_processing\n");
  
  $this->__start_timer;
  
  # run all the time
  do {
    $this->__drop_message("In the main loop.\n") if ($this->{debug} >= 4);
    
	  if (!defined $this->{tid_id} || $this->{tid_id} eq "")  {
  	  $this->{tid_id} = $this->__getNextTID;

    	if (!defined $this->{tid_id}) {
      	sleep($this->{config}->getAttribute("NextTID_WaitTime"));
	    }
  	}

	  if (defined $this->{tid_id} && $this->{tid_id} ne "") {
	    my $t;
  	  #my $do_logout = 0;
	    my $connection;
			my $collector;
			
			$this->__get_interface_info();
			
	    # go through the records of result
  	  foreach my $protocol (keys %{$this->{protocol_list}}) {
	      $this->__drop_message("In the protocol loop for $protocol.\n") if($this->{debug} >= 4);
      
  	    next unless $this->__load_protocol($protocol);
    	  $collector = $this->{loaded_protocols}->{$protocol};
    
      	$this->__drop_message("Going to setConnection.\n") if($this->{debug} >= 4);
      
	      $connection = $collector->setConnection($connection, $this->{ipaddress}, $this->{port});
  	 	  
  	 	  if($connection < 0) {
  	 	  	$this->{sock}->send("UpdateError|e|COM|" . $this->{tid_id} . "\n");
  	 	  	undef $connection;
  	 	  	next;
  	 	  }
      
        my $xtid = "";
        
      	foreach my $interface (sort { $this->{interfaces}{$a}{tid} <=> $this->{interfaces}{$b}{tid} } @{$this->{protocol_list}->{$protocol}}) {
        	$this->__drop_message("In the interface loop for $interface.\n") if ($this->{debug} >= 4);
        
	        my $thisif = $this->{interfaces}->{$interface};
        
  	      if($this->{debug} >= 4) {
    	      $this->__drop_message("Contents of thisif:\n");
      	    foreach my $q (keys %{$thisif}) {
        	    $this->__drop_message("$q -- " . $thisif->{$q} . "\n");
	          }
          	$this->__drop_message("Looking at interface type " . $thisif->{interface_type} . " for interface " . $thisif->{"interface"} . "\n");
  	      }
        
    	    my $thisiftype = $this->{interface_types}->{$thisif->{interface_type}};
        
      	  if($this->{debug} >= 4) {
        	  $this->__drop_message("Contents of thisiftype:\n");
          	foreach my $q (keys %{$thisiftype}) {
            	$this->__drop_message("$q -- " . $thisiftype->{$q} . "\n");
	          }
  	      }

          if($xtid ne "" && $thisif->{"tid"} ne $xtid) {
            $collector->__logout;
          }
          $xtid = $thisif->{"tid"};
          
    	    $collector->request($thisif, $thisiftype, $pass);
      	  $collector->submit_updates($thisif->{"interface_id"});

		      sleep 2;
	      }
      
      	last if $this->{debug} >= 6;
	    }
	    #$collector->__logout() if($do_logout);  
	    $collector->__logout() if defined $collector;  
	    delete $collector->{connection};
   	  $connection->finishOperation if defined $connection;
   	  undef $connection;
	  }

  	sleep 5;

	  $this->__shiftPreviousTID($this->{tid_id}) if(defined $this->{tid_id});
  	delete $this->{tid_id};
  
    $pass++;
  } while($keep_processing);

  $this->__stop_timer if ($keep_processing == 0);
  $this->__close_logfiles();

  $this->__drop_message("Exiting\n", 1, 1) if ($this->{debug} >= 1);
}


