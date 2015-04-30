package Collectors::Collector_Base;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use Net::Telnet ();
use Time::Local;
use Devel::Leak;
use SubmittorSockWrapper;
use ConfigFileReader;
use Collectors::PM_Connection;


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
  my ($class, $sock, $loghandle, $errhandle, $config, $debug) = @_;

  print "In Collector_Base::new\n" if $debug >= 5;
  
  my $this = {
    "class" => $class,
    "debug" => $debug,
    "config" => $config,
    "sock" => $sock,
    "loghandle" => $loghandle,
    "errhandle" => $errhandle,
    "loggedin" => 0,
    #"ors" => "\n",
  };

  bless($this, $class);

  print "Returning from Collector_base::new\n" if $debug >= 5;
  
  # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}


# DESTROY is called automatically when the object is deleted
sub DESTROY
{
  my ($this) = @_;

  return;  
}

sub __drop_message
{
  my ($this, $msg, $err, $out) = @_;
  
  print { $this->{errhandle} } $msg if $err;
  print { $this->{loghandle} } $msg if $out;
}





sub setConnection
{
  my ($this, $connection, $ipaddress, $tidport) = @_;
  
  if(defined $this->{connection}) {
  	$this->__drop_message("\$this already has connection: $connection\n", $this->{debug} >= 4, 0);
  	
		return $this->{connection} 
  }
  
	if(defined $tidport) {
		$this->{port} = $tidport;
	}
	
  if(defined $connection) {
  	$this->__drop_message("Defined connection: $connection\n", $this->{debug} >= 4, 0);
  	
    my ($port, $prompt) = $connection->getPortAndPrompt;
    
    if(($port eq $this->{port}) && ($prompt eq $this->{prompt})) {
      $this->{connection} = $connection;  
    }
  }
  
  if(!defined($this->{connection})) {
  	$this->__drop_message("$ipaddress, " . $this->{port} . ", " . $this->{prompt} . "\n", $this->{debug} >= 5, 0);
  	
    $this->{connection} = new Collectors::PM_Connection($ipaddress, $this->{loghandle}, $this->{errhandle}, $this->{debug});
    my $retval = $this->{connection}->connect($this->{port}, $this->{prompt}, $this->{timeout}, $this->{ors});
    
    return $retval if($retval < 0);
  }
  
  $this->{connection}->setErrMode([\&Collectors::Collector_Base::doError, $this, 'e', 'COM', $this->{req}->{tidid}]);
  return $this->{connection};
}




