#!/usr/local/bin/perl

#use lib "c:/eric/site/lib";

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


$statements{"LookupTID"} = {
  "select" => 1,
  "datatypes" => [SQL_VARCHAR,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "SELECT tidid, tid, ipaddress, slot_transmitter, facilityid, receive_channelid,"
  . " slot_receiver, cityid"
  . " FROM tid "
  . " WHERE tid = ? and shelf = ? and (channel = ? OR (? IS NULL AND channel IS NULL))"};
$statements{"LookupTID"}->{"handle"} = $dbi->prepare($statements{"LookupTID"}->{"statement"});

print "Checking LookupTID: " . $statements{LookupTID}->{handle} . "\n" if($debug >= 1);


$statements{"UpdateTIDInfo"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_INTEGER,SQL_VARCHAR,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "UPDATE tid"
  . " SET cityid = ?, element_typeid = ?, timeentered = SYSDATE,"
  . " flag = ?, facilityid = NULL, deleted = NULL "
  . " WHERE tidid = ? and shelf = ? and (channel = ? OR (? IS NULL AND channel IS NULL))"};
$statements{"UpdateTIDInfo"}->{"handle"} = $dbi->prepare($statements{"UpdateTIDInfo"}->{"statement"});

print "Checking UpdateTIDInfo: " . $statements{UpdateTIDInfo}->{handle} . "\n" if($debug >= 1);


$statements{"UpdateError"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_VARCHAR,SQL_INTEGER],
  "statement" =>
    "UPDATE tid "
  . "SET flag = ?, transmit_cv = -1, transmit_es = -1, "
  . "transmit_ses = -1, transmit_uas = -1, receive_cv = -1, receive_es = -1, "
  . "receive_ses = -1, receive_uas = -1, cause = ?, connect_attempt = MOD(connect_attempt + 1, 100) "
  . "WHERE tidid = ?"};
$statements{"UpdateError"}->{"handle"} = $dbi->prepare($statements{"UpdateError"}->{"statement"});

print "Checking UpdateError: " . $statements{UpdateError}->{handle} . "\n" if($debug >= 1);


$statements{"GetEchoStarCounts"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER],
  "statement" =>
    "SELECT flag, cause, total_transmit_cv, total_transmit_es, total_transmit_ses, total_transmit_uas,"
  . " to_char(timeentered, 'MM/DD/YYYY HH24:MI:SS') as last_date,"
  . " to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') as now"
  . " FROM tid "
  . " WHERE tidid = ?"};
$statements{"GetEchoStarCounts"}->{"handle"} = $dbi->prepare($statements{"GetEchoStarCounts"}->{"statement"});

print "Checking GetEchoStarCounts: " . $statements{GetEchoStarCounts}->{handle} . "\n" if($debug >= 1);



$statements{"GetTotals"} = {
  "select" => 1,
  "datatypes" => [SQL_INTEGER],
  "statement" =>
    "SELECT total_transmit_CV, total_transmit_ES, total_transmit_SES,"
  . " total_transmit_UAS, total_receive_CV, total_receive_ES, total_receive_SES,"
  . " total_receive_UAS"
  . " FROM tid"
  . " WHERE tidid = ?"};
$statements{"GetTotals"}->{"handle"} = $dbi->prepare($statements{"GetTotals"}->{"statement"});


print "Checking GetTotals: " . $statements{GetTotals}->{handle} . "\n" if($debug >= 1);


$statements{"UpdateFacilityTNT"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_VARCHAR],
  "statement" =>
    "UPDATE facility "
  . "SET testandturnupid = ? "
  . "WHERE facility = ?"};
$statements{"UpdateFacilityTNT"}->{"handle"} = $dbi->prepare($statements{"UpdateFacilityTNT"}->{"statement"});

print "Checking UpdateFacilityTNT: " . $statements{UpdateFacilityTNT}->{handle} . "\n" if($debug >= 1);



$statements{"InsertFacility"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_INTEGER,SQL_VARCHAR],
  "statement" =>
    "INSERT into facility "
  . "select seq_facilityid.nextval, ?, ?, customer.customerid "
  . "from customer "
  . "where upper(customer) = upper(?)"};
$statements{"InsertFacility"}->{"handle"} = $dbi->prepare($statements{"InsertFacility"}->{"statement"});

print "Checking InsertFacility: " . $statements{InsertFacility}->{handle} . "\n" if($debug >= 1);


$statements{"LookupFacility"} = {
  "select" => 1,
  "datatypes" => [SQL_VARCHAR],
  "statement" =>
    "SELECT facilityid "
  . "FROM facility "
  . "WHERE facility = ?"};
$statements{"LookupFacility"}->{"handle"} = $dbi->prepare($statements{"LookupFacility"}->{"statement"});

print "Checking LookupFacility: " . $statements{LookupFacility}->{handle} . "\n" if($debug >= 1);



