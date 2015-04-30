<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: SmallColorBlock
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: SmallColorBlock implements a small version of the ColorBlocks.
 *              Additionally, the small blocks are placed on the display using
 *              absolute position of DHTML layers.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2005-06-10 13:27:57 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");
include_once("Features/ColorBlock_Base.inc");

class SmallColorBlock extends ColorBlock_Base
{
  var $top;
  var $left;

  function SmallColorBlock($cols, $top, $left, $config, $debug=0)
  {
    $this->top = $top;
    $this->left = $left;

    $this->ColorBlock_Base($cols, $config, $debug);
  }


  function generate_Stylesheet()
  {
    $top = $this->top;
    $left = $this->left;

		$postring = "position:relative;";
		
		if($top >= 0 && $left >= 0) {
			$postring = "position:absolute; top: $top; left: $left;";
		}
		
    $style =<<<EOS

    .colorBlock {font-family:verdana,sans-serif; font-weight: bold; font-size: 7pt; color: #000000; text-decoration: none;}
    div.blockDiv {font-family:verdana,arial,sans-serif; $postring font-weight:bold; font-size: 10pt; color:#000000; z-index: 52;}
EOS;

    return $style;
  }


  function generate_Layer($customerInfo, $facilities)
  {
  	$layer = "";
  	
  	if($this->left < 0 && $this->top < 0) {
  		$layer .= "<br><br>\n";
  	}
  	 
    $layer .= "<div id=\"blockDiv\" class=\"blockDiv\">\n";

    $layer .= $this->display_blocks($customerInfo, $facilities);

    $layer .= "</div>\n";
    return $layer;
  }

  function display_blocks($customerInfo, $facilities)
  {
    $count = 0;
		$html = "";
		
    $html .= "<table border=\"1\">\n";

		#uasort($customerInfo->customersInfo, create_function('$a,$b','return strcasecmp($a["short_name"], $b["short_name"]);'));
		
		$groups = array_keys($customerInfo->user->info["grouporder"]);
		
		foreach($groups as $q) {
			
      foreach($customerInfo->get_group_customers($q) as $k) {
      	$v = $customerInfo->customersInfo[$k];

        if($this->__skip_customer($customerInfo, $k)) {
          continue;
        }

        if(!isset($customerInfo->customersInfo[$k]["short_name"]) || $customerInfo->customersInfo[$k]["short_name"] == "") {
        	continue;
        }
        
        if(($count % $this->cols) == 0) {
          $html .= "<tr>\n";
        }

        if($this->debug >= 3) {
          print("customerid: $k -- flag: " . $customerInfo->get_Customer_Flag($k) . "<br>\n");
        }

        $html .= "<td valign=\"middle\" nowrap style=\"background-color: " . $this->colors[$customerInfo->get_Customer_Flag($k)] . ";\" id=\"c$k\" valign=\"top\" align=\"center\">\n";
 
        list($fac_url, $xhtml) = $this->__handle_facility_counts($customerInfo->customersInfo[$k], $k, $facilities, false);
        $html .= $xhtml;

        $html .= "<a href=\"map.php?customer=$k$fac_url\"><span class=\"colorBlock\">" . $customerInfo->customersInfo[$k]["short_name"] . "</span></a>\n";
        $html .= "</td>\n";

        if(($count % $this->cols) == ($this->cols - 1)) {
          $html .= "</tr>\n";
        }

        $count++;
      }
		}
		
    $html .= "</table>\n";

    return $html;
  }


}

?>
