<?php
  #########################################
  #
  # GeoNet
  #
  # CustomerFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.2 $
  # Last Change Date: $Date: 2006-07-18 21:31:56 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Customer.
  #
  #########################################

include_once("FilterBase.inc");

class CustomerXXXFilter extends FilterBase
{
  function CustomerXXXFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fcustomerxxx", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    global $user;

    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "id in (select outage_proc_id from proc_customer_map where customer_id = " . $this->value . ")";
    } else {
      $custs = array_keys($user->info["customerlist"]);
      $wair = "id in (select outage_proc_id from proc_customer_map where customer_id in (" . join(",", $custs) . "))";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    global $projectName;
    global $user;
    
    $custs = array_keys($user->info["customerlist"]);
    
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">Customer:</span><br>\n" .
            popup_menu($this->name, $this->value, "id, name", "customers", "id in (" . join(",", $custs) . ")", $this->dbh, "All Customers", "name") .
            "</td>\n";

    return $html;
  }

}
?>