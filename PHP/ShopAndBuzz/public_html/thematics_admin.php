<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Admin_Page($dbh);
require_once("../Libs/common_smarty.inc");

$image_file_list = array();
$css_file_list = array();
$js_file_list = array();
$thematics_dir = opendir("thematics");
while($thematics_file_name = readdir($thematics_dir)) {
    $path_info = pathinfo($thematics_file_name);
    #print_r($path_info);
    if(   $path_info['extension'] == 'gif'
       || $path_info['extension'] == 'jpg'
      ) {
       $image_file_list[] = array("filename"=> $thematics_file_name, "display" => $path_info['basename']);
    }
    if(   $path_info['extension'] == 'js'
      ) {
       $js_file_list[] = array("filename"=> $thematics_file_name, "display" => $path_info['basename']);
    }
    if(   $path_info['extension'] == 'css'
      ) {
       $css_file_list[] = array("filename"=> $thematics_file_name, "display" => $path_info['basename']);
    }
}
sort($image_file_list);
sort($js_file_list);
sort($css_file_list);

$smarty->assign("image_files", $image_file_list);
$smarty->assign("js_files", $js_file_list);
$smarty->assign("css_files", $css_file_list);

$smarty->display('thematics_admin.tpl');

?>
