#!/usr/bin/perl
use DBI;
use EmailWrapper;
use LWP::UserAgent;

my $killed_submittor = 0;
my $lockfile = "logs/Watchdog.lock";
&__check_lockfile($lockfile, @ARGV);

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

my $i = 0;
while($config->getAttribute("DatabaseDriver") eq "") {
	sleep 2;
	$config = ConfigFileReader->new("GeoNet");
	last if(++$i > 10);
}

# used for debugging
our $debug = $ARGV[0] || $config->getAttribute("DebugLevel") || 0;

$|=1 if($debug >= 1); #Set 1 to flush (for tailing the log file)

print "WatchDog running at: " . localtime() . "\n";
&grab_uptime() if($debug >= 1);

my $zmail = new EmailWrapper($config, $debug);
my $dbh = &check_DB($config, $debug, $zmail);

&watch_Apache($dbh, $config, $zmail) if((localtime)[1] % 10 == 0 || $debug >= 4);

my $restart_collectors = 0;

if(defined $dbh && $dbh->{validConnection} == 1) {
  $restart_collectors = &watch_Submittor($dbh, $config, $zmail);
  $restart_collectors = &watch_Requestor($dbh, $config, $zmail) || $restart_collectors;

  &general_housekeeping($config, $zmail) if((localtime)[1] % 5 == 0 || $debug >= 4);

  my $num_of_starting_collectors = $config->getAttribute("StartingNumOfCollectors") || 100;
  &verify_Collectors($dbh, $config, $restart_collectors, $num_of_starting_collectors, $zmail);

  eval "&check_queue(\$dbh, \$config, \$zmail);" if((localtime)[1] % 5 == 0);
  print $@ . "\n" if defined $@;

  &populate_queue($dbh, $config, $zmail) if((localtime)[1] % 5 == 0);
}

#&watch_Trap_Receiver($dbh, $config, $zmail);

&__unlock_lockfile($lockfile);

$dbh->Close() if(defined $dbh && $dbh->{validConnection} == 1);
exit;




sub watch_Submittor
{
  my ($dbh, $config, $zmail) = @_;

  print "Monitoring Submitor\n\n\n" if($debug >= 1);

  my ($taskview, $taskname, $timeout, $logdir, @tlist, @active) =
    (
      $config->getAttribute("Submittor_TaskView"),
      $config->getAttribute("Submittor_TaskName"),
      $config->getAttribute("Submittor_Timeout"),
      $config->getAttribute("LogDir")
    );


  print "taskview - $taskview\n" if($debug >= 5);
  print "taskname - $taskname\n" if($debug >= 5);
  print "timeout - $timeout\n" if($debug >= 5);
  print "logdir - $logdir\n" if($debug >= 5);

  # Watchdogging the Submittor
  my $isrun = `$taskview`;

  $isrun =~ s/\s+//g;

  print "isrun - $isrun\n" if($debug >= 5);

  my ($pid, $ttime);
  
  if($isrun >= 1) {
    if(open(FH, "< $logdir/Submittor.pid")) {
      ($pid, $ttime) = <FH>;
      chomp $pid; chomp $ttime;
			close FH;
			
      print "pid: $pid  --  ttime: $ttime\n" if ($debug >= 0);

      if($ttime > 1000 && time() - $ttime >= $timeout) {
        print "Killing Submittor because it hasn't updated its PID in $timeout seconds.\n";
        system("kill $pid") if($debug <= 3);

        $isrun = 0;
      }
    }
  }

  my $restarted = 0;

  unless($isrun) {
    my $message = "Restarting $taskname at " . localtime() . "\n";

    if(!defined $pid && open(FH, "< $logdir/Submittor.pid")) {
      ($pid, $ttime) = <FH>;
      chomp $pid; chomp $ttime;
      close FH;
    }

    if($debug <= 3) {
      open FH, ">> $logdir/Submittor.log" or print "Can't open Submittor Log file: $!\n";
      print FH $message;
      close FH;

      rename("$logdir/Submittor.log","$logdir/Submittor.log.$pid");

      open FH, ">> $logdir/Submittor.log" or print "Can't open Submittor Log file: $!\n";
      print FH $message;
      close FH;

      open FH, ">> $logdir/Submittor.err" or print "Can't open Submittor Error file: $!\n";
      print FH $message;
      close FH;

      rename("$logdir/Submittor.err","$logdir/Submittor.err.$pid");

      open FH, ">> $logdir/Submittor.err" or print "Can't open Submittor Error file: $!\n";
      print FH $message;
      close FH;
    }

    print $message;
    
    print `/usr/bin/perl /work/WADappl/Projects/GeoNet/scheduled/GeoShutdown.pl 1`;

		if(!$killed_submittor) {
			print localtime() . " -- executing restart_submittor()\n";
			#$dbh->DoSQL("BEGIN restart_submittor(); END;;") if($debug <= 3);
			print localtime() . " -- completed restart_submittor()\n";
		}
		
    $dbh->Delete("tid_queue", "active = 1") if($debug <= 3);

    my $cmd = "$taskname > $logdir/Submittor.log 2> $logdir/Submittor.err &";
    print "$cmd\n" if($debug >= 1);
    system($cmd) if($debug <= 3);

		my $hostname = `hostname`;
		chomp $hostname;
		
  	$zmail->sendTemplateEmail("Submittor_Restart", "GeoNet Submittor Process Restarted", $config->getAttribute("NotificationEmails"), {"hostname" => $hostname});

    $restarted = 1;
  }

  return $restarted;
}