sub validate_request
{
  my ($this) = @_;
  
  if($this->{debug} >= 4) {
    foreach my $x (keys %{$this->{req}}) {
      $this->__drop_message("$x: " . $this->{req}->{$x} . "\n", 1, 0);
    }
  }

  my $msg = localtime() . " -- TIDID: " . $this->{req}->{tid_id} . ", " . $this->{req}->{tid} . ", " . $this->{req}->{ipaddress} . ", " . $this->{req}->{element_type_id} . ", " . $this->{req}->{protocol} . "\n";

  $this->__drop_message($msg, 1, 1);

  # if we have the key for this element
  if (!exists $this->{req}->{tid_id}) {
    $msg = "No tidid for this element!.";
    $this->__drop_message($msg, 1, 1);
    return;
  }

  # if we have enough parameters to connect to the element
  if (   (!exists $this->{req}->{tid} || $this->{req}->{tid} eq "") 
      || (!exists $this->{req}->{ipaddress} || $this->{req}->{ipaddress} eq "")
      || (!exists $this->{req}->{channel} || $this->{req}->{channel} eq "")
      || (!exists $this->{req}->{receive_channel} || $this->{req}->{receive_channel} eq "")
      || (!exists $this->{req}->{protocol} || $this->{req}->{protocol} eq "")
      || (!exists $this->{req}->{element_type_id} || $this->{req}->{element_type_id} eq "")
      || (   (   (!exists $this->{req}->{shelf} || $this->{req}->{shelf} eq "")
              || (!exists $this->{req}->{slot_transmitter} || $this->{req}->{slot_transmitter} eq "")
              || (!exists $this->{req}->{slot_receiver} || $this->{req}->{slot_receiver} eq "")
             )
          && ($this->{req}->{protocol} ne 'AlcatelTL1')
         )
     ) {
    my $msg = "Not enough data to connect to the element " . $this->{req}->{tid} . ": " .
              "ipaddress = " . $this->{req}->{ipaddress} . ", " .
              "shelf = " . $this->{req}->{shelf} . ", " .
              "channel = " . $this->{req}->{channel} . ", " .
              "slot_transmitter = " . $this->{req}->{slot_transmitter} . ", " .
              "slot_receiver = " . $this->{req}->{slot_receiver} . ", " .
              "receive_channel = " . $this->{req}->{receive_channel} . ", " . 
              "protocol = " . $this->{req}->{protocol} . ", " .
              "element_type_id = " . $this->{req}->{element_type_id} . ".\n";
              
    $this->__drop_message($msg, 1, 1);
    $this->doError("e", "Database", $this->{req}->{tid_id}, $msg);
    return;
  }

  # if some of the parameters are invalid
  if (!(   $this->{req}->{ipaddress} =~ /^\d+\.\d+\.\d+\.\d+$/ 
        && $this->isaInteger($this->{req}->{shelf})
        && $this->isaInteger($this->{req}->{channel}) 
        && $this->isaInteger($this->{req}->{slot_transmitter}) 
        && $this->isaInteger($this->{req}->{slot_receiver})
     )) {
    my $msg = "Invalid data for " . $this->{req}->{tid} . ": " .
              "ipaddress = " . $this->{req}->{ipaddress} . ", " .
              "shelf = " . $this->{req}->{shelf} . ", " .
              "channel = " . $this->{req}->{channel} . ", " .
              "slot_transmitter = " . $this->{req}->{slot_transmitter} . ", " .
              "slot_receiver = " . $this->{req}->{slot_receiver} . ".\n";
              
    $this->__drop_message($msg, 1, 1);
    $this->doError("e", "Database", $this->{req}->{tid_id}, $msg);
    return;
  }

#  if ($this->{req}->{receive_channel} =~ /Top/) {
#    $this->{req}->{receive_channel} = "Top"; 
#  
#  } elsif ($this->{req}->{receive_channel} =~ /Bot/) { 
#    $this->{req}->{receive_channel} = "Bottom"; 
#  
#  } elsif (   $this->{req}->{element_type} ne "Ciena CoreStream" 
#           && $this->{req}->{element_type} ne "Alcatel 1640 WM" 
#           && $this->{req}->{element_type} ne "Alcatel 1640 WADM") {  
#    my $msg = "Unexpected Receiver Channel " . $this->{req}->{receive_channel} . "\n";
#    $this->__drop_message($msg, 1, 1);
#    $this->doError("e", "Database", $this->{req}->{tid_id}, $msg); 
#    return;
#  }
  
  return 1;
}



# just print the error message
# it is called when an error occured and
# the error message is automatically sent to it
# @param $msg the error message
# @return an error flag
sub printErrorAndReturn
{
  my ($this, $msg) = @_;
  $this->__drop_message("Error: $msg\n", 1, 1);
  return "e";
}




# if an error occur during the main while loop
# this function is called. It displays an error message,
# and update the flag to 'e' for this element if we have the key to it
# @param $dbh the database handler
# @param $tidid the key for the element in the database
# @param $error_msg the error message to display
sub doError
{
  my ($this, $flag, $cause, $tidid, $error_msg) = @_;

  $this->__drop_message("$error_msg\n", 1, 1);
  
  if ($tidid =~ /\d+/)
  {
    # update the flag for the current record
    $this->{sock}->send("UpdateError|$flag|$cause|$tidid\n");
  }

}




# check if the parameter is a number
# @param $value the value to check
# @return 1 if it is a number, 0 if not
sub isaInteger
{
  my ($this, $value) = @_;

  return 1 if ($value =~ /^-?\d+$/);
  
  $this->__drop_message("$value is not an integer!\n", $this->{debug} >= 4, 0);
  return 0;
}



sub submit_updates
{
  my ($this, $thisif) = @_;
  
  $this->__drop_message("Updating: " . $this->{req}->{tid_id} . "/$thisif, " . $this->{req}->{tid} . "\n\n", $this->{debug} >= 3, 0);
  return unless ($this->{req}->{tid_id} && $thisif);
  
  my ($cs, $as);
  for(my $i = 1; $i <= 10; $i++) {
    $cs .= "|" . (defined($this->{updates}->{"c$i"}) ? $this->{updates}->{"c$i"} : -1);
    $as .= "|" . (defined($this->{updates}->{"a$i"}) ? $this->{updates}->{"a$i"} : ($this->{req}->{pm_totals}->{"a$i"} ? $this->{req}->{pm_totals}->{"a$i"} : 0));
  }
  
  $this->{sock}->send("UpdatePMInfo|||cllctr|$cs$as|" . $this->{req}->{tid_id} .  "|$thisif\n", 10);


}

sub request
{
  my ($this) = @_;
  return;
}


sub __populate_local_names
{
  my ($this) = @_;
  
  foreach my $xx (keys %{$this->{LOCATORS}}) {
    $this->{req}->{$xx} = $this->{req}->{$this->{LOCATORS}->{$xx}};
  }
}




  

1;
