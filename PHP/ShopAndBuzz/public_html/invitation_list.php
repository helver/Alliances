<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$smarty->assign("invitations", $user->GetMyInvites());

$smarty->display('invitation_list.tpl');

?>
