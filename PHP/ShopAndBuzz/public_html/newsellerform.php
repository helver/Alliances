<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");
include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

$paypal_email = $dbh->SelectSingleValue("paypal_email", "buzz_user_profile", "buzz_user_id = " . $user->GetMyID());
$ebay_stuff = $dbh->SelectFirstRow("ebay_auth, ebay_username, ebay_exp_date", "ebay", "ebay_exp_date > now() and buzz_user_id = " . $user->GetMyID());

if(isset($_REQUEST["error_message"])) {
    $smarty->assign("error_message", $_REQUEST["error_message"]);
}

$res = $dbh->SelectFirstRow("category_id, fee_schedule_id, description, subscription_active, subscription_start_date, subscription_ended_date", "seller_profile", "buzz_user_id = " . $user->GetMyID());

if(is_array($res)) {
  $cur_category = $res["category_id"];
  $signed_up = ($res["subscription_active"] == "t" ? true : false);
  $cur_desc = $res["description"];
  $was_signed_up = ($res["subscription_start_date"] == "" ? false : true);
  if($res["subscription_active"] == "f" && $res["subscription_ended_date"] == "") {
    $broken_seller_profile = true;
  } else {
    $broken_seller_profile = false;
  }
  $fee_sched_id = $res["fee_schedule_id"];
} else {
  $cur_category = "";
  $cur_desc = "";
  $signed_up = false;
  $was_signed_up = false;
  $broken_seller_profile = false;
  $fee_schedule_id = "";
}

if($fee_schedule_id == "" && !isset($_REQUEST["coupon_code"])) {
  header("Location: /users/" . $user->GetDisplayName() . "/couponcode/");
  exit();
}

$coupon_code = $_REQUEST["coupon_code"];

if(   $paypal_email != "" 
   && (isset($ebay_stuff["ebay_auth"]) && $ebay_stuff["ebay_auth"] != "")
   && (isset($ebay_stuff["ebay_username"]) && $ebay_stuff["ebay_username"] != "")) {

   $smarty->assign("category_list", popup_menu("category_id", $cur_category, "id, name", "seller_category", "", $dbh, "Choose a Category", "name"));
   $smarty->assign("signed_up", $signed_up);
   $smarty->assign("was_signed_up", $was_signed_up);
   $smarty->assign("cur_category", $cur_category);
   $smarty->assign("coupon_code", $coupon_code);
   $smarty->assign("fee_sched", $fee_schedule_id);
   $smarty->assign("cur_desc", $cur_desc);
   $smarty->assign("paypalURL", $config->getAttribute("paypalURL"));
   $smarty->assign("paypalAccount", urlencode($config->getAttribute("paypalAccount")));
   $smarty->assign("broken_seller_profile", $broken_seller_profile);

   $smarty->display('newsellerform.tpl');
} else {
   header("Location: /users/" . $user->GetDisplayName() . "/private/?error_text=" . urlencode("You must have your eBay information complete and up to date and your PayPal email address on file in order to open a Buzz Seller Account."));
   exit();
}

?>