$statements{"UpdateTID"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_VARCHAR,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER],
  "statement" =>
    "UPDATE tid "
  . "SET flag = ?, timeEntered = SYSDATE, connect_attempt = null, cause = ?, "
  . "deleted = NULL, transmit_CV = ?, transmit_ES = ?, transmit_SES = ?, "
  . "transmit_UAS = ?, receive_CV = ?, receive_ES = ?, "
  . "receive_SES = ?, receive_UAS  = ?, "
  . "total_transmit_CV = ?, total_transmit_ES = ?, total_transmit_SES = ?, "
  . "total_transmit_UAS = ?, total_receive_CV = ?, total_receive_ES = ?, "
  . "total_receive_SES = ?, total_receive_UAS  = ? "
  . "WHERE tidid = ?"};
$statements{"UpdateTID"}->{"handle"} = $dbi->prepare($statements{"UpdateTID"}->{"statement"});

print "Checking UpdateTID: " . $statements{UpdateTID}->{handle} . "\n" if($debug >= 1);



$statements{"InsertTID"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_VARCHAR,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "INSERT INTO tid "
  . "(tidid, tid, ipaddress, slot_transmitter, facilityid, timeentered, "
  . " receive_channelid, cityid, element_typeid, "
  . " shelf, channel, slot_receiver, flag) "
  . "SELECT seq_tidid.nextval, ?, ?, ?, NULL, SYSDATE, ?, ?, ?, ?, ?, ?, 't' "
  . "FROM dual"};
$statements{"InsertTID"}->{"handle"} = $dbi->prepare($statements{"InsertTID"}->{"statement"});

print "Checking InsertTID: " . $statements{InsertTID}->{handle} . "\n" if($debug >= 1);



$statements{"BuildElementMap"} = {
  "select" => 1,
  "datatypes" => [],
  "statement" =>
    "SELECT element_type.element_type as type, element_type.element_typeid as id, "
  . "protocol.protocol as proto "
  . "FROM protocol, element_type "
  . "WHERE element_type.protocolid = protocol.protocolid"};
$statements{"BuildElementMap"}->{"handle"} = $dbi->prepare($statements{"BuildElementMap"}->{"statement"});

print "Checking BuildElementMap: " . $statements{BuildElementMap}->{handle} . "\n" if($debug >= 1);


$statements{"BuildCityMap"} = {
  "select" => 1,
  "datatypes" => [],
  "statement" =>
    "SELECT cityid, tid "
  . "FROM city"};
$statements{"BuildCityMap"}->{"handle"} = $dbi->prepare($statements{"BuildCityMap"}->{"statement"});

print "Checking BuildCityMap: " . $statements{BuildCityMap}->{handle} . "\n" if($debug >= 1);




$statements{"InsertTIDHistory"} = {
  "select" => 0,
  "datatypes" => [SQL_VARCHAR,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_VARCHAR,SQL_INTEGER,
                  SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,
                 ],
  "statement" =>
    "INSERT INTO tid_history "
  . "(  TID_historyid, tidid, TID, ipaddress, shelf, Channel, "
  . "   Slot_Transmitter, Slot_Receiver, Receive_Channelid, "
  . "   Facilityid, "
  . "   cityid, element_typeid, timeentered, flag, transmit_CV, "
  . "   transmit_ES, transmit_SES, transmit_UAS, receive_CV, "
  . "   receive_ES, receive_SES, receive_UAS, source"
  . ") "
  . "SELECT "
  . "  seq_tid_historyid.nextval, tidid, tid, ipaddress, shelf, "
  . "  channel, slot_transmitter, slot_receiver, receive_channelid, "
  . "  facilityid, cityid, "
  . "  element_typeid, sysdate, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'EDB' "
  . "from tid "
  . "where tidid = ? and "
  . "( flag <> ? or "
  . "  transmit_SES is null or transmit_SES <> ? or "
  . "  transmit_UAS is null or transmit_UAS <> ? or "
  . "  receive_CV is null or receive_CV <> ? or "
  . "  receive_ES is null or receive_ES <> ? or "
  . "  receive_SES is null or receive_SES <> ? or "
  . "  receive_UAS is null or receive_UAS <> ? or "
  . "  0 = ?"
  . ")"};
$statements{"InsertTIDHistory"}->{"handle"} = $dbi->prepare($statements{"InsertTIDHistory"}->{"statement"});

print "Checking InsertTIDHistory: " . $statements{InsertTIDHistory}->{handle} . "\n" if($debug >= 1);


