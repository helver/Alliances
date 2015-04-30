<?php
/**
 * Project: GeoNet Monitor
 *
 * pre_history.php
 * Author: Eric Helvey
 * Create Date: 3/18/2004
 *
 * Description: Shows the ports on an element that have history available.
 *              Also shows color-coded representation of port status.
 *
 * Revision: $Revision: 1.11 $
 * Last Change Date: $Date: 2005-06-17 14:37:40 $
 * Last Editor: $Author: eric $
*/

  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "CustomerAccessLevel";
  
  include_once("ifc_prefs.inc");

  if(!isset($_REQUEST["tid_id"])) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  if(!$user->hasAccessToTid($_REQUEST["tid_id"])) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  $ifsx = $dbh->Select("*", "if_status_tid_and_cust_view", "tid_id = " . $_REQUEST["tid_id"] . " and customer_id in (" . join(",", array_keys($user->info["customerlist"])) . ")", "interface_id, customer_id");

  if(!is_array($ifsx) || count($ifsx) < 1) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  if(count($ifsx) == 1) {
    __redirector($config->getAttribute("URLDir") . "/history.php?tid_id=" . $_REQUEST["tid_id"] . "&interface_id=" . $ifsx[0]["interface_id"], $debug);
  }

	for($i = 0; isset($ifsx[$i]); $i++) {
		if(!isset($ifs[$ifsx[$i]["interface_id"]])) {
			$ifs[$ifsx[$i]["interface_id"]] = $ifsx[$i];
		} else {
			if($ifsx[$i]["sorttime"] > $ifs[$ifsx[$i]["interface_id"]]["sorttime"]) {
				$ifs[$ifsx[$i]["interface_id"]] = $ifsx[$i];
			}
		}
	}
	
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

  # In order to set up some additional Primus clues, we need to know
  # what kind of element we're dealing with.
  $et = $dbh->SelectSingleValue("et.primus_name", "tids t, element_types et", "t.id =" . $_REQUEST["tid_id"] . "and t.element_type_id = et.id");
  if($et == "" || $et == -1) {
    $et = $dbh->SelectSingleValue("et.name", "tids t, element_types et", "t.id =" . $_REQUEST["tid_id"] . "and t.element_type_id = et.id");
  }

  # Here we're setting up additional Primus Information since we know
  # a little bit about the element at this point.
  $lft->set_Primus_Info(array("element_type" => $et));


  # Here we're loading up the Color Block feature.  For the Map page
  # we actually load the small color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SmallColorBlock.inc");
  $cb = new SmallColorBlock(6, -1, -1, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $cb);




  //////////////////////////////////////////////////////////////
  // DATA GATHERING
  //////////////////////////////////////////////////////////////


  # This call begins the process of gathering data about Customers.
  # Two method calls below must also be invoked to fully gather the
  # data needed by the color block code and left menu code.
  include_once("CustomerInfo.inc");
  $cust = new CustomerInfo($sev, $user, $config, $dbh, $debug);


  # This call begins the process of gathering data about Facilities.
  # One method call below must also be invoked to fully gather the
  # data needed by the color block code and left menu code.
  include_once("FacilityInfo.inc");
  $facs = new FacilityInfo($cust, $sev, $user, $config, $dbh, $debug);

  # The order of these calls is important.  Do not change the order
  # of these method calls.
  $cust->set_Facilities_List($facs);
  $facs->update_facility_list();

  __loadFeatures($features, $theme);
  $tid = $dbh->SelectFirstRow("id, name", "tids", "id =" . $_REQUEST["tid_id"]);

  $theme->updateAttr("title", "GeoNet - $tid Details");
  print($theme->generate_pagetop());

?>
<p class="pageHead">TID Details: <?= $tid["name"] ?> <span class="content">(<a href="tids_list.php?filter=Filter&fhidtidid=<?= $tid["id"] ?>">List</a>) (<a href="update.php?table=tids&id=<?= $tid["id"] ?>">Edit</a>)</span></p>

<table border="0" cellpadding="3" cellspacing="1">
  <tr>
    <td class="tableHeader">&nbsp;</td>
    <?= ($user->hasAccessLevel("InternalUser") ? "<td align=\"center\" class=\"tableHeader\">Interface</td>" : "") ?>
    <td align="center" class="tableHeader">Facility</td>
    <td align="center" class="tableHeader">Customer</td>
    <td align="center" class="tableHeader">Cause</td>
    <td align="center" class="tableHeader">Last Attempt</td>
    <td align="center" class="tableHeader">Failed Attempts</td>
    <td align="center" class="tableHeader">Facility Notes</td>
  <? 
    ksort($ifs);
    foreach($ifs as $i => $j) {
      print("<tr bgcolor=\"" . $cb->colors[$ifs[$i]["flag"]] . "\">\n");
      print("<td class=\"contentmedium\"><a href=\"history.php?tid_id=" . $ifs[$i]["tid_id"] . "&interface_id=" . $ifs[$i]["interface_id"] . "\">Detailed History</a></td>\n");
      print(($user->hasAccessLevel("InternalUser") ? "<td class=\"contentmedium\">" . $ifs[$i]["namelbl"] . ": " . $ifs[$i]["interface"] . "</td>\n" : ""));
      print("<td class=\"contentmedium\">" . ($user->hasAccessLevel("InternalUser") ? "<a href=\"facilities_list.php?fcustomer=&factive=&fspeed=&filter=Filter&fhidfac=" . $ifs[$i]["facility_id"] . "\">" . $ifs[$i]["facility"] . "</a>" : $ifs[$i]["facility"]) . " (" . $ifs[$i]["facility_active"] . ")</td>\n");
      print("<td class=\"contentmedium\">" . $ifs[$i]["customer"] . "</td>\n");
      print("<td class=\"contentmedium\">" . $ifs[$i]["cause"] . "</td>\n");
      print("<td class=\"contentmedium\">" . $ifs[$i]["timeentered"] . "</td>\n");
      print("<td class=\"contentmedium\">" . $ifs[$i]["connect_attempts"] . "</td>\n");
      print("<td class=\"contentmedium\">" . $ifs[$i]["notes"] . "</td>\n");
      print("</tr>\n");
    }
  ?>
</table>
<?
  print($lft->generate_Layer($cust, $facs));
  print($cb->generate_Layer($cust, $facs));
  print($theme->generate_pagebottom());
?>