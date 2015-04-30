<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$smarty->assign("me_user", $user->GetDisplayName());
$smarty->assign("user", $_REQUEST["victim"]);

$user_obj = new aswas_user($dbh);
$user_obj->LoadUser($_REQUEST["victim"]);

$smarty->assign("user_obj", $user_obj);

$smarty->display('honeycomberror.tpl');

?>
