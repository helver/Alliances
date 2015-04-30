<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

$user = new aswas_user($dbh);
$user->LoadUser($_REQUEST["user"]);

$reco = $user->GetRecoByName($_REQUEST["victim"]);

#print_r($reco);

if(!is_array($reco) || count($reco) < 1) {
    header("Location: /users/" . $_REQUEST["user"] . "/recommendations/");
    exit();
}

$smarty->assign("user", $user->GetDisplayName());
$smarty->assign("recommendation", $reco);
$smarty->display('recommendation_detail.tpl');

if(isset($me_user)) {
    if($me_user->GetMyID() != $user->GetMyID()) {
        $me_user->set_ref($user->GetMyID(), $reco["userid"]);
    }
}

?>
