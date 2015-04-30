<?php
include_once("FilterBase.inc");

class SellerUnpaidFilter extends FilterBase
{
  function SellerUnpaidFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
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
      $wair = "buzz_name = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"whitetext\">Seller:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct buzz_name, buzz_name as name", 
"commissions_due_to_me_unpaid", "", $this->dbh, "All Sellers", "buzz_name") .
            "</td>\n";

    return $html;
  }

}
?>
