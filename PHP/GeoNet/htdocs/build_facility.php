<?
/**
 * Project: GeoNet Monitor
 *
 * build_facility.php
 * Author: Eric Helvey
 * Create Date: 3/12/2004
 *
 * Description: This is where users build facilities.
 *
 * Revision: $Revision: 1.16 $
 * Last Change Date: $Date: 2005-11-30 22:38:45 $
 * Last Editor: $Author: eric $
*/

  $debug = $_REQUEST[debug];
	$requireLogin = 1;
	$minLevel = "UserAccessLevel";

  include_once("ifc_prefs.inc");

  $theme->updateAttr("currentLoc", "Database");

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # Index page, so we're loading up the LeftMenu for the Index page.  The
  # LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  $jscode =<<<EOS

  function load_tid(dir,tform)
  {
    var where = "";
  
    where = "tid_id=" + escape(tform.tid_id.options[tform.tid_id.selectedIndex].value) + "&" +
            "grouping_name=" + escape(tform.grouping_name.value) + "&" +
            "dwdm_facility=" + escape(tform.dwdm_facility.value) + "&" +
            "speed_id=" + escape(tform.speed_id.options[tform.speed_id.selectedIndex].value) + "&" +
            "ifname=" + escape(tform.ifname.value); 

    tform.tid_id.selectedIndex = 0;
    tform.grouping_name.value = "";
    tform.dwdm_facility.value = "";
    tform.ifname.value = "";

    window.open(dir + "/lookup_tid.php?" + where, "", "width=300,height=100,resizable=no,status=no");
  }  

  function __addOne(tfield, id, label)
  {
    var skip = false;
  
    for(i = 0; i < tfield.options.length; i++) {
      if(tfield.options[i].value == id) {
        skip = true;
      }
    }
  
    if(!skip) {
      tfield.options[tfield.options.length] = new Option(label,id,true,false);
    }

    for(i = 0; i < tfield.options.length; i++) {
      tfield.options[i].selected = true;
      if(tfield.options[i].value == "") {
        tfield.options[i] = null;
        i--;
      }
    }
  }  

  function addItem(id,label)
  {
  	//alert("Got id: " + id + " and label: " + label);
  	
  	if(id != "-1") {
	    theField = document.facmap["trans_avail[]"];
  	  __addOne(theField, id, label);

    	theField = document.facmap["recv_avail[]"];
    	__addOne(theField, id, label);
  	} else {
  		alert("Unable to find matching TID,Speed,(Channel/AID) combination.");
  	}
  }


EOS;

  $facs = $dbh->Select("*", "tids_in_facility_view", "facility_id = " . $_REQUEST["id"]);

  $transavail = array();
  $recvavail = array();
  $transtids = array();
  $recvtids = array();

  $blahtrans = array();
  $blahrecv = array();

  $styles = array();
  
  for($i = 0; isset($facs[$i]); $i++) {
  
    if($debug >= 4) {
      foreach($facs[$i] as $k=>$v) {
        print("$k => $v<br>\n");
      }
      print("<hr><br>\n");
    }
      
    if($facs[$i]["trans_seq"] != 0) {
    	$transavail[$facs[$i]["tid_id"]] = ($facs[$i]["certified"] == "t" ? "*" : "") . $facs[$i]["tid"];
    }
    
    if($facs[$i]["recv_seq"] != 0) {
    	$recvavail[$facs[$i]["tid_id"]] = ($facs[$i]["certified_recv"] == "t" ? "*" : "") . $facs[$i]["tid"];
    }
    
    if($facs[$i]["certified"] == 't') {
      $styles[$facs[$i]["tid_id"]] = "font-weight: bold;";
    }
    
    if($facs[$i]["certified_recv"] == 't') {
      $styles_recv[$facs[$i]["tid_id"]] = "font-weight: bold;";
    }
    
    if($facs[$i]["trans_seq"] > 0) {
      $blahtrans[$facs[$i]["trans_seq"]] = $facs[$i]["tid_id"];
    } else {
      $blahta[($facs[$i]["certified"] == "t" ? "*" : "") . $facs[$i]["tid"]] = $facs[$i]["trans_seq"];
    }
    
    if($facs[$i]["recv_seq"] > 0) {
      $blahrecv[$facs[$i]["recv_seq"]] = $facs[$i]["tid_id"];
    } else {
      $blahra[($facs[$i]["certified_recv"] == "t" ? "*" : "") . $facs[$i]["tid"]] = $facs[$i]["recv_seq"];
    }    
  }

  ksort($blahtrans);
  ksort($blahrecv);

  foreach($blahtrans as $v) {
    #print "moving $v from avail to used.<br>\n";

    $transtids[$v] = $transavail[$v];
    unset($transavail[$v]);
  }

  foreach($blahrecv as $v) {
    $recvtids[$v] = $recvavail[$v];
    unset($recvavail[$v]);
  }

  function do_sort_recv_seq($left, $right)
  {
    global $blahra;
    return $blahra[$right] - $blahra[$left];
  }
  
  
  function do_sort_trans_seq($left, $right)
  {
    global $blahta;
    #print($blahta[$right] . " - " . $blahta[$left] . "<br>\n");
    
    return $blahta[$right] - $blahta[$left];
  }
  
  uasort($transavail, "do_sort_trans_seq");
  uasort($recvavail, "do_sort_recv_seq");
  
  $theme->addToAttr("jscode", $jscode);

  __loadFeatures(array($lft), $theme);

  $fac = $dbh->SelectFirstRow("f.id as facility_id, f.name as facility, c.id as customer_id, c.short_name as customer, NVL(all_speeds_for_speed(f.speed_id), 'Multi-Speed') as speed", "facilities f, customers c", "f.customer_id = c.id and f.id = " . $_REQUEST["id"]);
  
  $theme->updateAttr("title", "GeoNet - Facility: " . $fac["customer"] . "&nbsp;/&nbsp;" . $fac["facility"]);
  print($theme->generate_pagetop());

  if(isset($_REQUEST["error"])) {
    print("<table border=\"0\"><tr><td class=\"error\">" . $_REQUEST["error"] . "</td></tr></table>\n");
  }
