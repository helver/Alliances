<?php
require_once("../Libs/common.inc");

$page = new Private_Page($dbh, $_REQUEST["user"]);

require_once("../Libs/common_smarty.inc");

$smarty->assign("user", $_REQUEST["user"]);
$smarty->assign("me", "i_am_me");

$smarty->assign("blacklist", array(array("user"=>"poodiddly"), array("user"=>"mammajamma")));

$smarty->assign("delivery_schedule", "Immediate");

$smarty->assign("delivery_schedules", array(array("name"=>"Immediate", "id"=>1), array("name"=>"Daily", "id"=>2)));

$smarty->display('userprefs.tpl');

?>
