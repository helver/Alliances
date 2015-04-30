<?php
  #########################################
  #
  # GeoNet
  #
  # ElementTypeFilter.inc
  # Initial Creation Date: 3/4/2005
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-03-08 23:11:00 $
  # Last Editor: $Author: eric $
  #
  #
  # Filter based on Element Type.
  #
  #########################################

include_once("FilterBase.inc");

class ElementTypeFilter extends FilterBase
{
  function ElementTypeFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("felementtype", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    if($this->value != "") {
      $wair = "element_type_id = " . $this->value;
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    global $projectName;
    
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">Element Type:</span><br>\n" .
            popup_menu($this->name, $this->value, "id, name", "element_types", "", $this->dbh, "All Element Types", "name") .
            "</td>\n";

    return $html;
  }

}
?>