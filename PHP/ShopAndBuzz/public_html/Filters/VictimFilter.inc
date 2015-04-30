<?php
include_once("FilterBase.inc");

class VictimFilter extends FilterBase
{
  function VictimFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("victim_name", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "victim_name = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    
    $label = "Victim";
    
    if($this->config->getAttribute("VictimFilterLabel") != "") {
        $label = $this->config->getAttribute("VictimFilterLabel");
    }
    

    $html = "<td colspan=\"2\"><span class=\"whitetext\">$label:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct username, username as name", 
"buzz_user", "", $this->dbh, "All ${label}s", "username") .
            "</td>\n";

    return $html;
  }

}
?>
