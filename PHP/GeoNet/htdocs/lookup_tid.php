<?php
/**
 * Project: GeoNet Monitor
 *
 * lookup_tid.php
 * Author: Eric Helvey
 * Creation Date: 3/16/2004
 *
 * Description: This page is looks up a TID by some mechanism, TID, grouping name
 *              or dwdm facility.
 *
 * Revision: $Revision: 1.10 $
 * Last Change Date: $Date: 2005-09-22 20:54:26 $
 * Last Editor: $Author: eric $
*/
  #$debug = 5;
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  $where = "";
  $ordr = "";

  if(isset($_REQUEST["tid_id"]) && $_REQUEST["tid_id"] != "") {
    $where .= ($where == "" ? "" : " and ") . "tid_id = " . $_REQUEST["tid_id"];
  }

  if(isset($_REQUEST["speed_id"]) && $_REQUEST["speed_id"] != "") {
    $where .= ($where == "" ? "" : " and ") . "speed_id = " . $_REQUEST["speed_id"];
  }

  if(isset($_REQUEST["grouping_name"]) && $_REQUEST["grouping_name"] != "") {
    $where .= ($where == "" ? "" : " and ") . "upper(grouping_name) like upper('" . $_REQUEST["grouping_name"] . "%')";
    $ordr .= ($ordr == "" ? "" : ", ") . "upper(substr(grouping_name, " . strlen($_REQUEST["grouping_name"]) . "," . (14 - strlen($_REQUEST["grouping_name"])) . "))";
  }

  if(isset($_REQUEST["dwdm_facility"]) && $_REQUEST["dwdm_facility"] != "") {
    $where .= ($where == "" ? "" : " and ") . "dwdm_facility = '" . $_REQUEST["dwdm_facility"] . "'";
  }

  if(isset($_REQUEST["ifname"]) && $_REQUEST["ifname"] != "") {
    $where .= ($where == "" ? "" : " and ") . "ifname = '" . $_REQUEST["ifname"] . "'";
  }

  # First we lookup the address in the project_contact table.
  $qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);

	if(!is_array($qqtid) || count($qqtid) == 0) {
		#print("Missed<br>\n");
		$vals = $dbh->SelectFirstRow("e.id as id, e.predefined_ifs as predef", "element_types e, interface_types it, tids t", "it.element_type_id = e.id and it.speed_id = " . $_REQUEST["speed_id"] . " and t.id = " . $_REQUEST["tid_id"] . " and t.element_type_id = e.id");
		if($vals["id"] == 2) {
			if(ereg("-", $_REQUEST["ifname"])) {
			  $newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			  $comps = split("-", $_REQUEST["ifname"]);
			
			  print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			  $vals = array(
				  "id" => $newid,
				  "name" => $_REQUEST["ifname"],
				  "e1" => $comps[1],
				  "e2" => $comps[2],
				  "e3" => $comps[2],
				  "e4" => 3,
				  "e5" => $comps[0],
				  "interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
			  );
			  $dbh->Insert("interfaces", $vals);

	  	  # First we lookup the address in the project_contact table.
  		  $qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
			}
		} elseif($vals["id"] == 49) {
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$comps = split("-", $_REQUEST["ifname"]);
			
			print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"e1" => $comps[1],
				"e2" => $comps[2],
				"e3" => $comps[2],
				"e4" => 3,
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
				
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} elseif($vals["id"] == 51) {
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$comps = split("-", $_REQUEST["ifname"]);
			
			print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"e1" => $comps[1],
				"e2" => $comps[2],
				"e3" => $comps[3],
				"e4" => $comps[4],
				"e5" => $comps[0],
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
				
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} elseif($vals["id"] == 50) {
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$comps = split("-", $_REQUEST["ifname"]);
			
			print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"e1" => $comps[1],
				"e2" => $comps[2],
				"e3" => $comps[3],
				"e4" => $comps[4],
				"e5" => $comps[0],
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
				
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} elseif($vals["id"] == 5) {
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$comps = split("-", $_REQUEST["ifname"]);
			
			print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"e1" => $comps[0],
				"e2" => $comps[1],
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
				
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} elseif($vals["id"] == 1) {
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$comps = split("-", $_REQUEST["ifname"]);
			
			print($_REQUEST["ifname"] . " -- " . join("**", $comps) . "<br>\n");
			
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"e1" => $comps[0],
				"e2" => $comps[1],
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = " . $vals["id"] .  " and speed_id = " . $_REQUEST["speed_id"]),
				
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} elseif($vals["predef"] == "f") {
			#print("Adding new interface<br>\n");
			$newid = $dbh->getNextSeq("INTERFACE_ID_SEQ");
			$vals = array(
				"id" => $newid,
				"name" => $_REQUEST["ifname"],
				"interface_type_id" => $dbh->SelectSingleValue("id", "interface_types", "element_type_id = (select element_type_id from tids where id = " . $_REQUEST["tid_id"] . ") and speed_id = " . $_REQUEST["speed_id"]),
				
			);
			$dbh->Insert("interfaces", $vals);

	  	# First we lookup the address in the project_contact table.
  		$qqtid = $dbh->Select("id, name", "tids_lookup_view", $where, $ordr);
		} else {
			$error = "Unable to find requested TID,Speed,Channel/AID combination.";
			$qqtid[0]["id"] = -1;
		}
	}
?>
<html>
<head>
<script language="JavaScript">
<!--

//
//
// Function: add_item
//
// add_item invokes the addItem function the parent window.  This will
// take a the values retrieved from the project_contact table and move
// them over into the SME dropdown list on either the Project Request
// Page or the Project Update Page.  Once the item has been added, this
// subwindow is closed and control returns to the parent window.
//
// add_item takes the following arguments:
//   field - the name of the field that the item should be added to.
//   id - the contactid of the person to add.
//   label - the name of the person to add.
//
// No return value.
//
function add_item ()
{
<?php
  for($i = 0; isset($qqtid[$i]); $i++) {
    print("  window.opener.addItem('" . $qqtid[$i]["id"] . "','" . $qqtid[$i]["name"] . "');\n");
  }

  if($debug <= 0) {
?>
  window.close();
<?php
  } else {
?>
  setTimeout("window.close()", 5000);
<? } ?>
}

// -->
</script>
  <title>TID Lookup</title>
</head><body onLoad="add_item();">

<h3><?php echo($error); ?></h3>

</body>
</html>
