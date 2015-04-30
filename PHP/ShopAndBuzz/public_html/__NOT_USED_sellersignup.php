<?php
$debug = 5;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $user);
require_once("../Libs/common_smarty.inc");

$smarty->display('seller_signup.tpl');
?>
