<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete") {
  $dbh->Delete("user_profile_mesgs", "id = " . $_REQUEST["mesg_id"] . " and buzz_user_id = " . $user->GetMyID()); 
}

exit();
?>