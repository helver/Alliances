<?php 
   require_once('../../Libs/common.inc');
   require_once ('Bus_Objects/inc.ebay_request.php');
   require_once ('Bus_Objects/inc.ebay_functions.php');

   $page = new Public_Page($dbh, "noone");
   //$page = new Private_Page($dbh, $_REQUEST["user"]);
   if (! $page->user_allowed()) {
     echo "Not Allowed or Not Logged In!<BR>\n";
   //  exit;
   }
   
   $user = $page->get_user();

   $display = getEbayStatus($user);   
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
 "http://www.w3.org/TR/html4/loose.dtd">

<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<TITLE>Get Status #2</TITLE>
</HEAD>
<BODY>

<P>
Got: > <?php print_r($display);?> <
</P>

</BODY>
</HTML>

