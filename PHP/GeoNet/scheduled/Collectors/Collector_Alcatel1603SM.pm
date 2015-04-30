package Collectors::Collector_Alcatel1603SM;

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

  $this->__drop_message("In ${class}::new\n", $debug >= 0, 0);
  
  $this->{leakcheck} = 0;
  $this->{username} = "SUPERUSER";
  $this->{password} = "ANS#150";
  $this->{port} = 5000;
  $this->{prompt} = '/[;| ]/';
  $this->{timeout} = 5;
  $this->{sleeptime} = 2;
  
  $this->{PARAMETERS} = {
      "TRANSMIT_CV"  => "c1",
      "TRANSMIT_ES"  => "c2",
      "TRANSMIT_SES" => "c3",
      "TRANSMIT_UAS" => "c4",
      "TRANSMIT_SEF" => "c4",
      "RECEIVE_CV"   => "c5",
      "RECEIVE_ES"   => "c6",
      "RECEIVE_SES"  => "c7",
      "RECEIVE_UAS"  => "c8",
      "RECEIVE_SEF"  => "c8",
  };

  $this->{LOCATORS} = {
      "aid"         => "interface",
  };


  $this->{speed_specific}->{"OC12"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "S" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|S),((\d+)|(NA)),[^,]*,NEND/,
  	"command" => "RTRV-PM-OC12",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"OC3"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "S" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|S),((\d+)|(NA)),[^,]*,NEND/,
  	"command" => "RTRV-PM-OC3",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"T1"} = {
  	"tr_code" => { "transmit" => "L", "receive" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L|P),((\d+)|(NA)),[^,]*,NEND,RCV/,
  	"command" => "RTRV-PM-T1",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"T3"} = {
  	"tr_code" => { "transmit" => "L" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(L),((\d+)|(NA)),[^,]*,NEND,RCV/,
  	"command" => "RTRV-PM-T3",
  	"transcol" => 2,
  };
  
  $this->{speed_specific}->{"VT1"} = {
  	"tr_code" => { "transmit" => "P" },
  	"first_regex" => qr/15-MIN/,
  	"second_regex" => qr/:([A-Z]{2,3})(P),((\d+)|(NA)),[^,]*,NEND/,
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
    $this->__drop_message("aid: " . $this->{req}->{aid} . "\n", 1, 0);
  }

  my $speed = $this->{type}->{speed};
	
  # Send the RTRV-PM-OCH command.
  $cmd = $this->{speed_specific}->{$this->{type}->{speed}}->{command} . ":" . $this->{req}->{tid} . ":" . $this->{req}->{aid} . ":GEO::,0-up,,,15-MIN,,;";;
  my ($before, $lines) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});

  return $lines;
}



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

    # in this regular expression, the 1st element is one of the PM:
    # CV, ES, SES, or UAS followed by a S
    # 2nd element: the value of the PM
    # 3rd element: T or R tells us if it is transmit or receive data
    my ($pm, $mode2, $value, $mode4);
    ($pm, $mode2, $value, $mode4) = ($line =~ /$specs->{second_regex}/);
    
    next if $pm eq "";
    
#    my ($pm, $mode2, $value, $mode4) = ($1, $2, $3, $4);
    
    $this->__drop_message("pm: $pm, mode2: $mode2, value: $value, mode4: $mode4\n", $this->{debug} >= 4, 0);
    $this->__drop_message("Made it past second regex.\n", $this->{debug} >= 5, 0);
    
    my $transid;
    eval("\$transid = \$mode" . $specs->{transcol} . ";");
    
    $this->__drop_message("Transid: $transid -- " . $specs->{tr_code}->{transmit} . "--" . $specs->{tr_code}->{receive} . "\n", $this->{debug} >= 5, 0);


    # we have some valid data
    $weGotSomething = 1;

    # set the value of the variables
    my $st;
    if(defined $mode2) {
      $st = "transmit" if (defined $specs->{tr_code}->{transmit} && $mode2 eq $specs->{tr_code}->{transmit});
      $st = "receive" if (defined $specs->{tr_code}->{receive} && $mode2 eq $specs->{tr_code}->{receive});
    }

    # update the PM in the database
    if($value eq "NA") {
      $this->{updates}->{$this->{PARAMETERS}->{uc("${st}_${pm}")}} = $value;
    } else {
      $this->{updates}->{$this->{PARAMETERS}->{uc("${st}_${pm}")}} += $value;
    }

    $this->__drop_message("pm: $pm, mode2: $mode2, value: $value, mode4: $mode4\n", $this->{debug} >= 4, 0);
      
  }

  # if we did not receive any valid data, return an error flag
  $this->{updates}->{"flag"} = "e" if ($weGotSomething == 0);

  return $weGotSomething;
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
  $cmd = "ACT-USER:" . $this->{req}->{tid} . ":" . $this->{username} . ":123::" . $this->{password} . ":;";
  $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  
  # turn off autonomous messages
  $cmd = "INH-MSG-ALL:" . $this->{req}->{tid} . ":ALL:124::;";
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
  $cmd = "CANC-USER:" . $this->{req}->{tid} . "::126:::;";
  $this->{connection}->print($cmd);
  
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


