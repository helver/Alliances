<?php
/**
 * Project: GeoNet Monitor
 *
 * map.php
 * Author: Marie Roux
 * Creation Date: 3/29/2002
 *
 * Description: This generates the GeoNet Map page.
 *
 * Revision: $Revision: 1.101 $
 * Last Change Date: $Date: 2005-10-20 19:55:51 $
 * Last Editor: $Author: eric $
*/
  $debug = $_REQUEST["debug"] || 0;
	$requireLogin = 1;
	$minLevel = "CustomerAccessLevel";
  
  include_once("ifc_prefs.inc");
  $theme->addToAttr("jscode", file_get_contents($confg->getAttribute("PHPlibDir") . "overlib400/overlib.js"));

  if(!$user->hasAccessToCustomer($_REQUEST["customer"])) {
    __redirector($config->getAttribute("URLDir") . "/colorBlock.php", $debug);
  }

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Map page, so we're loading up the LeftMenu for the Map page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuMap.inc");
  $lft = new LeftMenuMap($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  # Here we're loading up the Color Block feature.  For the Map page
  # we actually load the small color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SmallColorBlock.inc");
  $cb = new SmallColorBlock(6, 540, 10, $config, $debug);


  # This loads up the map feature.  The code in Map.inc does not
  # actually generate the Map, it just handles the layer creation,
  # CSS, JavaScript and onLoad stuff for the map.  It also allows
  # us to make sure that the customer and the facilities that we've
  # been given make sense.
  include_once("Features/Map.inc");
  $map = new Map($user, $dbh, $config, $debug);
  list($customer, $facility) = $map->get_customer_facility($customer, $facility);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $cb, $map);



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
  $facs->update_facility_list($_REQUEST["customer"], $_REQUEST["facility"]);

  __loadFeatures($features, $theme);

  $theme->updateAttr("httpmetatag", ($debug >= 1 ? "3000" : $config->getAttribute("standardRefreshTime")) . ";URL=" . $_SERVER["PHP_SELF"] . "?" . $_SERVER["QUERY_STRING"], "Refresh");
  $theme->updateAttr("httpmetatag", "-1", "Expires");

  $custName = $dbh->SelectSingleValue("name", "customers", "id = " . $_REQUEST["customer"]);

  $theme->updateAttr("title", "GeoNet - $custName Map");
  $theme->updateAttr("showLeftNav", 0);
  print($theme->generate_pagetop());

  print($lft->generate_Layer($cust, $facs, $_REQUEST["customer"]));
  print($cb->generate_Layer($cust, $facs));
  print($map->generate_Layer($_REQUEST["customer"], $_REQUEST["facility"], time(), $facs));
	
  print($theme->generate_pagebottom());
?>
