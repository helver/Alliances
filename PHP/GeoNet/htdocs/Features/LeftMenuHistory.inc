<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LeftMenuHistory
 * Author: Eric Helvey
 * Create Date: 12/26/2002
 *
 * Description: LeftMenuHistory is a class used to generate the left 
 *              menu contents on the GeoNet History page.
 *
 * Revision: $Revision: 1.8 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/


include_once("Features/LeftMenu.inc");

class LeftMenuHistory extends LeftMenu
{
  var $customer;

  function LeftMenuHistory($customer, $user, $config, $debug, $dbh = "")
  {
    $this->LeftMenu($user, $config, $debug, $dbh);

    $this->sub_feature["fac_list"] = 1;
    $this->customer = $customer;
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


  function customer_facility_list($cust, $facs, $customer = -1)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenuHistory::customer_facility_list<br>\n");
    }

    return $this->all_customers_facility_list($cust, $facs, $customer);
  }


  function generate_OnLoad()
  {
    return "updateFacList(" . $this->customer . ");";
  }

  function leftside_loggedin_links()
  {
    return array("logoff", "database", "alarms", "outage_report", "outage_clock", "outage_proc", "primus", "tracepath", "help", "home");
  }


}
?>