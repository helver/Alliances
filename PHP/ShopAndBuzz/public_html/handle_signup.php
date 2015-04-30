<?php
$debug = 0;
require_once("../Libs/common.inc");
include_once("Template.inc");
$page = new Open_Page($dbh);
auth_check($page, $dbh);

$error = False;
$error_text = "";
$url = "";

if(isset($_REQUEST["username"]) && $_REQUEST["username"] != "") {
  $username = $_REQUEST["username"];
  
  $xcount = $dbh->SelectSingleValue("count(1)", "buzz_user", "username = '$username'");
  $ycount = $dbh->SelectSingleValue("count(1)", "unconfirmed_user", "username = '$username'");
  
  if($xcount > 0 || $ycount > 0) {
    $error = True;
    $error_text .= "<br>Username must be unique.";
  } else {
    $url .= ($url == "" ? "" : "&") . "username=" . urlencode($username);
  }
} else {
  $error = True;
  $error_text .= "<br>Username is required.";
}

#if(isset($_REQUEST["ebay_username"]) && $_REQUEST["ebay_username"] != "") {
#  $ebay_username = $_REQUEST["ebay_username"];
#  $url .= ($url == "" ? "" : "&") . "ebay_username=" . urlencode($ebay_username);
#} else {
  $ebay_username = md5(uniqid(rand(), true));
#}

if(isset($_REQUEST["newpass"]) && $_REQUEST["newpass"] != "") {
  $password = $_REQUEST["newpass"];
} else {
  $error = True;
  $error_text .= "<br>Password is required.";
}

if(isset($_REQUEST["email"]) && $_REQUEST["email"] != "") {
  $email = $_REQUEST["email"];

  $xcount = $dbh->SelectSingleValue("count(1)", "buzz_user", "email = '$email'");
  $ycount = $dbh->SelectSingleValue("count(1)", "unconfirmed_user", "email = '$email'");

  if($xcount > 0 || $ycount > 0) {
    $error = True;
    $error_text .= "<br>Email address must be unique.";
  } else {
    $url .= ($url == "" ? "" : "&") . "email=" . urlencode($email);
  }
} else {
  $error = True;
  $error_text .= "<br>Email is required.";
}

if(isset($_REQUEST["name"]) && $_REQUEST["name"] != "") {
  $name = $_REQUEST["name"];
  $url .= ($url == "" ? "" : "&") . "name=" . urlencode($name);
} else {
  $error = True;
  $error_text .= "<br>Name is required.";
}


$token = $username;

if(isset($_REQUEST["paypal"]) && $_REQUEST["paypal"] != "") {
  $paypal = $_REQUEST["paypal"];

  $xcount = $dbh->SelectSingleValue("count(1)", "buzz_user_profile", "paypal_email = '$paypal'");
  $ycount = $dbh->SelectSingleValue("count(1)", "unconfirmed_user", "paypal_user = '$paypal'");

  if($xcount > 0 || $ycount > 0) {
    $error = True;
    $error_text .= "<br>Paypal Email address must be unique.";
  } else {
    $url .= ($url == "" ? "" : "&") . "paypal=" . urlencode($paypal);
  }
}

if(!$error) {
    //NEED TO ALSO CHECK THE BUZZ_USER TABLE
    if($dbh->SelectSingleValue("count(1) as mycount", "unconfirmed_user", "username='$username' or email='$email'") >= 1) {
         $error = True;
         $error_text .= "<br>You have already requsted an account with this name.  Please Click on the link that was sent to your email address, to confirm your account.";
    }
    
    if($dbh->SelectSingleValue("count(1) as mycount", "buzz_user", "username='$username' or email='$email'") >= 1) {
        $error = True;
        $error_text .= "<br>You are already an user.  Please go to the login page to login: <a href=\"/login\">Login Here</a>.";
    }
}

#print("error: $error; error_text: $error_text<br>\n");

if($error) {
  if($debug <= 1) {
    header("Location: /signup/?$url&error_text=" . urlencode($error_text));
  } else {
    print("error_text = $error_text<br>\n");
  }
  exit();
}

$dbh->Insert("unconfirmed_user",
              array("username" => $username,
                    "email"    => $email,
                    "password" => $password,
                    "ebay_username" => $ebay_username,
                    "token"    => $token,
		            "paypal_user" => $paypal,
                    "realname" => $name,
			));

$me_user = $page->get_user();
$me_user->ConfirmUnconfirmed($token);

$dbh->Update("buzz_user", array("email_token" => $token), "id = " . $me_user->GetMyID());

$mypass = $dbh->SelectSingleValue("password", "buzz_user", "id = " . $me_user->GetMyID());

$me_user->LoginByName($me_user->GetDisplayName(), $password);

$theLink = $GLOBALS["SiteURL"] . "/signup/confirmemail/$token/";

$fields = array("username" => $username, "theLink" => $theLink, "SiteURL" => $GLOBALS["SiteURL"]);
$me_user->deliverEmail($me_user->GetMyID(), "signup.tpl", $fields, "New Shop And Buzz Member Account");

$loc = "/ebay/SignInRedir.php";

if($debug >= 1) {
  print("Going to: $loc<br>\n");
}
if($debug <= 1) {
  header("Location: $loc");
}
exit();

?>
