<?php
$debug=0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$smarty->assign("blacklist", $user->GetMyBlacklist());

$xx = $user->GetMyEmailFreq();
print("xx: $xx<Br>\n");

$smarty->assign("delivery_schedule", $xx);
$smarty->assign("delivery_schedules", GetEmailFreq($dbh));

$buzz_user_profile_rec = $dbh->SelectFirstRow("*", "buzz_user_profile", "buzz_user_id = " . $user->GetMyID());

$smarty->assign("paypal_email", ($buzz_user_profile_rec["paypal_email"] != "" ? $buzz_user_profile_rec["paypal_email"] : ""));
$smarty->assign("user_desc", ($buzz_user_profile_rec["description"] != "" ? $buzz_user_profile_rec["description"] : ""));

$smarty->display('userprefs.tpl');

?>
