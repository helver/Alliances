<?php

#
# Class: ActiveFilter
#
# ActiveFilter is a class used to store handle widgets used to
# apply filters to a database query.
#
# Author: eric
# Create Date: 2/2`/2003
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2005-03-07 22:38:36 $
# Last Editor: $Author: eric $
#
#
#

include_once("FilterBase.inc");

class ActiveFilter extends FilterBase
{
  function ActiveFilter($HTTP_GET_VARS, $config, $dbh, $debug = 0, $sess = "")
  {
    $this->FilterBase("factive", $HTTP_GET_VARS, $config, $dbh, $debug, $sess);
  }


  function createFilterString($page = "projectlist")
  {
    if($this->debug) {
      print("Active: " . $this->value . "<br>\n");
    }

    if($this->value != "all") {
    	if($this->value == "f") {
	      $wair = "(active is not null and active = 'No')";
	    } elseif ($this->value == "t") {
	    	$wair = "(active is null or active = 'Yes')";
	    }
    }

    return $wair;
  }


  function createFilterWidget($page = "projectlist")
  {
    $html = "<td><span class=\"content\">Active?:</span><br>\n" .
            "  <select name=\"" . $this->name . "\">\n" .
            "    <option value=\"all\"" . ($this->value == "all" ? " selected" : "") . ">All</option>\n" .
            "    <option value=\"t\"" . ($this->value == "t" ? " selected" : "") . ">Active</option>\n" .
            "    <option value=\"f\"" . ($this->value == "f" ? " selected" : "") . ">Inactive</option>\n" .
            "  </select>\n" .
            "</td>\n";

    return $html;
  }

}
?>