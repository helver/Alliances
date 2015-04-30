<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: ReportTemplate.php
 * Author: Eric Helvey
 * Create Date: 1/3/2003
 *
 * Description: Template used to display TableUpdate container pages.
 *
 * Revision: $Revision: 1.11 $
 * Last Change Date: $Date: 2005-03-11 16:21:48 $
 * Last Editor: $Author: eric $
*/

	global $theme;

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Index page, so we're loading up the LeftMenu for the Index page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($this->user, $this->config, $debug, $this->dbh);
  $lft->set_Primus_Info(array("user" => $this->user->lookupPrimusUserName()));


  if($this->user->hasAccessLevel("Admin")) {
    $me_admin = 1;
  }

  # Here we're loading up the TableUpdate Report Feature.  This executes
  # the appropriate queries and formats the output for the type of report
  # we want.
  include_once("Features/DBReport.inc");
  $rpt = new DBReport($this, $this->config, $debug);


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft, $rpt);

  __loadFeatures($features, $theme);

  $theme->updateAttr("currentLoc", "Database");
	print($theme->generate_pagetop());

  print($lft->generate_Layer($cust, $facs));
  print($rpt->generate_Layer());
	
  print($theme->generate_pagebottom());
?>
