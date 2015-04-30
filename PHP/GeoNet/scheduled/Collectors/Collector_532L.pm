package Collectors::Collector_532L;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use Net::Telnet ();
use IO::Socket;
use Time::Local;
use Devel::Leak;
use Collectors::Collector_Base;


# Modules should almost always "use strict".  This forces
# you to use variable declarations and ensure that variables
# are not globally scoped.
use strict;

# This stuff is needed for modules.
use vars qw(@ISA @EXPORT $VERSION);
@ISA = ('Collectors::Collector_Base');
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
  my ($class, $sock, $loghandle, $errhandle, $config, $debug) = @_;

  my $this = $class->SUPER::new($sock, $loghandle, $errhandle, $config, $debug);

  $this->__drop_message("In ${class}::new\n", $debug >= 0, 0);

  $this->{leakcheck} = 0;
  $this->{username} = "CONFIG";   # Username to log into the element
  $this->{password} = "GR8DAY";   # Password to log into the element
  $this->{port} = 23;             # TL1 port on the element
  $this->{prompt} = '/[;| ]/';    # Prompt regular expression
  $this->{timeout} = 5;           # Time to wait before a timeout
  $this->{sleeptime} = 2;         # Time to sleep between commands
  
  # Translating pm_info columns to element type specific parameters.
  $this->{PARAMETERS} = {
      "TRANSMIT_CV"  => "c1",
      "TRANSMIT_ES"  => "c2",
      "RECEIVE_CV"   => "c3",
      "RECEIVE_ES"   => "c4",
      "RECEIVE_SES"  => "c5",
      "RECEIVE_UAS"  => "c6",
  };

  # Translating protocol columns to element type specific parameters
  $this->{LOCATORS} = {
      "aid"              => "interface",
  };

  $this->__drop_message("Returning from ${class}::new\n", $debug >= 5, 0);

   # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}



sub T1
{
  my ($this) = @_;

  my $cmd = "UTL::QRY,PMON,15MIN,NPC " . $this->{req}->{$this->{LOCATORS}->{aid}} . "!";

  return $cmd;
}


# can't use the __pull_data method from Collector_Base as
# we're not expecting 'GEO COMPLD' but only 'COMPLD'
sub __pull_data
{
  my ($this, $t) = @_;

	my $speed = $this->{type}->{speed};
	
  # Send the RTRV-PM-T1 command.
  my $cmd = $this->$speed();

  $this->__drop_message("Command: $cmd\n", $this->{debug} >= 5, 0);
  my ($before, $lines) = $this->{connection}->print($cmd, 'COMPLD', 2);

	$this->__drop_message("Lines: $lines\n", $this->{debug} >= 5, 0);
	
  $this->__drop_message("Post Data Collection\n", $this->{debug} >= 2, 0);
  sleep(1);

  return $lines;
}



sub __parse_lines
{
  my ($this, $lines) = @_;

  my $weGotSomething = 0;
  my $pm_line = 0;
  
  # go through each line of the result
  foreach my $line (split /\s*\n\s*/, $lines) {

    $this->__drop_message("Examining: $line\n", $this->{debug} >= 5, 0);

    if ($pm_line == 1)
    {
      $this->__drop_message(" -P values:\n", $this->{debug} >= 5, 0);
      
      $pm_line = 0;
      $weGotSomething = 1;
      
      my @temp = split /-V\s*/, $line;
      $this->{updates}->{$this->{PARAMETERS}->{"RECEIVE_CV"}} = $temp[1] + 0;
      $this->{updates}->{$this->{PARAMETERS}->{"RECEIVE_ES"}} = $temp[2] + 0;
      $this->{updates}->{$this->{PARAMETERS}->{"RECEIVE_SES"}} = $temp[5] + 0;
      $this->{updates}->{$this->{PARAMETERS}->{"RECEIVE_UAS"}} = $temp[6] + 0;
      
      if ($this->{debug} >= 5)
      {
        for (my $i=0; $temp[$i]; $i++)
        {
          $this->__drop_message("$i: ". $temp[$i] . "\n", 1, 0);
        }
      }
    }
    elsif ($pm_line == 2)
    {
      $this->__drop_message(" -L values:\n", $this->{debug} >= 5, 0);
      
      $pm_line = 0;
      $weGotSomething = 1;
      
      my @temp = split /-V\s*/, $line;
      $this->{updates}->{$this->{PARAMETERS}->{"TRANSMIT_CV"}} = $temp[0] + 0;
      $this->{updates}->{$this->{PARAMETERS}->{"TRANSMIT_ES"}} = $temp[1] + 0;
      
      if ($this->{debug} >= 5)
      {
        for (my $i=0; $temp[$i]; $i++)
        {
          $this->__drop_message("$i: ". $temp[$i] . "\n", 1, 0);
        }
      }
    }


    # parse only the line that may contain data
    if ($line =~/CV-P\s/)
    {
      $pm_line = 1;
      next;
    }
    elsif ($line =~/CV-L\s/)
    {
      $pm_line = 2;
      next;
    }
    
  }

  # if we did not receive any valid data, return an error flag
  $this->{updates}->{"flag"} = "e" if ($weGotSomething == 0);

  return $weGotSomething;
}


sub __login
{
  my ($this) = @_;

  $this->__drop_message($this->{class} . "::login called\n", $this->{debug} > 3, 0);

  my ($before, $at) = $this->{connection}->print("", 'PF', 1);
	sleep(2);
	
  # Send the login command
  my $cmd = 'UTL::LOGIN, USER ' . $this->{username} . '!';
  ($before, $at) = $this->{connection}->print($cmd, 'PASSWORD', 0);

	$this->__drop_message("At: $at\n", $this->{debug} >= 5, 0);
	
  $cmd = $this->{password} . "\n";
  ($before, $at) = $this->{connection}->print($cmd, 'UTL LOGIN USER ' . $this->{username} . ' COMPL', 0);

	$this->__drop_message("At: $at\n", $this->{debug} >= 5, 0);
	
  $this->{"loggedin"} = 1;
}


sub __logout
{
  my ($this) = @_;
  
  $this->__drop_message($this->{class} . "::logout called\n", $this->{debug} > 3, 0);

  # log off and close the telnet session
  $this->{connection}->print("UTL::LOGOUT\n");
  $this->__drop_message("Post Sending Logout.\n", $this->{debug} >= 5, 0);

  $this->{"loggedin"} = 0;
}


#
#
# Function: request
#
# This function handles the processing of PMs for a single channel on
# the element.
#
#
sub request
{
  my ($this, $thisif, $thisiftype, $pass) = @_;

  $this->__drop_message($this->{class} . "::request called\n", $this->{debug} > 3, 0);

  $this->{req} = $thisif;
  $this->{type} = $thisiftype;
  
  if($this->{debug} >= 5) {
    $this->__drop_message("Type:\n", 1, 0);
    foreach my $q (keys %{$this->{type}}) {
      $this->__drop_message("$q -- " . $this->{type}->{$q} . "\n", 1, 0);
    }
  
  
    $this->__drop_message("Req:\n", 1, 0);
    foreach my $q (keys %{$this->{req}}) {
      $this->__drop_message("$q -- " . $this->{req}->{$q} . "\n", 1, 0);
    }
  }
  
  $this->{updates} = {};

	$this->__login() unless ($this->{"loggedin"} == 1);
	
  # Pull the data from the element.    
  my $lines = $this->__pull_data;

  # Bail if we didn't get anything back.
  return unless $lines;

  # Parse the result to retrieve the PMs
  return unless $this->__parse_lines($lines);
  
  return 1;
}


1;