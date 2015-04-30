<?php
/**
 * Project: GeoNet Monitor
 *
 * update.php
 * Author: Eric Helvey
 *
 * Description: This page is the generic tie-in into TableUpdate classes.
 *
 * Revision: $Revision: 1.16 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/
  $debug = $_REQUEST["debug"];
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  $skip = array("users"=>"security.php");

  if(isset($skip[$table])) {
    __redirector($skip[$table], $debug);
  }


  if(isset($_REQUEST["table"]) && $_REQUEST["table"] != "") {
    $table = $_REQUEST["table"];

    include_once("Database/" . $table . "Update.inc");
    eval ("\$tab = new " . $table . "Update(\$config, \$debug, \"GeoNet\");");

		if(isset($_REQUEST["return_page"])) {
			$tab->return_page = $_REQUEST["return_page"];
		}
		
		if(!isset($tab->return_page) || $tab->return_page == "") {
    	$tab->return_page = "update.php?table=" . urlencode($tab->table_name) . "&oper=report";
		}

    $theme->addToAttr("title", " - " . $tab->report_label);

    $tab->processFormSubmission();

    $delete_string = "table=" . urlencode($table) . "&" . urlencode($tab->id) . "=" . urlencode($tab->getVal($tab->id));

    if ($_REQUEST["oper"] == "view") {
      $tab->template = "Database/ViewTemplate.php";
      $GLOBALS["delete_string"] = $delete_string;
    } elseif($_REQUEST["oper"] == "report") {
      $tab->template = "Database/ReportTemplate.php";
    } else {
      if($GLOBALS["accessLevel"] >= $config->getAttribute("userAccessLevel")) {
        $tab->template = "Database/EditTemplate.php";
        $GLOBALS["delete_string"] = $delete_string;
      } else {
        $tab->template = "Database/ViewTemplate.php";
        $GLOBALS["delete_string"] = $delete_string;
      }
    }

    $tab->user = $user;

    $tab->displayPage();
    exit();
  }

  __redirector("links.php", $debug);

?>
