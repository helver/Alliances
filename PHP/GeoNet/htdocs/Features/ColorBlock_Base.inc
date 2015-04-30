<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: ColorBlock_Base
 * Author: Eric Helvey
 * Create Date: 2/12/2004
 *
 * Description: ColorBlock_Base is a class used to provide generic ColorBlock
 *              functionality to the various implementations of ColorBlock.
 *
 * Revision: $Revision: 1.7 $
 * Last Change Date: $Date: 2005-06-17 14:40:01 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class ColorBlock_Base extends GeoNetFeature
{
  var $cols;

  function ColorBlock_Base($cols, $config, $debug=0)
  {
    $this->cols = $cols;

    $this->GeoNetFeature($config, $debug);
  }


  function generate_OnLoad()
  {
    return "startBlink(Geo_blink, '#ff0000');";
  }


  function generate_JavaScript()
  {
    $errColor = $this->colors["R"];

    $script=<<<EOS
  var Geo_blink = new Object();
	
  function startBlink(Geo_blink, color) {
    var doBlink = 0;

    for(var i in Geo_blink) {
      //alert("Checking " + i);

      if(Geo_blink[i] >= 1000) {
        continue;
      }
      //alert("Blinking " + i + " on " + Geo_blink[i] + "ms interval.");
      tid = setTimeout('goBlink("'+i+'","'+color+'")', Geo_blink[i]);

			if(!i.match(/^c/)) {
        doBlink = 1;
			}
    }

    if(doBlink == 1) {
      setTimeout('docBlink("' + color + '")', 500);
      window.focus();
    }
  }

  function docBlink(color) {
  	var bbdiv;
  	if(document.getElementById) {
    	bbdiv = document.getElementById("bbdiv");
  	} else {
  		bbdiv = document.all["bbdiv"];
  	}
    
    if(bbdiv == null) {
    	return;
    }
    
    bbdiv.style.backgroundColor = color;
    
    //for(var i in bbdiv) {
    //	alert(i + " -- " + bbdiv.i);
    //}
    
    if(color == ("$errColor")) {
      color = '';
    } else {
      color = "$errColor";
    }

    setTimeout('docBlink("' + color + '")', 500);
  }


  function goBlink(i,color) {
    cell = document.getElementById("c"+i);

    cell.style.backgroundColor = color;

    if(color == ("$errColor")) {
      color = '';
    } else {
      color = "$errColor";
    }

    //alert("Blinking " + i + " on " + Geo_blink[i] + "ms interval.");
    tid = setTimeout('goBlink("'+i+'","'+color+'")', Geo_blink[i]);
  }
EOS;

    return $script;
  }



  function __handle_facility_counts($cust, $custid, $facs, $doHtmlCombo)
  {
    if(is_array($cust["facilities"])) {
      asort($cust["facilities"]);
      $k = $custid;
   
      $err_count = 0;
      $fac_url = "";
      $bhtml = "<script language=\"JavaScript\">\n";
      $html = "  vals[$k] = new Array();\n";

      foreach($cust["facilities"] as $j) {
        $html .= "  temp = vals[$k].length;\n";
        $html .= "  vals[$k][temp] = new Option('" . $facs->facilitiesInfo[$j]["facility"] . "',$j);\n";

        if($facs->facilitiesInfo[$j]["flag"] == "r") {
          $fac_url .= "&facility[]=$j";
          $r = $this->colors["r"];
          
          $html .=<<<EOS

  if(vals[$k][temp].style && vals[$k][temp].style.setProperty) {
    vals[$k][temp].style.setProperty('fontWeight', 'bold', '');
    vals[$k][temp].style.setProperty('backgroundColor', '$r', '');
    vals[$k][temp].style.setProperty('color', 'white', '');
  } else {
    vals[$k][temp].style.fontWeight = 'bold';
    vals[$k][temp].style.backgroundColor = '$r';
    vals[$k][temp].style.color = 'white';
  }
  
EOS;

        } elseif($facs->facilitiesInfo[$j]["flag"] == "R") {
          $fac_url .= "&facility[]=$j";
          $r = $this->colors["R"];
          $err_count++;

          $html .=<<<EOS

  if(vals[$k][temp].style && vals[$k][temp].style.setProperty) {
    vals[$k][temp].style.setProperty('fontWeight', 'bold', '');
    vals[$k][temp].style.setProperty('backgroundColor', '$r', '');
    vals[$k][temp].style.setProperty('color', 'white', '');
  } else {
    vals[$k][temp].style.fontWeight = 'bold';
    vals[$k][temp].style.backgroundColor = '$r';
    vals[$k][temp].style.color = 'white';
  }
  
EOS;


        } elseif($facs->facilitiesInfo[$j]["flag"] == "y") {
          $fac_url .= "&facility[]=$j";

        } else {
          #print("  vals[$k][temp].style = 'leftside';\n");
        }
      }

			#print("err_count: $err_count<br>\n");
			
      if(count($cust["facilities"]) > 0) {
        $err_count = ($err_count / count($cust["facilities"]));
      } else {
        $err_count = 0;
      }

			#print("err_count2: $err_count<br>\n");
			
      if($err_count >= .9) {
        $err_count = .9;
      }

			#print("err_count: $err_count<br>\n");
			
      if($doHtmlCombo) {
      	print("attaching html to bhtml<br>\n");
        $bhtml .= $html;
      }

      $bhtml .= "  Geo_blink['$k'] = 1000 - (1000 * ($err_count));\n";
      $bhtml .= "</script>\n";
    }

    return array($fac_url, $bhtml);
  }


  function __skip_customer($customerInfo, $k)
  {
    if($k == "") {
      return true;
    }

    if($this->debug >= 3) {
      print("Checking customer $k for TNT: " . $customerInfo->get_Customer_Flag($k) . "<br>\n");
      print("DisplayTNT: " . $this->config->getAttribute("DisplayTNT") . "<br>\n");
    }

    if(   $this->config->getAttribute("DisplayTNT") == 0
       && $customerInfo->get_Customer_Flag($k) == "t") {
      if($this->debug >= 3) {
        print("Skipping customer $k because it's TNT.<br>\n");
      }
      return true;
    }

    return false;
  }



}

?>
