<?php
include_once("FilterBase.inc");

class SellerFilter extends FilterBase
{
  function SellerFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("seller", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "seller_name = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    $label = "Seller";
    
    if($this->config->getAttribute("SellerFilterLabel") != "") {
        $label = $this->config->getAttribute("SellerFilterLabel");
    }
    

    $html = "<td colspan=\"2\"><span class=\"whitetext\">$label:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct u.username, u.username as name", 
"buzz_user u, seller_profile s", "u.id = s.buzz_user_id", $this->dbh, "All Sellers", "u.username") .
            "</td>\n";

    return $html;
  }

}
?>
