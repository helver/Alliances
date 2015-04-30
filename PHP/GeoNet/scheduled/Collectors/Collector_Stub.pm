package Collectors::Collector_Stub;
#
# Project: GeoNet Monitor
#
# Class: Collectors::Collector_Stub
# Author: Eric Helvey
# Creation Date: 11/4/2003
#
# Description: Stub Collector.
#
# Revision: $Revision: 1.2 $
# Last Change Date: $Date: 2005-06-02 16:05:05 $
# Last Editor: $Author: eric $
#

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
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


#
#
# Function: new
#
# new is the module constructor.  It doesn't do much besides create
# the object.  
#
# $class is a reference to the object class
# $query is a reference to the CGI object we're using.
# @vars is a list of other variables passed to the constructor.
sub new {
  my ($class, $sock, $loghandle, $errhandle, $config, $debug) = @_;

  # Calling the superclass constructor.
  my $this = $class->SUPER::new($sock, $loghandle, $errhandle, $config, $debug);

	$this->__drop_message("In ${class}::new\n", $debug >= 5, 0);
	
  $this->{username} = "USER";   # Username to log into the element
  $this->{password} = "PASS";   # Password to log into the element
  $this->{port} = 1;           # TL1 port on the element
  $this->{prompt} = '/[;| ]/';    # Prompt regular expression
  $this->{timeout} = 5;           # Time to wait before a timeout
  $this->{sleeptime} = 2;         # Time to sleep between commands
  
  # Translating pm_info columns to element type specific parameters.
  $this->{PARAMETERS} = {
      "TRANSMIT_CV"  => "c1",
      "TRANSMIT_ES"  => "c2",
      "TRANSMIT_SES" => "c3",
      "TRANSMIT_UAS" => "c4",
      "RECEIVE_CV"   => "c5",
      "RECEIVE_ES"   => "c6",
      "RECEIVE_SES"  => "c7",
      "RECEIVE_UAS"  => "c8",
  };

  # Translating protocol columns to element type specific parameters
  $this->{LOCATORS} = {
      "channel"          => "interface",
      "shelf"            => "e1",
      "slot_transmitter" => "e2",
      "slot_receiver"    => "e3",
      "receive_channel"  => "e4",
      "oadm"             => "e5",
  };

  $this->__drop_message("Returning from ${class}::new\n", $debug >= 5, 0);
  
  return $this;
}



sub validate_request
{
  my ($this) = @_;
  
  return unless $this->SUPER::validate_request;

  if (   $this->{req}->{receive_channel} != 1 
      && $this->{req}->{receive_channel} != 2
      && $this->{req}->{receive_channel} != 3) {
    my $msg = "Receive Channel incorrect for " . $this->{req}->{tid} . "," . $this->{req}->{interface} . ": " . $this->{req}->{receive_channel} . ", (neither TOP nor BOTTOM). Returning an error.";
    
    $this->__drop_message($msg, 1, 1);
    $this->{updates}->{"flag"} = "e";
    return;
  }

  return 1;
}
  

#
#
# Function: __login
#
# This function handles logging into the element.
#
#
sub __login
{
  my ($this) = @_;
  my $cmd;
  
  # Send a little wakeup command.
  $this->{connection}->print('', undef, $this->{sleeptime});

  # Send the login command
  $cmd = 'ACT-USER::"' . $this->{username} . '":123::"' . $this->{password} . '";';
  $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  
  $this->{"loggedin"} = 1;
}


#
#
# Function: __logout
#
# This function handles logging out of the element.
#
#
sub __logout
{
  my ($this) = @_;
  my $cmd;
  
  # log off and close the telnet session
  $cmd = 'CANC-USER:::126;';
  $this->{connection}->print($cmd);
  
  $this->{connection}->errmode('die');
  $this->{connection}->buffer_empty;
  $this->{connection}->close;

  # Undef the connection
  delete $this->{connection};
  
  $this->{"loggedin"} = 0;
} 


