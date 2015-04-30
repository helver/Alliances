<?php
  #########################################
  #
  # GeoNet
  #
  # TID_IDFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-07-21 19:56:18 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on TID_IDFilter.
  #
  #########################################

include_once("FilterBase.inc");

class TID_IDFilter extends FilterBase
{
  function TID_IDFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("ftidid", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "tid_id = " . $this->value;
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

    $html = "<td colspan=\"2\"><span class=\"content\">TID:</span><br>\n" .
            popup_menu($this->name, $this->value, "id, name", "tids", "id in (select tid_id from tid_facility_map where facility_id in (select id from facilities where customer_id in (" . join(",", $custs) . ")))", $this->dbh, "All CLLIs", "name") .
            "</td>\n";

    return $html;
  }

}
?>