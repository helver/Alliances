<?php

#
# Class: ATMMap
#
# ATMMap is a class used to generate the ATMMap Map Pages
#
# Author: eric
# Create Date: 12/20/2002
#
# Revision: $Revision: 1.15 $
# Last Change Date: $Date: 2005-02-28 22:15:51 $
# Last Editor: $Author: eric $
#
# Development History:
# $Log: ATMMap.inc,v $
# Revision 1.15  2005-02-28 22:15:51  eric
# Code Timestamp.
#
# Revision 1.14  2004/07/09 14:31:04  marie
# *** empty log message ***
#
# Revision 1.13  2004/06/08 19:43:10  marie
# *** empty log message ***
#
# Revision 1.12  2004/05/28 21:13:59  marie
# *** empty log message ***
#
# Revision 1.11  2004/05/14 14:55:19  marie
# Echostar
#
# Revision 1.10  2004/04/06 12:25:47  marie
# added for Echostar PNNI project
#
# Revision 1.9  2003/02/11 21:46:24  eric
# Shifting security level roles.
#
# Revision 1.8  2003/01/30 21:46:59  eric
# Restricting access to proprietary information.
#
# Revision 1.7  2003/01/10 16:34:59  eric
# Ignoring facilities in test and turnup mode.
#
# Revision 1.6  2003/01/08 14:53:00  eric
# Setting up include paths.
#
# Revision 1.5  2002/12/31 16:34:27  eric
# Debugging.
#
# Revision 1.4  2002/12/31 16:25:06  eric
# Adding cause to ATM popups.
#
# Revision 1.3  2002/12/30 22:06:45  eric
# Showing only the facilities specified - and only if they are in error.
#
# Revision 1.2  2002/12/27 19:43:15  eric
# Fixing parse error.
#
# Revision 1.1  2002/12/27 15:23:26  eric
# Adding map base class and transport type specific Map classes.
#
# Revision 1.1  2002/12/26 15:23:27  eric
# New classes needed to implement the feature based display.
#
#
#

include_once("Map/MapBase.inc");

class ATMMap extends MapBase
{
	var $tidFacilityInfo;
	
  function ATMMap(&$user, $dbh, $config, $debug=0)
  {
    $this->MapBase($user, $dbh, $config, $debug);

    $this->tidFacilityInfo = array();
  }

  function acquire_dataset($where) # $customer, $facility, $where
  {
  	$res = $this->dbh->Select("*", "ATMMap_Dataset_View", $where);
  	
    if($this->debug >= 5) {
      print("# Items in Result:" . count($res) . "<br>\n");
    }

  	$lastupdateds = $this->dbh->SelectMap("tid_id, to_char(max(timeentered), 'MM-DD-YYYY HH24:MI:SS') AS lasttime"
  			, "ATMMap_Dataset_View", $where, "", "tid_id, lasttime");
  			
  	$this->dataSet = array();
  	
  	
  	# eliminate any tid_id duplicates
		# we want to draw the tid_ids only once on the map
		# but the query will return several rows (connections) per tid
    for($i = 0; $res[$i]; $i++) 
    {
    	#print("i: $i, tid_id: ". $res[$i]["tid_id"] . "<BR>\n"); 
    	
  		if (!isset($this->tidFacilityInfo[$res[$i]["tid_id"]]))
  		{
  			#print("not set<BR>\n");
  			
  			$res[$i]["lasttime"] = $lastupdateds[$res[$i]["tid_id"]];
  			
  			$this->dataSet[] = $res[$i];
  			#print("last time: ". $this->dataSet[count($this->dataSet) - 1]["lasttime"] . "<BR>\n");
  		}
  		
  		$this->tidFacilityInfo[$res[$i]["tid_id"]]["connections"][] = array(
  				"connection" => $res[$i]["facility"], 
  				"flag" => $res[$i]["conflag"], 
  				"cause" => $res[$i]["cause"], 
  			);
    }
  	
    
    if($this->debug >= 5) {
      print("# Items in Data Set:" . count($this->dataSet) . "<br>\n");
    }
  }



  function acquire_link_dataset($where) #$customer, $facility, $where
  {
    if($this->debug >= 5) {
      print("start acquire_link_dataset<br>\n");
    }

    // select all the transmitter paths
    //$this->transPaths = $this->dbh->Select("*", "ATMMap_Trans_Links_View"); #, $where);
    $this->transPaths = array();

    // select all the receiver paths
    $this->recvPaths = array();

    if($this->debug >= 5) {
      print("# Items in Trans Data Set:" . count($this->transPaths) . "<br>\n");
      print("# Items in Recv Data Set:" . count($this->recvPaths) . "<br>\n");
    }
  }



  function generate_popup_info($record, $flag)
  {
    if($this->debug >= 5) {
      print("start generate_popup_info for tid: ".$record["tid_id"]."<br>\n");
    }

		$alt = "";
		
		if (is_array($this->tidFacilityInfo[$record["tid_id"]]["connections"]))
		{
			
	    if($this->debug >= 5) {
	      print("There is an array of connections.<br>\n");
	    }
    	// create the alt tag
			$alt = "<TABLE CELLPADDING=1 CELLSPACING=0>";
	    
	    for ($i=0; $this->tidFacilityInfo[$record["tid_id"]]["connections"][$i]; $i++)
	    {
	    	$info = $this->tidFacilityInfo[$record["tid_id"]]["connections"][$i];

		    if($this->debug >= 5) {
		      print("connection:" . $info["connection"] . "<br>\n");
		    }
	    	
	    	# if the flag is red, display the connection name in red
	    	# same for yellow,
	    	# otherwise, just use the regular size
	    	#if ($i == 0) { $info["flag"] = 'r';}
	    	#else if ($i == 1) {$info["flag"] = 'y'; } 
	    	$colorclass = ($info["flag"] == 'r' ? "contentSmallAltalarm" 
	    						: ($info["flag"] == 'y' ? "contentSmallAltwarning"
	    						: "contentSmallAlt"));
	    	
	    	$alt .= "<tr><td class='" . $colorclass . "'>"   # class='" . $colorclass . "'
	    			. "<a class='$colorclass' href='" . $this->config->getAttribute("TracePathURL") 
	    			. urlencode($info["connection"]) . "&StartDate=" . urlencode(date("YmdHis")) 
	    			. "&geonetuserid=" . urlencode($GLOBALS["personID"]) . "'>"
	    			. $info["connection"] . "</a></td>"
	    			. "<td class='" .$colorclass. "' nowrap>" . ($info["cause"] ? $info["cause"] : "&nbsp;") . "</td></tr>";
	    	
		    if($this->debug >= 5) {
		      print("End of the loop for connection:" . $info["connection"] . "<br>\n");
		    }
	    }
    	
    	$alt .= "</TABLE>";
    	
		}

		$alt .= "<BR>";

    if($this->debug >= 5) {
      print("stop generate_popup_info<br>\n");
    }
		
    return $alt;
  }

}

?>