#
#
# Function: __pull_data
#
# This function handles the process of issuing command and retrieving the
# results of those commands with the intent of pulling PM info from the
# element.
#
#
sub __pull_data
{
  my ($this) = @_;
   
  my $cmd;  # Variables used to process switch commands.
  
  if($this->{debug} >= 4) {
    $this->__drop_message("channel: " . $this->{req}->{channel} . "\n", 1, 0);
    $this->__drop_message("receive_channel: " . $this->{req}->{receive_channel} . "\n", 1, 0);
  }

	my $speed = $this->{req}->{speed};
	
  # Send the RTRV-PM-OCH command.
  $cmd = $this->$speed();
  my ($before, $lines) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});

  return $lines;
}


sub OC48
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub OC3
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub OC12
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub OC192
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub DS3
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub T3
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub STS1
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub STS3C
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub STS12C
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub STS48C
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub STS192C
{
	my ($this) = @_;
	
	return 'COMMAND';
}


sub T1
{
	my ($this) = @_;
	
	return 'COMMAND';
}


#
#
# Function: __parse_lines
#
# This function handles the parsing the command results and pulling the 
# information we're interested out of the result set.  This function also
# fills in the update structure used to send updates into the database.
#
#
sub __parse_lines
{
  my ($this, $lines) = @_;
  
  my $weGotSomething = 0;
  
  # go through each line of the result
  foreach my $line (split /\s*\n\s*/, $lines) {
  
    $this->__drop_message("Examining: $line\n", $this->{debug} >= 4, 0);
    
    # parse only the line that may contain data
    next unless ($line =~/15-MIN/);
    
    $this->__drop_message("Found 15 Minute line: $line\n", $this->{debug} >= 4, 0);

    # example of output:
    #    "TXCVR-3-18,OC48:UASS,0,PRTL,,TRMT,15-MIN,04-05,14-30"
    #    "TXCVR-3-18,OC48:CVS,0,PRTL,,RCV,15-MIN,04-05,14-30"

    # in this regular expression, the 1st element is one of the PM:
    # CV, ES, SES, or UAS followed by a S
    # 2nd element: the value of the PM
    # 3rd element: T or R tells us if it is transmit or receive data
    next unless ($line =~ /:([A-Z]{2,3})S,(\d+),[^,]*,[^,]*,([T|R])/);
    next unless ($3 eq "T" || $3 eq "R");

    # it is counter intuitive, the transmit command retrieve recv
    # stat, but the customer requested that we show it as transmit
    # stats and vice-versa

    # we get rid of the transmit [respectively receive] stats
    # if the element is not on a transmit [respectively receive] path
    next if ($3 eq "R" && $this->{req}->{trans_seq} < 0);
    next if ($3 eq "T" && $this->{req}->{recv_seq} < 0);

    # we have some valid data
    $weGotSomething = 1;

    # set the value of the variables
    my $st = ($3 eq "R" ? "transmit" : "receive");
    my $pm = $1;

    # update the PM in the database
    $this->{updates}->{$this->{PARAMETERS}->{uc("${st}_${pm}")}} = $2;

    $this->__drop_message("pm: $1, value: $2, mode: $3\n", $this->{debug} >= 4, 0);
  }

  # if we did not receive any valid data, return an error flag
  $this->{updates}->{"flag"} = "e" if ($weGotSomething == 0);

  return $weGotSomething;
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

  $this->__drop_message($this->{class} . "::request called\n", $this->{debug} >= 4, 0);

  $this->{req} = $thisif;
  $this->{type} = $thisiftype;
  
  $this->__populate_local_names;
  
  if($this->{debug} >= 4) {
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
	
  return unless ($this->validate_request);

  # Pull the data from the element.    
  my $lines = $this->__pull_data;

  # Bail if we didn't get anything back.
  return unless $lines;

  # Parse the result to retrieve the PMs
  return unless $this->__parse_lines($lines);
  
  return 1;
}


