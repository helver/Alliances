package Collectors::Collector_AlcatelTL1;
#
# Project: GeoNet Monitor
#
# Class: Collectors::Collector_AlcatelTL1
# Author: Eric Helvey
# Creation Date: 11/4/2003
#
# Description: Does data collection for Ciena TL1 elements.
#
# Revision: $Revision: 1.9 $
# Last Change Date: $Date: 2005-09-15 21:54:48 $
# Last Editor: $Author: eric $
#

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use strict;
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

  $this->{username} = "CONFIG";
  $this->{password} = "AS7#8DC4";
  $this->{port} = 5000;
  $this->{prompt} = '/[;| ]/';
  $this->{timeout} = 5;
  $this->{sleeptime} = 2;
  
  $this->{PARAMETERS} = {
      "CV"        => "c1",
      "ES"        => "c2",
      "SES"       => "c3",
      "LOSS"      => "c4",
      "PREFECCV"  => "c5",
      "POSTFECCV" => "c6"
  };

  $this->{TEMPL}{1} = {
      "channel"         => "interface",
      "receive_channel" => "e1",
      "oadm"            => "e2",
  };
  $this->{TEMPL}{5} = {
      "identifier"       => "interface",
      "channel"          => "e1",
      "directionality"   => "e2",
  };

  # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}


