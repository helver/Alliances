<?php
$debug = 0;
require_once("../../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../../Libs/common_smarty.inc");

//*** print out the html code
echo "<html>";
echo "<head>";

if (isset($me_user)) {
	echo "<meta http-equiv=\"refresh\" content=\"5; URL=" . $GLOBALS["SiteURL"] . "/users/" . $me_user->GetDisplayName() . "/private/\">";
} else {
	echo "<meta http-equiv=\"refresh\" content=\"5; URL=" . $GLOBALS["SiteURL"] . "/\">";
}

echo "</head>";
echo "<body>";
//*** if we want to customize what the page says, put it here
echo "Thank you for your payment.  You will be redirected back to Shop And Buzz in 5 seconds.";
echo "</body>";
echo "</html>";

?>
