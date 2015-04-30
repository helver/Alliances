<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
require_once("../Libs/common_smarty.inc");

if(isset($_REQUEST["victim"]) and $_REQUEST["victim"] != "") {
  $t_user = $_REQUEST["victim"];
} elseif(isset($_REQUEST["newfriend_2"]) && $_REQUEST["newfriend_2"] != "") {
  $t_user = $_REQUEST["newfriend_2"];
} else {
  if($debug <= 1) {
    header("Location: " . $_SERVER['HTTP_REFERER'] );
  }
  exit();
}


if(isset($_REQUEST["op"]) && $_REQUEST["op"] == "Delete") {
  #print "Removing<br>\n";
  $res = $user->RemoveUserFromMyHoneyComb($t_user);
} else {
  $res = $user->AddUserToMyHoneyComb($t_user);
}


if($res) {
  $smarty->assign("seller", $t_user);
  $smarty->display('recommendation.tpl');
} else {
  if($debug <= 1) {
    header("Location: /users/" . $user->GetDisplayName() . "/honeycomberror/$t_user/");
  }
}

exit();

?>
