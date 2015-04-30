<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
auth_check($page, $dbh);

$user = $_REQUEST["user"];

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "activate") {
  list($ok, $email) = $dbh->SelectFirstRow("id, email", "suspended_user", "username = '$user'");
  if($ok > 0) {
    $dbh->Insert("buzz_user", "select * from suspended_user where id = $ok");
    $dbh->Delete("suspended_user", "id = $ok");
  }
  $op = $_REQUEST["op"] . "d";
}

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "inactivate") {
  list($ok, $email) = $dbh->SelectFirstRow("id, email", "buzz_user", "username = '$user'");
  if($ok > 0) {
    $dbh->Insert("suspended_user", "select * from buzz_user where id = $ok");
    $dbh->Delete("buzz_user", "id = $ok");
  }
  $op = $_REQUEST["op"] . "d";
}

$t_user = new aswas_user($dbh);
$t_user->LoadUser($_REQUEST["user"]);

$fields = array("user" => $user, "op" => $op, "SiteURL" => $GLOBALS["SiteURL"]);
$t_user->deliverEmail($t_user->GetMyID(), "activate.tpl", $fields, "Account Administrative Action");

header("Location: " . $_SERVER["HTTP_REFERER"]);
exit();

?>
