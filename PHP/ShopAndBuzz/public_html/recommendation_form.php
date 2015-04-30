<?php
$debug = 0;
require_once("../Libs/common.inc");

if(!isset($_REQUEST["user"]) || $_REQUEST["user"] == "") {
	if($debug <= 1) {
		header("Location: /users/" . $_REQUEST["user"] . "/");
	}
	exit();
}

$page = new Public_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");


if($me_user->CheckMyReco($_REQUEST["user"]) > 0) {
	if($debug <= 1) {
	    header("Location: " . $_SERVER['HTTP_REFERER'] );
	}
}

$smarty->assign("seller", $_REQUEST["user"]);
$smarty->display('recommendation.tpl');


?>
