<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$schedule = $_REQUEST["schedule"];

$user->UpdateEmailFreq($schedule);

header("Location: " . $_SERVER["HTTP_REFERER"]);
exit();

?>
