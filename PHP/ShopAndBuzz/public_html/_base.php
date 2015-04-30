<?php

require '../libs/Smarty.class.php';

$smarty = new Smarty;

$smarty->compile_check = true;
$smarty->debugging = true;

$template_name = "blah"

$smarty->display($template_name . '.tpl');

?>
