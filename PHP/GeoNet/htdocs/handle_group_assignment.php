<?php
/**
 * Project: GeoNet Monitor
 *
 * handle_group_assignment.php
 * Author: Eric Helvey
 * Create Date: 2/11/2004
 *
 * Description: This is where users get assigned to user groups.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2005-06-07 16:36:31 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "AdminAccessLevel";
  
  include_once("ifc_prefs.inc");

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  $dbh->Delete("user_group_user_map", "user_id in (" . join(",",$_POST["user_ids"]) . ")");

  foreach($_POST["user_ids"] as $id) {
  	if(isset($_POST["groups"]) && is_array($_POST["groups"])) {
      foreach($_POST["groups"] as $group) {
        $res = $dbh->Insert("user_group_user_map", array("user_id"=>$id, "user_group_id"=>$group));
 
        if($res < 0) {
          $loc = "Location: update_group_assignment.php?error=" . urlencode($dbh->getErrorMessage());
          if($debug >= 1) {
            print("Got Error - " . $dbh->getErrorMessage() . " would have gone to $loc<br>\n");
          } else {
            header($loc);
          }
          exit();
        }
      }
    }
  }
    
  $loc = "view_group_assignment.php?error=" . urlencode("Group Assignments Successful") . "&user_ids%5B%5D=" . join("&user_ids%5B%5D=", $_POST["user_ids"]);
  __redirector($loc, $debug);
?>