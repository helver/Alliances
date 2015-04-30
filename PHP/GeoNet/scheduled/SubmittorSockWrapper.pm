package SubmittorSockWrapper;

# We need the followiong modules to make this work:
# Exporter is used to make this a real Perl modules
use Exporter;
use strict;
use IO::Socket;
use IO::Select;
use ConfigFileReader;


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
  my ($class, $config, $debug) = @_;

  my $port = $config->getAttribute("SubmittorPort") + ($debug >= 5 ? $debug : 0);
  
  print "Opening TCP socket to " . $config->getAttribute("SubmittorHost") . " on port $port\n" if($debug >= 4);
  
  my $sock = IO::Socket::INET->new(
     Proto => "tcp",
     PeerPort => $port,
     PeerAddr => $config->getAttribute("SubmittorHost"),
     Type => SOCK_STREAM,
  ) or die "Can't create client socket: $!, $@\n";
   
  print "Successfully opened TCP socket to " . $config->getAttribute("SubmittorHost") . " on port $port\n" if($debug >= 4);

  my $this = {
    "debug" => $debug,
    "config" => $config,
    "sock" => $sock,
  };

  bless($this, $class);

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



sub send
{
  my ($this, $dat, $debugger) = @_;
  
  $debugger = 0 unless defined $debugger;
  
  print "Sending '$dat'\n" if ($this->{debug} >= 2);
  
  $this->{sock}->send($dat) or die "SubmittorSockWrapper::send Error: $!\n";
}


sub receive_data
{
  my ($this) = @_;

  my ($dat, $res);

  my $select = IO::Select->new($this->{sock});

 	my $count = 0;
  while($res !~ /\n?END\n$/) {
  	#exit if $this->{sock}->eof();
  	
    while($select->can_read(1)) {
      defined($this->{sock}->recv($dat, 1024, 0)) or die "SubmittorSockWrapper::recv Error: $!\n";
      print "dat: $dat\n" if($this->{debug} >= 1);

      $res .= $dat;

			$count++ if($dat eq "");
			last if $count > 10;
    }
    exit if $count > 10;
  }
  $res =~ s/\n?END\n$//;

  print "res: $res\n" if($this->{debug} >= 1);

  return $res;
}

1;