sub watch_Requestor
{
  my ($dbh, $config, $zmail) = @_;

  print "Monitoring Requestor\n\n\n" if($debug >= 1);

  my ($taskview, $taskname, $timeout, $logdir, @tlist, @active) =
    (
      $config->getAttribute("Requestor_TaskView"),
      $config->getAttribute("Requestor_TaskName"),
      $config->getAttribute("Requestor_Timeout"),
      $config->getAttribute("LogDir")
    );


  print "taskview - $taskview\n" if($debug >= 5);
  print "taskname - $taskname\n" if($debug >= 5);
  print "timeout - $timeout\n" if($debug >= 5);
  print "logdir - $logdir\n" if($debug >= 5);

  # Watchdogging the Requestor
  my $isrun = `$taskview`;

  $isrun =~ s/\s+//g;

  print "isrun - $isrun\n" if($debug >= 5);

  my ($pid, $ttime);
  
  if($isrun >= 1) {
    if(open(FH, "< $logdir/Requestor.pid")) {
      ($pid, $ttime) = <FH>;
      chomp $pid; chomp $ttime;
			close FH;
			
      print "pid: $pid  --  ttime: $ttime\n" if ($debug >= 0);

      if($ttime > 1000 && time() - $ttime >= $timeout) {
        print "Killing Requestor because it hasn't updated its PID in $timeout seconds.\n";
        system("kill $pid") if($debug <= 3);

        $isrun = 0;
      }
    }
  }

  my $restarted = 0;

  unless($isrun) {
    my $message = "Restarting $taskname at " . localtime() . "\n";

    if(!defined $pid && open(FH, "< $logdir/Requestor.pid")) {
      ($pid, $ttime) = <FH>;
      chomp $pid; chomp $ttime;
      close FH;
    }

    if($debug <= 3) {
      open FH, ">> $logdir/Requestor.log" or print "Can't open Requestor Log file: $!\n";
      print FH $message;
      close FH;

      rename("$logdir/Requestor.log","$logdir/Requestor.log.$pid");

      open FH, ">> $logdir/Requestor.log" or print "Can't open Requestor Log file: $!\n";
      print FH $message;
      close FH;

      open FH, ">> $logdir/Requestor.err" or print "Can't open Requestor Error file: $!\n";
      print FH $message;
      close FH;

      rename("$logdir/Requestor.err","$logdir/Requestor.err.$pid");

      open FH, ">> $logdir/Requestor.err" or print "Can't open Requestor Error file: $!\n";
      print FH $message;
      close FH;
    }

    print $message;
    
    print `/usr/bin/perl /work/WADappl/Projects/GeoNet/scheduled/GeoShutdown.pl 1`;

    $dbh->Delete("tid_queue", "active = 1") if($debug <= 3);

    my $cmd = "$taskname > $logdir/Requestor.log 2> $logdir/Requestor.err &";
    print "$cmd\n" if($debug >= 1);
    system($cmd) if($debug <= 3);

		my $hostname = `hostname`;
		chomp $hostname;
		
  	$zmail->sendTemplateEmail("Requestor_Restart", "GeoNet Requestor Process Restarted", $config->getAttribute("NotificationEmails"), {"hostname" => $hostname});

    $restarted = 1;
  }

  return $restarted;
}



sub general_housekeeping
{
  my ($config, $zmail) = @_;

  print "HouseKeeping\n\n\n" if($debug >= 1);

  my ($taskview, $taskname, $logdir, @tlist, @active) =
    (
      $config->getAttribute("HK_TaskView"),
      $config->getAttribute("HK_TaskName"),
      $config->getAttribute("LogDir"),
    );

  print "taskview - $taskview\n" if($debug >= 5);
  print "taskname - $taskname\n" if($debug >= 5);
  print "logdir - $logdir\n" if($debug >= 5);

  my $isrun = `$taskview`;

  $isrun =~ s/^\s+//;
  ($isrun) = split /\s+/, $isrun;
  $isrun =~ s/\s//g;

  print "isrun - $isrun\n" if($debug >= 5);

  if($isrun) {
    print "Killing house_keeping.pl because it's stuck.\n";
    system("kill $isrun") if($debug <= 3);
  }

  my $message = "Starting $taskname at " . localtime() . "\n";

  print $message;

  my $cmd = "$taskname >> $logdir/HouseKeeping.log 2> $logdir/HouseKeeping.err &";
  print "$cmd\n" if($debug >= 1);
  system($cmd) if($debug <= 3);
}



