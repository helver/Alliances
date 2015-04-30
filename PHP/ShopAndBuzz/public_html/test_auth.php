<?php
require_once("../Libs/common.inc");

$test_user_name = "eric";

$pages = array("Open" => false,
               "User" => true,
               "Public" => true,
               "Private" => true,
               "Admin" => false,
);

$page = $_REQUEST["page"];

    if($pages[$page]) {
        eval("\$obj = new ${page}_Page(\$dbh, \$test_user_name);");
    } else {
        eval("\$obj = new ${page}_Page(\$dbh);");
    }
    $user = $obj->get_user();
    
    print("{$page}_Page:<br>\n");
    #print("obj: $obj<br>\n");
    print("User Name: " . $obj->get_user()->GetDisplayName() . "<Br>\n");
    print("User Active: " . $obj->is_user_active() . "<br>\n");
    print("User Admin: " . $obj->is_user_admin() . "<br>\n");
    print("User Auth: " . $obj->get_user()->Sess_isAuth() . "<br>\n");
    print("Session User: " . $obj->get_user()->GetDisplayName() . " page_owner: $test_user_name $page: " . $obj->user_allowed() . "<Br>\n");
    print("-------------<br>\n");


?>
