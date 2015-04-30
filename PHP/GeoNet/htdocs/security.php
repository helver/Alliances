<?php
/**
 * Project: GeoNet Monitor
 *
 * security.php
 * Author: Eric Helvey
 * Create Date: 2/15/2004
 *
 * Description: This page allows admin of users.
 *
 * Revision: $Revision: 1.8 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "AdminAccessLevel";

  include_once("ifc_prefs.inc");

	$theme->updateAttr("currentLoc", "Users");

  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  if(isset($user)) {
  	$lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));
  }

	include_once("LoginManagement.inc");
	$login = new LoginManagement($projectName, $theme, $dbh, $config, $debug);

  $theme->updateAttr("title", "GeoNet - User Admin");

  __loadFeatures(array($lft), $theme);
  
  print($theme->generate_pagetop());
  print($lft->generate_Layer($cust, $facs));

  if(   $_REQUEST["op"] == "Delete Users"
     && isset($_POST["users"]) 
     && is_array($_POST["users"]) 
     && count($_POST["users"]) > 0) {
    $dbh->Delete("user_group_user_map", "user_id in (" . join(",", $_POST["users"]) . ")");
  }
  
  
	$login->process_submission();

	print($login->userAdminPage());
	
  print("<p class=\"contentsmall\"><a href=\"update_group_assignment.php\">Update Group Assignments</a></p>\n");

  print($theme->generate_pagebottom());

?>