<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
auth_check($page, $dbh);

if(!isset($_REQUEST["template"])) {
    header("Location: /admin/files/");
    exit();
}

$template = $_REQUEST["template"];

if(!isset($_REQUEST["timestamp"])) {
    $timestamp = time();

    #print_r($_FILES);

    move_uploaded_file($_FILES['template_contents']['tmp_name'], "templates/$template.tpl.$timestamp");
    chmod("templates/$template.tpl.$timestamp", 0666);
}  else {
    $timestamp = $_REQUEST["timestamp"];
}

if(!file_exists("templates/$template.tpl.$timestamp")) {
    header("Location: /admin/files/");
    exit();
}

copy("templates/$template.tpl.$timestamp", "templates/$template.tpl");

if($debug == 0) {
    header("Location: /admin/files/$template/");
    exit();
}

?>
