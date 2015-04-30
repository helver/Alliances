<?php
require_once("../Libs/common.inc");
require_once ("../Libs/Bus_Objects/inc.aswas_user.php");

$user = new aswas_user($dbh);
$user->logout();

header("Location: /");
exit();

?>