$statements{"InsertLastTIDHistory"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER],
  "statement" =>
    "INSERT INTO tid_history "
  . "(  TID_historyid, tidid, TID, ipaddress, shelf, Channel, "
  . "   Slot_Transmitter, Slot_Receiver, Receive_Channelid, "
  . "   cityid, element_typeid, timeentered, flag, transmit_CV, "
  . "   transmit_ES, transmit_SES, transmit_UAS, receive_CV, "
  . "   receive_ES, receive_SES, receive_UAS, source"
  . ") "
  . "SELECT "
  . "  seq_tid_historyid.nextval, tidid, tid, ipaddress, shelf, "
  . "  channel, slot_transmitter, slot_receiver, receive_channelid, "
  . "  cityid, "
  . "  element_typeid, timeentered, flag, transmit_CV, "
  . "  transmit_ES, transmit_SES, transmit_UAS, receive_CV, "
  . "  receive_ES, receive_SES, receive_UAS, 'EDB' "
  . "from tid "
  . "where tidid = ? and flag <> 'e'"};
$statements{"InsertLastTIDHistory"}->{"handle"} = $dbi->prepare($statements{"InsertLastTIDHistory"}->{"statement"});

print "Checking InsertLastTIDHistory: " . $statements{InsertLastTIDHistory}->{handle} . "\n" if($debug >= 1);






$statements{"UpdateIFNum"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "UPDATE tid "
  . "SET slot_receiver = ? "
  . "WHERE tidid = ?"};
$statements{"UpdateIFNum"}->{"handle"} = $dbi->prepare($statements{"UpdateIFNum"}->{"statement"});

print "Checking UpdateIFNum: " . $statements{UpdateIFNum}->{handle} . "\n" if($debug >= 1);


$statements{"UpdateFacilityMap"} = {
  "select" => 0,
  "datatypes" => [SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER,SQL_INTEGER],
  "statement" =>
    "INSERT INTO facility_map "
  . "SELECT ?, ?, ? FROM dual WHERE ? not in "
  . "(SELECT facilityid FROM facility_map WHERE tidid = ?)"};
$statements{"UpdateFacilityMap"}->{"handle"} = $dbi->prepare($statements{"UpdateFacilityMap"}->{"statement"});

print "Checking UpdateFacilityMap: " . $statements{UpdateFacilityMap}->{handle} . "\n" if($debug >= 1);





my $build_report = 0;


my %element_map = &build_element_map(\%statements);
my %city_map = &build_city_map(\%statements);



$config->{attrs}{"DatabaseHost"} = "ntac2.oss.sprint.com";
$config->{attrs}{"DatabaseSID"} = "NTACCM";
my $dbh = DBWrapper::OCI_DBWrapper->new($config, "NTACCM", $debug);

my $circuits = &pull_circuit_list($dbh, \%statements);


my ($workbook,$worksheet,$rowcount) = &set_up_report() if($build_report);

my $clli;
my $lookup_cache;
my $counter = 0;

while($counter == 0 || $debug <= 6) {
  my $start = time();

  unless($debug) {
    open (FH, "> " . $config->getAttribute("LogDir") . "/EchoStar.pid") or
      die "Can't open EchoStar.pid file: $!\n";
    print FH "$$\n$start\n";
    close FH;
  }

  for(my $i = 0; $circuits->[$i]; $i++) {
    if($clli ne $circuits->[$i]{"clli"}) {
      $clli = $circuits->[$i]{"clli"};
      undef $lookup_cache;
    }

    my $model = $circuits->[$i]{"vendor"} . " " . $circuits->[$i]{"model"};

    if($element_map{$model}) {
      print ($circuits->[$i]{"clli"} . ", " . $circuits->[$i]{"port"} . ", " . $circuits->[$i]{"ip"} . "\n") if($debug >= 1);

      undef $!;
      eval("&" . $element_map{$model}{"request"} . "(\\\%statements, \$circuits->[\$i], \$circuits->[\$i-1], \\\$lookup_cache, \$counter);");
      print "$@\n" if ($@);
      die "$@\n" if ($debug >= 1 && $@);

    } else {
      print "No protocol for $model elements.\n";
    }
  }

  my $end = time();
  my $interval = $config->getAttribute("EchoStar_CycleTime");

  print "Elapsed Time: " . ($end - $start) . "\n";

  my $sleeptime = (($start - $end + $interval) > 0 ? ($start - $end + $interval) : 0);

  print "Going to sleep for $sleeptime seconds.\n";

  sleep ($sleeptime) if($debug <= 6);

  if(++$counter >= 61) {
    $circuits = &pull_circuit_list($dbh, \%statements);

    %element_map = &build_element_map(\%statements);
    %city_map = &build_city_map(\%statements);

    $counter = 1;
  }
}

$workbook->close() if($build_report);


exit;



