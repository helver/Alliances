#!/usr/bin/perl

# DWDM_DataSubmittor.pl is a TCP/IP based database access process.  All of 
# the DWDM_DataCollector processes invoke their database requests through 
# the Submittor.  It works by opening a single database connection and 
# preparing all possible database statements.  When a request is received, 
# the appropriate statement is already prepared, the new parameters are 
# bound to the statement, and the statement is executed again.  This 
# provides a significant performance improvement, reduces the load on the 
# database and reduces the liklihood that we'll have multiple quries 
# running at the same time.

use strict;
use DBI qw(:sql_types);

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

use lib ".";
use DB_Proxy_Service;

# used for debugging
our ($debug) = @ARGV;

$debug = $config->getAttribute("DebugLevel") unless defined $debug;

my $dbi;
eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
eval("\$dbi = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"GeoNet\", $debug);");

my $dbh = $dbi->{"theDB"}{(keys %{$dbi->{"theDB"}})[0]};
$dbh->{PrintError} = "on";
$dbh->{RaiseError} = "off";

$|=1 if($debug >= 1);


# ---------------------------------------------------------
# Start of SQL Definitions
# ---------------------------------------------------------


my %statements;

$statements{"UpdateError"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_VARCHAR,SQL_INTEGER],
  "statement" =>
    "UPDATE tids_to_update_view "
  . "SET status = -1, flag = ?, cause = ? "
  . "WHERE tid_id = ?"};
$statements{"UpdateError"}->{"handle"} = $dbh->prepare($statements{"UpdateError"}->{"statement"});
print "Checking UpdateError: " . $statements{UpdateError}->{handle} . "\n" if($debug >= 1);




$statements{"UpdatePMInfo"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_VARCHAR,SQL_VARCHAR,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "UPDATE pm_info "
  . "SET status = ?, timeEntered = SYSDATE, cause = ?, agent = ?, trapnum = ?, "
  . "c1 = ?, c2 = ?, c3 = ?, c4 = ?, c5 = ?, c6 = ?, c7 = ?, c8 = ?, c9 = ?, c10 = ?, "
  . "a1 = ?, a2 = ?, a3 = ?, a4 = ?, a5 = ?, a6 = ?, a7 = ?, a8 = ?, a9 = ?, a10 = ? "
  . "WHERE tid_id = ? and interface_id = ?"};
$statements{"UpdatePMInfo"}->{"handle"} = $dbh->prepare($statements{"UpdatePMInfo"}->{"statement"});
print "Checking UpdatePMInfo: " . $statements{UpdatePMInfo}->{handle} . "\n" if($debug >= 1);



# ---------------------------------------------------------
# End of SQL Definitions
# ---------------------------------------------------------



my $proxy_service = new DB_Proxy_Service(
      \%statements, 
      $config->getAttribute("SubmittorPort"),
      $config->getAttribute("Submittor_CycleTime"),
      $config->getAttribute("LogDir") . "/Submittor.pid",
      $debug
  );
  
$proxy_service->server_loop();


$dbi->Close;
print("Exiting\n") if ($debug >= 1);

exit;
