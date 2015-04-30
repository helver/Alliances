<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: FacilityInfo
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: FacilityInfo is a class used to acquire and store 
 *              information about the current state of GeoNet facilities.
 *
 * Revision: $Revision: 1.13 $
 * Last Change Date: $Date: 2005-03-08 20:41:58 $
 * Last Editor: $Author: eric $
*/

class FacilityInfo
{
  var $dbh;
  var $config;
  var $debug;
  var $user;

  var $facilitiesInfo;
  var $custObj;
  var $sev;

  function FacilityInfo(&$custObj, $sev, &$user, $config, $dbh, $debug)
  {
    $this->debug = $debug;
    $this->config = $config;
    $this->dbh = $dbh;
    $this->custObj =& $custObj;
    $this->sev = $sev;
    $this->user = $user;

    $this->__pull_facilities_info();
  }



  function __pull_facilities_info()
  {
    if($this->debug >= 5) {
      print("Entering FacilityInfo::__pull_facilities_info<br>\n");
    }

    $custs = $this->user->getInfo("customerlist");
    $custring = join(",", array_keys($custs));

    # Determine which, if any, facilities for this customer have an
    # unacknowledged alarm.
    #$this->dbh->debug(5);
    $res = $this->dbh->Select("*", "pull_facilities_info_view", "customer_id in ($custring)", "facility_id");

    for($i = 0; $res[$i]; $i++) {
      $this->facilitiesInfo[$res[$i]["facility_id"]] = array("facility"=>$res[$i]["facility"], "customer_id"=>$res[$i]["customer_id"], "flag"=>$res[$i]["flag"]);

      if($debug >= 4) {
        print ($res[$i]["facility_id"] . " -- " . $res[$i]["facility"] . " -- " . $res[$i]["customer_id"] . " -- " . $res[$i]["flag"] . "<br>\n");
      }
    }

    if($this->debug >= 5) {
      print("Exiting FacilityInfo::__pull_customers_info<br>\n");
    }
  }


  function update_facility_list($customer = -1, $facility = -1)
  {
    if($this->debug >= 5) {
      print("Entering FacilityInfo::update_facility_list<br>\n");
    }

    if($customer != -1) {
      $this->__identify_shown_facilities($customer, $facility);
    }

    if($this->debug >= 5) {
      print("Exiting FacilityInfo::update_facility_list<br>\n");
    }
  }


  function __identify_shown_facilities($customer, $facility)
  {
    if($this->debug >= 5) {
      print("Entering FacilityInfo::__identify_shown_facilities<br>\n");
    }

    # If we've been told to view a particular facility, note that in the
    # facilities information.
    if(isset($facility) && is_array($facility)) {
      foreach($facility as $v) {
        if($this->debug >= 5) {
          print("included facility: $v<br>\n");
        }
        $this->facilitiesInfo[$v]["shown"] = 1;
      }
    } else {
      foreach($this->custObj->get_Customer_Facilities($customer) as $v) {
        $this->facilitiesInfo[$v]["shown"] = 1;
      }
    }

    if($this->debug >= 5) {
      print("Exiting FacilityInfo::__identify_shown_facilities<br>\n");
    }
  }


  function get_Facility_Shown($facId)
  {
    return $this->facilitiesInfo[$facId]["shown"];
  }


  function get_Facility_Flag($facId)
  {
    return $this->facilitiesInfo[$facId]["flag"];
  }

  function get_Facility_Name($facId)
  {
    return $this->facilitiesInfo[$facId]["facility"];
  }

}
