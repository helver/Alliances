<?php
  $debug = 0;
  require_once("../Libs/common.inc");
  $page = new Admin_Page($dbh, "Admin");
  require_once("../Libs/common_smarty.inc");

  include_once("ConfigFileReader.inc");
  $config = new ConfigFileReader("aswas");
  $config->setAttribute("DBApplication", "aswas");
  $config->setAttribute("DBUserName", $GLOBALS["db_user"]);
  $config->setAttribute("DatabaseDB", $GLOBALS["db"]);
  $config->setAttribute("DatabaseHost", "db");
  $config->setAttribute("DBPassword", $GLOBALS["db_pass"]);

  if(!isset($debug)) {
    $debug = $config->getAttribute("DebugLevel") || 0;
    $debug = (int)$debug;
  }

  include_once("ListView.inc");

  if(!isset($_GET["orderbyplug"])) {
    unset($GLOBALS["orderbyplug"]);
  }

  $excel_levels = array(
    "Excel" => 1,
  );

  $formatting = array(
    "colheader_style" => "whitetext",
    "summaryrow_style" => "whitetext",
    "pageheader_style" => "whitetext",
    "instructions_style" => "whitetext",
    "datatable_bordercolor" => "#555555",
    "datatable_cellpadding" => "3",
    "datatable_cellspacing" => "0",
    "datarow_colors" => array("#ddaaaa", "#aadddd"),
  );

  $filter_names = array(
    "BuzzUser",
    "ActiveUser",
  );

  $lv = new ListView("admin_userlist", "aswas", "", $config, $dbh, $debug);

  $lv->setIncludeDir("AdminObjects");
  $lv->setExcelLevels($excel_levels);
  $lv->setFilterNames($filter_names);
  $lv->setFilterColumns(2);
  $lv->setDefaultOrderBy("buzz_user_name");
  $lv->setFormatting($formatting);
  #$lv->setRequireFilter();
  $lv->setColHeaderInterval(25);
  $lv->setPrinterFriendly();
  $lv->setup();

  #$lv->generate_list_page();

  $smarty->assign("blah", "blah");
  $smarty->assign("title_string", "User List");
  $smarty->assign("lv", $lv);
  
  $smarty->display('list_view_standard_template.tpl');

  $dbh->Close();
?>