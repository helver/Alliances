<?php

#
# Class: FacilityHistoryBase
#
# FacilityHistoryBase is an abstract class used to define common functionality
# used by different GeoNet element type.  You should not use this class
# directly.
#
# Author: eric
# Create Date: 11/7/2002
#
# Revision: $Revision: 1.2 $
# Last Change Date: $Date: 2005-07-26 14:28:28 $
# Last Editor: $Author: eric $
#
#

include_once("History/HistoryBase.inc");

class FacilityHistoryBase extends HistoryBase
{
  #
  # Function: FacilityHistoryBase
  #
  # FacilityHistoryBase is the contstuctor for the class.  Basically all we're
  # doing here is setting our ConfigFileReader object and DBWrappr
  # object and then reading configuration values.
  #
  # FacilityHistoryBase has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # FacilityHistoryBase returns on object of type FacilityHistoryBase.
  function FacilityHistoryBase(&$user, $config, $dbh, $debug = 0)
  {
    # Setting Main Attributes.
    $this->config = $config;
    $dbh->debug($debug);
    $this->dbh = $dbh;
    $this->user = $user;
    $this->debug = $debug;

    // list of PMs (statistics of errors in the element)
    $this->PMs = array ("CV", "ES", "SES", "UAS");

    $this->__init();

    if($this->debug >= 5) {
      print("ln: " . $this->ln . "<BR>\n");
    }
  }





  #
  # Function: __calculateLimits
  #
  # __calculateLimits caculates all the maximums, minimums and
  # coefficients used in the construction of the graphs.  We calculate
  # maximum and minimum real values, pixels values, and the coefficients
  # to calculte pixel values from real values.
  #
  # __calculateLimits has the following parameters:
  #   $maxClause - Select clause that will pull the max for all pms.
  #   $tidid - The TIDID of the element that we're interested in.
  #
  # __calculateLimits has no return value.
  function __calculate_limits($maxClause, $facid)
  {
    // X represents the time in seconds
    // select the minimum date to get the min of X on the graph
    $this->MINX = $this->dbh->SelectSingleValue("to_char(SYSDATE, 'SSSSS')", "DUAL");
    $this->MAXX = $this->MINX + $this->nbSecondsInOneDay;

    // select the max of each PMs to get the max of Y on the graph
    $maxError = $this->dbh->SelectFirstRow("MAX(max_ec) as max_ec, MIN(min_ec) as min_ec" ,"FacHistory_Error_Limits_View", "facility_id = $facid");

    if(!(isset($maxError) && is_array($maxError))) {
      $this->fatalError("No data found for the last 24 hours.");
    }

    $this->MAXY = $maxError["max_ec"];
    $this->MINY = $maxError["min_ec"];

    if($this->debug >= 3) {
      print ("MAXY: " . $this->MAXY . "<br>\n");
      print ("YVal(MAXY): " . ($this->get_YValue($this->MAXY) * 1000). "<br>\n");
      print ("ceil(YVal(MAXY)): " . ceil($this->get_YValue($this->MAXY)) . "<br>\n");
      print ("ungetY(ceil(YVal(MAXY))): " . $this->unget_YValue(ceil($this->get_YValue($this->MAXY))) . "<br>\n");
    }

    $this->MAXY = $this->unget_YValue(ceil($this->get_YValue($this->MAXY)));


    if($this->ln == "logBase10") {
      $this->MINY = 0;
    }

    if($this->debug >= 2) {
      print("MINX: " . $this->MINX . ", MAXX: " . $this->MAXX . "<BR>\n");
      print("MINY: " . $this->MINY . ", MAXY: " . $this->MAXY . "<BR>\n");
    }

    // coordinates in pixels on the graph are in lower case
    // there is a border of $offSet
    $this->minx = (strlen($this->MAXY) * ImageFontWidth($this->textGraphAxeFont)) + $this->textSpacingX + $this->offSet;

    foreach($this->facInfo["tids"] as $k=>$v) {
      $leg_length = max($leg_length, strlen($this->facInfo["tids"][$k]));
    }

    if(isset($this->tps)) {
      foreach($this->tps as $k=>$v) {
        $leg_length = max($leg_length, strlen($k));
      }
    }

    $this->maxx = $this->picWidth - ($leg_length * ImageFontWidth($this->textGraphAxeFont)) - $this->textSpacingX - $this->offSet - $this->textSpacingY;
    $this->miny = $this->picHeight - (2* $this->offSet);
    $this->maxy = $this->offSet; # + ($this->createOffset * count($this->facInfo["tids"]));

    if($this->debug >= 3) {
      $this->debug_output();
    }

    // calculate the coefficient to transform time
    // and number of errors in pixels
    $this->coeffx = ($this->maxx - $this->minx) / ($this->MAXX - $this->MINX);

    if($this->MAXY == $this->MINY || $this->get_YValue($this->MAXY) == $this->get_YValue($this->MINY)) {
      $this->coeffy = 1;
    } else {
      $this->coeffy = ($this->maxy - $this->miny) / ($this->get_YValue($this->MAXY) - $this->get_YValue($this->MINY));
    }

    if($this->debug >= 3) {
      print("YVal(MAXY): " . $this->get_YValue($this->MAXY) . " -- YVal(MINY): " . $this->get_YValue($this->MINY) . "<br>\n");
      $this->debug_output();
    }

  }