sub pull_circuit_list
{
  my ($dbh, $statements) = @_;

  my $where = ($debug >= 6 ? "spid = 10006567" : "");

  my $subsub = $dbh->Select("nvc_id as spid, status", "echostar", $where, "fms_circuit_id, status");

  foreach(my $i = 0; $subsub->[$i]; $i++) {
    print "About to UpdateFacilityTNT\n" if($debug >= 5);
    &execute_SQL($statements->{UpdateFacilityTNT}, ($subsub->[$i]{"status"} eq "In-Service" ? 2 : 1), $subsub->[$i]{spid});
    print "Done with UpdateFacilityTNT\n" if($debug >= 5);
  }

  my $circuits = $dbh->Select("unique port, clli_cd as clli, vendor, model_mbr as model, ip, nvc_id as spid, status, customer, seq_nbr as seq, xmit_rate, rcvd_rate",
                              "echostar", $where, "clli, port");

  return $circuits;
}

sub requestSkip
{
  my ($statements, $row, $lastrow, $lookup_cache, $counter) = @_;

  print "In requestSkip for " . $row->{"vendor"} . " " . $row->{"clli"} . "<br>\n" if($debug >= 1);

  my $facid = &get_facilityid($statements, $row->{"spid"}, $row->{"status"}, $row->{"customer"});

  if($row->{"port"} == "") {
    $row->{"port"} = 1;
  }

  my $port_clause;

  if($row->{"port"} =~ /[A-Za-z]/) {
    ($row->{"port"}, $row->{"channel"}) = &_get_port_translated($row->{"port"});
  } else {
    $port_clause = " and shelf = " . $row->{"port"};
  }

  print "About to LookupTID\n" if($debug >= 5);
  my ($res) = &execute_SQL($statements->{LookupTID}, $clli, $row->{"port"}, $row->{"channel"}, $row->{"channel"});
  print "Done with LookupTID\n" if($debug >= 5);

  if($res->[0]) {
    print "model: " . $row->{"vendor"} ." ". $row->{"model"} . "<br>\n" if ($debug >= 3);
    print "About to UpdateTIDInfo\n" if($debug >= 5);
    &execute_SQL($statements->{UpdateTIDInfo},
      ($city_map{substr($row->{"clli"}, 0, 6)} ? $city_map{substr($row->{"clli"}, 0, 6)} : undef),
      $element_map{$row->{"vendor"} ." ". $row->{"model"}}{"id"},
      "t", -1, $res->[0], $row->{"port"}, $row->{"channel"}, $row->{"channel"});
    print "Done with UpdateTIDInfo\n" if($debug >= 5);

    print "About to UpdateFacilityMap\n" if($debug >= 5);
    my ($res) = &execute_SQL($statements->{UpdateFacilityMap}, $res->[0], $facid, $row->{"seq"}, $facid, $res->[0]);
    print "Done with UpdateFacilityMap\n" if($debug >= 5);

  } else {

    print "About to InsertTID\n" if($debug >= 5);
    &execute_SQL($statements->{InsertTID}, $row->{"clli"}, $row->{"ip"}, 0, 0,
                 ($city_map{substr($row->{"clli"}, 0, 6)} ? $city_map{substr($row->{"clli"}, 0, 6)} : undef),
                 $element_map{$row->{"vendor"} ." ". $row->{"model"}}{"id"},
                 $row->{"port"}, $row->{"channel"}, 0);
    print "Done with InsertTID\n" if($debug >= 5);
  }

  return;
}




