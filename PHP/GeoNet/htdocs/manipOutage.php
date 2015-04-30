<?php
/**
 * Project: GeoNet Monitor
 *
 * update.php
 * Author: Eric Helvey
 *
 * Description: This page is the generic tie-in into TableUpdate classes.
 *
 * Revision: $Revision: 1.8 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/
  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  $skip = array("users"=>"security.php");

	$vals = array(
    "START_TIME" => "NEW_TIME(to_date('" . $_POST["start"] . "', 'DD MON YYYY HH24:MI:SS'), 'GMT', 'CST')",
    "END_TIME" => "NEW_TIME(to_date('" . $_POST["stop"] . "', 'DD MON YYYY HH24:MI:SS'), 'GMT', 'CST')",
    "DESCRIPTION" => $_POST["description"],
    "CUSTOMER_ID" => $_POST["customerid"],
    "FACILITY_ID" => $_POST["facilityid"],
    "TICKETNUM" => $_POST["ticketno"],
    "ASITE_ID" => $_POST["aside"],
    "ZSITE_ID" => $_POST["zside"],
    "STARTTIME_STRING" => $_POST["start"],
    "ENDTIME_STRING" => $_POST["stop"],
  );

	if(isset($_POST["outageid"])) {
		$dbh->Update("scheduled_outages", $vals, "id = " . $_POST["outageid"]);
	} else {
		$vals["ID"] = $dbh->getNextSeq("scheduled_outage_id_seq");
		  
		$dbh->Insert("scheduled_outages", $vals);
	}
	
	if($dbh->getErrorMessage() != "") {
		print($dbh->getErrorMessage() . "<br>\n");
	}
	
  __redirector("outageClock.php", $debug);

?>