sub grab_uptime
{
  my $ut_string = `uptime`;
  chomp $ut_string;

  print "$ut_string\n";
}

sub populate_queue
{
  my ($dbh, $config, $zmail) = @_;

	print "Populating queue.\n";
	
  $dbh->Delete("tid_queue", "active = 1 and timeentered < SYSDATE - .03");
  #$dbh->Select("call_populate_tid_queue()", "dual");
  #$dbh->debug(5);
  $dbh->DoSQL("BEGIN populate_TID_queue(); END;;");
}


sub check_queue
{
  my ($dbh, $config, $zmail) = @_;

	print "Checking queue.\n";
	
  my $res = $dbh->Select("count(1)", "tid_queue", "timeentered < SYSDATE - 0.00347 and (active = 0 or active is null)");
  my $num_left = $res->[0]->{0};

  print ("Current number of entries in tid_queue: $num_left\n");

  if($num_left > 0) {
    my $cmd = $config->getAttribute("Collector_TaskName") . " &";
    print "$cmd\n" if($debug >= 1);
    system($cmd) if($debug <= 3);
  }
}


sub verify_Collectors
{
  my ($dbh, $config, $restart, $count, $zmail) = @_;
  my $currentcount;

  my ($taskview, $taskname, $timeout, $logdir) =
    (
      $config->getAttribute("Collector_TaskView"),
      $config->getAttribute("Collector_TaskName"),
      $config->getAttribute("Collector_Timeout"),
      $config->getAttribute("LogDir")
    );

  if($restart == 1) {
    $currentcount = 0;

    my @actives=`/work/WADappl/Projects/GeoNet/scheduled/Geo`;

    foreach $active (@actives) {
      if ($active =~/^\s*([0-9]+)\s+.*(DWDM_DataCollector)/) {
        #my $pid=substr($active,0,5);
        my $pid = $1;
        print ("$active: kill $pid\n");
        kill KILL, $pid;
      }
    }

  } else {
    print "Verifying Collector Count.  Should be at least $count.\n\n\n" if($debug >= 1);

    print "taskview - $taskview\n" if($debug >= 5);
    print "taskname - $taskname\n" if($debug >= 5);
    print "timeout - $timeout\n" if($debug >= 5);
    print "logdir - $logdir\n" if($debug >= 5);

    $currcount = `$taskview | wc -l`;
  }

  print ("Current collector count: $currcount\n") if ($currcount < $count);

	if(defined $dbh && $dbh->{validConnection} == 1) {
	  # check if the task has failed
  	while ($currcount < $count) {
    	#my $cmd = "$taskname $fac > $logdir/facility${fac}.log 2> $logdir/facility${fac}.err &";
	    my $cmd = "$taskname &";
  	  print "$cmd\n" if($debug >= 1);
    	system($cmd) if($debug <= 3);

	    $currcount++;
  	}
	}
	
  $currcount = `$taskview | wc -l`;
	chomp $currcount;
	
  print ("Collector count: $currcount\n");
}




sub watch_Trap_Receiver
{
  my ($dbh, $config, $zmail) = @_;

  print "Monitoring Trap Receiver\n\n\n" if($debug >= 1);

  my ($taskview, $taskname, $logdir, @tlist, @active) =
    (
      $config->getAttribute("TrapReceiver_TaskView"),
      $config->getAttribute("TrapReceiverr_TaskName"),
      $config->getAttribute("LogDir")
    );


  print "taskview - $taskview\n" if($debug >= 5);
  print "taskname - $taskname\n" if($debug >= 5);
  print "logdir - $logdir\n" if($debug >= 5);

  # Watchdogging the Submittor
  my $isrun = `$taskview`;

  $isrun =~ s/\s+//g;

  print "isrun - $isrun\n" if($debug >= 5);

  if($isrun >= 1) {
    if(open(FH, "< $logdir/TrapReceiver.pid")) {
      my ($pid, $ttime) = <FH>;
      chomp $pid; chomp $ttime;

      print "pid: $pid  --  ttime: $ttime\n" if ($debug >= 5);

      if(time() - $ttime >= $timeout) {
        print "Killing TrapReceiver\n" if($debug >= 1);
        #system("kill $pid") if($debug <= 3);
        system("pkill $taskname") if($debug <= 3);

        $isrun = 0;
      }
    }
  }

  unless($isrun) {
    my $message = "Restarting $taskname at " . localtime() . "\n";

    if($debug <= 3) {
      unlink("$logdir/TrapReceiver.log.old");
      rename("$logdir/TrapReceiver.log","$logdir/TrapReceiver.log.old");

      open FH, ">> $logdir/TrapReceiver.log" or print "Can't open TrapReceiver Log file: $!\n";
      print FH $message;
      close FH;

      unlink("$logdir/TrapReceiver.err.old");
      rename("$logdir/TrapReceiver.err","$logdir/TrapReceiver.err.old");

      open FH, ">> $logdir/TrapReceiver.err" or print "Can't open TrapReceiver Error file: $!\n";
      print FH $message;
      close FH;
    }

    print $message;

    my $cmd = "$taskname > $logdir/TrapReceiver.log 2> $logdir/TrapReceiver.err &";
    print "$cmd\n" if($debug >= 1);
    system($cmd) if($debug <= 3);
  }
}


