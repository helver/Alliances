<?php
$debug = 0;
require_once("../Libs/common.inc");
include_once("Template.inc");
$page = new Open_Page($dbh);
auth_check($page, $dbh);

if(isset($_REQUEST["username"]) && $_REQUEST["username"] != "") {
    $username = $_REQUEST["username"];
} else {
    $username = "";
}

if(isset($_REQUEST["emailaddy"]) && $_REQUEST["emailaddy"] != "") {
    $emailaddy = $_REQUEST["emailaddy"];
} else {
    $emailaddy = "";
}

if(isset($_REQUEST["ebay_username"]) && $_REQUEST["ebay_username"] != "") {
    $ebay_username = $_REQUEST["ebay_username"];
} else {
    $ebay_username = "";
}


# If $username has a non-null value, look it up and send the
# password to the email address on the account.

# If the $emailaddy has a non-null value, look it up and send
# the username to the email addy.

//if(1) {
  # Development Case
//  print("This functionality has not been implemented yet.</br>\n");
//  print("Click <a href=\"/forgot/sent/\">here</a> for the next step in the chain.<br>\n");
//} else {
  # Production Case
 

if($username != "") {
	$res = $dbh->Select("password, email", "buzz_user", "lower(username) = lower('$username')");
	$password = $res[0]["password"];
	$emailaddy = $res[0]["email"];
	
	//passwordForgot.tpl
	$fields = array("password" => $password, "SiteURL" => $GLOBALS["SiteURL"]);
	$templ = new Template($fields);
	$body = $templ->load_file($templ->getTemplateName("passwordForgot.tpl", "EmailTemplates"));

} elseif ($ebay_username != "") {
    $res = $dbh->Select("b.password, b.username", "buzz_user b, ebay e", "b.id = e.buzz_user_id and lower(ebay_username) = lower('$ebay_username')");
    if ($res[0]["username"] != "") {
        $password = $res[0]["password"];
        $username = $res[0]["username"];
        $fields = array("username" => $username, "SiteURL" => $GLOBALS["SiteURL"]);
        $templ = new Template($fields);
        $body = $templ->load_file($templ->getTemplateName("usernameForgot.tpl", "EmailTemplates"));
    }
} elseif ($emailaddy != "") {
	$res = $dbh->Select("password, username", "buzz_user", "lower(email) = lower('$emailaddy')");
	if ($res[0]["username"] != "") {
		$password = $res[0]["password"];
		$username = $res[0]["username"];
		$fields = array("username" => $username, "SiteURL" => $GLOBALS["SiteURL"]);
       	$templ = new Template($fields);
       	$body = $templ->load_file($templ->getTemplateName("usernameForgot.tpl", "EmailTemplates"));
	} else {
		$fields = array("SiteURL" => $GLOBALS["SiteURL"]);
        $templ = new Template($fields);
		$body = $templ->load_file($templ->getTemplateName("noAccountForgot.tpl", "EmailTemplates"));
	} 
}
	SendEmail($emailaddy, "From: Shop And Buzz Support <support@shopandbuzz.com>", "Shop And Buzz Member Support", $body);

header("Location: /forgot/sent/");

exit();

?>
