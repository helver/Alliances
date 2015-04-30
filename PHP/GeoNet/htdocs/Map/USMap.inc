<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: USMap
 * Author: Eric Helvey
 * Creation Date: 12/20/2002
 *
 * Description: Map is a class used to generate the GeoNet USMap Page.
 *
 * Revision: $Revision: 1.9 $
 * Last Change Date: $Date: 2005-08-23 15:27:19 $
 * Last Editor: $Author: eric $
*/

include_once("Map/MapBase.inc");

class USMap extends MapBase
{
  var $AlcateldbPARAMETERS;

  function USMap(&$user, $dbh, $config, $debug=0)
  {
    $this->MapBase($user, $dbh, $config, $debug);
  }


  function acquire_dataset($where)
  {
    $aqr = $this->dbh->Select("*", "USMap_Dataset_View", $where);

    $this->dataSet = $aqr;
    
		$abc = array();
		for($i = 0; isset($aqr[$i]); $i++) {
			$key = $aqr[$i]["tid_id"];
			#print("key - $key -- index - $i<br>\n");
			if(!isset($abc[$key])) {
				$abc[$key] = $aqr[$i];
			} else {
				#print($abc[$key]["sorttime"] . "<" . $aqr[$i]["sorttime"] . "<br>\n");
				if($abc[$key]["sorttime"] < $aqr[$i]["sorttime"]) {
					$abc[$key] = $aqr[$i];
					#print("Taking #2<br>\n");
				}
			}
		}
		
		unset($aqr);
		
		$aqr = array_values($abc);
		
    if($this->debug >= 5) {
      print("# Items in Data Set:" . count($aqr) . "<br>\n");
      print("<pre>\n");
      print_r($aqr);
      print("</pre>\n");
    }
    
    $this->dataSet = $aqr;
  }



  function acquire_link_dataset($where)
  {
    // select all the transmitter paths
    $this->transPaths = $this->dbh->Select("*", "USMap_Trans_Links_View", $where);

    // select all the receiver paths
    $this->recvPaths = $this->dbh->Select("*", "USMap_Recv_Links_View", $where);

    if($this->debug >= 5) {
      print("# Items in Trans Data Set:" . count($this->transPaths) . "<br>\n");
      print("# Items in Recv Data Set:" . count($this->recvPaths) . "<br>\n");
    }
}



  function generate_popup_info($record, $flag)
  {
    // create the alt tag
    $tid = $record["tid"];
    $ipaddress = $record["ipaddress"];
    $channel = $record["ifname"];
    $et = $record["element_type"];

    $alt = "<span class=contentSmallAlt>" . $record["city"] . " "
        . (($this->user->hasAccessLevel("InternalUser") && isset($ipaddress)) ? " $ipaddress<br>" : "")
        . (($this->user->hasAccessLevel("InternalUser") && isset($record["element_type"])) ? " " . $record["element_type"] . "<br>" : ""). "<br>"
        . "</span>"
		;

    $aqr = $this->dbh->Select("*", "USMap_Ifc_Dataset_View", "tid_id = " . $record["tid_id"] . " and customer_id = " . $record["customer_id"]);

#		$abc = array();
#		for($i = 0; isset($aqr[$i]); $i++) {
#			$key = $aqr[$i]["tid_id"] . "," . $aqr[$i]["interface_id"];
#			#print("key - $key -- index - $i<br>\n");
#			if(!isset($abc[$key])) {
#				$abc[$key] = $aqr[$i];
#			} else {
#				#print($abc[$key]["sorttime"] . "<" . $aqr[$i]["sorttime"] . "<br>\n");
#				if($abc[$key]["sorttime"] < $aqr[$i]["sorttime"]) {
#					$abc[$key] = $aqr[$i];
#					#print("Taking #2<br>\n");
#				}
#			}
#		}
#		
#		unset($aqr);
#		
#		$aqr = array_values($abc);

    $alt .= "<TABLE CELLPADDING=0 CELLSPACING=0>";

		$used = 0;
    for($j = 1; $j <= 10; $j++) {
      if(isset($aqr[0]["c" . $j . "_label"]) && $aqr[0]["c" . $j . "_label"] != "") {
       	$used++;
   	  }
   	}
      		
    #print "Num Used: $used<br>\n";
    
    $numcols = 2;
		for($i = 0; isset($aqr[$i]); $i++) {
			$alt .= "<tr><td colspan=2 class=contentSmallAlt>" . $aqr[$i]["facility"] . ($this->user->hasAccessLevel("InternalUser") ? " on " . $aqr[$i]["ifname_lbl"] . ": " . $aqr[$i]["ifname"] : "") . "</td><td class=contentSmallAlt>&nbsp;&nbsp;&nbsp;<a href=history.php?tid_id=" . $aqr[$i]["tid_id"] . "&interface_id=" . $aqr[$i]["interface_id"] . "><img height=6 src=images/" . strtolower($aqr[$i]["flag"]) . ".png border=0></a></td></tr>";

			if($aqr[$i]["flag"] == "y" || $aqr[$i]["flag"] == "r" || $aqr[$i]["flag"] == "R") {
	      for($j = 1; $j <= $used; $j++) {
	      	if((($j - 1) % $numcols) == 0) {
  					$alt .= "<tr><td class=contentSmallAlt>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>";
	      	}

   	      $alt .= "<td class=contentSmallAlt>" . $aqr[$i]["c" . $j . "_label"] . ": " . ($aqr[$i]["c" . $j . "_val"] != "" ? $aqr[$i]["c" . $j . "_val"] : "null") . "</td>";

	      	if((($j - 1) % $numcols) == ($numcols - 1)) {
  					$alt .= "</tr>";
	      	}
      	}
      		
       	$alt .= "</tr>";
			}
			
			if(isset($aqr[$i]["notes"]) && $aqr[$i]["notes"] != "") {
				$alt .= "<tr><td colspan=3 class=contentSmallAlt>" . $aqr[$i]["notes"] . "</td></td></tr>";
			}
			
		}
		
		$alt .= "</table>";
		
    return $alt;
  }
}

?>

