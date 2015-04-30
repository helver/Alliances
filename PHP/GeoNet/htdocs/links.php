<?php
/**
 * Project: GeoNet Monitor
 *
 * links.php
 * Author: Marie Roux
 * Create Date: 4/2/2002
 *
 * Description: Allows users to choose the database table they want to update.
 *
 * Revision: $Revision: 1.16 $
 * Last Change Date: $Date: 2005-05-20 12:40:18 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");


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


  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  include_once("Features/DBChoice.inc");
  $dbc = new DBChoice($user, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $dbc);


  __loadFeatures($features, $theme);

  $theme->updateAttr("currentLoc", "Database");

  print($theme->generate_pagetop());

  print($lft->generate_Layer());
  print($dbc->generate_Layer());
	
  print($theme->generate_pagebottom());
?>

