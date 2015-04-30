<?php

#
# Class: FacilityHistory
#
# FacilityHistory is a class used to generate the GeoNet History Page.
#
# Author: eric
# Create Date: 12/20/2002
#
# Revision: $Revision: 1.2 $
# Last Change Date: $Date: 2005-08-30 19:05:26 $
# Last Editor: $Author: eric $
#
#

include_once("Features/GeoNetFeature.inc");
include_once("History/FacilityHistory.inc");

class FacilityHistoryFeature extends GeoNetFeature
{
  var $dbh;
  var $graphEngine;
  var $user;

  function FacilityHistoryFeature(&$user, $dbh, $config, $debug=0)
  {
    $this->dbh = $dbh;
    $this->user = $user;
    $this->GeoNetFeature($config, $debug);


    $this->graphEngine = new FacilityHistory($user, $config, $dbh, $debug);
  }

  function SingleFacility($facilityid)
  {
    $this->graphEngine->SingleFacility($facilityid);
    $this->graphEngine->load_Info();
  }


  function ChoiceFacility($facilities)
  {
    $this->graphEngine->ChoiceFacility($facilities);
    $this->graphEngine->load_Info();
  }

  function generate_JavaScript()
  {
  }



  function generate_Stylesheet()
  {
    $style =<<<EOS

   div.HistoryDiv {font-family:verdana,arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  .content {font-family:verdana,sans-serif; font-size: 10pt;}
  .contentlarge {font-family:verdana,sans-serif; font-size: 14pt;}
  .errorMessage {font-family:verdana,sans-serif; font-size: 10pt; color: #FF0000;}
  .label {font-family:verdana,sans-serif; font-size: 10pt; font-weight: bold;}
  .labelWhite {font-family:verdana,sans-serif; font-size: 10pt; font-weight: bold; color: #ffffff}
  .labelRed {font-family:verdana,sans-serif; font-size: 10pt; font-weight: bold; color: #ff0000}
EOS;

    return $style;
  }

  function generate_Layer($customerInfo, $facilities)
  {
    $layer = "<div id=\"HistoryDiv\" align=\"center\" class=\"HistoryDiv\">\n";

    $layer .= "<TABLE ALIGN=\"center\" BORDER=\"0\">\n<TR>\n<TD CLASS=\"content\" ALIGN=\"center\" VALIGN=\"top\">\n";
    $layer .= "<TABLE>\n<TR>\n<TD CLASS=\"content\" ALIGN=\"center\">\n";

    $layer .= $this->graphEngine->display_Info();

    $layer .= "</TD>\n<TD CLASS=\"content\" ALIGN=\"center\" VALIGN=\"top\" WIDTH=\"50%\">\n";
    $layer .= "<IMG SRC=\"images/geonetmonitorsmall.png\" BORDER=\"0\">\n<br>\n<SPAN CLASS=\"contentlarge\"><B>";

    $layer .= $this->graphEngine->getFacInfo("customer");

    $layer .= "</B></SPAN><BR>\n";

    $layer .= "</TD>\n</TR>\n</TABLE>\n<BR>\n</TD>\n</TR>\n<TR>\n";
    $layer .= "<TD CLASS=\"errorMessage\" ALIGN=\"left\">The times on the graphs are <B>GMT</B>\n";
    $layer .= "<BR><BR>\n</TD>\n</TR>\n";

    $layer .= $this->graphEngine->graphAllPMS();

    $layer .= "</TABLE>\n</div>\n";

    return $layer;
  }

}

?>

