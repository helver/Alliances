<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: GeoNetFeature
 * Author: Eric Helvey
 * Create Date: 2/12/2004
 *
 * Description: GeoNetFeature is an abstract class that defines the 
 *              basic interface for features that expand and extend the 
 *              functionality of GeoNet.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2004-03-22 14:42:08 $
 * Last Editor: $Author: eric $
*/

class GeoNetFeature
{
  var $debug = 0;
  var $config;
  var $err;

  var $colors = array("r" => "#ffaaaa",
                      "y" => "#ffff00",
                      "g" => "#00ff00",
                      "n" => "#777777",
                      "t" => "#7777ff",
                      "e" => "#ffffff",
                      "R" => "#ff0000",
                     );


  function GeoNetFeature($config, $debug)
  {
    $this->debug = $debug;
    $this->config = $config;
  }


  function generate_Stylesheet()
  {
  }


  function generate_OnLoad()
  {
  }


  function generate_JavaScript()
  {
  }


  function generate_Layer()
  {
  }

  function generate_Error()
  {
    if($this->err == "") {
      return 0;
    }


    return "<h3>" . $this->err . "</h3>\n";
  }

  function set_Error($string)
  {
    $this->err .= $string;
  }

}

?>
