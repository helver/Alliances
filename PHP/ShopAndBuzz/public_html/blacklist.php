<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$smarty->assign("blacklist", $dbh->Select("b.username as name, b.email as email", "buzz_user b, blocked_emails be", "be.from_id = b.id and be.to_id = " . $user->GetMyID()));

$smarty->display('blacklist_list.tpl');

?>
