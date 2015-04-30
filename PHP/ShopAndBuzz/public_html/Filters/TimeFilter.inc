<?php
include_once("FilterBase.inc");

class TimeFilter extends FilterBase
{
  function TimeFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("time", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "numDaysOld < " . $this->value ;
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"whitetext\">Time Frame:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct numDays, showText", 
"admin_time_table", "", $this->dbh, "All", "numDays") .
            "</td>\n";

    return $html;
  }

}
?>
