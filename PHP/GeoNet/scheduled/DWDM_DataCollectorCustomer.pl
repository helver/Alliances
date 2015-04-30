#!/usr/bin/perl

use Time::Local;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;

my $projectName = "GeoNet";
my $config = ConfigFileReader->new("GeoNet");

use lib ".";
use SubmittorSockWrapper;
use PM_Collector;

# get the parameters
my ($customer_id, $debug) = @ARGV;

$|=1 if($debug >= 1); #Flush output to log immediately

# used for debugging
$debug = $config->getAttribute("DebugLevel") unless (defined $debug);

if ($debug >= 0)
{
  print($config->getAttribute("DatabaseDriver") . "\n");
  print("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"$projectName\", $debug);\n");
}

eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
my $dbh;
eval("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"$projectName\", $debug);");
print "Error: $@\n" if($@);



my $sock = SubmittorSockWrapper->new($config, $debug);

my $res = $dbh->Select("distinct tfm.tid_id", "tid_facility_map tfm, facilities f",
    "tfm.facility_id = f.id and f.customer_id = $customer_id");
my @collectors = ();

for (my $i=0; $res->[$i]; $i++)
{
  my $tid_id = $res->[$i]{0};
  print($res->[$i]{0} . "\n") if ($debug >= 0);
  push(@collectors, new PM_Collector($sock, $tid_id, $config, $debug));
}

while (1)
{
  for (my $i=0; $collectors[$i]; $i++)
  {
    $collectors[$i]->collector_loop(1);
    print($i . " out of the loop\n") if ($debug >= 0);
  }
}

print("Exiting\n") if ($debug >= 1);
exit;

