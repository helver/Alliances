<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
auth_check($page, $dbh);

if(!isset($_REQUEST["op"]) || ($_REQUEST["op"] != "new" && $_REQUEST["op"] != "replace")) {
    print("Error 2<br>\n");
    if($debug == 0) {
        header("Location: /admin/thematics/");
        exit();
    }
}

if(isset($_FILES["uploadimgfile"])) {
    $u_file = $_FILES["uploadimgfile"];
    if($_REQUEST["op"] == "replace" && isset($_REQUEST["image_file"])) {
        $destfile = $_REQUEST["image_file"];
    } else {
        $xx = pathinfo($u_file['name']);
        $destfile = $xx['basename'];
    }
} elseif(isset($_FILES["uploadcssfile"])) {
    $u_file = $_FILES["uploadcssfile"];
    if($_REQUEST["op"] == "replace" && isset($_REQUEST["css_file"])) {
        $destfile = $_REQUEST["css_file"];
    } else {
        $xx = pathinfo($u_file['name']);
        $destfile = $xx['basename'];
    }
} elseif(isset($_FILES["uploadjsfile"])) {
    $u_file = $_FILES["uploadjsfile"];
    if($_REQUEST["op"] == "replace" && isset($_REQUEST["js_file"])) {
        $destfile = $_REQUEST["js_file"];
    } else {
        $xx = pathinfo($u_file['name']);
        $destfile = $xx['basename'];
    }
} else {
    print("Error 1<br>\n");
    if($debug == 0) {
        header("Location: /admin/thematics/");
        exit();
    }
}

move_uploaded_file($u_file['tmp_name'], "thematics/$destfile");
chmod("thematics/$destfile", 0666);

if($debug == 0) {
    header("Location: /admin/thematics/");
    exit();
}

?>
