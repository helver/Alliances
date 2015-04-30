<?php
$debug = 0;
require_once("../Libs/common.inc");
//$page = new Public_Page($dbh, $_REQUEST["user"]);
$page = new Open_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$invert = false;
$title_string = "";

if(isset($_REQUEST["invert"]) && $_REQUEST["invert"] == 1) {
	$invert = true;
	$title_string = "Memberships";
}

if($page->is_user_active()) {
$smarty->assign("honeycomb", $user->GetMyHoneycomb(-1, $invert));
$smarty->assign("title_string", $title_string);
$smarty->assign("invert", $invert);

if(!$invert && $me_user->GetMyID() != $user->GetMyID()) {
    $me_user->set_all_ref($user->GetMyHoneycombViewer(-1, $me_user->GetMyID()), $user->GetMyID());
}

$smarty->display('honeycomb_list.tpl');
} else {
	$user2 = new aswas_user($dbh);
        $user2->LoadUser($_REQUEST["user"]);

	$smarty->assign("user", $user2->getDisplayName());
	$smarty->assign("honeycomb", $user2->GetMyHoneycomb(-1, $invert));
	$smarty->assign("title_string", $title_string);
	$smarty->assign("invert", $invert);

	$smarty->display('honeycomb_list_nologgedin.tpl');
}
?>
