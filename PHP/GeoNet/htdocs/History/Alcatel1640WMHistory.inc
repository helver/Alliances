<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: Alcatel1640WMHistory
 * Author: Eric Helvey
 * Create Date: 11/7/2002
 *
 * Description: Alcatel1640WMHistory is a concrete class that provides a 
 *              HistoryBase implementation.  This particular class provides 
 *              history for Alcatel 1640 elements.
 *
 * Revision: $Revision: 1.10 $
 * Last Change Date: $Date: 2005-03-11 16:21:48 $
 * Last Editor: $Author: eric $
*/

include_once ("History/HistoryBase.inc");

class Alcatel1640WMHistory extends HistoryBase
{

  #
  # Function: Alcatel1640WMHistory
  #
  # Alcatel1640WMHistory is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # HisAlcatel1640WMHistoryoryBase has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # Alcatel1640WMHistory returns on object of type Alcatel1640WMHistory.
  function Alcatel1640WMHistory(&$user, $config, $dbh, $debug)
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

    $html = "";

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
		  "OCH" => array("c1", "c2", "c3", "c4"),
		  "TBRA" => array("c5", "c6"),
  	);
  	
    foreach($this->states as $state => $vals) {
      if($this->debug >= 5) {
        print("Doing $state<br>\n");
      }

      $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

      $html .= "$state\n</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

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
