<?php
$debug = 10;
require_once("../Libs/common.inc");

$page = new Admin_Page($dbh, $_REQUEST["user"]);

require_once("../Libs/common_smarty.inc");

if(!isset($_REQUEST["topic"])) {
  $smarty->display('users_admin.tpl');
}

$dbh->Close();
?>
