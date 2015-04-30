<?
/**
 * Project: GeoNet Monitor
 *
 * update_group_assignment.php
 * Author: Eric Helvey
 * Create Date: 2/11/2004
 *
 * Description: This is where users get assigned to user groups.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2005-07-27 20:28:52 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "AdminAccessLevel";

  include_once("ifc_prefs.inc");

  $theme->updateAttr("currentLoc", "Groups");

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Index page, so we're loading up the LeftMenu for the Index page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));

  $groups = $dbh->SelectMap("id, name", "user_groups");

  if(!isset($_REQUEST["user_ids"])) {
    $_REQUEST["user_ids"] = array($sess->getThisPersonID());
  } elseif (!is_array($_REQUEST["user_ids"])) {
    $_REQUEST["user_ids"] = array($_REQUEST["user_ids"]);
  }

  $selgroups = $dbh->SelectMap("g.id as id, g.name as name", "user_group_user_map m, user_groups g", "m.user_group_id = g.id and m.user_id = " . (is_array($_REQUEST["user_ids"]) ? $_REQUEST["user_ids"][0] : $_REQUEST["user_ids"]));
  if(is_array($selgroups)) {
    foreach($selgroups as $id=>$name) {
      unset($groups[$id]);
    }  
  } else {
    $selgroups = array();
  }

  __loadFeatures(array($lft), $theme);

  $theme->updateAttr("title", "GeoNet - Update Group Membership");
  print($theme->generate_pagetop());

  if(isset($_REQUEST["error"])) {
    print("<table border=\"0\"><tr><td class=\"error\">" . $_REQUEST["error"] . "</td></tr></table>\n");
  }
?>
<form method="POST" action="handle_group_assignment.php" onSubmit="selectAll(this, 'groups');">
<table border="0">
  <tr><td class="content">Select User(s):</td></tr>
  <tr><td class="content"><?= popup_menu("user_ids[]", array_flip($_REQUEST["user_ids"]), "id, lastname || ', ' || firstname", "users", "", $dbh, "", "lastname, firstname", 10) ?> <input type="button" value="View Group Assignments" onClick="this.form.action='view_group_assignment.php';this.form.submit();"></td></tr>
  <tr><td><hr></td></tr>
  <tr><td class="content">Add User(s) To The Following Groups:</td></tr>
  <tr><td class="content"><?= mapAdmin("groups", "Groups", $groups, (isset($selgroups) ? $selgroups : array())) ?></td></tr>
  <tr><td><hr></td></tr>
  <tr><td><input type="submit" value="Submit Group Membership Changes"></td></tr>
</table>
</form>
<?
  print($lft->generate_Layer());
  print($theme->generate_pagebottom());
?>
