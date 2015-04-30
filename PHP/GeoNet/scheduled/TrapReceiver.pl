#!/usr/local/bin/perl

use SNMPWrapper;
use DBWrapper::OCI_DBWrapper;
use ConfigFileReader;
use Date::Manip;
use strict;
use DBI qw(:sql_types);

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = 0;

# get the parameter for the database
my $dbhost = ($debug >= 5 ? "broadband.oss.sprint.com" : $config->getAttribute("DBhost"));
my $sid = ($debug >= 5 ? "ORCL" : $config->getAttribute("DatabaseSID"));
my $user = ($debug >= 5 ? "geonet" : $config->getAttribute("DBusername"));
my $pass = ($debug >= 5 ? "tenoeg" : $config->getAttribute("DBpassword"));

print("host: $dbhost\n") if $debug;
# connect to the database
my $dbi = DBI->connect( "dbi:Oracle:host=$dbhost;sid=$sid", $user, $pass)
      or die "Can't connect to Oracle database: $DBI::errstr\n";
if (!$dbi) { print "not connected to oracle\n"; exit; }
#$dbi->{ShowErrorStatement} = "on";
$dbi->{PrintError} = "on";
$dbi->{RaiseError} = "off";


my %statements;


$statements{"InsertTrap"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                 ],
  "statement" => 
  "INSERT INTO pm_info " . 
  "(PM_INFO_ID, AGENT, TRAPTIME, TRAPNUM, SHELF, CHANNEL, SLOT_TRANSMITTER, STATUS, " .
  "TRANSMIT_ES, TRANSMIT_SES, TRANSMIT_UAS, TRANSMIT_CV, " .
  "RECEIVE_ES,RECEIVE_SES, RECEIVE_UAS, RECEIVE_CV, " .
  "TOTAL_TRANSMIT_ES, TOTAL_TRANSMIT_SES, TOTAL_TRANSMIT_UAS, TOTAL_TRANSMIT_CV, " .
  "TOTAL_RECEIVE_ES, TOTAL_RECEIVE_SES, TOTAL_RECEIVE_UAS, TOTAL_RECEIVE_CV) " .
  "SELECT " .
  "seq_pm_info_id.nextval, ?, SYSDATE, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? " .
  "from DUAL",
};

$statements{"InsertTrap"}->{"handle"} = $dbi->prepare($statements{"InsertTrap"}->{"statement"});

print "Checking InsertTrap: " . $statements{InsertTrap}->{handle} . "\n" if($debug >= 1);


my $sess = SNMPWrapper->new("127.0.0.1", $debug, "public");

while(1) {
  eval "\$sess->Listen(\\\&processTrap);";
  $sess->{session}->close;
  print $@ if $@;
  last;
}


sub build_insert_array
{
  my ($trap_vals) = @_;
  
  my ($ifnum) = grep /^1\.3\.6\.1\.2\.1\.2\.2\.1\.1\./, keys %{$trap_vals};
  my @vals = ($trap_vals->{"Agent"}, $trap_vals->{"SpecificID"});
  $ifnum = $trap_vals->{$ifnum};
  
  if($trap_vals->{"SpecificID"} == 902) {  
    $trap_vals->{"1.3.6.1.2.1.2.2.1.2." . $ifnum} =~ m|^T3\s+(\d+)/(\d+)/(\d+)\s*$|;
    push @vals, ($1,$2,$3);
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.5.1.10." . $ifnum};
    push @vals, "";
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.4." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.5." . $ifnum};
    push @vals, "";

    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.8." . $ifnum};
    push @vals, "";
    push @vals, "";
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.6." . $ifnum};

    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.2." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.3." . $ifnum};
    push @vals, "";
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.7." . $ifnum};

    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.10." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.11." . $ifnum};
    push @vals, "";
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.30.6.1.9." . $ifnum};

  } elsif($trap_vals->{"SpecificID"} == 932 || $trap_vals->{"SpecificID"} == 933) {  
    $trap_vals->{"1.3.6.1.2.1.2.2.1.2." . $ifnum} =~ m|^POS3/(\d+)\s*$|;
    push @vals, ($1,"","");
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.2.1.1.1.2." . $ifnum};
    push @vals, ("","","",""); 
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.2.1.1.1.3." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.2.1.1.1.4." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.2.1.1.1.6." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.2.1.1.1.5." . $ifnum};
    push @vals, ("","","",""); 
    push @vals, ("","","",""); 
  } elsif($trap_vals->{"SpecificID"} == 936 || $trap_vals->{"SpecificID"} == 937) {  
    $trap_vals->{"1.3.6.1.2.1.2.2.1.2." . $ifnum} =~ m|^POS3/(\d+)\s*$|;
    push @vals, ($1,"","");
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.2.1.1.1." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.2.1.1.2." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.2.1.1.3." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.2.1.1.4." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.2.1.1.5." . $ifnum};
    push @vals, ("","","",""); 
    push @vals, ("","","",""); 
    push @vals, ("","","",""); 
  } elsif($trap_vals->{"SpecificID"} == 930 || $trap_vals->{"SpecificID"} == 931) {
    $trap_vals->{"1.3.6.1.2.1.2.2.1.2." . $ifnum} =~ m|^POS3/(\d+)\s*$|;
    push @vals, ($1,"","");
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.3.1.1.1." . $ifnum};
    push @vals, ("","","",""); 
    push @vals, ("","","",""); 
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.3.1.1.2." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.3.1.1.3." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.3.1.1.5." . $ifnum};
    push @vals, $trap_vals->{"1.3.6.1.2.1.10.39.1.3.1.1.4." . $ifnum};
    push @vals, ("","","",""); 
  }

  return @vals;
}  



sub processTrap
{
  my ($trap_vals) = @_;
  
  my @xx = &build_insert_array($trap_vals);
  
  if(   $trap_vals->{SpecificID} eq "902"
     || $trap_vals->{SpecificID} eq "930"
     || $trap_vals->{SpecificID} eq "931"
     || $trap_vals->{SpecificID} eq "932"
     || $trap_vals->{SpecificID} eq "933"
     || $trap_vals->{SpecificID} eq "937"
     || $trap_vals->{SpecificID} eq "936") {
    &display_SQL(\%statements, "InsertTrap", @xx) if($debug >= 2);
    &execute_SQL($statements{"InsertTrap"}, @xx);
    return;
  }
  
  print "Trap received at: " . localtime() . "\n";
  
  foreach my $x (keys %{$trap_vals}) {
    print "$x --> " . $trap_vals->{$x} . "\n";
  }
  
  print "------------------------\n\n\n\n";
  
}

sub display_SQL
{
  my ($statements, $method, @args) = @_;

  my $sql = $statements->{$method}{statement};

  print "pre: $sql\n";
  print "@args\n";

  for(my $i = 0; $i < @args; $i++) {
    $sql =~ s/\?/$args[$i]/;
  }

  print "sql: $sql\n";
}


sub execute_SQL
{
  my ($state, @args) = @_;

  for(my $i = 0; $i < @{$state->{datatypes}}; $i++) {
    print "$i - $args[$i] - " . $state->{datatypes}[$i] . "\n" if($debug >= 3);
    $state->{handle}->bind_param($i + 1, $args[$i], $state->{datatypes}[$i]);
  }

  print "Statement: " . $state->{handle}->{Statement} . "\n" if($debug >= 2);
  print join("|", @args), "\n" if($debug >= 2);

  $state->{handle}->execute;
}

