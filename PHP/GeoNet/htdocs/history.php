<?php
/**
 * Project: GeoNet Monitor
 *
 * history.php
 * Author: Marie Roux 
 * Create Date: 4/3/2002
 *
 * Description: Shows the PM history of different elements.
 *
 * Revision: $Revision: 1.58 $
 * Last Change Date: $Date: 2005-07-26 21:35:23 $
 * Last Editor: $Author: eric $
*/

  $debug = $_REQUEST["debug"] || 0;
	$requireLogin = 1;
	$minLevel = "CustomerAccessLevel";
  
  include_once("ifc_prefs.inc");
  $theme->addToAttr("jscode", file_get_contents($confg->getAttribute("PHPlibDir") . "overlib400/overlib.js"));

  if(!isset($_REQUEST["tid_id"])) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  if(!$user->hasAccessToTidIfc($_REQUEST["tid_id"], $_REQUEST["interface_id"])) {
    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the History Page main content.  This contains
  # element information and graphs.
  include_once("Features/History.inc");
  $his = new History($_REQUEST["tid_id"], $_REQUEST["interface_id"], $user, $dbh, $config, $debug);


  # Here we're loading up the Left Menu for this page.  This is the
  # History page, so we're loading up the LeftMenu for the History page.
  # The LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuHistory.inc");
  $lft = new LeftMenuHistory($his->graphEngine->getTidInfo("customerid"), $user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));

  # In order to set up some additional Primus clues, we need to know
  # what kind of element we're dealing with.
  $et = $dbh->SelectSingleValue("et.primus_name", "tids t, element_types et", "t.id = $tidid and t.element_type_id = et.id");
  if($et == "" || $et == -1) {
    $et = $dbh->SelectSingleValue("et.name", "tids t, element_types et", "t.id = $tidid and t.element_type_id = et.id");
  }

  # Here we're setting up additional Primus Information since we know
  # a little bit about the element at this point.
  $lft->set_Primus_Info(array("cause" => $his->graphEngine->getTidInfo("cause"),
                              "transport" => $his->graphEngine->getTidInfo("transport"),
                              "element_type" => $et,
                              "customer" => $his->graphEngine->getTidInfo("customer"),
                             ));


  # Here we're loading up the Color Block feature.  For the Map page
  # we actually load the small color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SmallColorBlock.inc");
  $cb = new SmallColorBlock(4, 200, 600, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $cb, $his);




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

  print($theme->generate_pagetop());

  print($lft->generate_Layer($cust, $facs, $his->graphEngine->getTidInfo("customerid")));
  print($his->generate_Layer($cust, $facs));
  print($cb->generate_Layer($cust, $facs));
	
  print($theme->generate_pagebottom());
?>