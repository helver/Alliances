<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: GroupColorBlock 
 * Author: Eric Helvey Create Date: 12/20/2002
 *
 * Description: BigColorBlock is a class that displays the large 
 *              dashboard-type color block feature.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2005-05-20 12:40:19 $
 * Last Editor: $Author: eric $
*/

include_once("Features/ColorBlock_Base.inc");

class GroupColorBlock extends ColorBlock_Base
{
  function GroupColorBlock($cols, $config, $debug)
  {
    $this->ColorBlock_Base($cols, $config, $debug);
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
			$groups = $customerInfo->dbh->SelectMap("id, name", "user_groups", "id in (" . join(",", array_values($customerInfo->user->info["groupmap"])) . ")");
			
			uasort($groups, create_function('$a,$b','return strcasecmp($a, $b);'));

      foreach($groups as $k=>$v) {
        if(($count % $this->cols) == 0) {
          $html .= "<tr height=\"60\">\n";
        }

        if($this->debug >= 3) {
          print("groupid: $k -- flag: " . $customerInfo->get_Group_Flag($k) . "<br>\n");
        }

        $html .= "<td nowrap id=\"c$k\" valign=\"top\" width=\"110\" align=\"center\">";
        $html .= "<a href=\"colorBlock.php?groupid=$k\">$v</a><br>";

        if($customerInfo->get_Group_Flag($k) == "R") {
        	$html .= "<script language=\"JavaScript\">\n  Geo_blink[" . $k . "] = 999;\n</script>\n";
        }

				$xx_flg = $customerInfo->get_Group_Flag($k);
        $xx_flg = ($xx_flg == "" ? "e" : $xx_flg);

        $html .= "<a href=\"colorBlock.php?groupid=$k\">";
        $html .= "<img border=\"0\" width=\"110\" height=\"40\" src=\"images/" . strtolower($xx_flg) . ".png\">";
        $html .= "</a>\n";

        $html .= "</td>\n";

        if(($count % $cols) == ($cols - 1)) {
          $html .= "</tr>\n";
        }

        $count++;
      }
    } else {
      $html .= "<tr><td class=\"error\">You are not assigned to any groups.</td></tr>\n";
    }

    $html .= "</table><br><br><br><Br><br><Br></div>\n";

    return $html;
  }
}

?>
