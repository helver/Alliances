<?php

  require_once ("../Libs/Ses_Objects/inc.page.php");

  $page = new User_Page();
  //$page = new Admin_Page();

  $html = "Nope";
  if ($page->user_allowed()) {
    $html = "Great";
  }

  echo $html;
?>
