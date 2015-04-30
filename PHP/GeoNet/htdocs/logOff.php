<?php
/**
 * Project: GeoNet Monitor
 *
 * logOff.php
 * Author: Eric Helvey
 *
 * Description: Terminates the session and removes session variables from
 *              the session database.
 *
 * Revision: $Revision: 1.9 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/

  // end the session, delete it from the database
  // it does delete the cookie
  #$debug = 5;

  if(!isset($_COOKIE["GeoNet"])) {
    header("Location: index.php");
    exit();
  }

  include_once("ifc_prefs.inc");

  $sess->endSession(0, "index.php");

  header("Location: index.php");
?>
