<?php
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$smarty->assign("error_text", (isset($_REQUEST["error_text"]) ? $_REQUEST["error_text"] : False));
$smarty->assign("username", (isset($_REQUEST["username"]) ? $_REQUEST["username"] : ""));
$smarty->assign("ebay_username", (isset($_REQUEST["ebay_username"]) ? $_REQUEST["ebay_username"] : ""));
$smarty->assign("name", (isset($_REQUEST["name"]) ? $_REQUEST["name"] : ""));
$smarty->assign("email", (isset($_REQUEST["email"]) ? $_REQUEST["email"] : ""));
$smarty->assign("paypal", (isset($_REQUEST["paypal"]) ? $_REQUEST["paypal"] : ""));
$smarty->display('signup.tpl');

?>
