#!/usr/bin/perl
use DBI;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = $config->getAttribute("DebugLevel") || $ARGV[0];

eval("use DBWrapper::" . $config->getAttribute("DatabaseDriver") . ";");
my $dbh;

eval("\$dbh = DBWrapper::" . $config->getAttribute("DatabaseDriver") . "->new(\$config, \"GeoNet\", \$debug);");


$|=1 if($debug >= 1); #Set 1 to flush (for tailing the log file)

print "HouseKeeping running at: " . localtime() . "\n";

#&gray_out_items_not_on_path($dbh, $config);
#&blue_out_items_in_TNT($dbh, $config);
&red_out_items_we_have_not_talked_to($dbh, $config);
&update_alarm_list($dbh, $config);

$dbh->Close();
exit();


sub gray_out_items_not_on_path
{
  my ($dbh, $config) = @_;

  # if an element is not on any path, give it a 'n' flag for 'N/A'
  $dbh->Update("tid_interface_status", {"flag" => 0, "cause" => "H_K"},  
        "(tid_id, interface_id) in (select tid_id, interface_id from tid_facility_map where trans_seq < 0 and (recv_seq < 0 or recv_seq is null))");
}


sub blue_out_items_in_TNT
{
  my ($dbh, $config) = @_;

  # if an element is in a non-monitored facility, give it a 't' flag for test
  $dbh->Update("tid_interface_status", {"flag" => 2, "cause" => "H_K"},
        "(tid_id, interface_id) in (select tfm.tid_id, tfm.interface_id from tid_facility_map tfm, facilities f WHERE f.id = tfm.facility_id and f.active = 'f')"
  );
}


sub red_out_items_we_have_not_talked_to
{
  my ($dbh, $config) = @_;

  # If we can't connect to an element for more than $maxCantConnectMinutes minutes
  # show it as an error (red) and update the database with null everywhere
  my $maxCantConnectMinutes = ($config->getAttribute("maxCantConnectMinutes") ? $config->getAttribute("maxCantConnectMinutes") : 60);

  # Conversion of minutes into days
  my $maxCantConnectDays = $maxCantConnectMinutes / (24*60);

	my $res = $dbh->Select("tis.tid_id as tid_id, tis.interface_id as interface_id", "tid_interface_status tis, tid_facility_map tfm, facilities f", "tis.tid_id = tfm.tid_id and tis.interface_id = tfm.interface_id and tfm.facility_id = f.id and f.active = 't' and tis.flag >= 4 and tis.error_time IS NOT NULL and tis.error_time < SYSDATE - $maxCantConnectDays");
	my %oldtids;
	my @oldtids;
	
	for(my $i = 0; defined $res->[$i]; $i++) {
		$oldtids{$res->[$i]{tid_id}}{$res->[$i]{interface_id}}++;
	}
	
	my $vals = {
		 "status" => -1, 
	   "timeEntered" => "SYSDATE", 
	   "cause" => "COM",
	   "agent" => "H_K",
     "c1" => -2, 
     "c2" => -1, 
     "c3" => -1, 
     "c4" => -1, 
     "c5" => -1, 
     "c6" => -1, 
     "c7" => -1, 
     "c8" => -1, 
     "c9" => -1, 
     "c10" => -1,
  };

	my $cantConnect = 0;
	  
	foreach my $tid (keys %oldtids) {
		foreach my $ifc (keys %{$oldtids{$tid}}) {
			next unless $oldtids{$tid}{$ifc} == scalar(keys(%{$dbh->{theDB}}));
		
			$cantConnect++;
			$dbh->Update("pm_info", $vals, "tid_id = $tid and interface_id = $ifc");

		  if($dbh->getErrorMessage()) {
    		print $dbh->getErrorMessage();
		  }
		}
	}
	
  if($cantConnect >= 1) {
    print "Updating $cantConnect TIDs due to not being able to connect within -- $maxCantConnectMinutes -- $maxCantConnectDays at " . localtime() . "\n";
  }
}



sub update_alarm_list
{
  my ($dbh, $config) = @_;

  $dbh->Update("alarms", {"cleared" => "t", "time_cleared"=>"SYSDATE"}, "cleared is null and tid_id in (select id from tids where flag < 8 and flag <> 5)");

  $new_alarms = $dbh->Select("*", "Alarm_Creation_View");
  
  for(my $i = 0; defined $new_alarms->[$i]; $i++) {
  	my $new_alarm_id = $dbh->getNextSeq("alarm_id_seq");
  	
  	my $fields = {
  		"acknowledge_date" => (defined $new_alarms->[$i]->{"acknowledge_date"} ? "to_date('" . $new_alarms->[$i]->{"acknowledge_date"} . "', 'MM/DD/YYYY HH24:MI:SS')" : "NULL"),
  		"timeentered" => "to_date('" . $new_alarms->[$i]->{"timeentered"} . "', 'MM/DD/YYYY HH24:MI:SS')",
  		"id" => $new_alarm_id,
  		"tid_id" => $new_alarms->[$i]->{"tid_id"},
  		"interface_id" => $new_alarms->[$i]->{"interface_id"},
  		"cause" => $new_alarms->[$i]->{"cause"},
  	};
  	
		# Insert any new alarm(s) in the alarm table
		$dbh->Insert("alarms", $fields);
  }
}
