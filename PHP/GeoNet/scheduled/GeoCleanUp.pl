#!/usr/bin/perl
use DBI;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = $config->getAttribute("DebugLevel") || 0;

eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
my $dbh;

eval("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"GeoNet\", \$debug);");


$|=1 if($debug >= 1); #Set 1 to flush (for tailing the log file)

print "GeoCleanUp running at: " . localtime() . "\n";

`/work/WADappl/Projects/GeoNet/scheduled/GeoControl stop`;
sleep 10;
`/work/WADappl/Projects/GeoNet/scheduled/GeoControl start`;
sleep 300;
$dbh->Delete("alarm", "cause = 'COM' and timeentered > SYSDATE - 1");

exit;

