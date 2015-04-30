<?php
/**
 * Project: GeoNet Monitor
 *
 * handle_facility_build.php
 * Author: Eric Helvey
 * Create Date: 3/16/2004
 *
 * Description: This is where facilities get built and reordered.
 *
 * Revision: $Revision: 1.15 $
 * Last Change Date: $Date: 2005-11-30 22:42:21 $
 * Last Editor: $Author: eric $
*/

  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  $Xnodes = $dbh->Select("*", "tid_facility_map", "(certified = 't' or certified_recv = 't') and facility_id = " . $_REQUEST["facility_id"]);
  $nodes = array();
  for($i = 0; isset($Xnodes[$i]); $i++) {
    $nodes[$Xnodes[$i]["tid_id"] . "," . $Xnodes[$i]["interface_id"]] = array(
      "tid_id" => $Xnodes[$i]["tid_id"],
      "interface_id" => $Xnodes[$i]["interface_id"],
      "facility_id" => $Xnodes[$i]["facility_id"],
      "trans_seq" => -99999 - $i,
      "recv_seq" => -99999 - $i,
      "certified" => $Xnodes[$i]["certified"],
      "certified_recv" => $Xnodes[$i]["certified_recv"],
    );
  }

  $arrays = array("recv", "trans", "recv_avail", "trans_avail");

  foreach($arrays as $a) {
    if(!is_array($_REQUEST[$a])) {
      continue;
    }

    if($debug >= 5) {
      print "$a list<br>\n";
      foreach($_REQUEST[$a] as $k=>$v) {
        print("$v<br>\n");
      }
      print("<hr><br>\n");
    }

    $i = 1;
    foreach($_REQUEST[$a] as $k=>$v) {
      list($tid_id, $if_id) = split(",", $v);

      if(!isset($nodes[$v])) {
        $nodes[$v] = array(
          "tid_id" => $tid_id,
          "interface_id" => $if_id,
          "facility_id" => $_REQUEST["facility_id"],
          "certified" => "f",
          "certified_recv" => "f",
          "trans_seq" => 0,
          "recv_seq" => 0,
        );
      } else {
        $nodes[$v]["tid_id"] = $tid_id;
        $nodes[$v]["interface_id"] = $if_id;
        $nodes[$v]["facility_id"] = $_REQUEST["facility_id"];
      }

      $xx = $dbh->SelectSingleValue("tid_id", "tid_interface_status", "tid_id = $tid_id and interface_id = $if_id");
      if($xx != $tid_id) {
        $vals = array(
          "flag" => (ereg("avail", $a) ? 0 : 4),
          "timeentered" => "SYSDATE",
          "cause" => "NULL",
          "connect_attempt" => "NULL",
          "tid_id" => $tid_id,
          "interface_id" => $if_id,
        );
        $dbh->Insert("tid_interface_status", $vals);
      }


      $xx = $dbh->SelectSingleValue("tid_id", "pm_info", "tid_id = $tid_id and interface_id = $if_id");
      if($xx != $tid_id) {
        $vals = array(
          "timeentered" => "SYSDATE",
          "cause" => "NULL",
          "tid_id" => $tid_id,
          "interface_id" => $if_id,
          "c1" => -5,
          "c2" => -5,
          "c3" => -5,
          "c4" => -5,
          "c5" => -5,
          "c6" => -5,
          "c7" => -5,
          "c8" => -5,
          "c9" => -5,
          "c10" => -5,
        );
        $dbh->Insert("pm_info", $vals);
        
        $vals["cause"] = "RESET";
        $dbh->Update("pm_info", $vals, "tid_id = $tid_id and interface_id = $if_id");
      }


      if($a == "trans") {
        $nodes[$v]["trans_seq"] = $i;
      } elseif ($a == "recv") {
        $nodes[$v]["recv_seq"] = $i;
      } elseif ($a == "trans_avail") {
        $nodes[$v]["trans_seq"] = $i * -1;
      } elseif ($a == "recv_avail") {
        $nodes[$v]["recv_seq"] = $i * -1;
      }
    
      $nodes[$v]["last_updatedate"] = "SYSDATE";
      if(isset($_REQUEST["certify"])) {
        if($a == "trans") {
          $nodes[$v]["certified"] = 't';
        } elseif ($a == "recv") {
          $nodes[$v]["certified_recv"] = 't';
        } elseif ($a == "recv_avail") {
          $nodes[$v]["certified_recv"] = 'f';
        } elseif ($a == "trans_avail") {
          $nodes[$v]["certified"] = 'f';
        }
      }
      $i++;
    }
  }

  $dbh->Delete("tid_facility_map", "facility_id = " . $_REQUEST["facility_id"]);

  foreach($nodes as $v) {
  	if($v["trans_seq"] != 0 || $v["recv_seq"] != 0) {
    	$dbh->Insert("tid_facility_map", $v);
  	}
    if($v["trans_seq"] < 0 && $v["recv_seq"] < 0) {
    	$dbh->Update("tid_interface_status", "flag = 0, cause = 'InAct'", "tid_id = " . $v["tid_id"] . " and interface_id = " . $v["interface_id"]);
    } else {
    	$dbh->Update("tid_interface_status", "flag = DECODE(flag, 0, 4, flag), cause = DECODE(flag, 0, '', cause)", "tid_id = " . $v["tid_id"] . " and interface_id = " . $v["interface_id"]);
    }
  }    


  $loc = "build_facility.php?id=" . $_REQUEST["facility_id"] . "&error=" . urlencode("Facility Built Successfully");
  __redirector($loc, $debug);
?>