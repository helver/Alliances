<?php

  require_once ("../Libs/Ses_Objects/inc.user.php");

  $user = new User();
  $user->logout();

?>

Logged Out.
