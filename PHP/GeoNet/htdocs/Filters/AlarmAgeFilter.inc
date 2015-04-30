<?php

#
# Class: AlarmAge
#
# AlarmAge is a class used to store handle widgets used to
# apply filters to a database query.
#
# Author: eric
# Create Date: 7/20/2005
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2005-07-21 19:56:18 $
# Last Editor: $Author: eric $
#
#
#

include_once("FilterBase.inc");

class AlarmAgeFilter extends FilterBase
{
  function AlarmAgeFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("falarmage", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "projectlist")
  {
    if($this->debug) {
      print("Active: " . $this->value . "<br>\n");
    }

    if($this->value == "") {
    	$this->value = 3;
    }

    $wair = "timeentered > SYSDATE - " . $this->value;
	
    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    $html = "<td><span class=\"content\">Previous Days:</span><br>\n" .
    			  text_field($this->name, $this->value, array("size"=>"3", "maxlength"=>3)) .
            "</td>\n";

    return $html;
  }

}
?>