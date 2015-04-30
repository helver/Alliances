package DB_Proxy_Service;

use IO::Socket;
use IO::Select;
use Tie::RefHash;
use POSIX;
use Socket;
use Fcntl;

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
sub new
{
  my ($class, $statements, $listener_port, $cycle_time, $pidfile, $debug) = @_;

  my $this = {
    "debug" => $debug,
    "statements" => $statements,
    "listener_port" => $listener_port,
    "port" => ($debug >= 2 ? $listener_port + $debug : $listener_port),
    "cycle_time" => $cycle_time,
    "pidfile" => $pidfile,
    "inbuffer" => {},
    "outbuffer" => {},
    "usocks" => {},
    "emptytime" => -1,
    "stmt" => "",
  };

  bless($this, $class);

  my %ready = ();
  tie %ready, 'Tie::RefHash';
  $this->{ready} = \%ready;
  
  $this->__open_server_socket;
  
  return $this;
}



#
#
# Function: __open_server_socket
#
# Open and configure a TCP/IP socket for the server to listen to.
#
sub __open_server_socket
{
  my ($this) = @_;
  
  $this->{server} = IO::Socket::INET->new(
                        LocalPort => $this->{port},
                        #Proto => "tcp",
                        Listen => 10,
                        Type => SOCK_STREAM,
                        Reuse => 1,
                    ) or die "Can't create server process: $!\n$@\n";

  print "Server: " . $this->{server} . " listening on port " . $this->{port} . "\n" if($this->{debug} >= 1);

  $this->__nonblock($this->{server});
  $this->{select} = IO::Select->new($this->{server});
}



#
#
# Function: __drop_pid_entry
#
# Here we're going to add a PID and Timestamp entry to our pidfile
# just so we can try to keep track of the process and to allow external
# watchdog programs to determine if this process is dead or stuck.
#
sub __drop_pid_entry
{
  my ($this) = @_;
  
  open (FH, "> " . $this->{pidfile}) or
    die "Can't open " . $this->{pidfile} . " file: $!\n";
  print FH "$$\n" . time() . "\n";
  
  if($this->{debug} >= 3) {
	  print "$$\n" . time() . "\n";
  }
  
  close FH;
}





#
#
# Function: __nonblock
#
# This function takes a socket and turns in into a nonblocking
# socket.  This allows us to use the socket in a select system
# call so that we can listen and wait for multiple sockets at
# the same time.
#
sub __nonblock
{
  my ($this, $sock) = @_;

  my $flags = fcntl($sock, F_GETFL, 0);
  fcntl($sock, F_SETFL, $flags | O_NONBLOCK);
}




#
#
# Function: __open_new_client
#
# Handles the opening and configuration of new client connections.
#
sub __open_new_client
{
  my ($this, $client) = @_;
  
  print "Client is Server - new connection.\n" if($this->{debug} >= 5);

  $client = $this->{server}->accept();

  print "New Client: $client\n" if($this->{debug} >= 3);

  $this->{select}->add($client);
  $this->__nonblock($client);

  return $client;
}


  

#
#
# Function: __close_dead_client
#
# Here we're cleaning up after a close connection.  Mostly what we're
# doing is unregistering the client from the select list and clearing
# out any buffers associated with the connection.
sub __close_dead_client
{
  my ($this, $client) = @_;
  
  print "Closing Client connection.\n" if($this->{debug} >= 3);
  delete $this->{inbuffer}->{$client};
  delete $this->{outbuffer}->{$client};
  delete $this->{ready}->{$client};

  $this->{select}->remove($client);
}




#
#
# Function: __receive_data_from_client
#
# Pulls data off the client connection and verifies that the client
# is still active.  Places all complete lines of data onto the 
# ready buffer for processing.
#
sub __receive_data_from_client
{
  my ($this, $client) = @_;
  
  my $data;
  my $rv = $client->recv($data, POSIX::BUFSIZ, 0);

  print "Received $rv bytes: $data\n" if($this->{debug} >= 5);

  unless(defined($rv) && length $data) {
    $this->__close_dead_client($client);
    return 1;
  }

  print "Setting client inbuffer\n" if($this->{debug} >= 5);

  $this->{inbuffer}->{$client} .= $data;

  while($this->{inbuffer}->{$client} =~ s/([^\n]*\n)//) {
    print "Setting client's ready buffer to: $1\n" if($this->{debug} >= 5);
    push( @{$this->{ready}->{$client}}, $1);
  }
  
  return;
}


  

#
#
# Function: __read_client_traffic
#
# Handles the creation of client connections, and the reception and 
# queueing of client submitted data.
#
sub __read_client_traffic
{
  my ($this) = @_;
  
  foreach my $client ($this->{select}->can_read($this->{cycle_time})) {
    print "client: $client\n" if($this->{debug} >= 5);

    if($client == $this->{server}) {
      $client = $this->__open_new_client;
    } else {
      print "Client is not server - existing connection.\n" if($this->{debug} >= 5);

      close $client if $this->__receive_data_from_client($client);
        
      print "Done messing with client: $client\n" if($this->{debug} >= 5);
    }
  }
  
  print "Done with client Traffic.\n" if($this->{debug} >= 1);
}


  