sub watch_Apache
{
	my ($dbh, $config, $zmail) = @_;
	
	my @apaches = split(",", $config->getAttribute("URLs")); 
  my $ua = new LWP::UserAgent;
  $ua->agent("GeoWatchdog " . $ua->agent);
	my @failed;
	
	foreach my $apache (@apaches) {
  	# URL used to verify that Apache is running.
    my $PHP_url = "http://${apache}.oss.sprint.com/geonetmonitor/whoami.php";
    
    # If we did not get a response...
    unless (&__get_URL($PHP_url, $ua)) {
    	push @failed, $apache;
    }
  }

	if(scalar(@failed)) {
	 	$zmail->sendTemplateEmail("Apache_Down", "GeoNet Webserver Connectivity Problem", $config->getAttribute("NotificationEmails"), {"servers" => join(".oss.sprint.com/, http://", @failed)});
  }
}
	

sub __get_URL
{
	my ($url, $ua) = @_;
	
  # Make the request.
  my $req = new HTTP::Request GET => $url;
  my $res = $ua->request($req);

  # If we did not get a response...
  return $res->is_success unless ($res->is_success);
  
  return $res->content;
}




sub check_DB
{
	my ($config, $debug, $zmail) = @_;
	
	eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
  print $@ . "\n" if defined $@;

  eval("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"GeoNet\", \$debug+1);");
  print $@ . "\n" if defined $@;

  if($dbh->{validConnection} == 0) {
  	#print "No valid database connection.\n";
  	
	  my $hostname = `hostname`;
	  chomp $hostname;
	  
  	my ($apaches) = split(",", $config->getAttribute("URLs")); 
    my $ua = new LWP::UserAgent;
    $ua->agent("GeoWatchdog " . $ua->agent);
	
	  # URL used to verify that Apache is running.
    my $PHP_url = "http://${apaches}.oss.sprint.com/geonetmonitor/whoami.php";
    
    #print "url: $PHP_url\n";

    my $res = &__get_URL($PHP_url, $ua);
    chomp $res;
    
    #print "res: $res\n";
    
    if($res =~ /$hostname/) {
  	  print "Going to send notification because DB is not connected.\n" if($debug >= 1);
  	  $zmail->sendTemplateEmail("DB_Conn_Notify", "$hostname - GeoNet Database Connectivity Problem", $config->getAttribute("NotificationEmails"), {"hostname" => $hostname, "proxyname" => $apaches});
	  }
	  
	  return undef;
  }
  
  return $dbh;
}


sub __check_lockfile
{
  my ($lockfile, @ARGV) = @_;
  
  if(scalar @ARGV == 0) {
    open FH, "< $lockfile";
    my ($lock, $timestamp, $ppid) = <FH>;
    close FH;

    if(   $lock >= 1 
       && (   $timestamp eq "" 
           || ($timestamp > (time() - (60 * 15))))) {
    	print localtime() . " -- Watchdog locked out.\n";
	    exit;
    } else {
    	if($timestamp <= (time() - (60 * 15))) {
    		#system("kill $ppid") if ($debug <= 3);
    		#print "Killing previous instance of WatchDog because it's stuck.\n";
    		#$killed_submittor = 1;
    	}
    	
	    open FH, "> $lockfile";
  	  print FH "1\n";
  	  print FH time() . "\n";
  	  print FH $$ . "\n";
    	close FH;
    }
  
    sleep 10;
  }
}


sub __unlock_lockfile
{
	my ($lockfile) = @_;
	
	open FH, "> $lockfile";
  print FH "0\n";
  close FH;
}

	


	