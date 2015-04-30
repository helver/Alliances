<?php
  #########################################
  #
  # GeoNet
  #
  # CauseFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-07-21 19:56:18 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on ause.
  #
  #########################################

include_once("FilterBase.inc");

class CauseFilter extends FilterBase
{
  function CauseFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fcause", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "cause = '" . $this->value . "'";
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

    $html = "<td colspan=\"2\"><span class=\"content\">Cause:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct cause, cause aa", "alarms", "", $this->dbh, "All Causes", "cause") .
            "</td>\n";

    return $html;
  }

}
?>