<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: ASX4000History
 * Author: Eric Helvey
 * Create Date: 11/7/2002
 *
 * Description: ASX4000History is a concrete class that provides a 
 *              HistoryBase implementation.  This particular class provides 
 *              history for ASX 4000 elements.
 *
 * Revision: $Revision: 1.8 $
 * Last Change Date: $Date: 2004-03-19 15:40:50 $
 * Last Editor: $Author: eric $
*/
include_once ("History/HistoryBase.inc");

class ASX4000History extends HistoryBase
{


  var $tps;

  #
  # Function: ASX4000History
  #
  # ASX4000History is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # ASX4000History has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # ASX4000History returns on object of type ASX4000History.
  function ASX4000History(&$user, $config, $dbh, $debug)
  {
    $this->HistoryBase($user, $config, $dbh, $debug);
    unset($this->tps);
    $this->states = array();
    unset($this->ln);
    unset($this->inverse_ln);
  }


  function set_tps($tps)
  {
    $this->tps = $tps;
  }


  function graphPMS($tidid, $pms, $state)
  {
    $this->MAXY = 10;
    $this->imageName = $this->imagesFolder . "graph" . $state;
    $this->set_pms($pms);
    return $this->generate_history_graph($tidid);
  }


  function getElementInfo($tidid)
  {
    return $this->ATM_Element_Info($tidid);
  }


  function graphAdditionals($tidid)
  {
  }



  function graphAllPMS($tidid)
  {
    return $this->graphStatus($tidid);
  }


  function graphRates($tidid)
  {
    $html = "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

    $html .= "Cell Rates\n</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

    $fieldsName = array();

    $fieldsName["transmit_cv"] = "Xmit Cell Rate";
    $fieldsName["transmit_es"] = "Rcvd Cell Rate";

    $html .= $this->graphPMS($tidid, $fieldsName, "rates");
    $html .= "<BR><BR>\n</TD>\n</TR>\n";

    return $html;
  }


  function graphStatus($tidid)
  {
    $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\n";

    $fieldsName = array();

    if ($this->tidInfo["slot_transmitter"] == 30) {
      $label = "DS3 Status";
      $fieldsName["transmit_ses"] = "DS3 Status";

    } elseif ($this->tidInfo["slot_transmitter"] == 50) {

      $label = "Sonet Status";
      $fieldsName["receive_cv"] = "Section";
      $fieldsName["receive_es"] = "Line";
      $fieldsName["receive_ses"] = "Path";
    }

    $fields = array();

    $fields["transmit_cv"] = "Xmit Cell Rate";
    $fields["transmit_es"] = "Rcvd Cell Rate";
    $this->set_tps($fields);

    $html .= "$label\n</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

    $html .= $this->graphPMS($tidid, $fieldsName, "status");
    $html .= "<BR><BR>\n</TD>\n</TR>\n";

    return $html;
  }


  function display_Info()
  {
    return $this->display_ATM_Info();
  }

  function additionalButtons()
  {
    if($this->user->hasAccessLevel("Admin")) {
      return "<INPUT TYPE=\"button\" VALUE=\"Clear Flag\" onclick=\"clearFlag();\"><BR><BR>\n";
    }
  }

}
?>
