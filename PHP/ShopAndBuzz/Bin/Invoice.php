#!/usr/bin/php
<?php

// This will generate an error if you run it from the Bin directory by hand.
// It is expected that this will run from cron, which expects to be in the
// home directory for the account.
chdir ("Bin");

include_once ("../Libs/common.inc");
include_once ("Bus_Objects/inc.aswas_user.php");
include_once ("Bus_Objects/inc.aswas_transaction.php");

if (!$dbh->validConnection()) {
  print "Connection database failed attempting to run Invoice.php";
  exit;
} 

get_invoice_list($dbh);

?>
