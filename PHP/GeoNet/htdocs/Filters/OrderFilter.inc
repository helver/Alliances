<?php
  #########################################
  #
  # FCC Reportable Outage Database
  #
  # OrderFilter.inc
  # Initial Creation Date: 10/20/2004
  # Initial Creator: eric
  #
  # Revision: $Revision: 1.1 $
  # Last Change Date: $Date: 2005-03-07 22:38:36 $
  # Last Editor: $Author: eric $
  #
  #
  # Generic Sorting Mechanism.
  #
  #########################################

include_once("FilterBase.inc");

class OrderFilter extends FilterBase
{
  function OrderFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("orderbyplug", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "index")
  {
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