  function set_pms($newpms = "")
  {
    if($newpms == "") {
      $this->pms = array();
    } elseif(is_array($newpms)) {
      $this->pms = $newpms;
    } else {
      $this->pms = split(",", $newpms);
    }
  }






  function generate_history_graph($facid)
  {
    $this->__calculate_limits($clause, $facid);

    $this->dataSet[] = $this->dbh->Select("*", "Fac_History_Old_Counts_View", "facility_id = $facid", "timeentered");
    $prev   = $this->dbh->Select("*", "Fac_History_Prev_Counts_View", "facility_id = $facid");
    $curr   = $this->dbh->SelectFirstRow("*", "Fac_History_Cur_Counts_View", "facility_id = $facid");


    for($i = 0; isset($this->dataSet[$i]); $i++) {
      $this->tiddata[$this->dataSet["tidid"]] = array($this->dataSet[$i]);
    }

    for($i = 0; isset($prev[$i]); $i++) {
      $this->tiddata[$prev[$i]["tidid"]][] = $prev[$i];
    }

    for($i = 0; isset($curr[$i]); $i++) {
      $this->tiddata[$curr["tidid"]][] = $curr[$i];
    }

    if($this->debug >= 5) {
      print("DataSet # of entries: " . count($this->dataSet) . "<br>\n");
    }

    return $this->printGraph();
  }





  function __graph_one_tid($pic, $tid)
  {
    if($this->debug >= 5) {
      print("Graphing $pm<br>\n");
    }

    $this->getNextColor();

    $tag = $this->facInfo["tids"][$tid];
    $pm = "ec";

    for ($i = 0; $this->dataSet[$i]; $i++) {

      if($this->debug >= 5) {
        print($this->dataSet[$i] . "<br>\n");
        print("pm = $pm -- " . $this->dataSet[$i][$pm] . "<br>\n");
      }

      if (isset($this->dataSet[$i][strtolower($pm)])) {

        $coord = $this->returnCoord($this->dataSet[$i][$this->xfieldname], $this->dataSet[$i][$pm]);
        $coord["y"] -= $this->graphOffSet;

        if($this->debug >= 5) {
          print("Drawing dot at $coord[x] $coord[y]<br>\n");
        }

        // if the coordinates are valid
        if (isset($coord) && is_array($coord))
        {
          // create the alt tag
          $alt = "$tag at ".$this->dataSet[$i][$this->xfieldname2].", count: ".$this->dataSet[$i][$pm];

          if($this->dataSet[$i][strtolower($pm)] <= -1) {
            // if a previous dot has been drawn, draw a line between them
            if (isset($previousCoord) && is_array($previousCoord)) {
              ImageLine($pic,$previousCoord["x"],$previousCoord["y"],$coord["x"], $previousCoord["y"],$this->get_color());
            }

            unset($previousCoord);
            continue;

          } else {

            // if a previous dot has been drawn, draw a line between them
            if (isset($previousCoord) && is_array($previousCoord)) {
              ImageLine($pic,$previousCoord["x"],$previousCoord["y"],$coord["x"], $previousCoord["y"],$this->get_color());
              #ImageLine($pic,$previousCoord["x"],$previousCoord["y"]+1,$coord["x"], $previousCoord["y"]+1,$this->get_color());
              #ImageLine($pic,$previousCoord["x"],$previousCoord["y"]-1,$coord["x"], $previousCoord["y"]-1,$this->get_color());
              ImageLine($pic,$coord["x"],$previousCoord["y"],$coord["x"], $coord["y"],$this->get_color());
            }

            // draw the dot
            $this->displayDot($pic, $coord["x"], $coord["y"], $this->dataSet[$i][$pm], $alt);

            // remember the coordinates of the previous dot
            $previousCoord = $coord;
          }
        }
      }
    }

    $this->__build_legend($pic, $tag);
  }







