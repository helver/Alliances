<?php
require_once("../Libs/common.inc");


$dbh->Debug(10);
$page = new Private_Page($dbh, "nick");


$user = $page->get_user();
print "DisplayName: " . $user->GetDisplayName();

//$user->AddMyHiveSession();
$myHive = $user->GetMyHiveSession();

print "hive:" . $myHive[1][0];


?>
