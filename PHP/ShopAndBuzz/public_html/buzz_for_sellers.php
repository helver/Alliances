<?php
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$smarty->display('buzz_for_sellers.tpl');

?>
