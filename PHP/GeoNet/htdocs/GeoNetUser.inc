<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: GeoNetUser
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: GeoNetUser is a class used to store user identify 
 *              and preferences.
 *
 * Revision: $Revision: 1.15 $
 * Last Change Date: $Date: 2006-07-13 19:30:55 $
 * Last Editor: $Author: eric $
*/

class GeoNetUser
{
  var $loggedin = false;
  var $dbh;
  var $config;
  var $debug;
  var $info;
  var $acf2id;

  function GeoNetUser($sess, $config, $dbh, $debug)
  {
    $this->debug = $debug;
    $this->config = $config;
    $this->dbh = $dbh;

    if($sess == -1 || !is_object($sess)) {
      $this->loggedin = false;
    } else {
      $this->loggedin = true;
    }

    $this->__lookupContactInfo();
  }

  function IsLoggedIn()
  {
    return $this->loggedin;
  }

  function lookupPrimusUserName()
  {
    return $this->getInfo("primususername");
  }

  function __lookupContactInfo()
  {
    if($this->debug >= 5) {
      print ("PersonID: " . $GLOBALS["personID"] . "<br>\n");
      print ("AccessLevel: " . $GLOBALS["accessLevel"] . "<br>\n");
    }

		$this->acf2id = $this->dbh->SelectSingleValue("acf2id", "appladmin.security", "applicationid = 1 and personid = " . $GLOBALS["personID"]);
		
    if (isset($GLOBALS["personID"])) {
      $info = $this->dbh->Select("*", "users", "id = " . $GLOBALS["personID"]);

      $this->info = $info[0];
      $this->info["accessLevel"] = $GLOBALS["accessLevel"];

      if($this->debug >= 5) {
        print("AccessLevel: " . $this->info["accessLevel"] . "<br>\n");
      }

      #$this->info["customerlist"] = $this->dbh->SelectMap("customer_id, group_id", "customer_list_by_user_view", "user_id = " . $GLOBALS["personID"]);
			
			$customers = $this->dbh->Select("*", "customer_list_by_user_view", "user_id = " . $GLOBALS["personID"]);
			for($i = 0; isset($customers[$i]); $i++) {
				$this->info["customerlist"][$customers[$i]["customer_id"]] = $customers[$i]["group_id"];
				$this->info["grouporder"][$customers[$i]["group_id"]][$customers[$i]["display_order"]] = $customers[$i]["customer_id"];
			}
			
			$this->info["groupmap"] = $this->info["customerlist"];

      if(!is_array($this->info["customerlist"])) {
        $this->info["customerlist"] = array();
      }
    }
  }

  function getInfo($field)
  {
    if($this->debug >= 5) {
      print("$field: " . $this->info[$field] . "<br>\n");
    }

    return $this->info[$field];
  }



  function hasAccessLevel($level_string)
  {
    if($this->getInfo("accessLevel") >= $this->config->getAttribute($level_string . "AccessLevel")) {
      return 1;
    }

    return 0;
  }



  function hasAccessToCustomer($customer_id)
  {
    return $this->info["customerlist"][$customer_id];
  }




  function hasAccessToFacility($facility_id)
  {
    $res = $this->dbh->Select("customerid", "facilities f", "f.id = $facilityid");

    return $this->info["customerlist"][$res[0]["customerid"]];
  }



  function hasAccessToTidIfc($tidid, $interface_id)
  {
    $res = $this->dbh->SelectSingleValue("customer_id", "facilities f, tid_facility_map t", "f.id = t.facility_id and t.tid_id = $tidid and t.interface_id = $interface_id");
    
    if($res > 0) {
      return true;
    }

    return false;
  }


  function hasAccessToTid($tidid)
  {
    $res = $this->dbh->SelectSingleValue("customer_id", "facilities f, tid_facility_map t", "f.id = t.facility_id and t.tid_id = $tidid");
    
    if($res > 0) {
      return true;
    }

    return false;
  }


  function getInitials()
  {
    return $this->dbh->SelectSingleValue("initials", "user_initials_view", "id = " . $GLOBALS["personID"]);
  }

}
?>