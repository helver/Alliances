<?php
$debug = 0;
require_once("../Libs/common.inc");
if(!ereg("/signup/$", $_SERVER["HTTP_REFERER"])) {
  header("Location: /");
  exit();
}

$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");
$user = $page->get_user();

$smarty->assign("debug", $debug);
$smarty->assign("email", $user->GetUnconfirmedUserEmail($_REQUEST["user"]));

$smarty->display('sent_confirmation_email.tpl');
?>
