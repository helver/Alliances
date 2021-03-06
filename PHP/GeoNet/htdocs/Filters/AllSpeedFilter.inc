<?php
  #########################################
  #
  # GeoNet
  #
  # AllSpeedFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-03-21 19:56:42 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Customer.
  #
  #########################################

include_once("FilterBase.inc");

class AllSpeedFilter extends FilterBase
{
  function AllSpeedFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fallspeedid", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "speed_id in (select id from speeds where relative_id = " . $this->value . ")";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    global $projectName;
    
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">Speed Rating:</span><br>\n" .
            popup_menu($this->name, $this->value, "id, all_speeds_for_speed(id)", "speeds", "id in (select distinct relative_id from speeds)", $this->dbh, "All Speeds", "id") .
            "</td>\n";

    return $html;
  }

}
?>