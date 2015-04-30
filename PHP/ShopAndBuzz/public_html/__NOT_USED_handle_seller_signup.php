<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$myName = $user->GetDisplayName();

//SHould I pull this from the Ebay API and just have them enter their ebay username?????

$vals = array("ebayusername" => $_REQUEST["name"],
		"feedback" => $_REQUEST["feedback"],	
		"positive_pct" => $_REQUEST["positive"],
		"power_seller" => $_REQUEST["powerseller"],
);

$resEbay = $dbh->Insert("ebay", $vals);

$resPaypal = $dbh->Insert("paypal", array("paypal_email" => $_REQUEST["paypal"]));

header("Location: /users/$myName/");
exit();

?>
