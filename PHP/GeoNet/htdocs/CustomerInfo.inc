<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: CustomerInfo
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: CustomerInfo is a class used to acquire and store 
 *              information about the current state of GeoNet Customers' 
 *              facilities.
 *
 * Revision: $Revision: 1.13 $
 * Last Change Date: $Date: 2005-07-06 22:08:39 $
 * Last Editor: $Author: eric $
*/

class CustomerInfo
{
  var $dbh;
  var $config;
  var $debug;
  var $sev;
  var $user;

  var $customersInfo;
  var $facObj;

  function CustomerInfo($sev, &$user, $config, $dbh, $debug)
  {
    $this->debug = $debug;
    $this->config = $config;
    $this->dbh = $dbh;
    $this->sev = $sev;
    $this->user = $user;

    $this->__pull_customers_info();
  }



  function get_customer_facility($c, $f)
  {

    if(is_array($f)) {
      $fac = "facility_id in (" . join(",", $f) . ")";
    } else {
      $fac = "facility_id = $f";
      $f = array($f);
    }

    $c = $this->dbh->SelectSingleValue("unique customer_id", "get_customer_facility_view", $fac);

    return array($c,$f);
  }


  function __pull_customers_info()
  {
    if($this->debug >= 5) {
      print("Entering CustomerInfo::__pull_customers_info<br>\n");
    }

    $custs = $this->user->getInfo("customerlist");
    $custring = join(",", array_keys($custs));

    if($this->debug >= 3) {
      print("$custring<br>\n");
    }


    # Pull Customer Information.
    $res = $this->dbh->Select("*", "pull_customer_list_view", "customer_id in ($custring)");

    for($i = 0; $res[$i]; $i++) {
      $this->customersInfo[$res[$i]["customer_id"]] = array("facilities" => array(), "name"=>$res[$i]["customer"], "short_name"=>$res[$i]["short_name"], "flag"=>$res[$i]["flag"], "flagname"=>$res[$i]["flagname"]);

      if($this->debug >= 4) {
        print("CustomerID: " . $res[$i][0] . " -- name: " . $res[$i][1] . " -- short_name: " . $res[$i][2] . "<br>\n");
      }
    }

		$custmap = $this->dbh->SelectMap("id, customer_id", "facilities", "customer_id in ($custring)");
		
		if(is_array($custmap)) {
  		foreach($custmap as $k=>$v) {
	  		$this->customersInfo[$v]["facilities"][] = $k;
		  }
		
  		foreach($this->customersInfo as $k => $v) {
	  		if(count($this->customersInfo[$k]["facilities"]) <= 0) {
		  		unset($this->customersInfo[$k]);
  			}
	  	}
		}
		
    if($this->debug >= 5) {
      print("Exiting CustomerInfo::__pull_customers_info<br>\n");
    }
  }


  function get_Customer_Facilities($customerId)
  {
    return $this->customersInfo[$customerId]["facilities"];
  }



  function get_Customer_Flag($customerId)
  {
  	$ffflag = $this->customersInfo[$customerId]["flagname"];
  	if($ffflag == "e") {
  		$ffflag = "g";
  	}
    return $ffflag;
  }


	function get_Group_Flag($groupid)
	{
		$flag = 0;
		$flagname = "";
		
		foreach($this->user->info["groupmap"] as $k=>$v) {
			if($v != $groupid) {
				continue;
			}
			
			if($flag == 0) {
				$flag = $this->customersInfo[$k]["flag"];
				$flagname = $this->customersInfo[$k]["flagname"];
			} else {
				$tmpflag = $this->customersInfo[$k]["flag"];
				
				if($flag < $tmpflag) {
					$flag = $tmpflag;
				  $flagname = $this->customersInfo[$k]["flagname"];
				}
			}

			if($flag == 9) {
				return $flagname;
			}
			
		}
		
  	if($flagname == "e") {
  		$flagname = "g";
  	}
		return $flagname;
	}
	
	
  function set_Facilities_List(&$f)
  {
    $this->facObj =& $f;
  }



	function get_group_customers($group_id)
	{
		return $this->user->info["grouporder"][$group_id];
	}
	

  function is_Customer_In_Alarm($customerId)
  {
    if($this->debug >= 5) {
      print("Entering CustomerInfo::__delete_customers_with_no_facilities<br>\n");
    }

    $inAlarm = $this->customerInfo[$customerId]["flag"] === "R";

    if($this->debug >= 5) {
      print("Exiting CustomerInfo::__delete_customers_with_no_facilities<br>\n");
    }

    return $inAlarm;
  }


}
