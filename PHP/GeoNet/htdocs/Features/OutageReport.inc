<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: OutageReport
 * Author: Eric Helvey
 * Create Date: 6/27/2003
 *
 * Description: OutageReport is a class that builds a form allowing the 
 *              user to record the time of a scheduled outage for one or 
 *              more facilities.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2004-03-22 20:07:04 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class OutageReport extends GeoNetFeature
{
  var $user;
  var $dbh;

  function OutageReport(&$user, $dbh, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);

    $this->user = $user;
    $this->dbh = $dbh;
  }


  function generate_Layer($cust, $facs)
  {
  	$num_of_days_on_report = 90;
  	
    $html =<<<EOS

  <table width="100%"><tr><td align="center">
    <TABLE ALIGN="center" BORDER="0" CELLSPACING="5"  BGCOLOR="#f3f3df">
      <TR>
        <TD CLASS="pageHead" nowrap ALIGN="center">Unscheduled Outages in Last $num_of_days_on_report Days:
        </TD>
      </tr>
      
      <tr>
        <TD CLASS="redcell" nowrap ALIGN="left">
          <table align="center" border="0" cellpadding="2" cellspacing="0">
EOS;

		unset($cust->customersInfo[""]);
		#$html .= join(",", array_keys($cust->customersInfo));
		
		$outages = $this->dbh->Select(
		  "facilityid, customerid, to_char(start_time, 'MM/DD/YYYY HH24:MI:SS') as start_time, to_char(end_time, 'MM/DD/YYYY HH24:MI:SS') as end_time, round(secs_duration) as secs_duration",
		  "unscheduled_outages_view",
		  "end_time > SYSDATE - $num_of_days_on_report and customerid in (" . join(",", array_keys($cust->customersInfo)) . ")",
		  "customerid, facilityid, start_time"
		);
		
		$html .= "<tr><td><b>Customer</b></td><td><b>Facility</b></td><td><b>Start Time</b></td><td><b>End Time</b></td><td><b>Duration (min)</b></td></tr>\n";
		$html .= "<tr height=\"3\"><td colspan=\"5\"><hr></td></tr>\n";
		
		$cur_fac = "";
		$cur_cus = "";
		$total = 0;
		$total_fac = 0;
		$total_cus = 0;
		$col_count = 0;
		
		if(isset($outages[0])) {
			for($i = 0; isset($outages[$i]); $i++) {
				if($cur_fac != "" && $outages[$i]["facilityid"] != $cur_fac) {
					$html .= "<tr bgcolor=\"#E1D7AA\"><td colspan=\"5\" align=\"right\">Total Facility Outage Time: " . $this->translate_duration($total_fac) . "</td></tr>\n";
					$html .= "<tr height=\"3\"><td colspan=\"5\"><font size=\"-3\">&nbsp;</font></td></tr>\n";
					$total_fac = 0;
					$col_count = 0;
				}
				$cur_fac = $outages[$i]["facilityid"];
				
				if($cur_cus != "" && $outages[$i]["customerid"] != $cur_cus) {
					$html .= "<tr><td colspan=\"5\" align=\"right\"><b>Total Customer Outage Time: " . $this->translate_duration($total_cus) . "</b></td></tr>\n";
					$html .= "<tr><td colspan=\"5\"><hr></td></tr>\n";
					$total_cus = 0;
				}
				$cur_cus = $outages[$i]["customerid"];
				
				$html .= "<tr" . ($col_count % 2 == 1 ? " bgcolor=\"#ccccaa\"" : "") . ">\n";
				$html .= "<td>" . ($cust->customersInfo[$outages[$i]["customerid"]]["name"] ? $cust->customersInfo[$outages[$i]["customerid"]]["name"] : $outages[$i]["customerid"]) . "</td>\n";
				$html .= "<td>" . ($facs->facilitiesInfo[$outages[$i]["facilityid"]]["name"] ? $facs->facilitiesInfo[$outages[$i]["facilityid"]]["name"] : $outages[$i]["facilityid"]) . "</td>\n";
				$html .= "<td>" . $outages[$i]["start_time"] . "&nbsp; &nbsp;</td>\n";
				$html .= "<td>" . $outages[$i]["end_time"] . "&nbsp; &nbsp;</td>\n";
				$html .= "<td align=\"right\">" . $this->translate_duration($outages[$i]["secs_duration"]) . "</td>\n";
				$html .= "</tr>\n";
				
				$col_count++;
				$total_cus += $outages[$i]["secs_duration"];
				$total_fac += $outages[$i]["secs_duration"];
				$total += $outages[$i]["secs_duration"];
			}
			$html .= "<tr bgcolor=\"#E1D7AA\"><td colspan=\"5\" align=\"right\">Total Facility Outage Time: " . $this->translate_duration($total_fac) . "</td></tr>\n";
			$html .= "<tr height=\"3\"><td colspan=\"5\"><font size=\"-3\">&nbsp;</font></td></tr>\n";
			$html .= "<tr><td colspan=\"5\" align=\"right\"><b>Total Customer Outage Time: " . $this->translate_duration($total_cus) . "</b></td></tr>\n";
			$html .= "<tr><td colspan=\"5\"><hr></td></tr>\n";
			$html .= "<tr><td class=\"head\" colspan=\"5\" align=\"right\">Grand Total Outage Time: " . $this->translate_duration($total) . "</td></tr>\n";
		} else {
			$html .= "<tr><td>No Unscheduled Outages</td></tr>\n";
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
	
	function translate_duration($num)
	{
		return (((int)($num / 300)+1) * 5) . " min";
	}
}
?>