sub validate_request
{
  my ($this) = @_;
  
  if (   $this->{req}->{direction} != 1 
      && $this->{req}->{direction} != 2) {
    my $msg = "Direction is incorrect for " . $this->{req}->{tid} . ": " . $this->{req}->{direction} . ", (neither 1 nor 2). Returning an error.";
    
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
  $cmd = 'ACT-USER:' . $this->{req}->{tid} . ':"' . $this->{username} . '":123::"' . $this->{password} . '";';
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
  $cmd = "CANC-USER:" . $this->{req}->{tid} . "::126;";
  $this->{connection}->print($cmd);
  
  $this->{"loggedin"} = 0;
} 



sub __calculate_tsh_tsl
{
  my ($this, $shift, $scale) = @_;
  
  my $tsh = int(($this->{req}->{channel} - $shift) / 8) + $scale;
  my $tsl = (($this->{req}->{channel} - $shift) % 8) + 2;


  #How do I handle this?
  if($this->{req}->{element_type_id} == 5)
  {
    #There are only 4 channels dropped at a WADM
    #and while there are 4 types of card named 101 through 104
    #only one exists in a given net element
    $tsh = $scale + ($scale > 20 ? 1 : 0);

    $tsl = $this->{req}->{channel};
    $tsl -= 20 if ($tsl > 20);
    $tsl -= 8 if ($tsl > 8);
    $tsl++;
    
    #if $direction is 1 (EAST heading West) then the slot is in the second half so add 4
    $tsl = $tsl + 4 if($this->{req}->{direction} == 1);
  }
  
  $this->{req}->{tsl} = $tsl;
  $this->{req}->{tsh} = $tsh;
}



sub __pull_data
{
  my ($this) = @_;
   
  my ($count, $now);  # Variables used to test memory leaks.
  my $cmd;  # Variables used to process switch commands.
  
  $this->__drop_message("Post Login:", $this->{debug} >= 5, 0);
  if($this->{debug} >= 4) {
    $this->__drop_message("channel: " . $this->{req}->{channel} . "\n", 1, 0);
    $this->__drop_message("direction: " . $this->{req}->{direction} . "\n", 1, 0);
  }

	my $speed = $this->{type}->{speed};
	
	my ($pm_och, $pm_eqpt) = $this->$speed();

  return ($pm_och, $pm_eqpt);
}


sub OC48
{
	my ($this) = @_;
	
	my $cmd;
	
  $this->__calculate_tsh_tsl(1, 1);
  
  # Send the RTRV-PM-OCH command.
  $cmd = "RTRV-PM-OCH:" . $this->{req}->{tid} . ":OCH-OTS" . $this->{req}->{direction} . "-" . $this->{req}->{channel} . ":124::,0-up,,,1-DAY;";
  my ($before_och, $pm_och) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  $this->__drop_message("Post RTRV-PM-OCH\n", $this->{debug} >= 4, 0);
  
  #my $pm_och = $this->{connection}->get();



  # Send the RTRV-PM-EQPT command.
  $cmd = "RTRV-PM-EQPT:" . $this->{req}->{tid} . ":TRBRA-TRIB" . $this->{req}->{tsh} . "-" . $this->{req}->{tsl} . ":125::,0-up,,,1-DAY;";
  my ($before_eqpt, $pm_eqpt) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  $this->__drop_message("Post RTRV-PM-EQPT\n", $this->{debug} >= 4, 0);


  #my $pm_eqpt = $this->{connection}->get();

  $this->__drop_message("Post Close:", $this->{debug} >= 5, 0);
  
	return ($pm_och, $pm_eqpt);
}


sub OC192
{
	my ($this) = @_;
	
	my $cmd;
	
  $this->__calculate_tsh_tsl(25, 21);

  # Send the RTRV-PM-OCH command.
  $cmd = "RTRV-PM-OCH:" . $this->{req}->{tid} . ":OCH-OTS" . $this->{req}->{direction} . "-" . $this->{req}->{channel} . ":124::,0-up,,,1-DAY;";
  my ($before_och, $pm_och) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  $this->__drop_message("Post RTRV-PM-OCH\n", $this->{debug} >= 4, 0);
  
  #my $pm_och = $this->{connection}->get();



  # Send the RTRV-PM-EQPT command.
  $cmd = "RTRV-PM-EQPT:" . $this->{req}->{tid} . ":TRBRA-TRIB" . $this->{req}->{tsh} . "-" . $this->{req}->{tsl} . ":125::,0-up,,,1-DAY;";
  my ($before_eqpt, $pm_eqpt) = $this->{connection}->print($cmd, 'COMPLD', $this->{sleeptime});
  $this->__drop_message("Post RTRV-PM-EQPT\n", $this->{debug} >= 4, 0);


  #my $pm_eqpt = $this->{connection}->get();

  $this->__drop_message("Post Close:", $this->{debug} >= 5, 0);
  
	return ($pm_och, $pm_eqpt);
}


sub __parse_lines
{
  my ($this, $lines, $matcher) = @_;
  
  $this->__drop_message($lines, $this->{debug} >= 4, 0);

  foreach my $line (split(/\n/,$lines)) {
    $this->__drop_message("$line\n", $this->{debug} >= 4, 0);
    next unless ($line =~/$matcher/);
    
    my @fields = split /[,|:]/, $line;

    $this->__drop_message("($fields[2])\t($fields[3])\t($fields[6])\n", $this->{debug} >= 4, 0);

    if (exists $this->{PARAMETERS}->{$fields[2]}) {
    	my $key = $this->{PARAMETERS}->{$fields[2]};
    	my $acc = $key;
    	$acc =~ s/^c/a/;
    	
    	$this->__drop_message("previous value: $key = ". $this->{req}->{pm_totals}->{$acc} . " \n", $this->{debug} >= 4, 0);
      $this->{updates}->{$acc} = $fields[3];
      $this->{updates}->{$key} = $this->{updates}->{$acc} - $this->{req}->{pm_totals}->{$acc};
    	
      $this->__drop_message($key . " = " . $this->{updates}->{$key} . "\n", $this->{debug} >= 4, 0);
    }
  }
  
  return 1;
}





sub request
{
  my ($this, $req, $type, $pass) = @_;

  $this->__drop_message($this->{class} . "::request called\n", $this->{debug} >= 4, 0);

  $this->{req} = $req;
  $this->{type} = $type;
  
  $this->{LOCATORS} = $this->{TEMPL}{$this->{req}->{element_type_id}};
  
  $this->__populate_local_names;
  
  $this->{req}->{direction} = $this->{req}->{directionality} - 3;

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
	
  #$this->__calculate_tsh_tsl;
  
  return unless ($this->validate_request);
  
  # parse the result to retrieve the PMs
  my ($pm_och, $pm_eqpt) = $this->__pull_data;

  # Bail if we didn't get anything back.
  return unless ($pm_och || $pm_eqpt);

  return unless $this->__parse_lines($pm_och, "OC");
  return unless $this->__parse_lines($pm_eqpt, "TR");
  
  return 1;
}





1;