  function __build_graph()
  {
    // create the image
    $pic = $this->__build_background();

    // eventually create yellow and red range zones
    if ($this->ErrorMinY != 0 && $this->ErrorMaxY != 0 && $this->WarnMinY != 0 && $this->WarnMaxY != 0) {
      $this->__build_color_ranges($pic);
    }

    // draw the grid
    $this->drawGrid($pic, $this->colors["cGrey"], $this->colors["cBlack"]);

    #$this->debug_output();

    // print the axes
    ImageLine($pic,$this->minx,$this->miny,$this->minx,$this->maxy,$this->colors["cBlack"]);
    ImageLine($pic,$this->minx,$this->miny,$this->maxx,$this->miny,$this->colors["cBlack"]);
    ImageLine($pic,$this->maxx,$this->miny,$this->maxx,$this->maxy,$this->colors["cBlack"]);
    ImageLine($pic,$this->minx,$this->maxy,$this->maxx,$this->maxy,$this->colors["cBlack"]);

    #$this->debug_output();

    $orig_miny = $this->miny;

    // draw a graph for each field
    foreach($this->facInfo["tids"] as $k=>$v) {
      #$this->miny = $orig_miny - $this->graphOffSet;
      #$this->graphOffSet += $this->createOffset;
      $this->dataSet = $this->tiddata[$k];
      $this->__graph_one_tid($pic, $k);
    }


    if(isset($this->tps)) {
      // draw a graph for each field
      foreach($this->tps as $k => $v) {
        #$this->graphOffSet += ($this->createOffset * 6);
        $this->__graph_one_tp($pic, $k);
      }
    }

    $this->miny = $orig_miny;

    return $pic;
  }




  function Facility_Info($facility)
  {
    $this->facInfo = $this->dbh->SelectFirstRow("f.id as id, f.name as name, ff.name as flag, c.id as customerid, c.name as customer", "facilities f, customers c, flags ff", "f.flag = ff.id and f.customer_id = c.id and f.id = $facility");

    if (!(isset($this->facInfo) && is_array($this->facInfo)))
    {
      print("No data found.");
      exit;
    }

    $tids_in_facility = $this->dbh->SelectMap("id, name", "tids", "id in (select tid_id from tid_facility_map where facility_id = $facility)");
    $this->facInfo["tids"] = $tids_in_facility;

    $associated_facilities = $this->dbh->SelectMap("a.fac1 as facid, b.name as facility", "facility_associations a, facilities b", "a.fac1 = b.id and a.fac2 = $facility");
    $this->facInfo["assfacs"] = $associated_facilities;
  }


  function display_Facility_Info()
  {
    $html = "<TABLE CELLPADDING=\"7\">\n";

    $html .= "<TR>\n<TD CLASS=\"content\" ALIGN=\"left\"><B>TIDs:</B></TD>\n";
    $html .= "<TD CLASS=\"content\">";

    $tids = "";
    if(!isset($this->facInfo["tids"]) || !is_array($this->facInfo["tids"]) || count($this->facInfo["tids"]) == 0) {
      $tids = "None";
    } else {
      foreach($this->facInfo["tids"] as $k=>$v) {
        $tids .= ($tids == "" ? "" : ", ") . "<a href=\"pre_history.php?tid_id=$k\">$v</a>";
      }
    }

    $html .= "$tids</TD>\n</tr>\n";

    $html .= "<TR>\n<TD CLASS=\"content\" ALIGN=\"left\"><B>Associated Facilities:</B></TD>\n";
    $html .= "<TD CLASS=\"content\">";

    $tids = "";
    if(!isset($this->facInfo["assfacs"]) || !is_array($this->facInfo["assfacs"]) || count($this->facInfo["assfacs"]) == 0) {
      $tids = "None";
    } else {
      foreach($this->facInfo["assfacs"] as $k=>$v) {
        $tids .= ($tids == "" ? "" : ", ") . "<a href=\"facility_history.php?facility[]=$k\">$v</a>";
      }
    }

    $html .= "$tids</TD>\n</tr>\n";

		#print_r($this->facInfo);
		
    $html .= "<tr>\n<td colspan=\"2\" class=\"content\">Current Status: <img height=\"14\" src=\"images/" . $this->facInfo["flag"] . ".png\"></td>\n</tr>\n";

    $html .= "</table>\n";

    return $html;
  }


  function getFacInfo($field)
  {
    return $this->facInfo[$field];
  }

}
?>

