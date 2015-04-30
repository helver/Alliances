<?php
include_once("FilterBase.inc");

class SellerHiddenFilter extends FilterBase
{
  function SellerHiddenFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
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

//    $html = "<td colspan=\"2\"><span class=\"whitetext\">Seller:</span><br>\n" .
//            popup_menu($this->name, $this->value, "distinct seller_name, seller_name as name", 
//"commissions_due_to_me_paid", "", $this->dbh, "All Sellers", "seller_name") .
//            "</td>\n";

	$html = "<input type=\"hidden\" name=\"" . $this->name . "\" value=\"" . $this->value . "\">";
    return $html;
  }

}
?>
