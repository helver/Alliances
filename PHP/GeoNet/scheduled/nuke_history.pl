#!/usr/bin/perl
use DBI qw(:sql_types);
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = $config->getAttribute("DebugLevel") || 1;

eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
my $qdbh;

eval("\$qdbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\"geonet\", \"tenoeg\", \"localhost\", \"GEONET\", \$debug);");
print $@ if $@;

my $dbh = (values %{$qdbh->{"theDB"}})[0];

$|=1 if($debug >= 1); #Set 1 to flush (for tailing the log file)

$dbh->{PrintError} = "on";
$dbh->{RaiseError} = "off";

my %statements;

$statements{"DelID"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_INTEGER,SQL_VARCHAR],
  "statement" =>
    "DELETE FROM pm_history "
  . " WHERE tid_id = ? and interface_id = ? and timeentered < to_date(?, 'MM/DD/YYYY HH24:MI:SS')"};
$statements{"DelID"}->{"handle"} = $dbh->prepare($statements{"DelID"}->{"statement"});

print "Checking DelID: " . $statements{DelID}->{handle} . "\n" if($debug >= 1);


$statements{"GetIDs"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER],
  "statement" =>
    "SELECT interface_id, to_char(MAX(timeentered), 'MM/DD/YYYY HH24:MI:SS')"
  . " FROM pm_history"
  . " WHERE tid_id = ? and timeentered <= SYSDATE - " . $config->getAttribute("DaysOfHistoryToKeep") . " GROUP BY interface_id"};
$statements{"GetIDs"}->{"handle"} = $dbh->prepare($statements{"GetIDs"}->{"statement"});

print "Checking GetIDs: " . $statements{GetIDs}->{handle} . "\n" if($debug >= 1);


$statements{"GetTIDs"} = {
  "select" => 1,
  "datatypes" => [],
  "statement" =>
    "SELECT id FROM tids order by id"};
$statements{"GetTIDs"}->{"handle"} = $dbh->prepare($statements{"GetTIDs"}->{"statement"});

print "Checking GetTIDs: " . $statements{GetTIDs}->{handle} . "\n" if($debug >= 1);

my $tids = &execute_SQL($statements{"GetTIDs"});

for(my $k = 0; $tids->[$k]; $k++) {
  my $tidid = $tids->[$k][0];

  print "Executing GetIDs for $tidid at " . $config->getAttribute("DaysOfHistoryToKeep") . "\n" if($debug >= 1);

  my $res = &execute_SQL($statements{"GetIDs"}, $tidid);

  print "Done executing GetIDs for $tidid\n" if($debug >= 1);

  for(my $i = 0; $res->[$i]; $i++) {
    print "Deleting tid_historyid " . $res->[$i][0] . "\n" if($debug >= 1);
    &execute_SQL($statements{"DelID"}, $tidid, $res->[$i][0], $res->[$i][1]);
  }
  
  sleep 2 unless($k % 10);
}

$qdbh->Close();


sub execute_SQL
{
  my ($state, @args) = @_;

  for(my $i = 0; $i < @{$state->{datatypes}}; $i++) {
    print "$i - $args[$i] - " . $state->{datatypes}[$i] . "\n" if($debug >= 3);
    $state->{handle}->bind_param($i + 1, $args[$i], $state->{datatypes}[$i]);
  }

  if($debug >= 3) {
    print "Statement: " . $state->{handle}->{Statement} . "\n";
    print join("|", @args), "\n";

    &display_SQL($state, @args);
  }

  $state->{handle}->execute if($debug <= 1);

  if($state->{handle}->{err}) {
    print "Error executing statement: " . $state->{handle}->{errstr} . "\n";
    return;
  }

  if($state->{select}) {
    my @rows;

    while (my @row = $state->{handle}->fetchrow_array()) {
      #print "row: @row\n";
      push @rows, \@row;
    }

    return \@rows;
  }

}

sub display_SQL
{
  my ($statements, @args) = @_;

  my $sql = $statements->{statement};

  print "pre: $sql\n";
  print "@args\n";

  for(my $i = 0; $i < @args; $i++) {
    $sql =~ s/\?/$args[$i]/;
  }

  print "sql: $sql\n";
}

