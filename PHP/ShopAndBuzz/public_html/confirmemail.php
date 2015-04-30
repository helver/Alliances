<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$signuptoken = $_REQUEST["signuptoken"];

$me_user = $page->get_user();
$me_user->ConfirmUnconfirmed($signuptoken);

$count = $dbh->Update("buzz_user", array("email_confirmed" => "t", "email_token"=> "NULL"), "email_token = '$signuptoken'");

$smarty->assign("debug", $debug);
$smarty->assign("user", $me_user->GetDisplayName());

$smarty->display('confirmemail.tpl');

?>
