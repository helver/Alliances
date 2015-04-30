<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: History
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: History is a class used to generate the GeoNet History Page.
 *
 * Revision: $Revision: 1.10 $
 * Last Change Date: $Date: 2005-08-30 19:05:26 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class History extends GeoNetFeature
{
  var $tidid;
  var $dbh;
  var $graphEngine;
  var $user;
  var $ifcid;

  function History($tidid, $ifcid, &$user, $dbh, $config, $debug=0)
  {
    $this->tidid = $tidid;
    $this->dbh = $dbh;
    $this->user = $user;
    $this->GeoNetFeature($config, $debug);
    $this->ifcid = $ifcid;


    $et = $dbh->SelectSingleValue("element_type_id", "tids", "id = $tidid");

    $historyClass = $config->getAttribute("HistoryClass$et");

    if($this->debug >= 5) {
      print("historyClass: $historyClass<br>\n");
    }

    if($historyClass == "") {
      $this->set_Error("No History Information Available.");
    } else {
      eval("include_once(\"History/" . $historyClass . ".inc\");");
      eval("\$this->graphEngine = new " . $historyClass . "(\$user, \$config, \$dbh, \$debug);");

      $this->graphEngine->getElementInfo($tidid, $ifcid);
    }
  }


  function generate_JavaScript()
  {
		$script = "";
    return $script;
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
   .contentSmallAlt {font-family:verdana,sans-serif; font-size: 7pt; color: #000000}
   .contentSmallAltalarm { font-family:verdana,sans-serif; font-size: 7pt; color: #FFFFFF; background-color:#DF0031; }
   .contentSmallAltwarning { font-family:verdana,sans-serif; font-size: 7pt; color: #000000; background-color:#FFE633; }
	 .contentSmallAltinactive { font-family:verdana,sans-serif; font-size: 7pt; color: #000000; background-color:#787878; }
    A:Link.contentSmallAlt {font-family:verdana,sans-serif; font-size: 7pt; color: #000000; text-decoration:underline; }
    A:Hover.contentSmallAlt { font-family:verdana,sans-serif; font-size: 7pt; color: #d80000;}
    A:Visited.contentSmallAlt { font-family:verdana,sans-serif; font-size: 7pt; color: #000000; text-decoration:none;}
    A:Link.contentSmallAltalarm {font-family:verdana,sans-serif; font-size: 7pt; color: #FFFFFF; background-color:#DF0031; text-decoration:underline;  }
    A:Hover.contentSmallAltalarm { font-family:verdana,sans-serif; font-size: 7pt; color: #d8FFFF; background-color:#DF0031; }
    A:Visited.contentSmallAltalarm { font-family:verdana,sans-serif; font-size: 7pt; color: #FFFFFF; background-color:#DF0031; text-decoration:none;}
    A:Link.contentSmallAltwarning {font-family:verdana,sans-serif; font-size: 7pt; color: #000000; background-color:#FFE633; text-decoration:underline;  }
    A:Hover.contentSmallAltwarning { font-family:verdana,sans-serif; font-size: 7pt; color: #d80000; background-color:#FFE633; }
    A:Visited.contentSmallAltwarning { font-family:verdana,sans-serif; font-size: 7pt; color: #000000; background-color:#FFE633; text-decoration:none;}
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
    $layer .= "<IMG SRC=\"images/geonetmonitorsmall.png\" BORDER=\"0\">\n<br>";
    
    $layer .= $this->graphEngine->additionalButtons();

    $layer .= "</FORM>\n</TD>\n</TR>\n</TABLE>\n<BR>\n</TD>\n</TR>\n<TR>\n";
    $layer .= "<TD CLASS=\"errorMessage\" ALIGN=\"center\">The times on the graphs are <B>GMT</B>\n";
    $layer .= "<BR><BR>\n</TD>\n</TR>\n";

    $layer .= $this->graphEngine->graphAllPMS($this->tidid, $this->ifcid);

    $layer .= $this->graphEngine->graphAdditionals($this->tidid, $this->ifcid);

    $layer .= "</TABLE>\n</div>\n";

		$layer .= "<div id=\"overDiv\" style=\"position:absolute; visibility:hidden; z-index:1000;\"></div>\n";

    return $layer;
  }

}

?>

