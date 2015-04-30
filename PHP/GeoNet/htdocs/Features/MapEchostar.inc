<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: Map
 * Author: Eric Helvey
 * Creation Date: 12/20/2002
 *
 * Description: Map is a class used to generate the GeoNet Map Page.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2004-05-28 21:14:11 $
 * Last Editor: $Author: marie $
*/

include_once("Features/GeoNetFeature.inc");
include_once("Map/ATMMap.inc");

class MapEchostar extends GeoNetFeature
{
  var $dbh;
  var $user;
  var $mapEngine;

  function MapEchostar(&$user, $dbh, $config, $debug=0)
  {
    $this->dbh = $dbh;
    $this->user = $user;
    $this->GeoNetFeature($config, $debug);
  }


  function generate_JavaScript()
  {
    $script = "";

    return $script;
  }



  function generate_Stylesheet()
  {
    $style =<<<EOS

   .contentSmallAlt {font-family:verdana,sans-serif; font-size: 7pt; color: #000000}
   .contentSmallAltalarm { font-family:verdana,sans-serif; font-size: 7pt; color: #FFFFFF; background-color:#DF0031; }
   .contentSmallAltwarning { font-family:verdana,sans-serif; font-size: 7pt; color: #000000; background-color:#FFE633; }
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

  function generate_Layer($customer, $facility, $timestamp)
  {
    $this->mapEngine = new ATMMap($this->user, $this->dbh, $this->config, $this->debug);

    $image_name = $this->mapEngine->generate_map($customer, $facility);

    $html .= "<div id=\"mapDiv\" class=\"Map\">\n";
    $html .= "  <img src=\"$image_name?changingvalue=$timestamp\" width=\"900\" height=\"478\" alt=\"\" border=\"0\" usemap=\"#sites\">\n";
    $html .= "</div>\n";

    $html .= "<map name=\"sites\">\n";
    $html .= $this->mapEngine->map . "\n";
    $html .= "</map>\n";

		$html .= "<div id=\"overDiv\" style=\"position:absolute; visibility:hidden; z-index:1000;\"></div>\n";

    return $html;
  }



  function get_customer_facility($c, $f)
  {

    if(is_array($f)) {
      $res = $this->dbh->Select("unique customerid", "facility", "facilityid in (" . join(",", $f) . ")");
      $c = $res[0][0];

      if(isset($res[1])) {
        header("Location: error.php?msg=" . urlencode("Facilities for more than one customer were selected.  GeoNet can only display facilities for a single customer at a time."));
        exit();
      }
    } elseif (isset($f)) {
      $f = array($f);
      $res = $this->dbh->Select("customerid", "facility", "facilityid = $f");
      $c = $res[0][0];
    }

    return array($c,$f);
  }




}

?>

