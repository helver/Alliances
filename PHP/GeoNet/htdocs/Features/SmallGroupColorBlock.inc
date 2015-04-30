<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: SmallGroupColorBlock 
 * Author: Eric Helvey Create Date: 12/20/2002
 *
 * Description: SmallColorBlock implements a small version of the ColorBlocks.
 *              Additionally, the small blocks are placed on the display using
 *              absolute position of DHTML layers.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2005-06-16 20:31:38 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");
include_once("Features/ColorBlock_Base.inc");

class SmallGroupColorBlock extends ColorBlock_Base
{
  var $top;
  var $left;

  function SmallGroupColorBlock($cols, $top, $left, $config, $debug=0)
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

    if(is_array($customerInfo->customersInfo)) {
			$groups = $customerInfo->dbh->SelectMap("id, short_name", "user_groups", "id in (" . join(",", array_values($customerInfo->user->info["groupmap"])) . ")");
			
			uasort($groups, create_function('$a,$b','return strcasecmp($a, $b);'));

      foreach($groups as $k=>$v) {
        if(($count % $this->cols) == 0) {
          $html .= "<tr>\n";
        }

        if($this->debug >= 3) {
          print("groupid: $k -- flag: " . $customerInfo->get_Group_Flag($k) . "<br>\n");
        }

        $html .= "<td valign=\"middle\" nowrap style=\"background-color: " . $this->colors[$customerInfo->get_Group_Flag($k)] . ";\" id=\"cc$k\" valign=\"top\" align=\"center\">\n";

        $html .= "<a href=\"colorBlock.php?groupid=$k\"><span class=\"colorBlock\">$v</span></a>\n";
        $html .= "</td>\n";

        if($customerInfo->get_Group_Flag($k) == "R") {
        	$html .= "<script language=\"JavaScript\">\n  Geo_blink['c" . $k . "'] = 999;\n</script>\n";
        }


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
