package Collectors::Collector_ASX_SNMP;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use strict;
use Collectors::Collector_Base;
use SNMPWrapper;
use Date::Manip;


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

  # not used for now
  $this->{LOCATORS} = {
      "port"            => "e1",
      "portnum"         => "e2",
      "bandwidth"       => "e3",
  };

  
  $this->__drop_message("Creating a new Collector_ASX_SNMP object.\n", $this->{debug} > 3, 0);
  
  # the session track object.
  return $this;
}


sub setConnection
{
  my ($this, $connection, $ipaddress) = @_;
  
  $this->{ipaddress} = $ipaddress;
  
  $this->__drop_message("Setting up the connection to $ipaddress.\n", $this->{debug} > 3, 0);
  
  $this->{session} = SNMPWrapper->new($ipaddress, $this->{debug}, "public");

  if (!$this->{session})
  {
    $this->__drop_message("Connection failed.\n", $this->{debug} > 3, 0);
  
    return -1; # failed
  }
  else
  {
    $this->__drop_message("Connection successful.\n", $this->{debug} > 3, 0);
  
    return $this;
  }
}


sub __login
{
  my ($this) = @_;
  
  return;
}

sub __logout
{
  my ($this) = @_;
  
  $this->__drop_message("Closing the SNMP connection to ip " . $this->{ipaddress} . ".\n", $this->{debug} > 3, 0);
  
  $this->{session}->Close();
  return;
}

 
 
sub request
{
  my ($this, $req, $type, $pass) = @_;

  $this->__drop_message($this->{class} . "::request called\n", $this->{debug} > 3, 0);

  $this->{req} = $req;
  $this->{type} = $type;
  
  $this->{updates} = {};
    
  #$this->__populate_local_names;
  #$this->__calculate_tsh_tsl;
  
  return unless ($this->validate_request);
  
  # get the receive cell count through an SNMP request
  my $receive_cell_count = $this->__lookup_receive_cell_count();
  
  # calculate the receive rate and the difference with the bandwidth,
  # both are to store in the database
  $this->__calculate_rates($receive_cell_count);
  
  return 1;
}


sub validate_request
{
  my ($this) = @_;
  
  my $req = $this->{req};
  
  if($this->{debug} >= 1) {
    $this->__drop_message("In validate_request.\n", $this->{debug} > 3, 0);
  
    foreach my $x (keys %{$req}) {
      $this->__drop_message("$x: " . $req->{$x} . "\n", 1, 0);
    }
  }

  my $msg = "TIDID: " . $req->{tid_id} . ", " . $req->{tid} . ", " . $req->{ipaddress} . ", " . $req->{element_type_id} . ", " . $req->{protocol} . "\n";

  # if we have the key for this element
  if (!exists $req->{tid_id}) {
    $msg = "No tidid for this element!.";
    $this->__drop_message($msg, 1, 1);
    return;
  }

  # if we have enough parameters to connect to the element
  if (   (!exists $req->{tid} || $req->{tid} eq "") 
      || (!exists $req->{ipaddress} || $req->{ipaddress} eq "")
      || (!exists $req->{"Port"} || $req->{"Port"} eq "")
      || (!exists $req->{"Port #"} || $req->{"Port #"} eq "")
      #|| (!exists $req->{"Bandwidth"} || $req->{"Bandwidth"} eq "")
      || (!exists $req->{protocol} || $req->{protocol} eq "")
      #|| (!exists $req->{element_type_id} || $req->{element_type} eq "")
     ) {
    my $msg = "Not enough data to connect to the element " . $req->{tid} . ": " .
              "ipaddress = " . $req->{ipaddress} . ", " .
              "Port = " . $req->{"Port"} . ", " .
              "Port # = " . $req->{"Port #"} . ", " .
              "Bandwidth = " . $req->{"Bandwidth"} . ", " .
              "protocol = " . $req->{protocol} . ", " .
              "element_type_id = " . $req->{element_type_id} . ".\n";
              
    $this->doError("e", "Database", $req->{tidid}, $msg);
    return;
  }

  # if some of the parameters are invalid
  if (!(   $req->{ipaddress} =~ /^\d+\.\d+\.\d+\.\d+$/ 
        && $this->isaInteger($req->{"Port #"})
     )) {
    my $msg = "Invalid data for " . $req->{tid} . ": " .
              "ipaddress = " . $req->{ipaddress} . ", " .
              "Port # = " . $req->{"Port #"} . ".\n";
              
    $this->doError("e", "Database", $req->{tidid}, $msg);
    return;
  }

  return 1;
}


