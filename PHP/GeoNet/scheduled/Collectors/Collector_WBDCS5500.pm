package Collectors::Collector_WBDCS5500;

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
  my ($class, $sock, $PMs, $states, $allpms, $totalpms, $config, $debug) = @_;

  my $this = $class->SUPER::new($sock, $PMs, $states, $allpms, $totalpms, $config, $debug);

	$this->__drop_message("In ${class}::new\n", $debug >= 5, 0);
	
  $this->{leakcheck} = 0;
  $this->{username} = "CONFIG";
  $this->{password} = "GR8#DAY";
  $this->{port} = 23;           # TL1 port on the element
  $this->{prompt} = '/[;| ]/';    # Prompt regular expression
  $this->{timeout} = 15;           # Time to wait before a timeout
  $this->{sleeptime} = 60;         # Time to sleep between commands
  
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
      "RECEIVE_SEF"  => "c8",
      "RECEIVE_SEFS"  => "c8",
  };

  # Translating protocol columns to element type specific parameters
  $this->{LOCATORS} = {
      "aid"          => "interface",
  };

  $this->{speed_specific}->{"OC12"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "S" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|S),((\d+)|(NA))/,
  	"command" => "RTRV-PM-OC12",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"OC3"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "S" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|S),((\d+)|(NA))/,
  	"command" => "RTRV-PM-OC3",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"STS1"} = {
  	"tr_code" => { "transmit" => "T", "receive" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(P),((\d+)|(NA))/,
  	"command" => "RTRV-PM-STS1",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"T1"} = {
  	"tr_code" => { "transmit" => "T", "receive" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(P),((\d+)|(NA))/,
  	"command" => "RTRV-PM-T1",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"T3"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|P),((\d+)|(NA))/,
  	"command" => "RTRV-PM-T3",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"VT1"} = {
  	"tr_code" => { "transmit" => "V", "receive" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(V),((\d+)|(NA))/,
  	"command" => "RTRV-PM-VT1",
  	"transcol" => 2,
  };
  
  $this->__drop_message("Returning from ${class}::new\n", $debug >= 5, 0);

   # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}


sub validate_request
{
  my ($this) = @_;
  
  if (   (!exists $this->{req}->{tid} || $this->{req}->{tid} eq "") 
      || (!exists $this->{req}->{ipaddress} || $this->{req}->{ipaddress} eq "")
      || (!exists $this->{req}->{aid} || $this->{req}->{aid} eq "")
     ) {
    my $msg = "Not enough data to connect to the element " . $this->{req}->{tid} . ": " .
              "ipaddress = " . $this->{req}->{ipaddress} . ", " .
              "aid = " . $this->{req}->{aid} . ", " .
              "protocol = " . $this->{req}->{protocol} . ", " .
              "element_type_id = " . $this->{req}->{element_type_id} . ".\n";
              
    $this->__drop_message($msg, 1, 1);
    $this->doError("e", "Database", $this->{req}->{tid_id}, $msg);
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
  my ($cmd, $before, $lines);

  sleep(1);
    
  ($before, $lines) = $this->{connection}->print('', "\n", 0);

  # Send the login command
  $cmd = 'ACT-USER::"' . $this->{username} . '":123::"' . $this->{password} . '";';
  $this->{connection}->print($cmd, 'COMPLD', 1);

  $this->__drop_message("Post Login:", $this->{debug} >= 4, 0);


  # Send the login command
  $cmd = 'ED-CHAN:::MOFF::NAEVT=OFF,MJALM=OFF,CRALM=OFF,MNALM=OFF:MLP=OFF;';
  $this->{connection}->print($cmd, 'COMPLD', 1);

  $this->__drop_message("Post Turning off Autonomous Messages:", $this->{debug} >= 4, 0);
  
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
  $cmd = 'CANC-USER::"' . $this->{username} . '":123;';
  $this->{connection}->print($cmd, "", 5);
  
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
  
	my $speed = $this->{speed_specific}->{$this->{type}->{speed}};
	
  # Send the RTRV-PM-OCH command.
  $cmd = $speed->{command} . "::" . $this->{req}->{aid} . ":GEO::ALL,0-up,,,15-MIN,;";

	my $prevtm = $this->{connection}->{timeout};
	$this->{connection}->{timeout} = 20;
  my ($before, $lines) = $this->{connection}->print($cmd, 'GEO COMPLD', 0, 5);
	$this->{connection}->{timeout} = $prevtm;
	
  $this->__drop_message("Collected Lines:\n$lines\n--------\n", $this->{debug} >= 4, 0);

  return $lines;
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
  
  my $specs = $this->{speed_specific}->{$this->{type}->{speed}};
  
  # go through each line of the result
  foreach my $line (split /\s*\n\s*/, $lines) {
  
    $this->__drop_message("Examining: $line\n", $this->{debug} >= 4, 0);
    
    # parse only the line that may contain data
    next unless ($line =~/$specs->{first_regex}/);
    
    $this->__drop_message("Found 15 Minute line: $line\n", $this->{debug} >= 4, 0);

    # example of output:
    #    "TXCVR-3-18,OC48:UASS,0,PRTL,,TRMT,15-MIN,04-05,14-30"
    #    "TXCVR-3-18,OC48:CVS,0,PRTL,,RCV,15-MIN,04-05,14-30"

    # in this regular expression, the 1st element is one of the PM:
    # CV, ES, SES, or UAS followed by a S
    # 2nd element: the value of the PM
    # 3rd element: T or R tells us if it is transmit or receive data
    my ($pm, $mode2, $full, $value, $mode4);
    ($pm, $mode2, $full, $value, $mode4) = ($line =~ /$specs->{second_regex}/);
    
    next if $pm eq "";
    
#    my ($pm, $mode2, $value, undef, undef, $mode4) = ($1, $2, $3, $4, $5, $6);
    
    $this->__drop_message("pm: $pm, mode2: $mode2, value: $value, mode4: $mode4\n", $this->{debug} >= 4, 0);
    $this->__drop_message("Made it past second regex.\n", $this->{debug} >= 4, 0);
    
    my $transid;
    eval("\$transid = \$mode" . $specs->{transcol} . ";");
    
    $this->__drop_message("Transid: $transid -- " . $specs->{tr_code}->{transmit} . "--" . $specs->{tr_code}->{receive} . "\n", $this->{debug} >= 4, 0);

    next unless (   (defined $specs->{tr_code}->{transmit} && $transid eq $specs->{tr_code}->{transmit})
                 || (defined $specs->{tr_code}->{receive} && $transid eq $specs->{tr_code}->{receive}));

    # we have some valid data
    $weGotSomething = 1;

    # set the value of the variables
    my $st = ($transid eq $specs->{tr_code}->{transmit} ? "transmit" : "receive");

    # update the PM in the database
    $this->{updates}->{$this->{PARAMETERS}->{uc("${st}_${pm}")}} = $value;

    $this->__drop_message("pm: $pm, mode2: $mode2, value: $value, mode4: $mode4\n", $this->{debug} >= 4, 0);
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




1;