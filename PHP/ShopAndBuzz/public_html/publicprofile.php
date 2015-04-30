<?php
//error_reporting(2047);

$debug = 0;
require_once("../Libs/common.inc");
//$page = new Public_Page($dbh, $_REQUEST["user"]);
$page = new Open_Page($dbh, $_REQUEST["user"]);

//print "Here: " .  $page->is_user_active();

require_once("../Libs/common_smarty.inc");

if($page->is_user_active()) {
  $me_user->IsProperlyRegistered();

  if($user->isValidUsername() < 0) {
        $smarty->display('invalid_user.tpl');
        exit();
  }

  #print("<br><br>past validusername check<br><Br><br>\n");

  $hive_size = 3;
  $hive = $user->GetMyHiveViewer($hive_size, $me_user->GetMyID());
  $hive_size = count($hive);

  $honeycomb_size = 3;
  $honeycomb = $user->GetMyHoneycombViewer($honeycomb_size,  $me_user->GetMyID());
  $honeycomb_size = count($honeycomb);

  $reco_size = 3;
  $recos = $user->GetMyRecos($reco_size);
  $reco_size = count($recos);
  if($reco_size > 0) {
    $reco_size++;
}

$mess_size = 5;
$i_am_me = ($user == $me_user ? true : false);
$mess = $user->GetLogMessages($mess_size, $i_am_me);
$mess_size = count($mess);

$seller_profile = $user->GetSellerProfile();

$smarty->assign("userlabel", $user->getDisplayName() . "'s");
$smarty->assign("user", $user->getDisplayName());
$smarty->assign("random_from_hive", $hive);
$smarty->assign("hive_size", $hive_size);
$smarty->assign("random_from_honeycomb", $honeycomb);
$smarty->assign("honeycomb_size", $honeycomb_size);
$smarty->assign("random_from_reco", $recos);
$smarty->assign("reco_size", $reco_size);
$smarty->assign("latest_updates", $mess);
$smarty->assign("mess_size", $mess_size);
$smarty->assign("news_size", $mess_size + $reco_size + 1);
$smarty->assign("ebay_info", $user->GetMyEbayInfo());
$smarty->assign("myAvgRating", $user->GetMyAvgRating());
$smarty->assign("my_recos", $user->GetRecosAboutMe(3));
$smarty->assign("ebay_username", $user->eBay_get_username());


if($me_user->GetMyID() != $user->GetMyID()) {
    $me_user->set_all_ref($honeycomb, $user->GetMyID());
    $me_user->set_all_ref($recos, $user->GetMyID());
}

$smarty->assign("seller_profile", $seller_profile);
$smarty->assign("has_seller_profile", count($seller_profile));

$smarty->display('publicprofile.tpl');

} else {
	//print "not logged in";
	//$dbh->Debug(10);
	$user2 = new aswas_user($dbh);
	$user2->LoadUser($_REQUEST["user"]);
	$show_count = 3;
	$smarty->assign("userlabel", $user2->getDisplayName() . "'s");
	$smarty->assign("user", $user2->getDisplayName());
	$smarty->assign("random_from_hive", $user2->getMyHive($show_count));
	$smarty->assign("hive_size", $show_count);
	$smarty->assign("random_from_honeycomb", $user2->getMyHoneycomb($show_count));
	$smarty->assign("honeycomb_size", $show_count);
	$smarty->assign("mess_size", $user2->GetLogMessages(3));
	$smarty->assign("news_size", $show_count);
	$smarty->display('publicprofile_nologgedin.tpl');
}
?>
