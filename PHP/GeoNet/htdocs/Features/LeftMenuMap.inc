<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LeftMenuMap
 * Author: Eric Helvey
 * Create Date: 12/26/2002
 *
 * Description: LeftMenuMap is a class used to generate the left menu contents 
 *              on the GeoNet Map page.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/


include_once("Features/LeftMenu.inc");

class LeftMenuMap extends LeftMenu
{
  function LeftMenuMap($user, $config, $debug, $dbh = "")
  {
    $this->LeftMenu($user, $config, $debug, $dbh);
  }


  function display_leftside($cust, $facs, $customer)
  {
    $html = $this->leftside_links();
    $html .= $this->customer_facility_list($cust, $facs, $customer);

    if($this->user->hasAccessLevel("User")) {
      $html .= $this->ack_ticket_list($cust, $facs, $customer);
    }

    return $html;
  }

  function leftside_loggedin_links()
  {
    return array("logoff", "database", "alarms", "outage_report", "outage_clock", "outage_proc", "primus", "tracepath", "help", "home");
  }


}
?>