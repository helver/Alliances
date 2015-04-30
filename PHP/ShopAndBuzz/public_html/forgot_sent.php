<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

if(!ereg("/forgot/$", $_SERVER["HTTP_REFERER"])) {
  header("Location: /");
  exit();
}

$smarty->display('forgot_sent.tpl');

?>
