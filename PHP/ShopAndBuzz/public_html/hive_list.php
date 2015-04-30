<?php
$debug = 0;
require_once("../Libs/common.inc");
//$page = new Public_Page($dbh, $_REQUEST["user"]);
$page = new Open_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$invert = False;
$title_string = "";

if(isset($_REQUEST["invert"]) && $_REQUEST["invert"] == 1) {
	$invert = True;
	$title_string = "Memberships";
}



if($page->is_user_active()) {
	$smarty->assign("hive", $user->GetMyHive(-1, $invert));
	$smarty->assign("title_string", $title_string);
	$smarty->assign("invert", $invert);

	$smarty->display('hive_list.tpl');
} else {
	//$dbh->Debug(10);
	$user2 = new aswas_user($dbh);
        $user2->LoadUser($_REQUEST["user"]);

	$smarty->assign("hive", $user2->GetMyHive(-1, $invert));
	$smarty->assign("userlabel", $user2->getDisplayName() . "'s");
	$smarty->assign("user", $user2->getDisplayName());
        $smarty->assign("title_string", $title_string);
        $smarty->assign("invert", $invert);
	$smarty->display('hive_list_nologgedin.tpl');
}

?>
