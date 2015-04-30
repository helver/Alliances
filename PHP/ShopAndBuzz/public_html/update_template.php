<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
auth_check($page, $dbh);

if(!isset($_REQUEST["template"])) {
    header("HTTP/1.0 404 Not Found");
    exit();
}

$template = $_REQUEST["template"];

if(!isset($_REQUEST["timestamp"])) {
    require_once("../Libs/common_smarty.inc");

    $template_file_list = array();
    $template_dir = opendir("templates");
    while($template_file_name = readdir($template_dir)) {
        if(strpos($template_file_name, $template) !== false) {
           $timestamp = preg_replace('/^.*\./', "", $template_file_name);
           if($timestamp == "tpl") {
               continue;
           }

           $template_file_list[] = array('uri'=> "$template/$timestamp/", 'date'=> date("r", $timestamp));
        }
    }
    sort($template_file_list);
    
    $smarty->assign("template_files", $template_file_list);
    $smarty->assign("template", $template);
    
    $smarty->display('update_template.tpl');

    exit();
}

$timestamp = $_REQUEST["timestamp"];
$template_file = "templates/$template.tpl.$timestamp";

header("Cache-Control: public, must-revalidate");
header("Pragma: hack");
header("Content-Type: application/octet-stream");
header("Content-Length: " . (string)(filesize($template_file)));
header("Content-Disposition: attachment; filename=\"$template_file\"");
header("Content-Transfer-Encoding: binary\n");

readfile($template_file);

?>
