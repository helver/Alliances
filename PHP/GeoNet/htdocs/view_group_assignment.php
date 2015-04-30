<?
/**
 * Project: GeoNet Monitor
 *
 * view_group_assignment.php
 * Author: Eric Helvey
 * Create Date: 2/11/2004
 *
 * Description: This is shows a group of users' group assignments.
 *
 * Revision: $Revision: 1.7 $
 * Last Change Date: $Date: 2005-06-17 14:37:41 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "InternalUserAccessLevel";
  
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

  if($GLOBALS["accessLevel"] < $config->getAttribute("adminAccessLevel")) {
    $_REQUEST["user_ids"] = $me;
    $show_link = false;
  } else {
    $show_link = true;
  }

  if(isset($_REQUEST["user_ids"])) {
    if($_REQUEST["user_ids"] == "all") {
      $user_ids = "";
    } elseif (is_array($_REQUEST["user_ids"])) {
      $user_ids = "id in (" . join(",", $_REQUEST["user_ids"]) . ")";
    } else {
      $user_ids = "id = " . $_REQUEST["user_ids"];
    }
  } else {
    $user_ids = "id = " . $me;
  }

  $allgroups = array();
  $user_groups = array();

  $users = $dbh->SelectMap("id, lastname || ', ' || firstname", "users", $user_ids, "lastname, firstname");
  if(!is_array($users)) {
    $users = array();
  }

  $groups = $dbh->Select("user_id, user_group_id", "user_group_user_map", ($user_ids == "" ? "" : "user_" . $user_ids));

  for($i = 0; isset($groups[$i]); $i++) {
    $user_groups[$groups[$i]["user_id"]][] = $groups[$i]["user_group_id"];
    $allgroups[$groups[$i]["user_group_id"]] = 1;
  }

  $groups = $dbh->SelectMap("id, name", "user_groups", "id in (" . join(",", array_keys($allgroups)) . ")");

  __loadFeatures(array($lft), $theme);

  $theme->updateAttr("title", "GeoNet - View Group Memberships");
  print($theme->generate_pagetop());
?>
<p class="pageHead">Group Assignments</p>

<form action="groupUpdate.php" method="POST">
<?= popup_menu("groupid", "", "id, name", "user_groups", "", $dbh, "", "name") ?><br>
<input type="submit" value="Update Customer Assignments"><br><br>
</form>

<? if($show_link) { ?>
  <p class="contentsmall"><a href="view_group_assignment.php?user_ids=all">View All Group Assignments</a></p>
<? } ?>

<hr width="100%">
<table border="0" width="60%" cellpadding="4" cellspacing="0">
  <?
    $i = 0;
    foreach($users as $id => $name) {
      print("<tr bgcolor=\"" . ($i % 2 == 0 ? "#ffffff" : "#f3f3df") . "\">\n");
      print("<td nowrap class=\"contentmedium\">" . ($show_link ? "<a href=\"update_group_assignment.php?user_ids[]=$id\">" : "") . "$name" . ($show_link ? "</a>" : "") . "</td>\n");
      print("<td nowrap class=\"contentsmall\">");
      if(isset($user_groups[$id]) && is_array($user_groups[$id])) {
        foreach($user_groups[$id] as $gid) {
          print($groups[$gid] . "<br>");
        }
      } else {
        print("No Group Assignments");
      }
      print("</td>\n");
      print("</tr>\n");
      $i++;
    }
  ?>
</table>
<?
  print($lft->generate_Layer());
  print($theme->generate_pagebottom());
?>
