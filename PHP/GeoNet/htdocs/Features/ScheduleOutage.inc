<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: ScheduleOutage
 * Author: Eric Helvey
 * Create Date: 6/27/2003
 *
 * Description: ScheduleOutage is a class that builds a form allowing 
 *              the user to record the time of a scheduled outage for 
 *              one or more facilities.
 *
 * Revision: $Revision: 1.9 $
 * Last Change Date: $Date: 2005-07-26 21:33:38 $
 * Last Editor: $Author: eric $
*/


include_once("Features/GeoNetFeature.inc");

class ScheduleOutage extends GeoNetFeature
{
  var $user;
  var $dbh;

  function ScheduleOutage(&$user, $dbh, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);

    $this->user = $user;
    $this->dbh = $dbh;
  }


  function generate_JavaScript()
  {
  	$debug = $this->debug;
  	
    $script .=<<<EOS

  var debug = $debug;

	function setDate(elem)
	{
		if(elem.value != "") {
			return;
		}
		
		elem.value = new Date().toUTCString().replace(/..., /, "");
		elem.value = elem.value.replace(/ ...$/, "");
	}
	
	function validate(tform)
	{
		if(tform.elements["facilityid"].options.length <= 0) {
			updateFacList(tform.elements["customerid"].options[tform.elements["customerid"].selectedIndex].value);
		}
		
		if(tform.elements["aside"].options.length <= 0) {
			changeFac(tform.elements["facilityid"]);
		}
		
		var drops = new Array("customerid", "facilityid", "aside", "zside");
		for (var i in drops) {
			if(   tform.elements[drops[i]].selectedIndex == 0
			   || tform.elements[drops[i]].options[tform.elements[drops[i]].selectedIndex].value == "") {
			  alert("The " + drops[i] + " field is required.");
			  tform.elements[drops[i]].focus();
			  return false;
		  }
		}
		
		var boxen = new Array("ticketno", "start", "stop", "description");
		for (var i in boxen) {
			if(tform.elements[boxen[i]].value == "") {
			  alert("The " + boxen[i] + " field is required.");
			  tform.elements[boxen[i]].focus();
			  return false;
		  }
		}
		
		if(! tform.elements["ticketno"].value.match(/^\d{5}(\d\d)?$/)) {
			alert("The 'ticket number' input box accepts only valid Sticket and SSTAT ticket numbers. No letters or characters (only 5 or 7 numbers are acceptable)");
			tform.elements["ticketno"].focus();
			return false;
		}
		
		return true;
	}
	
	function changeFac(facelem)
	{
    alert("Here");
		if(facelem.selectedIndex == 0 || facelem.options[facelem.selectedIndex].value == "") {
			return;
		}
		
		var aside = document.getElementById("outageform").elements["aside"];
		var sela = 0;
		if(cities[facelem.options[facelem.selectedIndex].value] != null) {
		  sela = cities[facelem.options[facelem.selectedIndex].value]["aside"];
	  }
		var found = false;
		
		for(var i = 0; i < aside.options.length; i++) {
			if(aside.options[i].value == sela) {
				aside.selectedIndex = i;
				found = true;
				break;
			}
		}
		
		if(!found) {
			aside.selectedIndex = 0;
		}
		
		var zside = document.getElementById("outageform").elements["zside"];
		var selz = 0;
		if(cities[facelem.options[facelem.selectedIndex].value] != null) {
		  selz = cities[facelem.options[facelem.selectedIndex].value]["zside"];
	  }
		found = false;
		
		for(var i = 0; i < zside.options.length; i++) {
			if(zside.options[i].value == selz) {
				zside.selectedIndex = i;
				found = true;
				break;
			}
		}
		
		if(!found) {
			zside.selectedIndex = 0;
		}
		
		var cust = document.getElementById("outageform").elements["customerid"];
		var selc = 0;
		if(custfacs[facelem.options[facelem.selectedIndex].value] != null) {
		  selc = custfacs[facelem.options[facelem.selectedIndex].value];
	  }
	  
		found = false;
		
		for(var i = 0; i < cust.options.length; i++) {
			if(cust.options[i].value == selc) {
				cust.selectedIndex = i;
				found = true;
				break;
			}
		}
		
		if(!found) {
			cust.selectedIndex = 0;
		}
	}
	
	function setFac(facility)
	{
    var elem = document.getElementById("outageform").elements["facilityid"];
    var opts = elem.options;
    for(var i = opts.length -1; i >= 0; i--) {
        if(opts[i].value == facility) {
          elem.selectedIndex = i;
        }
    }
  }
  
  
  function loadAllFacs()
  {
    var opts = document.getElementById("outageform").elements["facilityid"].options;
    for(var i = opts.length; i >= 0; i--) {
        opts[i] = null;
    }

		opts[0] = new Option();
		var j = 0;
		for (customer in vals) {
    	if(vals[customer]) {
      	for(var i = 0; i < vals[customer].length; i++) {
	        opts[j+i+1] = vals[customer][i];
  	    }
  	    j += i;
    	}
		}
  }
  	
	
  function updateFacList(customer)
  {
    var elem = document.getElementById("outageform").elements["customerid"];
    var opts = elem.options;
    for(var i = opts.length -1; i >= 0; i--) {
        if(opts[i].value == customer) {
          elem.selectedIndex = i;
        }
    }

    var opts = document.getElementById("outageform").elements["facilityid"].options;
    for(var i = opts.length; i >= 0; i--) {
        opts[i] = null;
    }

    if(vals[customer]) {
    	opts[0] = new Option();
      for(var i = 0; i < vals[customer].length; i++) {
        opts[i+1] = vals[customer][i];
      }
    }
  }

EOS;

    return $script;
  }



  function generate_Layer($cust, $facs)
  {
    $html =<<<EOS

  <table width="100%"><tr><td align="center">

EOS;

    if($this->user->hasAccessLevel("User")) {

    	if(isset($_GET["outageid"])) {
    		$outage = hidden_field("outageid", $_GET["outageid"]);
        $vals = array(
          "id" => "outageid",
          "ticketnum" => "ticketnum",
          "starttime_string" => "starttime",
          "endtime_string" => "stoptime",
          "description" => "description",
          "asite_id" => "aside",
          "zsite_id" => "zside",
          "customer_id" => "customerid",
          "facility_id" => "facilityid",
        );
    		$xx = $this->dbh->SelectFirstRow(array_flip($vals), "scheduled_outages", "id = " . $_GET["outageid"]);
    		$outage .= "<script language=\"JavaScript\">updateFacList(" . $xx["customerid"] . "); setFac(" . $xx["facilityid"] . ");</script>\n";
    	} else {
    		$outage = "";
    	}
    
    	$ticketbox = text_field("ticketno", $xx["ticketnum"], array("size"=>15, "maxlength"=>20));
    	$startbox = text_field("start", $xx["starttime"], array("size"=>20, "maxlength"=>20, "onFocus"=>"setDate(this);"));
    	$stopbox = text_field("stop", $xx["stoptime"], array("size"=>20, "maxlength"=>20, "onFocus"=>"setDate(this);"));
    	$descarea = text_area("description", $xx["description"],array("rows"=>3, "cols"=>65));
    	$customermenu = $this->all_customers_list($cust);
      $facmenu = $this->all_customers_facility_list($cust, $facs);
    	
    	$asidemenu = popup_menu("aside", $xx["aside"], "id, name || ', ' || state", "cities", "", $this->dbh, " ", "name, state");
    	$zsidemenu = popup_menu("zside", $xx["zside"], "id, name || ', ' || state", "cities", "", $this->dbh, " ", "name, state");
    	
      $html .= <<<EOS

  <FORM id="outageform" ACTION="manipOutage.php" METHOD=POST NAME="form_AdminGroup" onSubmit="return validate(this);">
    <TABLE width="75%" ALIGN="center" BORDER="0" CELLSPACING="5"  BGCOLOR="#E1D7AA">
      <TR>
        <TD CLASS="outageName" nowrap colspan="3" align="center">Ticket Number<br>$ticketbox</TD>
      </tr>
      <tr><td colspan="3">&nbsp;</td></tr>
      <tr><td class="outageName" align="center" nowrap>Customer<br>$customermenu</td>
          <td class="outageName" align="center" nowrap>A Site City/State<br>$asidemenu</td>
          <td class="outageName" align="center" nowrap>Start Date/Time (zulu)<br>$startbox</td>
      </tr>
      <tr><td class="outageName" align="center" nowrap>Facility<br>$facmenu</td>
          <td class="outageName" align="center" nowrap>Z Site City/State<br>$zsidemenu</td>
          <td class="outageName" align="center" nowrap>Stop Date/Time (zulu)<br>$stopbox</td>
      </tr>
      <TR>
        <TD CLASS="outageName" nowrap colspan="3" align="center">Outage Description<br>$descarea</TD>
      </tr>
      <tr>
        <td colspan="3" align="center"><input type="submit" name="op" value="Submit"> <input type="button" value="Reset" onClick="this.form.reset(); loadAllFacs();"></td>
      </tr>
EOS;


      $html .=<<<EOS

    </TABLE>
	  $outage
	  <br><br>
  </FORM>
EOS;

    }

$html .=<<<EOS
    <TABLE width="75%" ALIGN="center" BORDER="0" CELLSPACING="5"  BGCOLOR="#E1D7AA">
      <TR>
        <TD CLASS="redcell" nowrap ALIGN="left">
          <table align="center" border="1">
          	<tr><td>&nbsp;</td>
          	    <td nowrap class="outageName">Ticket #</td>
          	    <td class="outageName">Customer</td>
          	    <td class="outageName">Facility</td>
          	    <td class="outageName">A Site</td>
          	    <td class="outageName">Z Site</td>
          	    <td class="outageName">Start Time</td>
          	    <td class="outageName">Stop Time</td>
          	    <td class="outageName">Duration</td>
          	  </tr>
EOS;

		$outages = $this->dbh->Select("*","Last_15_Outages_View");
		
		if(isset($outages[0])) {
			for($i = 0; isset($outages[$i]); $i++) {
				if($i >= 15) {
					break;
				}
				
				$html .= "<tr>\n";
				$html .= "<td rowspan=\"2\" valign=\"top\"><a href=\"outageClock.php?outageid=" . $outages[$i]["outageid"] . "\">Edit</a></td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["ticketnum"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["customer"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["facility"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["aside"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["zside"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["starttime"] . "</td>\n";
				$html .= "<td valign=\"top\" class=\"content\" nowrap>" . $outages[$i]["stoptime"] . "</td>\n";
				$html .= "<td nowrap class=\"content\">" . $outages[$i]["duration"] . "</td>\n";
				$html .= "</tr>\n";
				$html .= "<tr><td colspan=\"8\" class=\"content\">" . $outages[$i]["description"] . "</td></tr>\n";
			}
		} else {
			$html .= "<tr><td colspan=\"8\" class=\"outageName\">No Active Scheduled Outages</td></tr>\n";
		}

    $html .=<<<EOS
					</table>
        </TD>
      </TR>
    </TABLE>
  </FORM>
  <br>
  <Br>
  </td></tr></table>
EOS;

    print($html);
  }


  function all_customers_facility_list($custObj, $facsObj, $dflt = -1)
  {
    if($this->debug >= 5) {
      print("Entering ScheduleOutage::all_customers_facility_list<br>\n");

      print("custObj - $custObj<br>\n");
    }

    $html = "<script language=\"JavaScript\">\n<!--\n  custfacs = new Array();\n";

    $cust = array();

    foreach($custObj->customersInfo as $k=>$v) {
      if($k == "") {
        continue;
      }

      if($this->debug >= 5) {
        print("CustomerID: $k<br>\n");
      }

      $cust[$k] = $custObj->customersInfo[$k]["name"];

      $html .= "  vals[$k] = new Array();\n";
      foreach($custObj->customersInfo[$k]["facilities"] as $i) {
      	$html .= "  custfacs[$i] = $k;\n";
        $html .= "  temp = vals[$k].length;\n  vals[$k][temp] = new Option('" . $facsObj->get_Facility_Name($i) . "', $i);\n";
      }
    }

		$faccities = $this->dbh->Select("*", "Facility_End_Cities_View");
		  
		$html .= "  cities = new Array(" . count($faccities) . ");\n";
		
		for($i = 0; isset($faccities[$i]); $i++) {
			$html .= "  cities[" . $faccities[$i]["facilityid"] . "] = new Array();\n";
			$html .= "  cities[" . $faccities[$i]["facilityid"] . "]['aside'] = " . $faccities[$i]["aside"] . ";\n";
			$html .= "  cities[" . $faccities[$i]["facilityid"] . "]['zside'] = " . $faccities[$i]["zside"] . ";\n";
		}

    $html .= "// -->\n</script>\n";

		$html .= popup_menu("facilityid", "", "id, name", "facilities", "customer_id in (" . join(",", array_keys($cust)) . ")", $this->dbh, " ", "name", "", "onChange=changeFac(this);");
		
    if($this->debug >= 5) {
      print("Exiting ScheduleOutage::all_customers_facility_list<br>\n");
    }

    return $html;
  }

  function all_customers_list($custObj)
  {
    if($this->debug >= 5) {
      print("Entering ScheduleOutage::all_customers_list<br>\n");

      print("custObj - $custObj<br>\n");
    }

		$custs = array();
		
    foreach($custObj->customersInfo as $k=>$v) {
      if($k == "") {
        continue;
      }

      if($this->debug >= 5) {
        print("CustomerID: $k<br>\n");
      }

			$custs[$k] = $custObj->customersInfo[$k]["name"];
    }

    asort($custs);
    $html .= array_menu("customerid",$custs,""," ","","onChange=\"updateFacList(this.options[this.selectedIndex].value);\"");

    if($this->debug >= 5) {
      print("Exiting ScheduleOutage::all_customers_list<br>\n");
    }

    return $html;
  }

}
?>


