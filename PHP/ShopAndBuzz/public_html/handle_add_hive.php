<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$t_user = $_REQUEST["new_friend"];

if($debug >= 5) {
  print "user: $t_user";
  print "<br> user2: " . $_REQUEST["new_friend"];
}

$user2 = new aswas_user($dbh);
$user2->LoadUser($_REQUEST["new_friend"]);

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete") {
  $res = $user->RemoveUserFromMyHive($t_user);
} else {
  $res = $user->AddUserToMyHive($t_user);
}

if($res) {
  if($debug <= 2) {
    header("Location: " . $_SERVER['HTTP_REFERER'] );
  }
} else {
	print "Error " . (isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete" ? "Deleting" : "Adding") . " User To Hive";
}
exit();

?>
