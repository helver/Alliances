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
  # Last Change Date: $Date: 2005-07-21 19:56:18 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Customer.
  #
  #########################################

include_once("FilterBase.inc");

class CustomerFilter extends FilterBase
{
  function CustomerFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fcustomer", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    global $user;

    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "customer_id = " . $this->value;
    } else {
      $custs = array_keys($user->info["customerlist"]);
      $wair = "customer_id in (" . join(",", $custs) . ")";
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