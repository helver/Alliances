<?php
$debug = 0;
require_once("form_elements.inc");
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

$text_images = array();
$notext_images = array();
$thematics_dir = opendir("thematics");
while($thematics_file_name = readdir($thematics_dir)) {
    $path_info = pathinfo($thematics_file_name);
    #print_r($path_info);
    if(ereg("^widget.*_text\.gif$", $thematics_file_name)) {
       #print("Found text widget: $thematics_file_name<br>\n");
       $text_images[] = $thematics_file_name;
    }
    if(ereg("^widget.*_notext\.gif$", $thematics_file_name)) {
       #print("Found no text widget: $thematics_file_name<br>\n");
       $notext_images[] = $thematics_file_name;
    }
}
sort($text_images);
sort($notext_images);

$js_libs = array("widget_tool.js");

$text_text = array();
$text_text[] = "eBay buyers, <a href=\"" . $GLOBALS["SiteURL"] . "/users/" . $user->GetDisplayName() . "/\">earn money</a> by telling friends about " . $user->eBay_get_username() . ".";
$text_text[] = "Love " . $user->eBay_get_username() . "? <a href=\"" . $GLOBALS["SiteURL"] . "/users/" . $user->GetDisplayName() . "/\">Earn commissions</a> for repeat business and telling friends!";
$text_text[] = "Visit <a href=\"" . $GLOBALS["SiteURL"] . "/users/" . $user->GetDisplayName() . "/\">our</a> ShopAndBuzz profile.";
$text_text[] = "Visit <a href=\"" . $GLOBALS["SiteURL"] . "/users/" . $user->GetDisplayName() . "/\">my</a> ShopAndBuzz profile.";

$smarty->assign("js_libs", $js_libs);
$smarty->assign("text_images", $text_images);
$smarty->assign("notext_images", $notext_images);
$smarty->assign("text_text", $text_text);

$smarty->display('widget_tool.tpl');

?>
