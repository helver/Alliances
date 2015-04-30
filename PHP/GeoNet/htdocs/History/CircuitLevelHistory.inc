<?
/**
 * Project: GeoNet Monitor
 *
 * Class: CircuitLevelHistory
 * Author: Eric Helvey
 * Create Date: 11/7/2002
 *
 * CircuitLevelHistory  is a concrete class that provides a 
 * HistoryBase implementation.  This particular class provides 
 * history for all the differenct circuit level elements 
 * (OC12, OC3, OC48, STS1, STS12C, T1, T3).
 *
 * Revision: $Revision: 1.1 $
 * Last Change Date: $Date: 2005-05-25 21:56:22 $
 * Last Editor: $Author: eric $
*/

include_once ("History/HistoryBase.inc");

class CircuitLevelHistory extends HistoryBase
{
  var $tps;
  var $profile;
  var $PM_label_for_circuitlevel;
  var $pm_direction;

  #
  # Function: CircuitLevelHistory
  #
  # CircuitLevelHistory is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # CircuitLevelHistory has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # CircuitLevelHistory returns on object of type CircuitLevelHistory.
  function CircuitLevelHistory(&$user, $config, $dbh, $debug)
  {
    $this->HistoryBase($user, $config, $dbh, $debug);

    $this->pm_direction = array("transmit", "receive");
    $this->PM_label_for_circuitlevel = array(
          "1" => array("transmit_CV"  => "CV-L",
                       "transmit_ES"  => "ES-L",
                       "transmit_SES" => "SES-L",
                       "transmit_UAS" => "UAS-L",
                       "receive_CV"  => "CV-S",
                       "receive_ES"  => "ES-S",
                       "receive_SES" => "SES-S",
                       "receive_UAS" => "SEF-S",
                      ),
          "2" => array("transmit_CV"  => "CV-P (trans)",
                       "transmit_ES"  => "ES-P (trans)",
                       "transmit_SES" => "SES-P (trans)",
                       "transmit_UAS" => "UAS-P (trans)",
                       "receive_CV"  => "CV-P (recv)",
                       "receive_ES"  => "ES-P (recv)",
                       "receive_SES" => "SES-P (recv)",
                       "receive_UAS" => "UAS-P (recv)",
                      ),
          "3" => array("transmit_CV"  => "CV-L",
                       "transmit_ES"  => "ES-L",
                       "transmit_SES" => "SES-L",
                       "transmit_UAS" => "UAS-L",
                       "receive_CV"  => "CV-P",
                       "receive_ES"  => "ES-P",
                       "receive_SES" => "SES-P",
                       "receive_UAS" => "UAS-P",
                      ),
          "4" => array("transmit_CV"  => "CV",
                       "transmit_ES"  => "ES",
                       "transmit_SES" => "SES",
                       "transmit_UAS" => "UAS",
                      ),
        );
  }


  function graphPMS($tidid, $ifcid, $state)
  {
    $this->MAXY = 10;
    $this->imageName = $this->imagesFolder . "graph" . $state;
    return $this->generate_history_graph($tidid, $ifcid);
  }


  function getElementInfo($tidid, $ifcid)
  {
    #return $this->ATM_Element_Info($tidid);
    return $this->DWS_Element_Info($tidid, $ifcid);
    #return $this->CircuitLevel_Element_Info($tidid);
    
  }


  function graphAdditionals($tidid)
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



  function graphStatus($tidid)
  {
    if($this->debug >= 5) { print("in graphStatus<BR>\n"); }
    
    list($element_type_name, $circuit_level) = split("_", $this->tidInfo["element_type"]);
    if($this->debug >= 5) { print("element_type_name: $element_type_name, circuit_level: $circuit_level<BR>\n"); }

    $profile = 1;
    if ($element_type_name == "Alcatel1603SM" and $circuit_level == "T1")
    {
      $profile = 3;
    }
    else if ($circuit_level == "STS1" || $circuit_level == "STS12C" || $circuit_level == "T1" || $circuit_level == "VT1")
    {
      $profile = 2;
    }
    else if (!$circuit_level)
    {
      if ($element_type_name == "532L") { $profile = 3; }
      else { $profile = 4; }
    }

    if($this->debug >= 5) {print("profile: $profile<BR>\n");}
    
#################

    foreach($this->pm_direction as $state) {
      if($this->debug >= 5) {
        print("Doing $state<br>\n");
      }

      $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

      $label = "&nbsp;"; #$state;

      $html .= "$label\n</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

      $fieldsName = array();

      // draw a graph for each PM
      for ($p = 0; $p < count($this->PMs); $p++) 
      {
        $pm = $this->PMs[$p];

        $fieldsName[strtolower($state . "_" . $pm)] =
          $this->PM_label_for_circuitlevel[$profile][$state . "_" . $pm];

      }

      $html .= $this->graphPMS($tidid, $fieldsName, $state);
      $html .= "<BR><BR>\n</TD>\n</TR>\n";
    }

    return $html;

#################

    $fieldsName = array();

    foreach( $this->PMs as $pm)
    {
      foreach ($this->pm_direction as $dir)  
      {
        if ($this->PM_label_for_circuitlevel[$profile][$dir . "_" . $pm])
        {
          $fieldsName[$dir . "_" . strtolower($pm)] = $this->PM_label_for_circuitlevel[$profile][$dir . "_" . $pm];
        }
      }
    }
    
    $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

    $html .= $this->graphPMS($tidid, $fieldsName, "status");
    $html .= "<BR><BR>\n</TD>\n</TR>\n";

    return $html;
  }


  function display_Info()
  {
    #return $this->display_ATM_Info();
    return $this->display_DWS_Info();
    #return $this->display_CircuitLevel_Info();
    
  }

  function additionalButtons()
  {
  }

}
?>
