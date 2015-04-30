package Collectors::Collector_AutomatedTelnet;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use Net::Telnet ();
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

  # Calling the superclass constructor.
  my $this = $class->SUPER::new($sock, $loghandle, $errhandle, $config, $debug);

  $this->__drop_message("In ${class}::new\n", $debug >= 5, 0);
  
  $this->{username} = "CONFIG";   # Username to log into the element
  $this->{password} = "NTAC!88";   # Password to log into the element
  $this->{port} = 23;           # TL1 port on the element
  $this->{prompt} = '/[:.]/';    # Prompt regular expression
  $this->{timeout} = 5;           # Time to wait before a timeout
  $this->{sleeptime} = 2;         # Time to sleep between commands
  
  $this->{directions} = {
      "transmit" => "Tx",
      "receive"  => "Rx",
  };

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
      "channel"          => "e5",
      "shelf"            => "e1",
      "slot_transmitter" => "e2",
      "slot_receiver"    => "e3",
      "receive_channel"  => "e4",
      "name"             => "interface",
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
  
  my $settle_time = 2;
  my $t = $this->{connection}->{connection};
  
  # Set special prompt
  my $pp = $t->prompt('/[:.]/');

  $this->__drop_message("Try to login: " . $this->{username} . ", " . $this->{password} . "\n", $this->{debug} >= 5, 0);
  my $ok = $t->login(Name => $this->{username}, Passwd => $this->{password});

  if (!$ok) {
    $this->{updates}->{"flag"} = "e";
    return;
  }


  # Don't send anything I don't ask for!
  $ok = $t->output_record_separator('');

  # Hit any key to continue
  $ok = $t->print("\n");

  # Select NE
  $ok = $t->print("\n");
  
  # PM History Setup
  $ok = $t->print('J');

  sleep $settle_time;

  # clear buffer
  $t->get();

  # PM History Display
  $ok = $t->print('J');
  $t->waitfor(-string=>'[23;03HUP/DOWN-Cursor RETURN-Select ESC-Quit'); #'

  sleep $settle_time;
  my $lines = $t->get();

	$this->{data} = $lines;
	
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

	my $t = $this->{connection}->{connection};
	
  #return to PM History Setup
  $t->cmd('Q');

  #return to NE
  $t->cmd('Q');

  #return to Main Menu
  $t->cmd('Q');
  $t->cmd('Y');
  
  #log out
  $t->cmd('Q');
  $t->cmd('Y');

  $this->{"loggedin"} = 0;
  delete $this->{data} if defined $this->{data};
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
   
  return $this->{data};
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
  
  delete $this->{updates} if defined $this->{updates};
  $this->{updates} = {};

	for(my $i = 1; $i <= 10; $i++) {
		$this->{updates}->{"c" . $i} = 0;
		$this->{updates}->{"a" . $i} = 0;
	}
	
  return unless ($this->validate_request);

	$this->__login() unless ($this->{"loggedin"} == 1);
	
  # Pull the data from the element.    
  my $lines = $this->__pull_data;

  # Bail if we didn't get anything back.
  return unless $lines;

  # Parse the result to retrieve the PMs
  return unless $this->__parse_lines($lines);
  
  return 1;
}



sub __parse_lines
{
  my ($this, $lines) = @_;
  
  $this->__drop_message("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n$lines", $this->{debug} >= 4, 0);

  $this->__drop_message("???". $lines . "???\n", $this->{debug} >= 5, 0);

  my @lines = split /\n/, $lines;
  
  if ($lines[0] !~ /Current 24 hour/) {
    $this->{updates}->{"flag"} = "e";
    return;
  }

  foreach my $line (split(/\[[0-9]*;[0-9]*H/, $lines)) {
    $this->__drop_message("Line: $line\n", $this->{debug} >= 4, 0);
    
    foreach my $state (("transmit", "receive")) {
      $this->__drop_message("Checking state: $state\n", $this->{debug} >= 4, 0);
      
      $this->__drop_message("state: $state  -- trans_facility_path: " . $this->{req}->{trans_seq} . "\n", $this->{debug} >= 4, 0);
      next if ($state eq "transmit" && $this->{req}->{trans_seq} <= 0);

      $this->__drop_message("state: $state  -- recv_facility_path: " . $this->{req}->{recv_seq} . "\n", $this->{debug} >= 4, 0);
      next if ($state eq "receive" && $this->{req}->{recv_seq} <= 0);

      $this->__drop_message("Passed state and path check.\n", $this->{debug} >= 4, 0);
      
      my $pattern = $this->{directions}->{$state} . " " . ($this->{req}->{channel} < 10 ? "0" : "") . $this->{req}->{channel} . " ";
      
      $this->__drop_message("Checking line against pattern: $pattern\n", $this->{debug} >= 4, 0);
      next unless $line =~ /$pattern/;
      $this->__drop_message("Passed pattern check.\n", $this->{debug} >= 4, 0);
      
      $this->__drop_message($line, $this->{debug} >= 4, 0);
      
      if ($line =~ /$pattern[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+/) {
        my %line;
        my @pms = ("cv", "es", "ses", "uas");
        @line{@pms} = ($1, $2, $3, $4);
        
        $this->__drop_message("\ncv: $1, es: $2, ses: $3, uas: $4\n", $this->{debug} >= 4, 0);

				my $origdebug = $this->{debug};
				
        foreach my $i (@pms) {
          my $key = $this->{PARAMETERS}->{uc($state . "_" . $i)};
          my $acc = $key;
          $acc =~ s/c/a/;
        
          $this->{updates}->{$acc} = $line{$i};
          $this->__drop_message($key . " = ". $line{$i} . "\n", $this->{debug} >= 4, 0);

          $this->__drop_message("previous value: $key = ". $this->{req}->{pm_totals}->{$acc} . " \n", $this->{debug} >= 4, 0);
          $this->{updates}->{$key} = $this->{updates}->{$acc} - $this->{req}->{pm_totals}->{$acc};

					if($this->{updates}->{$key} > 3000) {
					  open(FH, ">> bigerr.txt") || print "Can't open bigerr.txt: $!\n";
					  print FH "\n\n" . localtime() . " -- " . $this->{req}->{tid} . "\n";
						print FH "Abnormally high PM value detected: $key - " . $this->{updates}->{$key} . " " . $this->{updates}->{$acc} . " - " . $this->{req}->{pm_totals}->{$acc} . "\n";
						print FH "$line\n";
						print FH "$lines\n";
						close FH;
					}
					
          $this->__drop_message($state . "_" . $i . " = " . $this->{updates}->{$state . "_". $i} . "\n", $this->{debug} >= 4, 0);
        }
      }
    }
  }

  return 1;
}




1;