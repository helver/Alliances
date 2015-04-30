<?php
/**
 * Project: GeoNet Monitor
 *
 * resetflag.php 
 * Author: Eric Helvey
 * Create Date: 3/16/2005
 *
 * Description: Reset the flag of a tid/interface combination.
 *
 * Revision: $Revision: 1.5 $
 * Last Change Date: $Date: 2005-06-10 21:55:38 $
 * Last Editor: $Author: eric $
*/

	$debug = 0;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  $initials = $user->getInitials();
  
 	$dbh->Update("pm_info", "timeentered = SYSDATE, cause = 'RESET'", "tid_id = " . $_REQUEST["tid_id"] . " and interface_id = " . $_REQUEST["interface_id"]);
  
  $dbh->Close();

  __redirector($_SERVER["HTTP_REFERER"], $debug);
?>