<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Public_Page($dbh, "");
require_once("../Libs/common_smarty.inc");

if(isset($_GET['searchstring']) && $_GET['searchstring'] != "") {
  $ss = "lower(username) like lower('%" . $_GET['searchstring'] . "%')";
} else {
  $ss = "1 = 0";
  $smarty->assign("error_message", "You must enter some filter criteria.");
}

$_form_elem_class="whitetext";

$seller_name_box = display_text_field("searchstring", "", "Search Name/Email", array("size"=>15, "maxlength"=>80), 0);

$filter_widgets = "<form method=\"GET\"><table border=\"0\">$seller_name_box<tr><td colspan=\"2\" align=\"center\" class=\"whitetext\"><input type=\"submit\" value=\"Search Members\"></td></tr></table></form>\n";

$smarty->assign("filter_widgets", $filter_widgets);


$smarty->assign("users", $me_user->GetUsersICanSee($ss));

$smarty->display('users_list.tpl');

?>