sub requestASX_SNMP
{
  my ($statements, $row, $lastrow, $lookup_cache, $counter) = @_;

  print "In requestASX_SNMP for " . $row->{"vendor"} . " " . $row->{"clli"} . "<br>\n" if($debug >= 1);

  my $facid = &get_facilityid($statements, $row->{"spid"}, $row->{"status"}, $row->{"customer"});

  my %hop;

  my %if_type_mapping = ( "30" => "_lookup_ds3_status",
                          "50" => "_lookup_sonet_status",
                          "18" => "_lookup_ds1_status",
                        );

  my $sess = SNMPWrapper->new($row->{"ip"}, $debug, "public");

  print "Port ID: " . &_build_port_oid($row->{"port"}) . "\n" if($debug >= 3);

  my $tidid = &get_tidid($statements, $sess, $row->{"clli"}, $row->{"ip"}, $row->{"port"},
                         $row->{"vendor"} . " " . $row->{"model"}, -1, $lookup_cache);

  print "About to UpdateFacilityMap\n" if($debug >= 5);
  my ($res) = &execute_SQL($statements->{UpdateFacilityMap}, $tidid->{"tidid"}, $facid, $row->{"seq"}, $facid, $tidid->{"tidid"});
  print "Done with UpdateFacilityMap\n" if($debug >= 5);

  return if($lastrow && $row->{"clli"} eq $lastrow->{"clli"} && $row->{"port"} eq $lastrow->{"port"});

  @hop{("port_xmit","port_rcvd","hw_loc")} = &_lookup_port_info($sess, $tidid->{"port_num"});

  if($tidid->{"if_type"} == 30) {
    &_check_if_num($statements,$sess,$tidid);
    $hop{"if_status"} = &_lookup_ds3_status($sess, $tidid->{"if_num"});

    unless($hop{"if_status"} >= 1) {
      print "About to InsertLastTIDHistory\n" if($debug >= 5);
      &execute_SQL($statements->{InsertLastTIDHistory}, $tidid->{"tidid"});
      print "Done with InsertLastTIDHistory\n" if($debug >= 5);

      print "About to UpdateError\n" if($debug >= 5);
      &execute_SQL($statements->{UpdateError}, "e", "COM", $tidid->{"tidid"});
      print "Done with UpdateError\n" if($debug >= 5);

      die "Error: " . $sess->getErrorMessage() . "\n";
    }

  } elsif ($tidid->{"if_type"} == 50) {
    @hop{("section_status", "line_status", "path_status")} = &_lookup_sonet_status($sess, $hop{"hw_loc"});

    unless($hop{"section_status"} >= 1) {
      print "About to InsertLastTIDHistory\n" if($debug >= 5);
      &execute_SQL($statements->{InsertLastTIDHistory}, $tidid->{"tidid"});
      print "Done with InsertLastTIDHistory\n" if($debug >= 5);

      print "About to UpdateError\n" if($debug >= 5);
      &execute_SQL($statements->{UpdateError}, "e", "COM", $tidid->{"tidid"});
      print "Done with UpdateError\n" if($debug >= 5);

      die "Error: " . $sess->getErrorMessage() . "\n";
    }

  }

  $sess->Close();

  print "About to GetEchoStarCounts\n" if($debug >= 5);
  my ($old_stats) = &execute_SQL($statements->{GetEchoStarCounts}, $tidid->{tidid});
  print "Done with GetEchoStarCounts\n" if($debug >= 5);

  my %old_stat;

  @old_stat{("flag","cause","total_transmit_cv", "total_transmit_es", "total_transmit_ses", "total_transmit_uas", "last_date", "now")} = @{$old_stats};

  my $last_date = &UnixDate(&ParseDate($old_stat{"last_date"}), "%s");
  my $cur_date = &UnixDate(&ParseDate($old_stat{"now"}), "%s");

  my $time_diff = $cur_date - $last_date;

  my $xmit_rate = &_get_rate($old_stat{"total_transmit_cv"}, $hop{"port_xmit"}, $time_diff);
  my $rcvd_rate = &_get_rate($old_stat{"total_transmit_es"}, $hop{"port_rcvd"}, $time_diff);

  $old_stat{"total_transmit_ses"} = $row->{xmit_rate} if($row->{xmit_rate} > -1);
  $old_stat{"total_transmit_uas"} = $row->{rcvd_rate} if($row->{rcvd_rate} > -1);

  my ($flag, $cause) = ($old_stat{"flag"}, $old_stat{"cause"});

  if($row->{xmit_rate} > -1 && $row->{rcvd_rate} > -1) {
    $flag = "g";
    $cause = "";
  }

  if($flag eq 'e' || $flag eq "" || $flag eq 'i' || $flag eq 't') {
    $flag = 'g';
    $cause = "Conn Estbd";
  }

  my ($xflag, $rflag) = (0,0);

  if($row->{xmit_rate} == -2) {
    if($old_stat{"total_transmit_cv"} < $hop{"port_xmit"}) {
      $flag = 'g';
    } else {
      $flag = 'r';
      $cause = 'XMIT Rate';
    }
  } else {
    if(&_get_rate_change($old_stat{"total_transmit_ses"}, $xmit_rate) >= 5) {
      $flag = 'r';
      $cause = 'XMIT Rate';
      $xflag = -1;
    }
    if(&_get_rate_change($xmit_rate, $old_stat{"total_transmit_ses"}) >= 5) {
      $flag = 'g';
      $cause = 'XMIT Rate';
      $xflag = 1;
    }
  }


  if($row->{rcvd_rate} == -2) {
    if($old_stat{"total_transmit_es"} < $hop{"port_rcvd"}) {
      $flag = 'g';
    } else {
      $flag = 'r';
      $cause = 'RCVD Rate';
    }
  } else {
    if(&_get_rate_change($old_stat{"total_transmit_uas"}, $rcvd_rate) >= 5) {
      $flag = 'r';
      $cause = 'RCVD Rate';
      $rflag = -1;
    }
    if(&_get_rate_change($rcvd_rate, $old_stat{"total_transmit_uas"}) >= 5) {
      $flag = 'g';
      $cause = 'RCVD Rate';
      $rflag = 1;
    }
  }

  if($flag eq $old_stat{"flag"}) {
    if($hop{"if_status"} && $hop{"if_status"} != 1) {
      $flag = 'r';
      $cause = 'DS3 Status';
    } elsif($hop{"section_status"} && $hop{"section_status"} != 1) {
      $flag = 'r';
      $cause = 'Sonet Stat';
    } elsif($hop{"line_status"} && $hop{"line_status"} != 1) {
      $flag = 'r';
      $cause = 'Sonet Stat';
    } elsif($hop{"path_status"} && $hop{"path_status"} != 1) {
      $flag = 'r';
      $cause = 'Sonet Stat';
    }
  }

  my @history = ( $flag,
                  $xflag,
                  $rflag,
                  ($hop{"if_status"} ? $hop{"if_status"} : 0),
                  0,
                  ($hop{"section_status"} ? $hop{"section_status"} : 0),
                  ($hop{"line_status"} ? $hop{"line_status"} : 0),
                  ($hop{"path_status"} ? $hop{"path_status"} : 0),
                  0,
                  $tidid->{"tidid"},
                  $flag,
                  ($hop{"if_status"} ? $hop{"if_status"} : 0),
                  0,
                  ($hop{"section_status"} ? $hop{"section_status"} : 0),
                  ($hop{"line_status"} ? $hop{"line_status"} : 0),
                  ($hop{"path_status"} ? $hop{"path_status"} : 0),
                  0,
                  $counter,
                );

  print "About to InsertTIDHistory\n" if($debug >= 5);
  &execute_SQL($statements->{InsertTIDHistory}, @history);
  print "Done with InsertTIDHistory\n" if($debug >= 5);


  my @status = ( $flag,
                 ($cause ? $cause : undef),
                 $xflag,
                 $rflag,
                 ($hop{"if_status"} ? $hop{"if_status"} : 0),
                 0,
                 ($hop{"section_status"} ? $hop{"section_status"} : 0),
                 ($hop{"line_status"} ? $hop{"line_status"} : 0),
                 ($hop{"path_status"} ? $hop{"path_status"} : 0),
                 0,
                 $hop{"port_xmit"},
                 $hop{"port_rcvd"},
                 $xmit_rate,
                 $rcvd_rate,
                 0,0,0,0,
                 $tidid->{"tidid"},
               );

  print "About to UpdateTID\n" if($debug >= 5);
  &execute_SQL($statements->{UpdateTID}, @status);
  print "Done with UpdateTID\n" if($debug >= 5);


  if($build_report) {
    my $j = 0;
    $rowcount++;

    foreach my $field (($row->{"clli"}, $row->{"port"}, $tidid->{"if_type"}, @hop{("port_xmit", "port_rcvd", "if_status", "section_status", "line_status", "path_status")})) {
      $worksheet->write($rowcount, $j, $field);
      $j++;
    }
  }
}



