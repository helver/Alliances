<?php
  #########################################
  #
  # GeoNet
  #
  # CLLI_TIDFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-03-08 23:11:00 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Customer.
  #
  #########################################

include_once("FilterBase.inc");

class CLLI_TIDFilter extends FilterBase
{
  function CLLI_TIDFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fclli_tid", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "clli_tid = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    global $projectName;
    
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">CLLI:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct clli_tid, clli_tid as name", "cities", "", $this->dbh, "All CLLIs", "clli_tid") .
            "</td>\n";

    return $html;
  }

}
?>