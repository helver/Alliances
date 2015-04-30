<?php
/**
 * Project: GeoNet Monitor
 *
 * colorBlock.php
 * Author: Eric Helvey
 *
 * Description: This is the dashboard page where we see a roll-up
 *              of element status at a customer level.
 *
 * Revision: $Revision: 1.37 $
 * Last Change Date: $Date: 2006-05-25 14:40:29 $
 * Last Editor: $Author: eric $
*/
	#$debug = 5;
	$requireLogin = 1;
	$minLevel = "CustomerAccessLevel";
  
  include_once("ifc_prefs.inc");

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Index page, so we're loading up the LeftMenu for the Index page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuIndex.inc");
  $leftmenu = new LeftMenuIndex($user, $config, $debug, $dbh);
  $leftmenu->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  # Here we're loading up the LastUpdate feature.  On several pages
  # we had code that generated and placed the last time this page was
  # loaded.  This just consolidates that effort and makes it just a
  # little easier to deal with.
  include_once("Features/LastUpdate.inc");
  $lastupdate = new LastUpdate(80, 580, $config, $debug);

	if(   (!isset($_REQUEST["groupid"]) || $_REQUEST["groupid"] == "") 
	   && count($user->info["grouporder"]) == 1) {
		list($xgg) = array_keys($user->info["grouporder"]);
		$_REQUEST["groupid"] = $xgg;
	}
		

  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  if(isset($_REQUEST["groupid"]) && $_REQUEST["groupid"] != "") {
  	include_once("Features/BigColorBlock.inc");
  	$bigcolorblock = new BigColorBlock(5, $_REQUEST["groupid"], $config, $debug);
  	include_once("Features/SmallGroupColorBlock.inc");
  	$sgcb = new SmallGroupColorBlock(6, 486, 10, $config, $debug);
  } else {
  	include_once("Features/GroupColorBlock.inc");
  	$bigcolorblock = new GroupColorBlock(5, $config, $debug);
  }


  # Here we're loading up the Active Outage feature.  
  include_once("Features/ActiveOutage.inc");
  $active = new ActiveOutage(65, 5, $dbh, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($leftmenu, $lastupdate, $bigcolorblock, $active);
	if(isset($sgcb)) {
		$features[] = $sgcb;
	}



  //////////////////////////////////////////////////////////////
  // DATA GATHERING
  //////////////////////////////////////////////////////////////


  # This call begins the process of gathering data about Customers.
  # Two method calls below must also be invoked to fully gather the
  # data needed by the color block code and left menu code.  $sev is
  # included by constantsDefinition.inc which is included by auth.inc.
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

  $theme->updateAttr("httpmetatag", ($debug >= 1 ? "3000" : $config->getAttribute("overviewRefreshTime")) . ";URL=" . $_SERVER["PHP_SELF"] . "?" . $_SERVER["QUERY_STRING"], "Refresh");
  $theme->updateAttr("httpmetatag", "-1", "Expires");
	
  print($theme->generate_pagetop());
  #print("<script language=\"JavaScript\"><!--\n\nsetTimeout('stagnantPage()',65000);\n\nfunction stagnantPage()\n{\nalert('This page is stagnant.  Refresh it.');\n}\n// --></script>\n");

  print($active->generate_Layer());
  print($leftmenu->generate_Layer($cust, $facs));
  print($lastupdate->generate_Layer());
  print($bigcolorblock->generate_Layer($cust, $facs));
  
  if(isset($sgcb)) {
	  print($sgcb->generate_Layer($cust, $facs));
  }	
	
  print($theme->generate_pagebottom());
  
?>
