<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Open_Page($dbh);
require_once("../Libs/common_smarty.inc");

if($debug >= 3) {
  if(isset($_REQUEST["searchstring"])) {
    print "here: " . $_REQUEST["searchstring"];
  }
}

if(isset($_REQUEST['searchstring']) && $_REQUEST['searchstring'] != "") {
  $ss = " and (lower(username) like lower('%" . $_REQUEST['searchstring'] . "%') or lower(email) like lower('%" . $_REQUEST['searchstring'] . "%'))";
} else {
  $ss = "";
}

if(isset($_REQUEST['cat']) && $_REQUEST['cat'] != "") {
  $ss .= " and sc.id = " . $_REQUEST['cat'];
} else {
  $ss .= "";
}

if($debug >= 3) {
  print("SS: $ss<br>\n");
  #print("me_user: $me_user<br>\n");
}

$_form_elem_class="whitetext";

$seller_name_box = display_text_field("searchstring", "", "Search Name/Email", array("size"=>15, "maxlength"=>80), 0);
$category_box = display_popup_menu("cat", "", "Search Category", array("id,name", "seller_category", "", $dbh, "Choose", "name", "", ""), 0);

$filter_widgets = "<form method=\"GET\"><table border=\"0\">$seller_name_box$category_box<tr><td colspan=\"2\" align=\"center\" class=\"whitetext\"><input type=\"submit\" value=\"Search Sellers\"></td></tr></table></form>\n";

$smarty->assign("filter_widgets", $filter_widgets);

if(!isset($me_user) || $me_user == "") {
    $res = $dbh->Select("b.username as user, " .
                        "sc.id as category_id, " .
                        "sc.name as category, " .
                        "eb.ebay_username as ebay_username, " .
                        "p.description as seller_desc", 
    
                        "(((buzz_user b " .
                        "inner join seller_profile p on b.id = p.buzz_user_id) " .
                        "inner join ebay eb on eb.buzz_user_id = p.buzz_user_id) " .
                        "inner join seller_category sc on sc.id = p.category_id) ",
    
                        "p.subscription_active='t' " . $ss,
    
                        "b.username"); 

    $template_file = 'sellers_list_unloggedin.tpl';
     
} else {
    $res = $dbh->Select("b.username as user, " .
                        "sc.id as category_id, " .
                        "sc.name as category, " .
                        "r.reco_id as reco, " .
                        "eb.ebay_username as ebay_username, " .
                        "p.description as seller_desc", 
    
                        "(((((buzz_user b " .
                        "inner join seller_profile p on b.id = p.buzz_user_id) " .
                        "inner join ebay eb on eb.buzz_user_id = p.buzz_user_id) " .
                        "inner join seller_category sc on sc.id = p.category_id) " .
                        "left outer join blocked_emails bl on (bl.to_id = b.id and bl.from_id = " . $me_user->GetMyID() . ")) " .
                        "left outer join recommendation r on (r.seller_id = b.id and r.buzz_user_id = " . $me_user->GetMyID() . "))",
    
                        "p.subscription_active='t' and b.id != " . $me_user->GetMyID() . " and bl.to_id is NULL " . $ss,
    
                        "b.username");
                        
    $template_file = 'sellers_list.tpl';
     
}

$smarty->assign("sellers", $res);

$smarty->display($template_file);

?>
