<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

if(!isset($_REQUEST["comm_level"]) || $_REQUEST["comm_level"] == ""){
	if($debug <= 1) {
		header("Location: /users/" . $_REQUEST["user"] . "/private/");
	}
	exit();
}

if($_REQUEST["comm_level"] == 1) {
	$cl_prefix = "buyer_";
} else {
	$cl_prefix = "referer_";
}

$fields = array(
	"buzz_user_id" => $user->GetMyID(),
	"comm_level" => $_REQUEST["comm_level"],
	"active" => 't',
	"add_date" => 'now',
	"remain" => (isset($_REQUEST[$cl_prefix . "max_limit"]) ? $_REQUEST[$cl_prefix . "max_limit"] : ""),
    "amount" => (isset($_REQUEST[$cl_prefix . "amount"]) ? $_REQUEST[$cl_prefix . "amount"] : ""),
    "max_limit" => (isset($_REQUEST[$cl_prefix . "max_limit"]) ? $_REQUEST[$cl_prefix . "max_limit"] : ""),
    "min_pay_threshold" => (isset($_REQUEST[$cl_prefix . "min_pay_threshold"]) ? $_REQUEST[$cl_prefix . "min_pay_threshold"] : ""),
    "max_amount" => (isset($_REQUEST[$cl_prefix . "max_amount"]) ? $_REQUEST[$cl_prefix . "max_amount"] : ""),
    "pay_type" => (isset($_REQUEST[$cl_prefix . "pay_type"]) ? $_REQUEST[$cl_prefix . "pay_type"] : ""),
    "limit_type" => (isset($_REQUEST[$cl_prefix . "limit_type"]) ? $_REQUEST[$cl_prefix . "limit_type"] : ""),
);

foreach($fields as $k=>$v) {
	if($v == "") {
		unset($fields[$k]);
	}
}

$where_clause = "comm_level = " . $_REQUEST["comm_level"] . " and buzz_user_id = " . $user->GetMyID();

$dbh->Update("commission_schedule", array("active"=>'f'), $where_clause);
$dbh->Insert("commission_schedule", $fields);

if($debug <= 1) {
  header("Location: /users/" . $user->GetDisplayName() . "/commission_schedule/");
}
exit();

?>
