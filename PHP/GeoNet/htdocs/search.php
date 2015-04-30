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
 * Revision: $Revision: 1.17 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/

  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  $skip = array(
    "user"=>"adminUser.php", 
    "project_contact"=>"links.php", 
    "security"=>"links.php"
  );

  if(isset($skip[$_REQUEST["table"]]) && $skip[$_REQUEST["table"]] != "") {
    __redirector($skip[$table], $debug);
  }


  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Index page, so we're loading up the LeftMenu for the Index page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  # Here we're loading up the Color Block feature.  For the Index page
  # we actually load the big color block.  This feature contains all
  # the blinky lights.
  include_once("Features/DBSearch.inc");
  $dbs = new DBSearch($user, $config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $dbs);



  __loadFeatures($features, $theme);

  $theme->updateAttr("title", "GeoNet Database Search");
  print($theme->generate_pagetop());

  print($lft->generate_Layer());
  print($dbs->generate_Layer($_REQUEST["table"]));
	
  print($theme->generate_pagebottom());
?>