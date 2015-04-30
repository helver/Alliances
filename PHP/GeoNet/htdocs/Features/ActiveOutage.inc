<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: ActiveOutage
 * Author: Eric Helvey
 * Creation Date: 6/27/2003
 *
 * Description: ActiveOutage is a class that whether there are any 
 *              Active Scheduled Outages.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2004-03-22 15:00:32 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class ActiveOutage extends GeoNetFeature
{
  var $top;
  var $left;
	var $dbh;
	
  function ActiveOutage($top, $left, $dbh, $config, $debug)
  {
    $this->top = $top;
    $this->left = $left;
		$this->dbh = $dbh;
		
    $this->GeoNetFeature($config, $debug);
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

  .outageName {font-family:arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  .outageOld {font-family:arial,sans-serif; font-weight:bold; font-size: 10pt; color:#ff0000; z-index: 50;}
EOS;

    return $style;
  }


  function generate_Layer()
  {
  	$res = $this->dbh->SelectFirstRow("to_char(min(start_time), 'MM/DD/YYYY HH24:MI:SS') as start_time, decode(to_char(trunc(SYSDATE) + .25 - (SYSDATE - min(start_time)), 'MM/DD/YYYY'), to_char(SYSDATE, 'MM/DD/YYYY'), 'outageName', 'outageOld') as style", "scheduled_outages", "start_time < SYSDATE and (end_time is null or end_time > SYSDATE)");
  	
  	if(isset($res[0][0])) {
	    $html = "<span class=\"" . $res["style"] . "\">Scheduled Outage in Effect Since " . $res[0] . " GMT</span>\n";
  	}
  	
    return $html;
  }
}

?>
