<?php
require_once("form_elements.inc");
require_once("common.inc");

require('Smarty.class.php');

$smarty = new Smarty;

$smarty->compile_check = true;
$smarty->debugging = false;
$smarty->assign("loggedin", 0);
$smarty->assign("SiteURL", $GLOBALS["SiteURL"]);

smarty_auth_check($page, $smarty, $dbh);

if(   isset($_COOKIE["SandBUser"]) && $_COOKIE["SandBUser"] != "") {
    $smarty->assign("login_username", $_COOKIE["SandBUser"]);
} else {
    $smarty->assign("login_username", "");
}
 
?>

