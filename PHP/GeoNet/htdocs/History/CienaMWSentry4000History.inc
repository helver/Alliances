<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: CienaMWSentry4000History
 * Author: Eric Helvey
 * Create Date: 11/7/2002
 *
 * Description: CienaMWSentry4000History is a concrete class that provides a 
 *              HistoryBase implementation.  This particular class provides 
 *              history for Ciena MultiWave Sentry elements.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2005-03-08 20:21:57 $
 * Last Editor: $Author: eric $
*/
include_once ("History/HistoryBase.inc");

class CienaMWSentry4000History extends HistoryBase
{

  #
  # Function: CienaMWSentry4000History
  #
  # CienaMWSentry4000History is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # CienaMWSentry4000History has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # CienaMWSentry4000History returns on object of type CienaMWSentry4000History.
  function CienaMWSentry4000History(&$user, $config, $dbh, $debug)
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

    $xx = $this->dbh->SelectFirstRow($fields, "Interface_Labels_View", "interface_id = $ifcid");
    foreach($fields as $k) {
    	$v = $xx[$k];
      if(!isset($v) || $v == "") {
        continue;
      }
      $this->PMS[$k] = $v;
      #print("$k -- $v<br>\n");
    }

		$this->states = array(
		  "transmit" => array("c1", "c2", "c3", "c4"),
		  "receive" => array("c5", "c6", "c7", "c8"),
  	);
  	
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
