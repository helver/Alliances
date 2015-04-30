<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");
include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

if(isset($_REQUEST["error_message"])) {
    $smarty->assign("error_message", $_REQUEST["error_message"]);
}

$res = $dbh->SelectFirstRow("fee_schedule_id, subscription_active", "seller_profile", "buzz_user_id = " . $user->GetMyID());

if(is_array($res)) {
  $signed_up = ($res["subscription_active"] == "t" ? true : false);
  $coupon_code = $res["fee_schedule_id"];
} else {
  $coupon_code = "";
  $signed_up = false;
}

if($signed_up) {
   header("Location: /users/" . $user->GetDisplayName() . "/seller_profile/");
   exit();
}

$smarty->assign("coupon_code", $coupon_code);

$smarty->display('coupon_code_form.tpl');
?>
