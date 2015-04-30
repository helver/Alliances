<?php
include_once("FilterBase.inc");

class ActiveUserFilter extends FilterBase
{
  function ActiveUserFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("factive_user", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "active_user = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    
    $label = "Active Users";
    
    $html = "<td colspan=\"2\"><span class=\"whitetext\">$label:</span><br>\n" .
            array_menu($this->name, array("" => "All Users", "t"=>"Active Users Only", "f"=>"Inactive Users Only"), $this->value) .
            "</td>\n";

    return $html;
  }

}
?>
