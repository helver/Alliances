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

$statements{"GetInterfaceInfoByTID"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER, SQL_INTEGER],
  "statement" =>
    "SELECT *"
  . " FROM interface_info_by_tid_view"
  . " WHERE (tid_id = ? or ring_id = ?)"
  . " order by tid_id, interface_id"};
$statements{"GetInterfaceInfoByTID"}->{"handle"} = $dbh->prepare($statements{"GetInterfaceInfoByTID"}->{"statement"});
print "Checking GetInterfaceInfoByTID: " . $statements{GetInterfaceInfoByTID}->{handle} . "\n" if($debug >= 1);




$statements{"GetInterfaceTypeInfo"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER],
  "statement" =>
    "SELECT *"
  . " FROM interface_type_info_view"
  . " WHERE interface_type = ?"};
$statements{"GetInterfaceTypeInfo"}->{"handle"} = $dbh->prepare($statements{"GetInterfaceTypeInfo"}->{"statement"});
print "Checking GetInterfaceTypeInfo: " . $statements{GetInterfaceTypeInfo}->{handle} . "\n" if($debug >= 1);




$statements{"GetTotals"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER, SQL_INTEGER],
  "statement" =>
    "SELECT *"
  . " FROM pm_totals_view"
  . " WHERE tid_id = ? AND interface_id = ?"};
$statements{"GetTotals"}->{"handle"} = $dbh->prepare($statements{"GetTotals"}->{"statement"});
print "Checking GetTotals: " . $statements{GetTotals}->{handle} . "\n" if($debug >= 1);




$statements{"GetNextTID"} = {
  "select" => 1,
  "datatypes" => [],
  "statement" =>
    "SELECT get_next_tid() FROM DUAL"};
$statements{"GetNextTID"}->{"handle"} = $dbh->prepare($statements{"GetNextTID"}->{"statement"});

# to repopulate it:
# execute populate_tid_queue;

print "Checking GetNextTID: " . $statements{GetNextTID}->{handle} . "\n" if($debug >= 1);



$statements{"ShiftPreviousTID"} = {
  "select" => 1,
  "datatypes" => [SQL_VARCHAR],
  "statement" =>
    "SELECT shift_tid_queue(?) FROM DUAL"};
$statements{"ShiftPreviousTID"}->{"handle"} = $dbh->prepare($statements{"ShiftPreviousTID"}->{"statement"});

# to repopulate it:
# execute populate_tid_queue;

print "Checking ShiftPreviousTID: " . $statements{ShiftPreviousTID}->{handle} . "\n" if($debug >= 1);

# ---------------------------------------------------------
# End of SQL Definitions
# ---------------------------------------------------------



my $proxy_service = new DB_Proxy_Service(
      \%statements, 
      $config->getAttribute("RequestorPort"),
      $config->getAttribute("Requestor_CycleTime"),
      $config->getAttribute("LogDir") . "/Requestor.pid",
      $debug
  );
  
$proxy_service->server_loop();


$dbi->Close;
print("Exiting\n") if ($debug >= 1);

exit;