sub _get_rate_change
{
  my ($oldun, $newun) = @_;

  print "Oldun - $oldun, Newun - $newun<br>\n" if($debug >= 3);

  return 1 unless $newun;

  return $oldun/$newun;
}


sub _get_rate
{
  my ($prev, $curr, $timey) = @_;

  return 0 unless $timey;
  return int(($curr - $prev)/$timey);
}

sub _get_port_translated
{
  my ($port) = @_;

  my ($port,$channels) = split /[\[\]]/, $port;

  my @port = split //, $port, 3;

  $port[1] = ord(uc($port[1])) - ord('A');

  $channels =~ s/,//g;

  return (join("", @port), $channels);
}


sub _get_port_clause
{
  my ($port) = @_;

  my ($pt, $ct) = &_get_port_translated($port);

  my $where = " and shelf = $pt";

  $where .= " and channel = $ct" if($ct);

  return $where;
}


sub get_tidid
{
  my ($statements, $sess, $clli, $ip, $port, $model, $facid, $lookup_cache) = @_;

  if($debug >= 3) {
    print("clli - $clli<br>\n");
    print("ip - $ip<br>\n");
    print("port - $port<br>\n");
    print("model - $model<br>\n");
    print("facid - $facid<br>\n");
  }

  my ($shelf, $channel);

  if($port =~ /[A-Za-z]/) {
    ($shelf, $channel) = &_get_port_translated($port);
  } else {
    $shelf = $port;
  }

  my ($res, %retvals);

  print "About to LookupTID\n" if($debug >= 5);
  ($res) = &execute_SQL($statements->{LookupTID}, $clli, $shelf, $channel, $channel);
  print "Done with LookupTID\n" if($debug >= 5);

  if($res->[0]) {
    @retvals{("tidid","clli","ip","if_type","facility","port_num","if_num","city")} = @{$res};

    unless($sess->getValidConnection()) {
      print "About to InsertLastTIDHistory\n" if($debug >= 5);
      &execute_SQL($statements->{InsertLastTIDHistory}, $retvals{"tidid"});
      print "Done with InsertLastTIDHistory\n" if($debug >= 5);

      print "About to UpdateError\n" if($debug >= 5);
      &execute_SQL($statements->{UpdateError}, "e", "COM", $retvals{"tidid"});
      print "Done with UpdateError\n" if($debug >= 5);

      die "Error: " . $sess->getErrorMessage() . "\n";
    }

  } else {
    unless($sess->getValidConnection()) {
      die "Error: " . $sess->getErrorMessage() . "\n";
    }

    my $slt_trns = &_guess_if_type($sess, $port);
    my @insert_fields = ( $clli,
                          $ip,
                          $slt_trns,
                          &_lookup_port_num($sess, $port),
                          ($city_map{substr($clli, 0, 6)} ? $city_map{substr($clli, 0, 6)} : "NULL"),
                          $element_map{$model}{"id"},
                          $shelf,
                          $channel,
                          ($slt_trns == 30 ? &_lookup_if_num($sess,$port,$lookup_cache) : undef),
                        );


    print "About to InsertTID\n" if($debug >= 5);
    ($res) = &execute_SQL($statements->{InsertTID}, @insert_fields);
    print "Done with InsertTID\n" if($debug >= 5);

    print "About to LookupTID\n" if($debug >= 5);
    ($res) = &execute_SQL($statements->{LookupTID}, $clli, $shelf, $channel, $channel);
    print "Done with LookupTID\n" if($debug >= 5);

    @retvals{("tidid","clli","ip","if_type","facility","port_num","if_num","city")} = @{$res};
  }

  $retvals{"port"} = $port;
  $retvals{"model"} = $model;

  return \%retvals;
}




