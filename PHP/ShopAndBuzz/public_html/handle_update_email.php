<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
auth_check($page, $dbh);

if(!isset($_REQUEST["template"])) {
    header("Location: /admin/email/");
    exit();
}

$template = $_REQUEST["template"];

if(!isset($_REQUEST["timestamp"])) {
    $timestamp = time();

    #print_r($_FILES);

    move_uploaded_file($_FILES['template_contents']['tmp_name'], "EmailTemplates/$template.tpl.$timestamp");
    chmod("EmailTemplates/$template.tpl.$timestamp", 0666);
}  else {
    $timestamp = $_REQUEST["timestamp"];
}

if(!file_exists("EmailTemplates/$template.tpl.$timestamp")) {
    header("Location: /admin/email/");
    exit();
}

copy("EmailTemplates/$template.tpl.$timestamp", "EmailTemplates/$template.tpl");

if($debug == 0) {
    header("Location: /admin/email/$template/");
    exit();
}

?>
