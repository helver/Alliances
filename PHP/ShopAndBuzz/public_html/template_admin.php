<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
require_once("../Libs/common_smarty.inc");

$template_file_list = array();
$template_dir = opendir("templates");
while($template_file_name = readdir($template_dir)) {
    if(ereg("\.tpl$", $template_file_name)) {
       $template_file_list[] = ereg_replace("\.tpl$", "", $template_file_name);
    }
}
sort($template_file_list);

$smarty->assign("template_files", $template_file_list);

$smarty->display('template_admin.tpl');

?>
