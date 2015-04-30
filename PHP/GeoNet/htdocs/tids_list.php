<?php
  #########################################
  #
  # GeoNet
  #
  # tids_list.php
  # Initial Creation Date: 10/13/2004
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.9 $
  # Last Change Date: $Date: 2005-07-27 20:28:52 $
  # Last Editor: $Author: eric $
  #
  #
  # TIDS List View
  #
  #########################################

  $debug = $_REQUEST["debug"] || 0;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
	
	if(isset($_REQUEST["debug"])) {
		$debug = $_REQUEST["debug"];
	}
	
	if(!isset($_GET["orderbyplug"])) {
		unset($HTTP_GET_VARS["orderbyplug"]);
		unset($GLOBALS["orderbyplug"]);
	}
	
  include_once("ifc_prefs.inc");
	include_once("ListView.inc");

	$GLOBALS["table"] = "tids";
	
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));

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
    "datarow_style_key_column" => "alarm",
  );

  $filter_names = array(
    "CLLI_TID",
    "State",
    "ElementType",
    "HidDWDMFac",
    "HidGroupName",
    "HidTidID",
  );

  $lv = new ListView("tids_list_view", $projectName, $sess, $config, $dbh, $debug);

  $lv->setExcelLevels($excel_levels);
  $lv->setFilterNames($filter_names);
  $lv->setFilterColumns(3);
  $lv->setDefaultOrderBy("tid");
  $lv->setFormatting($formatting);
  #$lv->useOracleOptimizedFunctions();
  $lv->setColAccess($col_access);
  $lv->setRequireFilter();
  $lv->setPrinterFriendly();
  $lv->setup();

  if($lv->excel_level <= 0) {
    $theme->updateAttr("currentLoc", "Database");

    __loadFeatures(array($lft), $theme);

		if(!isset($_REQUEST["printpage"])) {
		  print($theme->generate_pagetop());
		  print($lft->generate_Layer($cust, $facs));
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