?>
<form name="facmap" method="POST" action="handle_facility_build.php" onSubmit="selectAll(this, 'trans', 1);selectAll(this, 'recv', 1);">
<?= hidden_field("facility_id", $_REQUEST["id"]) ?>
<table border="0">
  <tr><td class="content">(<a href="map.php?customer=<?= $fac["customer_id"] ?>&facility[]=<?= $fac["facility_id"] ?>">Map</a>) (<a href="facilities_list.php">List</a>) (<a href="facility_walk_list.php?fhidfac=<?= $fac["facility_id"] ?>">Breakdown</a>) (<a href="update.php?table=facilities&id=<?= $fac["facility_id"] ?>">Edit</a>)</td></tr>
  
  <tr><td>
    <table width="100%" border="0" cellspacing="10">
      <tr>
        <td width="33%" align="center" class="content">Add TIDs:</td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td width="33%" align="center" class="content">Enter Interface:</td>
        <td width="33%" align="center" class="content">Click to Add:</td>
      </tr>
      
      <tr>
        <td valign="middle" class="content">
          <table border="0">
            <tr><td nowrap align="right" class="contentmedium">CLLI:</td><td><?= popup_menu("tid_id", "", "id, name", "tids", "element_type_id in (select distinct DECODE(f.speed_id, NULL, it.element_type_id, s.relative_id, it.element_type_id, NULL) from interface_types it, speeds s, facilities f where it.speed_id = s.id and f.id = " . $_REQUEST["id"] . ")", $dbh, "Select A TID", "name") ?></td></tr>
            <tr><td nowrap align="right" class="contentmedium">DWDM GROUPING NAME:</td><td><?= text_field("grouping_name", "", array("size"=>14, "maxlength"=>14)) ?></td></tr>
            <tr><td nowrap align="right" class="contentmedium">DWDM FACILITY ID:</td><td><?= text_field("dwdm_facility", "", array("size"=>9, "maxlength"=>9)) ?></td></tr>
          </table>
        </td>
        
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        
        <td nowrap align="left" valign="top" class="content">
          Channel/AID: <?= text_field("ifname", "", array("size"=>15, "maxlength"=>30)) ?><br>
          Speed: <?= popup_menu("speed_id", "", "id, name", "speeds", "relative_id in (select distinct decode(f.speed_id, NULL, s.id, s.id, s.id, NULL) from speeds s, facilities f where f.id = " . $_REQUEST["id"] . ")", $dbh, "", "name") ?>
        </td>
        
        <td align="center" valign="top">
          <input type="button" value="Add TID" onClick="load_tid('<?= $config->getAttribute("URLDir") ?>', this.form);">
        </td>
      </tr>
    </table></td>
    
  <tr><td><hr></td></tr>
  <tr><td class="content">Transmit Sequence:</td></tr>
  <tr><td class="content"><?= mapAdmin("trans", "TIDs", $transavail, $transtids, 6, array("showDelete"=>1, "showSelectedOrder"=>1, "showAvailableOrder"=>1), $styles) ?></td></tr>
  <tr><td><hr></td></tr>
  <tr><td class="content">Receive Sequence:</td></tr>
  <tr><td class="content"><?= mapAdmin("recv", "TIDs", $recvavail, $recvtids, 6, array("showDelete"=>1, "showSelectedOrder"=>1, "showAvailableOrder"=>1), $styles_recv) ?></td></tr>
  <tr><td><hr></td></tr>
  <tr><td><input type="submit" value="Submit Facility Layout"><?= ($GLOBALS["accessLevel"] >= $config->getAttribute("AdminAccessLevel") ? " &nbsp; &nbsp; <input type=\"submit\" name=\"certify\" value=\"Certify Facility Layout\">" : "") ?></td></tr>
</table>
</form>
<?
  print($lft->generate_Layer());
  print($theme->generate_pagebottom());
?>

