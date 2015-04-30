<?php

$GLOBALS["CONFIGROOT"] = '/home/beta/Libs';

$our_Lib = '/home/beta/Libs';
set_include_path(get_include_path() . PATH_SEPARATOR . $our_Lib);
$our_Lib = '/ucl/php';
set_include_path(get_include_path() . PATH_SEPARATOR . $our_Lib);

$GLOBALS["SiteHTTPURL"] = "http://beta.shopandbuzz.com:8082";
$GLOBALS["SiteHTTPSURL"] = "https://beta.shopandbuzz.com:4444";

if(isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") {
    $GLOBALS["SiteURL"] = $GLOBALS["SiteHTTPSURL"];
} else {
    $GLOBALS["SiteURL"] = $GLOBALS["SiteHTTPURL"];
}

$GLOBALS["db"] = "beta";
$GLOBALS["db_user"] = "beta";
$GLOBALS["db_pass"] = "g1Ebay";
$GLOBALS["db_server"] = "db";

if (!defined('NOT_A_WEB_PAGE')) {
  require_once ("Ses_Objects/inc.page.php");
}
include_once("PG_DBWrapper.inc");
require_once("Bus_Objects/inc.aswas_user.php");

if(!isset($debug)) {
  $debug = 0;
}

$dbh = new PG_DBWrapper("beta", "g1Ebay", "db", "beta", 0);
$dbh->debug($debug);

function GetEmailFreq($dbh) {
        return $dbh->Select("preference as id, value as name", "email_freq");
}

function SendEmail ($emailAddr, $from, $subject, $body)
{
    global $debug;
    
    if ($debug > 0) {
      echo "DEBUG ON:<br>\n";
    }

    mail($emailAddr, $subject, $body, $from);
}

$user = "";
$me_user = "";

function smarty_auth_check($page, $smarty, $dbh)
{
    global $debug;
    global $user;
    global $me_user;
    
    # Is the user logged in?
    if($page->is_user_active()) {
       $smarty->assign("loggedin", $page->is_user_active());
       $me_user = $page->get_user();
       
       # Is the user allowed on this page?
       if($page->user_allowed()) {
        
          # Yes.  Set up some standard variables.
          $smarty->assign("me_user", $page->get_user()->GetDisplayName());
          $smarty->assign("me_user_obj", $page->get_user());
          
          if(isset($_REQUEST["user"]) && $_REQUEST["user"] != "") {
             $smarty->assign("userlabel", "<a href=\"/users/" . $_REQUEST["user"] . "/\">" . $_REQUEST["user"] . "'s</a>");
             $smarty->assign("user", $_REQUEST["user"]);
             $user = new aswas_user($dbh);
             $user->LoadUser($_REQUEST["user"]);
             $smarty->assign("user_obj", $user);
          }
       } else {
          # No.  Redirect the user to their public profile page.
          
          if($debug < 1) {
            header("Location: /users/" . $page->get_user()->GetDisplayName() . "/");
          }
          exit();
       }
    } else {        
       if(!$page->user_allowed()) {
          # Unloggedin user can't be here.  Redirect to root page.
          if($debug < 1) {
            header("Location: /?redirect=0");
          }
          exit();
       }
    }
}

function auth_check($page, $dbh)
{
    global $debug;
    global $user;
    global $me_user;
    
    # Is the user logged in?
    if($page->is_user_active()) {
       $me_user = $page->get_user();
       
       # Is the user allowed on this page?
       if($page->user_allowed()) {
          if(isset($_REQUEST["user"]) && $_REQUEST["user"] != "") {
             $user = new aswas_user($dbh);
             $user->LoadUser($_REQUEST["user"]);
          }
       } else {
          # No.  Redirect the user to their public profile page.
          
          if($debug < 1) {
            header("Location: /users/" . $page->get_user()->GetDisplayName() . "/");
          }
          exit();
       }
    } else {        
       if(!$page->user_allowed()) {
          # Unloggedin user can't be here.  Redirect to root page.
          if($debug < 1) {
            header("Location: /?redirect=0");
          }
          exit();
       }
    }
}

?>
