<?php
/**
 * Project: GeoNet Monitor
 *
 * addAlarmTicket.php
 * Author: Marie Roux
 * Create Date: 5/22/2002
 *
 * Description: Here we acknowledge an alarm and add a Ticket number to
 *              to the Alarm entry.
 *
 * Revision: $Revision: 1.25 $
 * Last Change Date: $Date: 2006-07-13 19:30:55 $
 * Last Editor: $Author: eric $
*/

	#$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");
	
	if(isset($_REQUEST["facilityid"]) && is_array($_REQUEST["facilityid"])) {
		
    $initials = $user->acf2id;
  
    foreach($_REQUEST["facilityid"] as $q) {
  	  $vals = array(
    	  "facility_id" => $q,
  	    "ticketno" => trim($_REQUEST["TICKETNO"]),
    	  "initials" => $initials,
	    );
  
    	$dbh->Update("ack_alarms_view", $vals, "facility_id = $q");
  	
      if($debug >= 3) {
  	  	print($dbh->getErrorMessage() . "<Br>\n");
      }
    }
  }
  
  $dbh->Close();

  __redirector($_SERVER["HTTP_REFERER"], $debug);
?>