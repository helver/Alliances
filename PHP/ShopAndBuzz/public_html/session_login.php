<?php

  require_once ("../Libs/Ses_Objects/inc.user.php");

  $user = new User();
  $user->auth_user(1, "a", "b");

?>

No Error!
