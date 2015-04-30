<?php

include_once("FilterBase.inc");

class OrderFilter extends FilterBase
{
  function OrderFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("orderbyplug", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
    $wair = "";
    
    # What directors do we want to see?
    if(isset($this->value) && $this->value != "") {
      $wair = $this->value;
    }

    return $wair;
  }


  function createFilterWidget($page = "index")
  {
  }

}
?>