sub get_facilityid
{
  my ($statements, $spid, $status, $customer) = @_;

  print "About to LookupFacility\n" if($debug >= 5);
  my @res = &execute_SQL($statements->{LookupFacility}, $spid);
  print "Done with LookupFacility\n" if($debug >= 5);

  unless($res[0]) {

    print "About to InsertFacility\n" if($debug >= 5);
    &execute_SQL($statements->{InsertFacility}, $spid, ($status eq "In-Service" ? 2 : 1), $customer);
    print "Done with InsertFacility\n" if($debug >= 5);

    print "About to LookupFacility\n" if($debug >= 5);
    @res = &execute_SQL($statements->{LookupFacility}, $spid);
    print "Done with LookupFacility\n" if($debug >= 5);
  }

  print "facid: " . $res[0]->[0] . "<br>\n" if($debug >= 3);

  return $res[0]->[0];
}



sub execute_SQL
{
  my ($state, @args) = @_;

  for(my $i = 0; $i < @{$state->{datatypes}}; $i++) {
    print "$i - $args[$i] - " . $state->{datatypes}[$i] . "\n" if($debug >= 3);
    $state->{handle}->bind_param($i + 1, $args[$i], $state->{datatypes}[$i]);
  }

  if($debug >= 3) {
    #open(FH, ">> logs/EchoStar.log");
    #print FH "Statement: " . $state->{handle}->{Statement} . "\n";
    #print FH join("|", @args), "\n";
    print "Statement: " . $state->{handle}->{Statement} . "\n";
    print join("|", @args), "\n";
    #close FH;
  }
  
  if($debug >= 1) {
    &display_SQL($state, @args);
  }

  $state->{handle}->execute;

  if($state->{handle}->{err}) {
    print "Error executing statement: " . $state->{handle}->{errstr} . "\n";
    return;
  }

  if($state->{select}) {
    my @rows;

    while (my @row = $state->{handle}->fetchrow_array()) {
      push @rows, \@row;
    }

    return @rows;
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



sub build_element_map
{
  my ($statements) = @_;

  print "\n\nIn build_element_map\n" if($debug >= 3);

  my %mappy;

  print "About to BuildElementMap\n" if($debug >= 5);
  my @results = &execute_SQL($statements->{BuildElementMap});
  print "Done with BuildElementMap\n" if($debug >= 5);

  print join(",", @results), "\n" if($debug >= 5);

  foreach my $row (@results) {
    print join(",", @{$row}), "\n" if($debug >= 5);

    $mappy{$row->[0]} = { "request" => "request" . $row->[2],
                          "id" => $row->[1],
                        };
  }

  if($debug >= 3) {
    print join(",", keys %mappy) . "<br>\n";
  }

  print "Returning build_element_map\n\n" if($debug >= 3);

  return %mappy;
}


sub build_city_map
{
  my ($statements) = @_;

  print "\n\nIn build_city_map\n" if($debug >= 3);

  my %mappy;

  print "About to BuildCityMap\n" if($debug >= 5);
  my @results = &execute_SQL($statements->{BuildCityMap});
  print "Done with BuildCityMap\n" if($debug >= 5);

  foreach my $row (@results) {
    $mappy{$row->[1]} = $row->[0];
  }

  print join(",", keys %mappy), "<br>\n" if($debug >= 3);

  print "Returning build_city_map\n\n" if($debug >= 3);

  return %mappy;
}


sub set_up_report
{
  my $workbook = Spreadsheet::WriteExcel->new ("echostar.xls");
  my $worksheet = $workbook->addworksheet("EchoStar");

  my $header = $workbook->addformat();
  $header->set_bold();
  $header->set_size(12);
  $header->set_merge();
  $header->set_text_wrap();

  my $i = 0;

  $worksheet->write(0, $i++, "CLLI", $header);
  $worksheet->write(0, $i++, "PORT", $header);
  $worksheet->write(0, $i++, "TYPE", $header);
  $worksheet->write(0, $i++, "XMIT", $header);
  $worksheet->write(0, $i++, "RCVD", $header);
  $worksheet->write(0, $i++, "DS3 STATUS", $header);
  $worksheet->write(0, $i++, "SECTION", $header);
  $worksheet->write(0, $i++, "LINE", $header);
  $worksheet->write(0, $i++, "PATH", $header);

  return ($workbook,$worksheet,0);
}




sub _lookup_sonet_status
{
  my ($sess, $hw_loc) = @_;

  my ($sec, $line, $path) = $sess->Get(map {"1.3.6.1.4.1.326.2.2.1.1.4.1.1.1.$_.$hw_loc"} (13,14,15));

  print "$hw_loc: Section - $sec, Line - $line, Path - $path\n" if($debug >= 1);

  return ($sec, $line, $path);
}


sub _lookup_ds1_status
{
  my ($sess, $hw_loc) = @_;

  return;
}


sub _lookup_port_info
{
  my ($sess, $port_num) = @_;

  my ($rcvd, $xmit, $brd, $mod, $prt) = $sess->Get(map {"1.3.6.1.4.1.326.2.2.2.1.2.2.1.$_.$port_num"} (12,18,19,20,21));

  print "$port_num: XMit - $xmit, Rcvd - $rcvd\n" if($debug >= 1);
  print "$port_num: Board - $brd, Module - $mod, Port - $prt\n" if($debug >= 1);

  return ($xmit, $rcvd, "$brd.$mod.$prt");
}

sub _lookup_ds3_status
{
  my ($sess, $if_num) = @_;

  my ($status) = $sess->Get("1.3.6.1.4.1.326.2.2.1.1.15.1.1.3.$if_num");

  print "$if_num status - $status\n" if($debug >= 1);

  return $status;
}



sub _guess_if_type
{
  my ($sess, $port) = @_;

  my $type;

  if($port =~ /,.*,/) {
    $type = 32;
  } elsif($port =~ /,/) {
    $type = 30;
  } else {
    $type = 50;
  }

  print "$port type - $type\n" if($debug >= 1);

  return $type;
}


sub _lookup_if_num
{
  my ($sess, $port, $vals) = @_;

  print ref($vals) . " -- $vals\n" if($debug >= 3);

  $$vals = $sess->GetNext("1.3.6.1.2.1.31.1.1.1.1") unless ($vals && $$vals);

  my @if_nums;

  foreach my $x (keys %{$$vals}) {
    foreach my $y (keys %{$$vals->{$x}}) {
      print "$x $y " . $$vals->{$x}{$y} . " -- $port\n" if($debug >= 3);

      print $$vals->{$x}{$y} . " -- $port --- We should match.\n" if ($$vals->{$x}{$y} eq $port && $debug >= 3);
      push @if_nums, $y if($$vals->{$x}{$y} eq $port);
    }
  }

  print "IFs - ", join(",", @if_nums), "\n" if($debug >= 3);

  return unless @if_nums;

  foreach my $iff (@if_nums) {
    my ($cx) = $sess->Get("1.3.6.1.2.1.2.2.1.3.$iff");
    return $iff if($cx == 30);
  }

  return;
}


sub _check_if_num
{
  my ($statements, $sess, $tidid) = @_;

  my ($port) = $sess->Get("1.3.6.1.2.1.31.1.1.1.1." . $tidid->{"if_num"});

  if($port eq $tidid->{"port"}) {
    return;
  }

  my %insert_fields;

  print "About to UpdateIFNum\n" if($debug >= 4);
  &execute_SQL($statements->{UpdateIFNum}, &_lookup_if_num($sess, $tidid->{"port"}), $tidid->{"tidid"});
  print "Done with UpdateIFNum\n" if($debug >= 4);
}



sub _build_port_oid
{
  my ($port) = @_;

  $port = "R$port" unless ($port =~ /^R/);

  my $val = length($port);

  $val .= "." . join(".", unpack("C*", $port));

  return $val;
}


sub _lookup_port_num
{
  my ($sess, $port) = @_;

  my ($port_num) =  $sess->Get("1.3.6.1.4.1.326.2.2.2.1.20.1.1.2." . &_build_port_oid($port));

  print "Port Num: $port_num\n" if($debug >= 1);

  return $port_num;
}