<?php
  #########################################
  #
  # GeoNet
  #
  # StateFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-03-07 22:38:36 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Customer.
  #
  #########################################

include_once("FilterBase.inc");

class StateFilter extends FilterBase
{
  function StateFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fstate", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "state = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    global $projectName;
    
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">State:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct state, state as name", "cities", "", $this->dbh, "All States", "state") .
            "</td>\n";

    return $html;
  }

}
?>