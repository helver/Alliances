#!/usr/bin/php
<?php

// This will generate an error if you run it from the Bin directory by hand.
// It is expected that this will run from cron, which expects to be in the
// home directory for the account.
chdir ("Bin");

include_once ("../Libs/common.inc");
include_once ("Bus_Objects/inc.aswas_user.php");
include_once ("Bus_Objects/inc.ebay_functions.php");

if (!$dbh->validConnection()) {
  print "Connection database failed attempting to run GoodStanding.php";
  exit;
} 

$res = $dbh->Select ("username", "buzz_user");

foreach ($res as $row) {
  $user = new aswas_user($dbh);
  $user->LoadUser($row[0]);

  $value = getEbayStatus($user);

  $userId = $user->GetMyID();

  echo $row[0] . "(" . $user->GetMyID() . ") -- $value\n";

  $upd = array();

  $upd['ebay_good_standing'] = $value['eBayGoodStanding'];
  $upd['ebay_power_seller'] = $value['SellerLevel'];
  $where = "buzz_user_id = $userId";

  $dbh->Update( "buzz_user_profile", $upd, $where);
}

?>
