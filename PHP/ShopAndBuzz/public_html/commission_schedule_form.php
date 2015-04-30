<?php
$debug = 0;
require_once("form_elements.inc");
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

if(!$user->IsSeller()) {
  if($debug <= 1) {
    header("Location: /users/" . $_REQUEST["user"] . "/private/");
  }
  exit();
}

$buyer_cs = $dbh->SelectFirstRow("*", "commission_schedule", "active = 't' and comm_level = 1 and buzz_user_id = " . $user->GetMyID());

if(!is_array($buyer_cs) || !isset($buyer_cs["comm_level"]) || $buyer_cs["comm_level"] != 1) {
	$buyer_cs = array(
       "amount" => "",
       "max_limit" => "",
       "min_pay_threshold" => "",
       "max_amount" => "",
       "pay_type" => "",
       "limit_type" => "",
    );
}

$buyer_amount = text_field("buyer_amount", $buyer_cs["amount"], array("size"=>6, "maxlength"=>40));
$buyer_max_limit = text_field("buyer_max_limit", $buyer_cs["max_limit"], array("size"=>6, "maxlength"=>40));
$buyer_min_pay_threshold = text_field("buyer_min_pay_threshold", $buyer_cs["min_pay_threshold"], array("size"=>6, "maxlength"=>40));
$buyer_max_amount = text_field("buyer_max_amount", $buyer_cs["max_amount"], array("size"=>6, "maxlength"=>40));
$buyer_pay_type = popup_menu("buyer_pay_type", $buyer_cs["pay_type"], "showtext, showtext as name", "pay_type", "", $dbh, "", "showtext", "", "");
$buyer_limit_type = popup_menu("buyer_limit_type", $buyer_cs["limit_type"], "showtext, showtext as name", "limit_type", "", $dbh, "", "showtext", "", "");

$referer_cs = $dbh->SelectFirstRow("*", "commission_schedule", "active = 't' and comm_level = 2 and buzz_user_id = " . $user->GetMyID());

if(!is_array($referer_cs) || !isset($referer_cs["comm_level"]) || $referer_cs["comm_level"] != 2) {
	$referer_cs = array(
       "amount" => "",
       "max_limit" => "",
       "min_pay_threshold" => "",
       "max_amount" => "",
       "pay_type" => "",
       "limit_type" => "",
    );
}

$referer_amount = text_field("referer_amount", $referer_cs["amount"], array("size"=>6, "maxlength"=>40));
$referer_max_limit = text_field("referer_max_limit", $referer_cs["max_limit"], array("size"=>6, "maxlength"=>40));
$referer_min_pay_threshold = text_field("referer_min_pay_threshold", $referer_cs["min_pay_threshold"], array("size"=>6, "maxlength"=>40));
$referer_max_amount = text_field("referer_max_amount", $referer_cs["max_amount"], array("size"=>6, "maxlength"=>40));
$referer_pay_type = popup_menu("referer_pay_type", $referer_cs["pay_type"], "showtext, showtext as name", "pay_type", "", $dbh, "", "showtext", "", "");
$referer_limit_type = popup_menu("referer_limit_type", $referer_cs["limit_type"], "showtext, showtext as name", "limit_type", "", $dbh, "", "showtext", "", "");

$smarty->assign("user", $_REQUEST["user"]);
$smarty->assign("user_obj", $user);

$smarty->assign("buyer_amount", $buyer_amount);
$smarty->assign("buyer_max_limit", $buyer_max_limit);
$smarty->assign("buyer_min_pay_threshold", $buyer_min_pay_threshold);
$smarty->assign("buyer_max_amount", $buyer_max_amount);
$smarty->assign("buyer_pay_type", $buyer_pay_type);
$smarty->assign("buyer_limit_type", $buyer_limit_type);

$smarty->assign("referer_amount", $referer_amount);
$smarty->assign("referer_max_limit", $referer_max_limit);
$smarty->assign("referer_min_pay_threshold", $referer_min_pay_threshold);
$smarty->assign("referer_max_amount", $referer_max_amount);
$smarty->assign("referer_pay_type", $referer_pay_type);
$smarty->assign("referer_limit_type", $referer_limit_type);

$smarty->display('commission_schedule.tpl');

?>
