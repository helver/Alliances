<?php

#
# Class: SingleElementStatusBlock
#
# SingleElementStatusBlock is a class used to generate a color 
# block comprised of different PMs for a single element.
#
# Author: eric
# Create Date: 11/10/2003
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2003-11-12 20:22:21 $
# Last Editor: $Author: eric $
#
#

include_once("Features/GeoNetFeature.inc");

class SingleElementStatusBlock extends GeoNetFeature
{
	var $dbh;
	
  function SingleElementStatusBlock($dbh, $config, $debug=0)
  {
  	$this->dbh = $dbh;
    $this->GeoNetFeature($config, $debug);
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

    .statusBlock {font-family:verdana,sans-serif; font-weight: bold; font-size: 7pt; color: #000000; text-decoration: none;}
    div.statusDiv {position:absolute; top: 100; left: 300; font-family:verdana,arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 52;}
    a:link {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000;}
    a:hover {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000;}
    a:visited {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000;}
EOS;

    return $style;
  }


  function generate_OnLoad()
  {
    return "startBlink(blink, '#ff0000');";
  }


  function generate_JavaScript()
  {
    $errColor = $this->colors["R"];

    $script=<<<EOS
  blink = new Array();

  function startSEPMBlink(blink, color) {
    var doBlink = 0;

    for(var i in blink) {
      if(blink[i] >= 1000) {
        continue;
      }
      //alert("Blinking " + i + " on " + blink[i] + "ms interval.");
      tid = setTimeout('goBlink('+i+',"'+color+'")', blink[i]);

      doBlink = 1;
    }

    if(doBlink == 1) {
      setTimeout('docSEPMBlink("' + color + '")', 500);
      window.focus();
    }
  }

  function docSEPMBlink(color) {
    document.bgColor = color;

    if(color == ("$errColor")) {
      color = '';
    } else {
      color = "$errColor";
    }

    setTimeout('docSEPMBlink("' + color + '")', 500);
  }


  function goSEPMBlink(i,color) {
    cell = document.getElementById("sepm"+i);

    cell.style.backgroundColor = color;

    if(color == ("$errColor")) {
      color = '';
    } else {
      color = "$errColor";
    }

    //alert("Blinking " + i + " on " + blink[i] + "ms interval.");
    tid = setTimeout('goSEPMBlink('+i+',"'+color+'")', blink[i]);
  }
EOS;

    return $script;
  }


  function generate_Layer($customer_id)
  {
    $layer = "<div id=\"statusDiv\" align=\"right\" class=\"statusDiv\">\n";

    $layer .= $this->display_blocks($customer_id);

    $layer .= "</div>\n";
    return $layer;
  }

  function display_blocks($customer_id)
  {
    $count = 0;

    if(   $this->config->getAttribute("DisplayTNT") == 0
       && $customerInfo->get_Customer_Flag($k) == "t") {
      if($this->debug >= 3) {
        print("Skipping customer $k because it's TNT.<br>\n");
      }
      return "";
    }

    $html = "<table border=\"1\">\n";
    $html .= "<tr>\n";

		$pms = $this->dbh->Select("p.pm, p.pm_group, p.value, p.timeentered", 
		                          "single_pms p, single_element e", 
		                          "p.tidid = e.tidid and e.customerid = $customer_id and p.is_current = 't'",
		                          "p.pm_group"
		                         );
		  
		$lastgroup = "";
		$flag = "g";
		$countpm = 0;
		$err_count = 0;
		   
		for($i = 0; isset($pms[$i]); $i++) {                     
  		if($lastgroup != $pms[$i]["pm_group"]) {
				$html .= $this->handlePM($lastgroup, $flag, $countpm, $err_count);
				
  			$lastgroup = $pms[$i]["pm_group"];
  			$flag = "g";
  			$countpm = 0;
  			$err_count = 0;
  		}
  		
  		$countpm++;
  		if($pms[$i]["value"] >= 1) {
  			$flag = "r";
  			$err_count++;
  		}
		}
		
		$html .= $this->handlePM($lastgroup, $flag, $countpm, $err_count);

    $html .= "</tr>\n";
    $html .= "</table>\n";

    return $html;
  }

	function handlePM($lastgroup, $flag, $countpm, $err_count)
  {
  	if($lastgroup == "") {
  		return "";
  	}
  	
  	$html = "<td valign=\"middle\" nowrap style=\"background-color: " . $this->colors[$flag] . ";\" id=\"sepm$lastgroup\" valign=\"top\" align=\"center\">\n";
		$html .= "<span class=\"statusBlock\">$lastgroup</td>\n";
		
		if($countpm == 0) {
			$err_count = 0;
		} else {
			$err_count /= $countpm;
		}
		
	  if($err_count >= .9) {
	    $err_count = .9;
	  }
	
	  $html .= "<script language=\"JavaScript\">\n";
	  $html .= "  blink[$lasgroup] = 1000 - (1000 * ($err_count));\n";
	  $html .= "</script>\n";
		
		return $html;
  }

}

?>
