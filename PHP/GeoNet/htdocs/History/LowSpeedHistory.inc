<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LowSpeedHistory
 * Author: Eric Helvey
 * Create Date: 4/10/2006
 *
 * Description: LowSpeedHistory is a concrete class that provides a 
 *              HistoryBase implementation.  This particular class provides 
 *              history for Ciena MultiWave Sentry elements.
 *
 * Revision: $Revision: 1.1 $
 * Last Change Date: $Date: 2006-05-25 14:40:29 $
 * Last Editor: $Author: eric $
*/
include_once ("History/HistoryBase.inc");

class LowSpeedHistory extends HistoryBase
{

  #
  # Function: LowSpeedHistory
  #
  # LowSpeedHistory is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # LowSpeedHistory has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # CienaMWSentry4000History returns on object of type LowSpeedHistory.
  function LowSpeedHistory(&$user, $config, $dbh, $debug)
  {
    $this->HistoryBase($user, $config, $dbh, $debug);

    $this->states = array();
  }



  function graphPMS($tidid, $ifcid, $state)
  {
    $this->MAXY = 10;
    $this->imageName = $this->imagesFolder . "graph" . $state;
    return $this->generate_history_graph($tidid, $ifcid);
  }


  function getElementInfo($tidid, $ifcid)
  {
    return $this->DWS_Element_Info($tidid, $ifcid);
  }


  function graphAdditionals($tidid, $ifcid)
  {
  }



  function graphAllPMS($tidid, $ifcid)
  {
    if($this->debug >= 5) {
      print("About to do states.<br>\n");
    }

  	$fields = array("c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10");

    $options = array(
      "s" => "segment",
      "l" => "line",
      "p" => "path",
    );
    
    $this->states = array();
    
    $xx = $this->dbh->SelectFirstRow($fields, "Interface_Labels_View", "interface_id = $ifcid");
    foreach($fields as $k) {
    	$v = $xx[$k];
      if(!isset($v) || $v == "") {
        continue;
      }
      $this->PMS[$k] = $v;
      #print("$k -- $v<br>\n");
      
      $lastchar = strtolower(substr($xx[$k], -1, 1));
      $this->states[$options[$lastchar]][] = $k;
    }

    foreach($this->states as $state => $vals) {
      if($this->debug >= 5) {
        print("Doing $state<br>\n");
      }

      $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

      $label = strtoupper($state) . " PMs";

      $html .= "$label\n</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

      $fieldsName = array();

			$this->pms = $vals;
			
      $html .= $this->graphPMS($tidid, $ifcid, $state);
      $html .= "<BR><BR>\n</TD>\n</TR>\n";
    }

    return $html;
  }


  function display_Info()
  {
    return $this->display_DWS_Info();
  }

}
?>
