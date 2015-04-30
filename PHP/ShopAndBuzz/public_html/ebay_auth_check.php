<?php
$local_debug = 0;
require_once("../Libs/common.inc");

if($local_debug > 0) {
  print("me_user: " . $me_user->getDisplayName() . "<br>\n");
  print("user: " . $user->getDisplayName() . "<br>\n");
}

$i_am_me = ($me_user->getDisplayName() == $user->getDisplayName() ? True : False);

if($local_debug > 0) {
  print $me_user->getDisplayName() . "<BR>\n";
  print $user->getDisplayName() . "<BR>\n";
  print $me_user->eBay_get_username() . " : $i_am_me<BR>\n";
}

if ($i_am_me && $me_user->eBay_get_username() != "") {
  $goto = 0;

  if($local_debug > 0) {
    print ">" . $me_user->eBay_get_sid() . "< (sid)<BR>\n";
    print ">" . $me_user->eBay_get_auth() . "< (auth)<BR>\n";
    print ">" . $me_user->eBay_is_auth_expired() . "< (exp)<BR>\n";
  }

  if (($me_user->eBay_get_sid() === 0) && ($me_user->eBay_get_auth() === 0)) {
    if($local_debug > 0) {
      print "no sid, no auth<BR>\n";
    }
    // forward to the SignInRedir.php page
    $goto = "/ebay/SignInRedir.php";
  } elseif ($me_user->eBay_get_auth() && $me_user->eBay_is_auth_expired()) {
    if($local_debug > 0) {
      print "auth expired<BR>\n";
    }
    // forward to the SignInRedir.php page
    $goto = "/ebay/SignInRedir.php";
  } elseif (($me_user->eBay_get_sid() > 0) && ($me_user->eBay_get_auth() == "")) {
    if($local_debug > 0) {
      print "fetching token<BR>\n";
    }
    // forward to the FetchToken.php page
    $goto = "/ebay/FetchToken.php";
  }

  if ($goto) {
    if($local_debug >= 1) {
      print("Going to: $goto<Br>\n");
    }
    if($local_debug <= 1) {
      header("Location: $goto");
    }
    exit();
  }
}

?>
