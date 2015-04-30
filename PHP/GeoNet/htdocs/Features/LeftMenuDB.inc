<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LeftMenuDB
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: LeftMenuDB is a class used to generate the left menu contents 
 *              on the GeoNet Database Access Pages.
 *
 * Revision: $Revision: 1.15 $
 * Last Change Date: $Date: 2005-06-17 14:37:41 $
 * Last Editor: $Author: eric $
*/


include_once("Features/LeftMenu.inc");

class LeftMenuDB extends LeftMenu
{
  function LeftMenuDB(&$user, $config, $debug, $dbh)
  {
    if($debug >= 4) {
      print("user - $user<br>\n");
      print("IsLoggedIn - " . $user->IsLoggedIn() . "<br>\n");
    }

    $this->LeftMenu($user, $config, $debug, $dbh);

    $this->sub_feature["fac_list"] = 0;

    if($debug >= 4) {
      print("IsLoggedIn - " . $this->user->IsLoggedIn() . "<br>\n");
    }
  }


  function display_leftside($cust, $facs, $customer)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenuIndex::display_leftside<br>\n");
    }

    $html = $this->leftside_links();

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::display_leftside<br>\n");
    }

    return $html;
  }

  function leftside_notloggedin_links()
  {
    return array( "help");
  }

  function leftside_loggedin_links()
  {
    return array("logoff", "home", "edit", "new", "delete", "search", "table", "database", "alarms", "outage_report", "outage_clock", "primus", "tracepath", "help");
  }

}
?>