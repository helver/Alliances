#!/usr/bin/php
<?php
include_once ("../Libs/common.inc");
echo "Hello there\n";

$dbh->DEBUG = 1;

if ($dbh->validConnection()) {
  echo "validConnection() returned TRUE\n";
} else {
  echo "validConnection() returned FALSE\n";
}

$res = $dbh->Select ("*", "hive");

echo "query 'select * from hive' returned " . count($res). " row(s):\n";

print_r ($res);

echo "\n";
?>
