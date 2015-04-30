<?php
$debug = 0;
require_once("../Libs/common.inc");
//$page = new Public_Page($dbh, $_REQUEST["user"]);
$page = new Open_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

if($page->is_user_active()) {

if(isset($_REQUEST["invert"]) && $_REQUEST["invert"] == 1) {
    $smarty->assign("recommendations", $user->GetRecosAboutMe());
    $smarty->assign("title", "Recommendations About " . $user->GetDisplayName());
    $smarty->assign("invert", true);
    if($me_user->GetMyID() != $user->GetMyID()) {
        $me_user->set_all_ref($user->GetRecosAboutMe(), $user->GetMyID());
    }

} else {
    $smarty->assign("recommendations", $user->GetMyRecos());
    $smarty->assign("title", "Recommendations By " . $user->GetDisplayName());
    $smarty->assign("invert", false);

    if($me_user->GetMyID() != $user->GetMyID()) {
        $me_user->set_all_ref($user->GetMyRecos(), $user->GetMyID());
    }
}

$smarty->display('recommendation_list.tpl');
} else {
	//$dbh->Debug(10);
        $user2 = new aswas_user($dbh);
        $user2->LoadUser($_REQUEST["user"]);
	$smarty->assign("recommendations", $user2->GetMyRecos());
    	$smarty->assign("title", "Recommendations By " . $user2->GetDisplayName());
    	$smarty->assign("invert", false);
	$smarty->display('recommendation_list_nologgedin.tpl');
}
?>
