<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$theID = $_REQUEST["victim"];

$smarty->assign("invitation", $user->GetMyInvites($theID));

$smarty->display('invitation_detail.tpl');

?>
