<?php
/**
 * Project: GeoNet Monitor
 *
 * update.php
 * Author: Eric Helvey
 *
 * Description: This page is the generic tie-in into TableUpdate classes.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2005-06-17 14:37:40 $
 * Last Editor: $Author: eric $
*/
  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  print("Not completely done yet.");

	# Make sure that we have a customer to monitor.
	if(!isset($_GET["customerid"])) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }
	
	$_title = $dbh->SelectSingleValue("name", "customers", "id = " . $_REQUEST["customerid"]);

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


  # Here we're loading up the LastUpdate feature.  On several pages
  # we had code that generated and placed the last time this page was
  # loaded.  This just consolidates that effort and makes it just a
  # little easier to deal with.
  include_once("Features/LastUpdate.inc");
  $lup = new LastUpdate(80, 180, $config, $debug);


  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SingleElementAlarmHistory.inc");
  $ah = new SingleElementAlarmHistory($dbh, $user, $config, $debug);


  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SingleElementStatusBlock.inc");
  $sesb = new SingleElementStatusBlock($dbh, $config, $debug);


  # Here we're loading up the Color Block feature.  For the Map page
  # we actually load the small color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SmallColorBlock.inc");
  $cb = new SmallColorBlock(4, 400, 5, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $lup, $cb, $ah, $sesb);




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

  $theme->updateAttr("httpmetatag", ($debug >= 1 ? "3000" : $config->getAttribute("overviewRefreshTime")) . $_SERVER["PHP_SELF"], "Refresh");
  $theme->updateAttr("httpmetatag", "-1", "Expires");

  $theme->updateAttr("title", "GeoNet - $_title Single Element");
  print($theme->generate_pagetop());

  print($active->generate_Layer());
  print($lft->generate_Layer($cust, $facs));
  print($lup->generate_Layer());
  print($ah->generate_Layer(1, $_REQUEST["customerid"]));
  print($cb->generate_Layer($cust, $facs));
	print($sesb->generate_Layer($_REQUEST["customerid"]));

  print($theme->generate_pagebottom());

?>