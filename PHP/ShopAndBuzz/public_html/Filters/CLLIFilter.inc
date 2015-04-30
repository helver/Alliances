<?php
include_once("FilterBase.inc");

class CLLIFilter extends FilterBase
{
  function CLLIFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fclli", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "clli = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"content\">CLLI:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct clli, clli as name", "dyn_portconv
ersion", "", $this->dbh, "All CLLIs", "clli") .
            "</td>\n";

    return $html;
  }

}
?>