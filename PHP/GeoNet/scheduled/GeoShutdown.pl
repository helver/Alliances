#!/usr/bin/perl
use DBI;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = $config->getAttribute("DebugLevel") || 0;

my $auto = $ARGV[0];

eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
my $dbh;

eval("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"GeoNet\", \$debug);");

$|=1 if($debug >= 1); #Set 1 to flush (for tailing the log file)

my @actives=`/work/WADappl/Projects/GeoNet/scheduled/Geo`;

foreach $active (@actives)
{
  if ($active =~/^\s*([0-9]+)\s+.*(DWDM_DataCollector)/)
  {
    #my $pid=substr($active,0,5);
    my $pid = $1;
    print ("$active: kill $pid\n");
    kill KILL, $pid;
  }
}

$dbh->Delete("tid_queue", "active = 1");

if($auto != 1) {
	print "Doing log rotation\n";
	rename("logs/Watchdog.log", "logs/Watchdog.log." . time());
}