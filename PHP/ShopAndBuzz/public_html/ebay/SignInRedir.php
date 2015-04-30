<?php
   require_once('../../Libs/common.inc');
//   require_once('variables.php');
   require_once('functions.php');
   include_once ('ConfigFileReader.inc');

   $config = new ConfigFileReader("aswas");
   $ruName = $config->getAttribute('ruName');

   $page = new Public_Page($dbh, "no one");
   //$page = new Private_Page($dbh, $_REQUEST["user"]);
   if (! $page->user_allowed()) {
     echo "Not Allowed or Not Logged In!<BR>\n";
   //  exit;
   }

   $user = $page->get_user();
   $sid = get_sid();

   // We'll need to get the sid back on another page in order
   // to retrieve the user's token.
   $user->eBay_set_sid($sid); 

   $vars = "SignIn&runame=$ruName&sid=$sid";
   $url = $config->getAttribute("signinURL") . '?' . $vars;

   #echo $url . "<BR>\n";

   header("Location: $url");
   exit()
?>
