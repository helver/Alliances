package Collectors::Collector_CiscoDS3Traps;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
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

  $this->{leakcheck} = 0;
  $this->{status} = 1;
    
  # If init comes back false, then we don't really want to create
  # the session track object.
  return $this;
}


sub __pull_data
{
  my ($this, $sock) = @_;
   
  $sock->send("GetTraps|" . $this->{req}->{ipaddress} . "|" . $this->{req}->{shelf} . "|" . $this->{req}->{channel} . "|" . $this->{req}->{slot_transmitter} . "\n", 10);
  my $dat = $sock->receive_data();
  
  my @cols = ("pm_info_id", "ipaddress", "timeentered", "trapnum", "shelf", "channel", 
              "slot_transmitter", "status", "transmit_es", "transmit_ses", "transmit_uas", 
              "transmit_cv", "receive_es", "receive_ses", "receive_uas", "receive_cv",
              "total_transmit_es", "total_transmit_ses", "total_transmit_uas", 
              "total_transmit_cv", "total_receive_es", "total_receive_ses", 
              "total_receive_uas", "total_receive_cv");
              
  my @updatecols = ("transmit_es", "transmit_ses", "transmit_uas", "transmit_cv", 
                    "receive_es", "receive_ses", "receive_uas", "receive_cv",
                    "total_transmit_es", "total_transmit_ses", "total_transmit_uas", 
                    "total_transmit_cv", "total_receive_es", "total_receive_ses", 
                    "total_receive_uas", "total_receive_cv");
              
  foreach my $line (split /\n/, $dat) {
    my %line;
    @line{@cols} = split /,/, $line;
    
    foreach my $x (@updatecols) {
      $this->{updates}->{$x} = $line{$x};
    }
    
    $this->{status} = $line{status};
    
    $this->__determine_color_and_cause;
    my ($flag, $cause) = ($this->{updates}->{"flag"}, $this->{updates}->{cause});
    
    $sock->send("UpdateTID|$flag|$cause|" . join("|", @line{@updatecols}) . "|" . $this->{req}->{tidid} . "\n");
  }
  
}


sub __determine_color_and_cause
{
  my ($this) = @_;

  my %failure_cause = (
    8 => 'AIS',
    16 => 'AIS',
    32 => 'LOF',
    64 => 'LOS',
    128 => 'Loop',
    256 => 'Test',
    512 => 'Othr',
    1024 => 'USS',
    2048 => 'OSS',
  );
  
  if($this->{status} == 1) {
    $this->{updates}->{"flag"} = "g";
  } elsif($this->{status} <= 6) {
    $this->{updates}->{"flag"} = "y";
    $this->{updates}->{"cause"} = "RAI";
  } elsif($this->{status} > 6) {
    
    $this->{updates}->{"flag"} = "r";
    foreach my $x (keys %failure_cause) {
      if(($this->{status} % $x) == 0) {
        $this->{updates}->{cause} = $failure_cause{$x};
        last;
      }
    }
    $this->{updates}->{cause} = "UNKN" unless (!defined $this->{updates}->{cause});
    
  } elsif (!defined($this->{updates}->{"flag"})) {
    $this->{updates}->{"flag"} = "g";
  }

  return 1;
}



sub request
{
  my ($this, $sock, $req) = @_;

  $this->__drop_message("Collector_CiscoTraps::request called\n", $this->{debug} >= 4, 0);

  $this->{req} = $req;
  $this->{updates} = {};
    
  return unless ($this->validate_request($req));
  
  $this->__pull_data($sock);

  return 1;
}


sub validate_request
{
  my ($this, $req) = @_;
  
  if($req->{ipaddress} ne "" && $req->{shelf} ne "") {
    return 1;
  }
  
  return 0;
}


1;
