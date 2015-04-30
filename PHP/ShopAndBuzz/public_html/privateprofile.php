<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$me_user->IsProperlyRegistered();

$cs_1_last_update = $dbh->SelectSingleValue("to_char(add_date, 'MM/DD/YYYY HH24:MI')", "commission_schedule", "comm_level = 1 and buzz_user_id = " . $user->GetMyID());
$cs_2_last_update = $dbh->SelectSingleValue("to_char(add_date, 'MM/DD/YYYY HH24:MI')", "commission_schedule", "comm_level = 2 and buzz_user_id = " . $user->GetMyID());

$displayMakePayment = true;

#$displayMakePayment = $user->NumOpenComms();

$smarty->assign("userlabel", $user->getDisplayName() . "'s");
$smarty->assign("user_obj", $user);
$smarty->assign("cs_1_last_update", $cs_1_last_update);
$smarty->assign("cs_2_last_update", $cs_2_last_update);
$smarty->assign("error_text", (isset($_REQUEST["error_text"]) ? $_REQUEST["error_text"] : False));
$smarty->assign("seller_status", $user->GetMyStatus());
$smarty->assign("seller_profile", $user->GetSellerProfile());
$smarty->assign("me_hive_count", $user->GetCountHivesContainsMe());
$smarty->assign("hive_count", $user->GetCountHive());
$smarty->assign("me_honeycomb_count", $user->GetCountHoneycombsContainsMe());
$smarty->assign("honeycomb_count", $user->GetCountHoneycomb());
$smarty->assign("ebay_standing", $user->GetEbayStatus());
$smarty->assign("displayMakePayment", $displayMakePayment);

$smarty->assign("invites_count", $user->GetInviteCount());

list($paid_count, $paid_amount) = $dbh->SelectFirstRow("count(1), translate(to_char(coalesce(sum(amount), 0), '$99,999,999.99'), ' ', '') ", "paid_comms", "paid_date + '6 months' > now() and seller_id = " . $user->GetMyID());
list($pending_paid_count, $pending_paid_amount) = $dbh->SelectFirstRow("count(1), translate(to_char(coalesce(sum(amount), 0), '$99,999,999.99'), ' ', '') ", "open_comm", "seller_id = " . $user->GetMyID());
list($pending_received_count, $pending_received_amount) = $dbh->SelectFirstRow("count(1), translate(to_char(coalesce(sum(amount), 0), '$99,999,999.99'), ' ', '') ", "open_comm", "buzz_user_id = " . $user->GetMyID());
list($received_count, $received_amount) = $dbh->SelectFirstRow("count(1), translate(to_char(coalesce(sum(amount), 0), '$99,999,999.99'), ' ', '') ", "paid_comms", "paid_date + '6 months' > now() and payee_id = " . $user->GetMyID());

$smarty->assign("paid_count", $paid_count);
$smarty->assign("paid_amount", $paid_amount);
$smarty->assign("pending_paid_count", $pending_paid_count);
$smarty->assign("pending_paid_amount", $pending_paid_amount);
$smarty->assign("pending_received_count", $pending_received_count);
$smarty->assign("pending_received_amount", $pending_received_amount);
$smarty->assign("received_count", $received_count);
$smarty->assign("received_amount", $received_amount);

$smarty->display('privateprofile.tpl');

?>