#
#
# Function: __write_client_traffic
#
# Handles the delivery of information back to clients.
#
sub __write_client_traffic
{
  my ($this) = @_;
  
  foreach my $client ($this->{select}->can_write($this->{cycle_time})) {
    print "client: $client\n" if($this->{debug} >= 5);

    next unless exists $this->{outbuffer}->{$client};

    print "We've got something to send to $client.\n" if($this->{debug} >= 3);

    my $rv = $client->send($this->{outbuffer}->{$client});

    print "Sent $rv bytes: " . $this->{outbuffer}->{$client} . "\n" if($this->{debug} >= 5);

    if($rv == length $this->{outbuffer}->{$client} || $! == POSIX::EWOULDBLOCK) {
      substr($this->{outbuffer}->{$client}, 0, $rv) = '';
      delete $this->{outbuffer}->{$client} unless length $this->{outbuffer}->{$client};
    } else {
      $this->__close_dead_client($client);
      close($client);
    }
  }
}





#
#
# Function: __handle_select
#
# Some of the statement we handle are SELECT statements.  This function
# processes the select statements and formats the result set so that the
# client processes can retrieve the data.
#
sub __handle_select
{
  my ($this, $stmt, $client) = @_;
  my $row;

	if($stmt eq "GetNextTID" && ($this->{emptytime} > time())) {
		print time() . " vs " . $this->{emptytime} . " -- sending cached empty queue.\n" if($this->{debug} >= 3);
		
    $this->{outbuffer}->{$client} .= "";
	} else {
		my $tot = "";
		
    while ($row = join('|', $this->{statements}->{$stmt}{handle}->fetchrow_array)) {
      $this->{outbuffer}->{$client} .= "$row\n";
      $tot .= $row;
    }
    
    if($stmt eq "GetNextTID") {
    	if($tot eq "") {
    		print "Setting emptytime to be: " . (time() + 5) . " vs " . time() . ".\n" if($this->{debug} >= 3);
      	$this->{emptytime} = time() + 5;
      } else {
  		  print "Clearing emptytime.\n" if($this->{debug} >= 3);
      	$this->{emptytime} = 0;
      }
    }
	}

  $this->{outbuffer}->{$client} .= "END\n";
  print $this->{outbuffer}->{$client} . "\n" if($this->{debug} >= 3);
}





#
#
# Function: __display_SQL
#
# __display_SQL takes a parameterized SQL statement and displays it twice -
# once without parameter substitution, once with parameters substituted
# for the ?'s.  The substitution is very crude and the resulting SQL is
# not fit for use, but it does let you know what values are being placed
# in what spots in the SQL.
#
sub __display_SQL
{
  my ($this, $method, @args) = @_;

  my $sql = $this->{statements}->{$method}{statement};

  print "pre: $sql\n";
  print "@args\n";

  for(my $i = 0; $i < @args; $i++) {
    $sql =~ s/\?/$args[$i]/;
  }

  print "sql: $sql\n";
}






#
#
# Function: __execute_SQL
#
# Here, we're taking the SQL statement requested by the client and binding
# the parameters into the SQL statement and executing the statement.
#
sub __execute_SQL
{
  my ($this, $state, @args) = @_;

  for(my $i = 0; $i < @{$state->{datatypes}}; $i++) {
    print "$i - $args[$i] - " . $state->{datatypes}[$i] . "\n" if($this->{debug} >= 3);
    $state->{handle}->bind_param($i + 1, $args[$i], $state->{datatypes}[$i]);
  }

  print "Statement: " . $state->{handle}->{Statement} . "\n" if($this->{debug} >= 1);
  print join("|", @args), "\n" if($this->{debug} >= 1);

	my $xxx = time();
	
	if($this->{stmt} eq "GetNextTID" && ($this->{emptytime} > time())) {
		print "Empty time - avoid GetNextTID\n" if ($this->{debug} >= 3);
	} else {
    eval "\$state->{handle}->execute;";
    print localtime() . "\n" . $@ . "\n" if defined $@;
	}
	
  print "Execution Duration: " . (time() - $xxx) . "\n"  if($this->{debug} >= 1);
}






#
#
# Function: __handle
#
# For any client connections that have data ready, this function goes
# through and processes the requests.
#
sub __handle
{
  my ($this, $client) = @_;

  print "Handling $client.\n" if($this->{debug} >= 3);

	my @requests = @{$this->{ready}->{$client}};
	
  delete $this->{ready}->{$client};

  while (@requests) {
  	my $request = shift @requests;
    chomp($request);

    my ($stmt, @req) = split(/\|/, $request);
    my $method;

		$this->{stmt} = $stmt;
		
    print "Executing $stmt statement.\n" if($this->{debug} >= 3);

    $this->__display_SQL($stmt, @req) if($this->{debug} >= 1);
    $this->__execute_SQL($this->{statements}->{$stmt},@req);

    if($this->{statements}->{$stmt}{handle}->{err}) {
      print "Error executing statement: " . $this->{statements}->{$stmt}{handle}->{errstr} . "\n";
      $this->__display_SQL($stmt, @req);

			push @{$this->{ready}->{$client}},  $request;
      next;
    }

    $this->__handle_select($stmt, $client) if($this->{statements}->{$stmt}{select});
  }

}




#
#
# Function: server_loop
#
# Main loop of the DB_Proxy_Service.  Processes enter here and really don't
# ever return.
#
sub server_loop
{
  my ($this) = @_;
  
  while(1) {
    $this->__drop_pid_entry;
    $this->__read_client_traffic;
    
    foreach my $client (keys %{$this->{ready}}) {
      $this->__handle($client);
      $this->__drop_pid_entry;
    }

    $this->__write_client_traffic;
  }

  print("Exiting\n") if ($this->{debug} >= 1);
}



1;




