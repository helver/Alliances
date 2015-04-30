<?php
/**
 * Project: GeoNet Monitor
 *
 * auth.inc
 * Author: Eric Helvey
 *
 * Description: This is the auth file.  It defines things related to authentication
 *              and session tracking.
 *
 * Revision: $Revision: 1.20 $
 * Last Change Date: $Date: 2006-02-01 23:16:05 $
 * Last Editor: $Author: eric $
*/


  include_once("SessionTrack.inc");

  // Set up the pages array used by AuthenticateUser and SessionTrack to
  // handle movement through the site.
  $pages = array(
    'loginPage'=>'index.php', 
    'errorPage'=>'index.php', 
    'noAccessPage'=>'colorBlock.php', 
    'logOffPage'=>'index.php', 
    'returnPage'=>(isset($_REQUEST["returnPage"]) ? $_REQUEST["returnPage"] : 'colorBlock.php'));

  // Create a new SessionTrack object.  This automagically handles user
  // authentication, session tracking, and session variables.
  $sess = new SessionTrack($projectName, $projectName, "username", "password", $pages, 86400, $debug);

  $me = $sess->getThisPersonID();

  if (isset($_REQUEST["returnPage"])) {
    if($debug >= 1) {
      print("Going to " . $_REQUEST["returnPage"] . "<br>\n");
    } else {
      header("Location: $_REQUEST[returnPage]");
    }
    exit();
  }
?>