<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LastUpdate
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: LastUpdate is a class that displays the last time this 
 *              page was updated.
 *
 * Revision: $Revision: 1.5 $
 * Last Change Date: $Date: 2005-03-11 16:21:47 $
 * Last Editor: $Author: eric $
*/


include_once("Features/GeoNetFeature.inc");

class LastUpdate extends GeoNetFeature
{
  var $top;
  var $left;

  function LastUpdate($top, $left, $config, $debug)
  {
    $this->top = $top;
    $this->left = $left;

    $this->GeoNetFeature($config, $debug);
  }


  function generate_Stylesheet()
  {
    $top = $this->top;
    $left = $this->left;

    $style =<<<EOS

  .lastUpdate {font-family:arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
EOS;

    return $style;
  }


  function generate_Layer()
  {
    $html = "<p class=\"lastUpdate\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last Update: " . date("G:i:s") . " GMT</p>\n";

    return $html;
  }
}

?>
