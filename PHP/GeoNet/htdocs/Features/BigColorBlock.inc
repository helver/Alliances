<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: BigColorBlock
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: BigColorBlock is a class that displays the large 
 *              dashboard-type color block feature.
 *
 * Revision: $Revision: 1.20 $
 * Last Change Date: $Date: 2005-06-16 20:31:38 $
 * Last Editor: $Author: eric $
*/

include_once("Features/ColorBlock_Base.inc");

class BigColorBlock extends ColorBlock_Base
{
	var $groupid;
	
  function BigColorBlock($cols, $groupid, $config, $debug)
  {
    $this->ColorBlock_Base($cols, $config, $debug);
    $this->groupid = $groupid;
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

  .colorBlock {font-family:verdana,sans-serif; font-weight: bold; font-size: 7pt; color: #000000; text-decoration: none;}

EOS;

    return $style;
  }


  function generate_Layer($customerInfo, $facilities)
  {
    $layer = $this->display_blocks($customerInfo, $facilities);
    return $layer;
  }

  function display_blocks($customerInfo, $facilities)
  {
    $count = 0;

    $html = "<div id=\"bbdiv\"><br><table border=\"3\">\n";

    if(is_array($customerInfo->customersInfo)) {

			#uasort($customerInfo->customersInfo, create_function('$a,$b','return strcasecmp($a["name"], $b["name"]);'));

      foreach($customerInfo->get_group_customers($this->groupid) as $k) {
      	$v = $customerInfo->customersInfo[$k];
      	
      	#print "$k -- " . $customerInfo->customersInfo[$k]["name"] . "<br>\n";
      	
        if($this->__skip_customer($customerInfo, $k)) {
          continue;
        }
        
        if($this->groupid != "" && $customerInfo->user->info["groupmap"][$k] != $this->groupid) {
        	continue;
        }

        if(($count % $this->cols) == 0) {
          $html .= "<tr height=\"60\">\n";
        }

        if($this->debug >= 3) {
          print("customerid: $k -- flag: " . $customerInfo->get_Customer_Flag($k) . "<br>\n");
        }

        $html .= "<td nowrap id=\"c$k\" valign=\"top\" width=\"". (100/$this->cols) . "%\" align=\"center\">";
        $html .= "<a href=\"map.php?customer=$k\">" . $customerInfo->customersInfo[$k]["name"] . "</a><br>";

        list($fac_url, $xhtml) = $this->__handle_facility_counts($customerInfo->customersInfo[$k], $k, $facilities, false);
        $html .= $xhtml;

        $xx_flg = strtolower($customerInfo->get_Customer_Flag($k));
        $xx_flg = ($xx_flg == "" ? "e" : $xx_flg);

        $html .= "<a href=\"map.php?customer=$k$fac_url\">";
        $html .= "<img border=\"0\" width=\"100%\" height=\"80\" src=\"images/" . strtolower($xx_flg) . ".png\">";
        $html .= "</a>\n";

        $html .= "</td>\n";

        if(($count % $cols) == ($cols - 1)) {
          $html .= "</tr>\n";
        }

        $count++;
      }
    } else {
      $html .= "<tr><td class=\"error\">You are not assigned to any customers.</td></tr>\n";
    }

    $html .= "</table><br><br><br><br></div>\n";

    return $html;
  }
}

?>
