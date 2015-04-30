<?php

#
# Class: HidDWDMFacFilter
#
# HidDWDMFacFilter is a class used to store handle widgets used to
# apply filters to a database query.
#
# Author: eric
# Create Date: 2/2`/2003
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2005-03-08 23:11:00 $
# Last Editor: $Author: eric $
#
#
#

include_once("FilterBase.inc");

class HidDWDMFacFilter extends FilterBase
{
  function HidDWDMFacFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("fdwdmfac", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "projectlist")
  {
    if($this->debug) {
      print("Active: " . $this->value . "<br>\n");
    }

		if($this->value != "") {
    	$wair = "dwdm_facility = '" . $this->value . "'";
		}

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
  	$html = hidden_field($this->name, "");
    return $html;
  }

}
?>