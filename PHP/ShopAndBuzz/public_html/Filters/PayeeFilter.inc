<?php
include_once("FilterBase.inc");

class PayeeFilter extends FilterBase
{
  function PayeeFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("payee", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    if(!$this->__check_col_access()) {
      return;
    }
    $wair = "";
    
    if($this->value != "") {
      $wair = "payee_name = '" . $this->value . "'";
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    if(!$this->__check_col_access()) {
      return;
    }

    $html = "<td colspan=\"2\"><span class=\"whitetext\">Payee:</span><br>\n" .
            popup_menu($this->name, $this->value, "distinct payee_name, payee_name as name", 
"commissions_due_to_me_paid", "", $this->dbh, "All Payees", "payee_name") .
            "</td>\n";

    return $html;
  }

}
?>
