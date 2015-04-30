<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$tool = $_REQUEST["victim"];

if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete") {
  $tool = new aswas_user($dbh);
  $tool->LoadUser($_REQUEST["victim"]);
  $user->RemoveBlacklist($tool->GetMyID());
} else {
  $user->AddBlacklist($tool);
}

header("Location: /users/" . $_REQUEST["user"] . "/blacklist/");
exit();

?>
