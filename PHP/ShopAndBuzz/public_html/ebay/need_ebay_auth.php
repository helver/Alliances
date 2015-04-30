<?php
$debug = 0;
require_once("../../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../../Libs/common_smarty.inc");

//*** print out the html code
echo "<html>";
echo "<head>";

echo "<meta http-equiv=\"refresh\" content=\"5; URL=" . $GLOBALS["SiteURL"] . "/ebay/SignInRedir.php\">";

echo "</head>";
echo "<body>";
//*** if we want to customize what the page says, put it here
echo "You need to reauthorize with eBay.  You will be redirected to eBay Auth&Auth site in 5 seconds.";
echo "</body>";
echo "</html>";

?>
