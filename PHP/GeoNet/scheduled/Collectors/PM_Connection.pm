package Collectors::PM_Connection;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use Net::Telnet ();
use Devel::Leak;


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
  my ($class, $ipaddress, $loghandle, $errhandle, $debug) = @_;

  print "In PM_Connection::new\n" if ($debug >= 5);
  
  my $this = {
    "class" => $class,
    "debug" => $debug,
    "ipaddress" => $ipaddress,
    "loghandle" => $loghandle,
    "errhandle" => $errhandle,
    "connection" => {},
  };

  bless($this, $class);

  print "Returning from PM_Connection::new\n" if ($debug >= 5);
  
  # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}




# DESTROY is called automatically when the object is deleted
sub DESTROY
{
  my ($this) = @_;

  $this->{connection}->close if(defined $this->{connection});
  return;  
}




sub __drop_message
{
  my ($this, $msg, $err, $out) = @_;
  
  print $msg if ($this->{debug} >= 4);
  print { $this->{errhandle} } $msg if $err;
  print { $this->{loghandle} } $msg if $out;
}




sub getPortAndPrompt
{
  my ($this) = @_;
  
  return ($this->{port}, $this->{prompt});
}





sub connect
{
  my ($this, $port, $prompt, $timeout, $ors) = @_;
  
  $this->__drop_message("Pre Object Instantiation:\n", $this->{debug} >= 5, 0);

  my $host = $this->{ipaddress};
  $this->{port} = $port;
  $this->{prompt} = $prompt;
  $this->{timeout} = $timeout;
  $this->{ors} = $ors;
  
  my %telnet_params = (
      Timeout => $timeout,
      Prompt => $prompt,
      Port => $port,
      TelnetMode => 1,
      #Output_record_separator => $ors,
  );
  
  if($this->{debug} >= 3) {
    $telnet_params{"Dump_Log"} = "/tmp/tlog.txt";
    $telnet_params{"Input_Log"} = "/tmp/tin_log.txt";
    $telnet_params{"Output_Log"} = "/tmp/tout_log.txt";
  }
  
  if($this->{debug} >= 4) {
    $this->__drop_message("Connecting to $host using the following paramters:\n", 1, 0);
    foreach my $z (keys %telnet_params) {
      $this->__drop_message("$z -- $telnet_params{$z}\n", 1, 0);
    }
  }
  
  # connect to the element using telnet
  $this->{connection} = new Net::Telnet(%telnet_params);

  $this->__drop_message("Post Object Instantiation:\n", $this->{debug} >= 5, 0);

  unless (defined($this->{connection})) {
    $this->__drop_message("Can't connect to port $port on host: $host\n", 1, 1);
    return -1;
  }

	$this->{connection}->errmode(\&doError);
	
  # open the connection
  unless ($this->{connection}->open($host)) {
    $this->__drop_message($this->{connection}->errmsg() ."\n", 1, 1);
    return -1;
  }

  $this->__drop_message("Post Connection Open:\n", $this->{debug} >= 5, 0);
  
  return 1;
}



# if an error occur during the main while loop
# this function is called. It displays an error message,
# and update the flag to 'e' for this element if we have the key to it
# @param $dbh the database handler
# @param $tidid the key for the element in the database
# @param $error_msg the error message to display
sub doError{}



sub __leak_check
{
  my ($this) = @_;
  
  my $count = Devel::Leak::NoteSV($this->{connection}) if $this->{leakcheck};
  
  my $now = Devel::Leak::CheckSV($this->{connection}) if $this->{leakcheck};
  $this->__drop_message("Before: $count -- Now: $now\n", 1, 0) if $this->{leakcheck};
}





sub finishOperation
{
  my ($this) = @_;
  
  $this->setErrMode('die');
  $this->{connection}->buffer_empty;
  $this->{connection}->close;
	delete $this->{connection};
	
  $this->__drop_message("Post Telnet Close.\n", $this->{debug} >= 5, 0);

}




sub setErrMode
{
  my ($this, $func) = @_;
  $this->{connection}->errmode($func);
}




sub print
{
  my ($this, $cmd, $waitfor_string, $sleeptime, $postsleep) = @_;

  $this->__drop_message("In PM_Connection::print - cmd: $cmd, waitfor_string: $waitfor_string, sleeptime: $sleeptime\n", $this->{debug} >= 4, 0);
    
  $this->__drop_message("Command: $cmd\n", 1) if ($this->{debug} >= 1);

  $this->{connection}->print($cmd);

  my ($before, $at);
  
  if(defined $waitfor_string) {
    $this->__drop_message("Error Mode: " . $this->{connection}->errmode . "\n", $this->{debug} >= 5, 0);
    sleep($sleeptime) if($sleeptime > 0);
    ($before, $at) = $this->{connection}->waitfor(Timeout => $this->{timeout}, String => $waitfor_string, Errmode => $this->{connection}->errmode);
    sleep($postsleep) if($postsleep > 0);
    
    $this->__drop_message("Before: $before\nAt: $at\n----------------\n\n", 1) if($this->{debug} >= 4);
  } else {
    sleep($sleeptime) if($sleeptime > 0);
    $before = $this->{connection}->get();
  }
  
  $at = $this->{connection}->get();
  $this->__drop_message("At: $at\n\n", 1) if($this->{debug} >= 4);
  
  return ($before, $at);
}  





sub get
{
  my ($this) = @_;

  return $this->{connection}->get();
}  

1;