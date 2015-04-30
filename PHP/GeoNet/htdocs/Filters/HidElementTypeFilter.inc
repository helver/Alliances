<?php

#
# Class: HidElementTypeFilter
#
# HidFacilityFilter is a class used to store handle widgets used to
# apply filters to a database query.
#
# Author: eric
# Create Date: 2/2`/2003
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2005-03-24 17:28:53 $
# Last Editor: $Author: eric $
#
#
#

include_once("FilterBase.inc");

class HidElementTypeFilter extends FilterBase
{
  function HidElementTypeFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fhidet", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "projectlist")
  {
    if($this->debug) {
      print("Active: " . $this->value . "<br>\n");
    }

		if($this->value != "") {
    	$wair = "element_type_id = " . $this->value;
		}

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    $html = hidden_field($this->name, "") . "\n";

    return $html;
  }

}
?>