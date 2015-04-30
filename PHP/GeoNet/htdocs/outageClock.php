<?php
/**
 * Project: GeoNet Monitor
 *
 * outageClock.php
 * Author: Eric Helvey
 * Creation Date: 6/27/2003
 *
 * Description: Provides a page where uses can schedule an outage so that
 *              it doesn't count as an unscheduled outage.
 *
 * Revision: $Revision: 1.7 $
 * Last Change Date: $Date: 2005-05-20 12:40:18 $
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
  include_once("Features/LeftMenuDB.inc");
  $leftmenu = new LeftMenuDB($user, $config, $debug, $dbh);


  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  include_once("Features/ScheduleOutage.inc");
  $outage = new ScheduleOutage($user, $dbh, $config, $debug);


  # Here we're loading up the Active Outage feature.  
  include_once("Features/ActiveOutage.inc");
  $active = new ActiveOutage(65, 5, $dbh, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($leftmenu, $outage, $active);




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

  $theme->updateAttr("title", "GeoNet - Scheduled Outages");

  print($theme->generate_pagetop());

  print($active->generate_Layer());
  print($leftmenu->generate_Layer($cust, $facs));
  print($outage->generate_Layer($cust, $facs));
	
  print($theme->generate_pagebottom());
?>
