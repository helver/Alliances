<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LeftMenuIndex
 * Author: Eric Helvey
 * Create Date: 12/26/2002
 *
 * Description: Used to generate the Left Menu for the Index and similar pages.
 *
 * Revision: $Revision: 1.11 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/

include_once("Features/LeftMenu.inc");

class LeftMenuIndex extends LeftMenu
{
  function LeftMenuIndex($user, $config, $debug, $dbh = "")
  {
    $this->LeftMenu($user, $config, $debug, $dbh);
    $this->sub_feature["fac_list"] = 1;
  }


  function display_leftside($cust, $facs, $customer)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenuIndex::display_leftside<br>\n");
    }

    $html = $this->leftside_links();
    $html .= $this->customer_facility_list($cust, $facs, $customer);

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::display_leftside<br>\n");
    }

    return $html;
  }

  function leftside_notloggedin_links()
  {
    return array("help");
  }

  function leftside_loggedin_links()
  {
    return array("logoff", "database", "alarms", "outage_report", "outage_clock", "outage_proc", "primus", "tracepath", "help");
  }

}
?>