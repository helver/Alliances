<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$smarty->assign("error_text",$_REQUEST["error_text"]);

$smarty->display('ebay_auth_error.tpl');

?>
