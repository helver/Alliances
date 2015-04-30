<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");
include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

#print_r($_SERVER);

#print("Referer:--" . (isset($_SERVER["HTTP_REFERER"]) ? $_SERVER["HTTP_REFERER"] : "") . "--<Br>\n");
#print("Referer:--" . $GLOBALS["SiteURL"] . "--<Br>\n");

#exit();

if(   isset($_COOKIE["SandBUser"]) 
   && $_COOKIE["SandBUser"] != "" 
   && isset($_SERVER["HTTP_REFERER"])
   && $_SERVER["HTTP_REFERER"] != ($GLOBALS["SiteURL"] . "/")
   && (!isset($_REQUEST["redirect"]) || $_REQUEST["redirect"] != "0")
  ) {
    $loc = "/users/" . $_COOKIE["SandBUser"] . "/";
    #print("Loc: $loc<br>\n");
    header("Location: $loc");
    exit();
} 

if(isset($_REQUEST['errormessage'])) {
    $smarty->assign('error_message', $_REQUEST['errormessage']);
} elseif ($config->getAttribute("IndexPageMessage") != "") {
    $smarty->assign('error_message', $config->getAttribute("IndexPageMessage"));
} else {
    $smarty->assign('error_message', '');
}

$num = 25;

$res = $dbh->Select("b.username as user, " .
                    "eb.ebay_username as ebay_username", 

                    "((buzz_user b " .
                    "inner join seller_profile p on b.id = p.buzz_user_id) " .
                    "inner join ebay eb on eb.buzz_user_id = p.buzz_user_id) ",

                    "",

                    "random()", "", "", "limit $num"); 

$names = array();
for($i = 0; isset($res[$i]); $i++) {
    $names[] = $res[$i]["ebay_username"];
}

$smarty->assign("sellernames", join("%2C", $names));
$smarty->assign("num", $num);
$smarty->display('index.tpl');

?>
