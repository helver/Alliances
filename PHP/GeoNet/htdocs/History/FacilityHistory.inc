<?

include_once ("History/FacilityHistoryBase.inc");

#
# Class: FacilityHistory
#
# FacilityHistory is a concrete class that provides a HistoryBase
# implementation.  This particular class provides history for Alcatel 1640
# elements.
#
# Author: eric
# Create Date: 11/7/2002
#
# Revision: $Revision: 1.2 $
# Last Change Date: $Date: 2005-07-26 14:28:28 $
# Last Editor: $Author: eric $
#
#

class FacilityHistory extends FacilityHistoryBase
{
  var $facilities;
  var $single;

  #
  # Function: FacilityHistory
  #
  # FacilityHistory is the contstuctor for the class.  Basically
  # all we're doing here is setting our ConfigFileReader object and
  # DBWrappr object and then reading configuration values.
  #
  # FacilityHistory has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # FacilityHistory returns on object of type FacilityHistory.
  function FacilityHistory(&$user, $config, $dbh, $debug = 0)
  {
    #print("config - $config<br>\n");
    $this->FacilityHistoryBase($user, $config, $dbh, $debug);
  }


  function SingleFacility($facilityid)
  {
    $this->facilities = array($facilityid);
    $related_facs = $this->dbh->SelectOneColumn("fac2", "facility_associations", "fac1 = $facilityid");
    $this->facilities = array_merge($this->facilities, $related_facs);
  }


  function ChoiceFacility($facilities)
  {
    $this->facilities = $facilities;
  }


  function graphPMS($facid, $pms)
  {
    $this->MAXY = 10;
    $this->MINY = 0;
    $this->imageName = $this->imagesFolder . "graph_fac_" . $facid . "_ec";
    $this->set_pms($pms);
    $this->Facility_Info($facid);
    return $this->generate_history_graph($facid);
  }


  function graphAllPMS()
  {
    #$this->debug = 5;

    if($this->debug >= 5) {
      print("About to do states.<br>\n");
    }

    $html = "";

    foreach($this->facilities as $state) {
      if($this->debug >= 5) {
        print("Doing $state<br>\n");
      }

      $facname = $this->dbh->Select("name", "facilities", "id = $state");

      $html .= "<TR>\n<TD CLASS=\"label\" ALIGN=\"center\">\nError Count for " . $facname[0][0] . "</td>\n</tr>\n<tr>\n<td align=\"center\">\n";

      $fieldsName = array();

      $thetids = $this->dbh->Select("id, name", "tids", "id in (select tid_id from tid_facility_map where facility_id = $state)");

      $tids = array();
      for($i = 0; isset($thetids[$i]); $i++) {
        $tids[] = $thetids[$i]["name"];
      }

      $this->PMs = $tids;

      $html .= $this->graphPMS($state, $fieldsName);
      $html .= "<BR><BR>\n</TD>\n</TR>\n";
    }

    return $html;
  }


  function display_Info()
  {
    return $this->display_Facility_Info($this->facilities[0]);
  }

  function load_Info()
  {
    #print("<p>This is fac 0: " . $this->facilities[0] . "</p>\n");

    $this->Facility_Info($this->facilities[0]);
  }

}
?>
