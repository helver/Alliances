<?php
include_once("FilterBase.inc");

class BuzzUserFilter extends FilterBase
{
  function BuzzUserFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("buzz_user_name", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "buzz_user_name = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    
    $label = "Buzz User";
    
    if($this->config->getAttribute("BuzzUserFilterLabel") != "") {
        $label = $this->config->getAttribute("BuzzUserFilterLabel");
    }
    

    $html = "<td colspan=\"2\"><span class=\"whitetext\">$label:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct username, username as name", 
"buzz_user", "", $this->dbh, "All ${label}s", "username") .
            "</td>\n";

    return $html;
  }

}
?>
