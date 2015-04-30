<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

if(!isset($_REQUEST["victim"]) || $_REQUEST["victim"] == "") {
	if($debug <= 1) {
		header("Location: /users/" . $_REQUEST["user"] . "/recommendations/");
	}
	exit();
}

$seller = $_REQUEST["victim"];

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete") {
	$user->RemoveReco($seller);
    header("HTTP/1.0 200 Done");
    exit();
} else {
    $vals = array(
		"num_purchases" => $_REQUEST["numTrans"],
		"speed_rating" => $_REQUEST["speed"],
		"expect_rating" => $_REQUEST["expect"],
		"value_rating" => $_REQUEST["thevalue"],
		"comm_rating" => $_REQUEST["communication"],
		"exp_rating" => $_REQUEST["overall"],
		"recommend" => $_REQUEST["why"],
	);
	$res = $user->set_reco($seller, $vals);
    
    if($res == 1) {
       $username = $_REQUEST["user"];
       
       $theLink = $GLOBALS["SiteURL"] . "/users/$username/recommendations/$seller/";
       $title = "New Recommendation From $username";
       $sellerid = $dbh->SelectSingleValue("id", "buzz_user", "username = '$seller'");
       
       $recd_seller = new aswas_user($dbh);
       $recd_seller->LoadUser($seller);
       
       $commText = $recd_seller->getCommScheduleDesc();
       
       #$commInfo = $dbh->Select("*", "commission_schedule", "buzz_user_id=$sellerid and active='t' and comm_level=1");
       #$commText = "Seller will pay ";
       #$commText .= ($commInfo["pay_type"] == "percent" ? $commInfo["amount"] . "%" : "$" . $commInfo["amount"]);
       #$commText .= ($commInfo["limit_type"] == "days" ? " for " . $commInfo["max_limit"] . " days." : " for the first ". $commInfo["max_limit"] . " purchases");
       #$commText .= " All purchases must be over $" . $commInfo["min_pay_threshold"] . " and the max commission is $" . $commInfo["max_amount"];
        
       $fields = array("username" => $username,
                       "theLink" => $thisLink,
                       "seller" => $seller,
                       "SiteURL" => $GLOBALS["SiteURL"],
                       "seller_ebayname" => $seller,
                       "recommendation_scores" => $_REQUEST["overall"],
                       "recommendation_description" => $_REQUEST["why"],
                       "seller_discount_information" => $commText,
               );
        $user->hiveDeliverEmail("recommendation.tpl", $fields, $title);
        $user->deliverEmail($sellerid, "recommendation.tpl", $fields, $title);
    }
}

$loc = "/users/" . $_REQUEST["user"] . "/recommendations/$seller/";
if($debug >= 1) {
    print("Would have gone to: $loc<br>\n");
}
if($debug <= 1) {
	header("Location: $loc");
}
exit();

?>
