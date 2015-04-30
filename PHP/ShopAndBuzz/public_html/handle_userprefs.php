<?php
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$fields = array();

if(isset($_REQUEST["paypal_email"])) {
  $fields["paypal_email"] = $_REQUEST["paypal_email"];
}

if(isset($_REQUEST["user_desc"])) {
  $fields["description"] = $_REQUEST["user_desc"];
}

$dbh->Update("buzz_user_profile", $fields, "buzz_user_id = " . $user->GetMyID());
  
header("Location: /users/" . $_REQUEST["user"] . "/preferences/");
exit();

?>
