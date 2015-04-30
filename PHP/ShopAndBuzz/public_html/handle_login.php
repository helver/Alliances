<?php
$debug = 0;
require_once("../Libs/common.inc");
require_once("../Libs/Bus_Objects/inc.aswas_user.php");

if(!isset($_REQUEST["username"]) || $_REQUEST["username"] == "" || !isset($_REQUEST["password"]) || $_REQUEST["password"] == "") {
    header("Location: /");
    exit();
}

$user = new aswas_user($dbh);
//$user->auth_user(1, $_REQUEST["username"], $_REQUEST["passowrd"]);

//Need To Check If Login Was Valid!
if($user->LoginByName($_REQUEST["username"], $_REQUEST["password"])) {
    
    $user->AddMyHiveSession();
    $user->AddMyHoneycombSession();
    
    #setcookie("trash", "0");
    $retval = setcookie("SandBUser", $user->GetDisplayName(), time() + (60*60*24*365), "/", ereg_replace("^http://(.*):.*$", "\\1", $GLOBALS["SiteURL"]));
    #print("Cookie retval: $retval<br>\n");
    
    $goto = "/users/" . $_REQUEST["username"] . "/";

    $has_profile = $dbh->SelectFirstRow("subscription_active as act, subscription_ended_date as ed", "seller_profile", "buzz_user_id = " . $user->GetMyID());
    if(is_array($has_profile) && $has_profile["act"] == "f" && $has_profile["ed"] == "") {
        $goto .= "seller_profile/";
    } else {
        if($user->IsProperlyRegistered() && $user->IsSeller()) {
            $active_comm_scheds = $dbh->SelectSingleValue("count(1)", "commission_schedule", "buzz_user_id = " . $user->GetMyID() . " and active = 't'");
            
            if($active_comm_scheds < 2) {
                $goto .= "commission_schedule/";
            }
        }
    }
} else {
    $goto = "/?errormessage=" . urlencode('Username/Password invalid.  Try again, or click <a href="/forgot/">here</a> for a reminder.');
}

if($debug >= 1) {
    print("Going to: $goto<br>\n");
}
if($debug <= 1) {
    header("Location: $goto");
    exit();
}

?>
