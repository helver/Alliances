<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$dbh->Update("invites", array("nomoreemail"=> 't', 'invite_date'=>'now', 'invite_status'=>'Declined'), "invite_email = '" . $_REQUEST["email"] . "'");

$smarty->assign('email', $_REQUEST['email']);

$smarty->display('nomoreemail.tpl');

?>
