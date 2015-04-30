<?php
/**
 * Project: GeoNet Monitor
 *
 * index.php
 * Author: Eric Helvey
 *
 * Description: This is basically the login page.
 *
 * Revision: $Revision: 1.15 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/

	$debug = 0;
	if($debug == 0 && isset($_REQUEST["debug"])) {
		$debug = $_REQUEST["debug"];
	}
	
  // if we're already logged in go to the first page
  if(isset($_COOKIE["GeoNet"]) && $_COOKIE["GeoNet"] != "") {
    $loc = ($_REQUEST["returnPage"] ? $_REQUEST["returnPage"] : "colorBlock.php");

    if($debug >= 1) {
      print("Going to $loc<br>\n");
    } else {
      header("Location: $loc");
    }
    exit();
  }

  include_once("ifc_prefs.inc");
  include_once("LoginManagement.inc");
  $login = new LoginManagement($projectName, $theme, $dbh, $config, $debug);

  $login->processLogin();

  $__menu = array(
		"Home" => $config->getAttribute("URLDir") . "/index.php",
	);
	
	
	$theme->updateAttr("topMenu", $__menu);

  print($theme->generate_pagetop());

 	if($debug >= 3) {
 		print("Before entering loginPage<br>\n");
	}
  print($login->loginPage("colorBlock.php"));
 	if($debug >= 3) {
 		print("After exiting loginPage<br>\n");
	}

  print($theme->generate_pagebottom());
?>