#!/usr/bin/perl

use Time::Local;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

use lib ".";
use SubmittorSockWrapper;
use RequestorSockWrapper;
use PM_Collector;

# used for debugging
our $debug = $config->getAttribute("DebugLevel") || 0;

if($ARGV[0] =~ /^-d=(\d+)/) {
  $debug = $1;
  shift;
}

# get the parameters
my $tid =  shift || undef;

# the script runs constantly
my $iterativeMode = 1;

$iterativeMode = 0 if (defined $tid && $tid ne "");

$debug = ($debug > 4 ? $debug : 4) if (defined $tid && $tid ne "");

$|=1 if($debug >= 1); #Flush output to log immediately

my $sock = SubmittorSockWrapper->new($config, $debug);
my $reqsock = RequestorSockWrapper->new($config, $debug);
my $collector = new PM_Collector($sock, $reqsock, $config, $debug);

$collector->collector_loop($iterativeMode, $tid);

print("Exiting\n") if ($debug >= 1);
exit;