sub __lookup_receive_cell_count
{
  my ($this) = @_;

  my $req = $this->{req};
  
  my ($rcvd) = $this->{session}->Get("1.3.6.1.4.1.326.2.2.2.1.2.2.1.12." . $req->{"Port #"});

  $this->__drop_message("Receive cell count: $rcvd.\n", $this->{debug} > 3, 0);
  
  return $rcvd;
}


sub __calculate_rates
{
  my ($this, $curr_receive_cell_count) = @_;
  
  my $req = $this->{req};
  
  $this->__drop_message("Previous pms: a2: " . $req->{"pm_totals"}{"a2"}
      . "\ntimeentered: " . $req->{"pm_totals"}{"timeentered"}
      . ".\n", this->{debug} > 3, 0);

  my $last_date = &UnixDate(&ParseDate($req->{"pm_totals"}{"timeentered"}), "%s");
  my $cur_date = &UnixDate("today", "%s");

  my $time_diff = ($last_date ? $cur_date - $last_date : 0);

  $this->__drop_message("Time difference between now ($cur_date) and last ($last_date): $time_diff.\n", $this->{debug} > 3, 0);
  
  my $received_rate = $this->_get_rate($req->{"pm_totals"}{"a2"}, $curr_receive_cell_count, $time_diff);
  
  $this->__drop_message("Receive_rate: $received_rate cells/sec.\n", $this->{debug} > 3, 0);
  
  # transform the rate into MB/sec
  # the number we have is in nb of cells / sec
  # there is 53 bytes per cell
  # and 8 bites / Byte
  $received_rate = $received_rate * 53 * 8;

  my $diffBandwidth = int(($received_rate - ($req->{"Bandwidth"} * 1000000)) / 1000000);
  #$diffBandwidth = ($diffBandwidth < 0 ? $diffBandwidth * -1 : $diffBandwidth);
  
  $this->__drop_message("Receive rate: $received_rate MB/s.\n", $this->{debug} > 3, 0);
  $this->__drop_message("bandwidth diff: ". $diffBandwidth . ".\n", $this->{debug} > 3, 0);
  
  $this->{updates}->{"a1"} = $received_rate; 
  $this->{updates}->{"c10"} = $diffBandwidth;
  $this->{updates}->{"a2"} = $curr_receive_cell_count;
  
  # keep the same c9 and cause which is the value set by tracepath changes
  $this->{updates}->{"c9"} = $req->{"pm_totals"}{"c9"}; 
  $this->{updates}->{"cause"} = $req->{"pm_totals"}{"cause"}; 
}



sub _get_rate
{
  my ($this, $prev, $curr, $timey) = @_;

  return 0 unless $timey;
  return int(($curr - $prev)/$timey);
}


# dummy method just to replicate the PM_Connection.finishOperation
# which is called from PM_Collector
sub finishOperation
{
  return;
}
 
sub submit_updates
{
  my ($this, $thisif) = @_;
  
  $this->__drop_message("Updating: " . $this->{req}->{tid_id} . "/$thisif, " . $this->{req}->{tid} . "\n\n", $this->{debug} >= 3, 0);
  return unless ($this->{req}->{tid_id} && $thisif);
  
  my ($cs, $as);
  for(my $i = 1; $i <= 10; $i++) {
    $cs .= "|" . (defined($this->{updates}->{"c$i"}) ? $this->{updates}->{"c$i"} : -1);
    $as .= "|" . (defined($this->{updates}->{"a$i"}) ? $this->{updates}->{"a$i"} : -1);
  }
  
  my $cause = (defined($this->{updates}->{"cause"}) ? $this->{updates}->{"cause"} : '');
  
  $this->{sock}->send("UpdatePMInfo||$cause|cllctr|$cs$as|" . $this->{req}->{tid_id} .  "|$thisif\n", 10);


}


  
1;
