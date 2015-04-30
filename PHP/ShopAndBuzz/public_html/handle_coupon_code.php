<?php
#error_reporting(2047);
$debug = 0;
require_once("../Libs/common.inc");
$page = new Public_Page($dbh, "");
require_once("../Libs/common_smarty.inc");
require_once("Bus_Objects/inc.ebay_functions.php");

include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

if(!isset($_REQUEST["coupon_code"]) || $_REQUEST["coupon_code"] == "") {
  header("Location: /users/" . $me_user->GetDisplayName() . "/couponcode/");
  exit();
}

$has_profile = $dbh->SelectSingleValue("subscription_active", "seller_profile", "buzz_user_id = " . $me_user->GetMyID());

if($has_profile == 't') {
  header("Location: /users/" . $me_user->GetDisplayName() . "/seller_profile/");
  exit();
}

$fields = array();

$fields["buzz_user_id"] = $me_user->GetMyID();
  
$cpn_cde = $_REQUEST["coupon_code"];

$fee_sched_id = $dbh->SelectSingleValue("id", "fee_schedule", "coupon_code = '$cpn_cde' and (start_date is NULL or start_date < now()) and (end_date is NULL or end_date > now())");
if($fee_sched_id < 0) {
    $fee_sched_id = 1;
}
  
$fields["fee_schedule_id"] = $fee_sched_id;

$fee_sched = $dbh->SelectFirstRow("*", "fee_schedule", "id = $fee_sched_id");

$smarty->assign("fee_sched", $fee_sched_id);
$smarty->assign("coupon_code", $cpn_cde);
$smarty->assign("months_free", $fee_sched["months_free"]);
$smarty->assign("monthly_rate", $fee_sched["monthly_rate"]);
  
$smarty->display('coupon_code_form2.tpl');
?>
