<?php
/**
 * Project: GeoNet Monitor
 *
 * showAlarms.php 
 * Author: Eric Helvey 
 * Create Date: 3/18/2004
 *
 * Description: Shows an alarm list.
 *
 * Revision: $Revision: 1.33 $
 * Last Change Date: $Date: 2005-07-21 19:56:18 $
 * Last Editor: $Author: eric $
*/

  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "CustomerAccessLevel";
	
	if(isset($_REQUEST["debug"])) {
		$debug = $_REQUEST["debug"];
	}
	
	if(!isset($_GET["orderbyplug"])) {
		unset($HTTP_GET_VARS["orderbyplug"]);
		unset($GLOBALS["orderbyplug"]);
	}
	
  include_once("ifc_prefs.inc");
	include_once("ListView.inc");

  $theme->updateAttr("title", "GeoNet Alarm History");

  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));

  # Here we're loading up the Color Block feature.  For the Map page
  # we actually load the small color block.  This feature contains all
  # the blinky lights.
  include_once("Features/SmallColorBlock.inc");
  $cb = new SmallColorBlock(2, 400, 5, $config, $debug);

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


  $excel_levels = array(
    "Excel" => 1,
  );

  $formatting = array(
    "colheader_style" => "tableHead",
    "summaryrow_style" => "tableHead",
    "pageheader_style" => "pagehead",
    "instructions_style" => "tableHeader",
    "datatable_bordercolor" => "#555555",
    "datatable_cellpadding" => "3",
    "datatable_cellspacing" => "0",
    "datarow_colors" => array("#ffffff", "#f3f3df"),
  );

  $filter_names = array(
    "Customer",
    "TID_ID",
    "AlarmAge",
    "Cause"
  );

  $lv = new ListView("showAlarms_view", $projectName, $sess, $config, $dbh, $debug);

  $lv->setExcelLevels($excel_levels);
  $lv->setFilterNames($filter_names);
  $lv->setFilterColumns(3);
  $lv->setDefaultOrderBy("thetime, tid");
  $lv->setFormatting($formatting);
  $lv->useOracleOptimizedFunctions();
  #$lv->setColAccess($col_access);
  #$lv->setRequireFilter();
  $lv->setPrinterFriendly();
  $lv->setColHeaderInterval(25);
  $lv->setup();

  if($lv->excel_level <= 0) {
    $theme->updateAttr("currentLoc", "Database");

    __loadFeatures(array($lft, $cb), $theme);

		if(!isset($_REQUEST["printpage"])) {
		  print($theme->generate_pagetop());
		  print($lft->generate_Layer($cust, $facs));
      print($cb->generate_Layer($cust, $facs));	
    } else {
      print("<html><head>" . $theme->generate_css() . "\n<title>" . $theme->title . "</title></head><body>\n");
		}
  }

  $lv->generate_list_page();

  $dbh->Close();

  if($lv->excel_level <= 0) {
		if(!isset($_REQUEST["printpage"])) {
		  print($theme->generate_pagebottom());
    } else {
      print("</body></html>\n");
		}
  }
  
?>
