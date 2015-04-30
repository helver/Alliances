<?php
#error_reporting(2047);
$debug = 0;
require_once("../Libs/common.inc");
$page = new Public_Page($dbh, "");
require_once("../Libs/common_smarty.inc");
require_once("Bus_Objects/inc.ebay_functions.php");

include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

$fields = array(
  "subscription_signup_nonce" => md5(uniqid(rand(), true)),
);

if(isset($_REQUEST["category_id"]) && $_REQUEST["category_id"] != "") {
  $fields["category_id"] = $_REQUEST["category_id"];
}

if(isset($_REQUEST["description"])) {
  $fields["description"] = $_REQUEST["description"];
}

if($config->getAttribute("SellerFeedbackCheck")) {
    #print("feedback_data: $feedback_data<br>\n");
    #print_r($feedback_data);
    
    $feedback_data = $feedback_data[0];
    
    #print_r($feedback_data);
    #exit();
    
    $com_tot = $feedback_data["UniqueNegativeFeedbackCount"] + $feedback_data["UniquePositiveFeedbackCount"];
    if($com_tot > 0) {
        $com_per = $feedback_data["UniquePositiveFeedbackCount"] / ($com_tot * 1.0);
    }
     
    if($feedback_data["FeedbackScore"] < 100 || $com_tot == 0 || $com_per < .98) {
        $err = "We are unable to process your request because your eBay feedback values do not meet " . 
               "the minimums required of Shop & Buzz Sellers.  Please concentrate your efforts on " .
               "improving your feedback scores then sign up with Shop & Buzz again.";
               
        $loc = "/users/" . $me_user->GetDisplayName() . "/seller_profile/?error_message=" . urlencode($err);
        header("Location: $loc");
        exit();
    }
}

$has_profile = $dbh->SelectSingleValue("subscription_active", "seller_profile", "buzz_user_id = " . $me_user->GetMyID());


function getFeeSchedule($dbh, $user_id)
{
  if(isset($_REQUEST["coupon_code"]) && $_REQUEST["coupon_code"] != "") {
    $cpn_cde = $_REQUEST["coupon_code"];
    
    $fee_sched_id = $dbh->SelectSingleValue("id", "fee_schedule", "coupon_code = '$cpn_cde' and (start_date is NULL or start_date < now()) and (end_date is NULL or end_date > now())");
    if($fee_sched_id < 0) {
        $fee_sched_id = 1;
    }
  } else {
    $fee_sched_id = 1;
  }
  
  return $fee_sched_id;
}


if($has_profile == 't') {
  $dbh->Update("seller_profile", $fields, "buzz_user_id = " . $me_user->GetMyID());

  if($debug <= 1) {
    header("Location: /users/" . $me_user->GetDisplayName() . "/");
  }

} else {
  if($has_profile == 'f') {
      $fee_sched_id = $dbh->SelectSingleValue("fee_schedule_id", "seller_profile", "buzz_user_id = " . $me_user->GetMyID());

      if($fee_sched_id < 1) {
        $fee_sched_id = getFeeSchedule($dbh, $fields["buzz_user_id"]);
      }
      $fields['fee_schedule_id'] = $fee_sched_id;
      
      $dbh->Update("seller_profile", $fields, "buzz_user_id = " . $me_user->GetMyID());

  } else {
      $fields["buzz_user_id"] = $me_user->GetMyID();
      
      $fee_sched_id = getFeeSchedule($dbh, $fields["buzz_user_id"]);
      
      $fields["fee_schedule_id"] = $fee_sched_id;
    
      $dbh->Insert("seller_profile", $fields);
  }
  
  $fee_sched = $dbh->SelectFirstRow("*", "fee_schedule", "id = $fee_sched_id");
  
  $smarty->assign("months_free", $fee_sched["months_free"]);
  $smarty->assign("monthly_rate", $fee_sched["monthly_rate"]);
  $smarty->assign("paypalURL", $config->getAttribute("paypalURL"));
  $smarty->assign("paypalAccount", $config->getAttribute("paypalAccount"));
  $smarty->assign("returnURL", $GLOBALS["SiteHTTPSURL"]);
  $smarty->assign("item_number", $fields["subscription_signup_nonce"]);
  $smarty->assign("custom_text", 0);
  
  $smarty->display('subscribe.tpl');
}
exit();

?>
