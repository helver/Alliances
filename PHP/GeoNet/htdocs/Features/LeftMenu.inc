<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: LeftMenu
 * Author: Eric Helvey
 * Create Date: 12/20/2002
 *
 * Description: LeftMenu is a class used to generate the left menu 
 *              contents on many of the GeoNet Pages.
 *
 * Revision: $Revision: 1.54 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class LeftMenu extends GeoNetFeature
{
  var $user;
  var $sub_feature;
  var $PrimusInfo;
  var $dbh;
  
  function LeftMenu(&$user, $config, $debug, $dbh)
  {
    $this->user = $user;
    $this->GeoNetFeature($config, $debug);

    $this->sub_feature = array();
    $this->PrimusInfo = array();
    $this->dbh = $dbh;
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

  a:link {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  a:hover {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  a:visited {font-family:arial,sans-serif; text-decoration:none; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  div.leftside {position:absolute; top: 80; left: 0; font-family:verdana,arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}
  .leftside {font-family:verdana,arial,sans-serif; font-weight:bold; font-size: 10pt; color:#000000; z-index: 50;}

  #menuShow{
  border: 1px solid #666666;
  background-color: #ffffff;
  padding: 13px;
  font-size: 13px;
  font-family: Verdana, Arial;
  position: absolute;
  width: auto;
  height: auto;
  z-index: 150;
  filter: progid:DXImageTransform.Microsoft.Alpha(opacity = 80);
  }

  #menuSelect{
  background-color: #ffffff;
  padding: 0px;
  font-size: 13px;
  font-family: Verdana, Arial;
  position: absolute;
  width: auto;
  height: auto;
  z-index: 150;
  }

  #legendShow{
  border: 1px solid #666666;
  background-color: #ffffff;
  padding: 13px;
  font-size: 13px;
  font-family: Verdana, Arial;
  position: absolute;
  width: auto;
  height: auto;
  z-index: 150;
  filter: progid:DXImageTransform.Microsoft.Alpha(opacity = 80);
  }

  #legendSelect{
  background-color: #ffffff;
  padding: 0px;
  font-size: 13px;
  font-family: Verdana, Arial;
  position: absolute;
  width: auto;
  height: auto;
  z-index: 150;
  }

EOS;

    return $style;
  }

  function generate_JavaScript()
  {
    $debug = $this->debug;

    $script = "  vals = new Array();\n\n";

    if($this->sub_feature["fac_list"] == 1) {
      $script .=<<<EOS

  var debug = $debug;

  function updateFacList(customer)
  {
    var elem = document.getElementById("circuitList").elements["customer"];
    var opts = elem.options;
    for(var i = opts.length -1; i >= 0; i--) {
        if(opts[i].value == customer) {
          elem.selectedIndex = i;
        }
    }

    var opts = document.getElementById("circuitList").elements["facility\[\]"].options;
    for(var i = opts.length; i >= 0; i--) {
        opts[i] = null;
    }

    if(vals[customer]) {
      for(var i = 0; i < vals[customer].length; i++) {
        opts[i] = vals[customer][i];
      }
    }
  }

EOS;
    }
    return $script;
  }


  function generate_OnLoad()
  {
    if($this->sub_feature["fac_list"] == 1) {
      list($num) = array_keys($this->user->getInfo("customerlist"));
      return "updateFacList($num);";
    }
  }


  function generate_Layer($cust = "", $facs = "", $customer = -1)
  {
    $layer = "<div id=\"menuSelect\">\n
              <a href=\"#\" onClick=\"menuShow('menuObj')\">\n
              <img src=\"images/Tab.gif\" border=\"0\"></a>\n
              </div>\n
              <div id=\"menuShow\">\n
              <a href=\"#\" onClick=\"menuHide('menuObj')\">\n
              <img src=\"images/hide.gif\" border=\"0\"></a>\n
              <br>\n
              <table border=\"0\" width=\"150\">";

    $layer .= $this->display_leftside($cust, $facs, $customer);

    $layer .= "</table>\n</div>\n";

    $layer .= "<div id=\"legendSelect\">\n
              <a href=\"#\" onClick=\"menuShow('legendObj')\">\n
              <img src=\"images/LegendTab.gif\" border=\"0\"></a>\n
              </div>\n
              <div id=\"legendShow\">\n
              <a href=\"#\" onClick=\"menuHide('legendObj')\">\n
              <img src=\"images/hide.gif\" border=\"0\"></a>\n
              <br>\n
              <table border=\"0\" width=\"150\">";

    $layer .= $this->display_legend();

    $layer .= "</table>\n</div>\n";

    $layer .= <<<EOS

    <script>

    // Set Show to "yes" to show the menu on start-up.
    // Set Show to "no" to show the selector on start-up.

    Show ="no";

    // Set OffX in pixels to a negative number
    // somewhat larger than the width of the menu.

    var OffX = -510;

    // Set the PosX and PosY variables
    // to the location on the screen where the
    // menu should position (in pixels) when stopped.

    function MenuThing(x, y, name)
    {
      this.PosX = x;
      this.PosY = y;
      this.layerName = name;

      this.MenuX = OffX;
      this.SelX = x;
      this.sPosX = x;
      this.sOffX = OffX;

      if (Show=="yes") {
        this.sPosX=OffX;
        this.sOffX=x;
        this.MenuX=x;
        this.SelX=OffX;
      }
    }


    var menuObj = new MenuThing(0, 130, 'menu');
    var legendObj = new MenuThing(0, 230, 'legend');

    var menus = new Array(menuObj, legendObj);

    // Usually, use the settings shown; but you can
    // change the speed and the increment of motion
    // across the screen, below.

    var speed        = 1;
    var increment    = 20;
    var incrementNS4 = 10; // for slower NS4 browsers

    // do not edit below this line
    // ===========================

    var is_NS = navigator.appName=="Netscape";
    var is_Ver = parseInt(navigator.appVersion);
    var is_NS4 = is_NS&&is_Ver>=4&&is_Ver<5;
    var is_NS5up = is_NS&&is_Ver>=5;

    for (var i = 0; i < menus.length; i++) {
      x = menus[i];

      if (is_NS4) {
        increment=incrementNS4;
        Lq="document.layers.";
        Sq="";
        eval(Lq + x.layerName + 'Select' + Sq + '.left=' + x.sPosX);
        eval(Lq + x.layerName + 'Show' + Sq + '.left=' + x.sOffX);
        eval(Lq + x.layerName + 'Select' + Sq + '.top=' + x.PosY);
        eval(Lq + x.layerName + 'Show' + Sq + '.top=' + x.PosY);

      } else {
        Lq="document.all.";
        Sq=".style";
        document.getElementById(x.layerName + 'Select').style.left = x.sPosX + "px";
        document.getElementById(x.layerName + 'Show').style.left = x.sOffX + "px";
        document.getElementById(x.layerName + 'Select').style.top = x.PosY + "px";
        document.getElementById(x.layerName + 'Show').style.top = x.PosY + "px";

      }
    }

    function menuShow(name)
    {
      for(var i = 0; i < menus.length; i++) {
        if(menus[i].layerName + "Obj" == name) {
          continue;
        } else {
          moveOffMenu(menus[i].layerName + "Obj");
          moveOnSelector(menus[i].layerName + "Obj");
        }
      }

      moveOffSelector(name);
      moveOnMenu(name);
    }


    function menuHide(name)
    {
      //alert("menuHide: " + name);
      for(var i = 0; i < menus.length; i++) {
        if(menus[i].layerName + "Obj" == name) {
          continue;
        } else {
          moveOffMenu(menus[i].layerName + "Obj");
          moveOnSelector(menus[i].layerName + "Obj");
        }
      }

      moveOffMenu(name);
      moveOnSelector(name);
    }


    function moveOnMenu(name)
    {
      x = eval(name);

      if (x.MenuX < x.PosX) {
        x.MenuX += increment;
        if (is_NS5up) {
          document.getElementById(x.layerName + 'Show').style.left = x.MenuX + "px";
        } else {
          eval(Lq + x.layerName + 'Show' + Sq + '.left=' + x.MenuX);
        }
        setTimeout('moveOnMenu("' + name + '")',speed);
      }
    }

    function moveOffMenu(name)
    {
      //alert("menuHide: " + name);
      x = eval(name);

      if (x.MenuX > OffX) {
        x.MenuX -= increment;
        if (is_NS5up) {
          document.getElementById(x.layerName + 'Show').style.left = x.MenuX + "px";
        } else {
          eval(Lq + x.layerName + 'Show' + Sq + '.left=' + x.MenuX);
        }
        setTimeout('moveOffMenu("' + name + '")',speed);
      }
    }

    function moveOffSelector(name)
    {
      x = eval(name);

      if (x.SelX > OffX){
        x.SelX -= increment;
        if (is_NS5up){
          document.getElementById(x.layerName + 'Select').style.left = x.SelX + "px";
        }else{
          eval(Lq + x.layerName + 'Select' + Sq + '.left=' + x.SelX);
        }
        setTimeout('moveOffSelector("' + name + '")',speed);
      }
    }

    function moveOnSelector(name)
    {
      x = eval(name);

      if (x.SelX < x.PosX) {
        x.SelX += increment;
        if (is_NS5up){
          document.getElementById(x.layerName + 'Select').style.left = x.SelX + "px";
        }else{
          eval(Lq + x.layerName + 'Select' + Sq + '.left=' + x.SelX);
        }
        setTimeout('moveOnSelector("' + name + '")',speed);
      }
    }
    </script>
EOS;

    return $layer;
  }





  #########
  # Links Generating Functions

  function link_logoff()
  {
    return "<a href=\"logOff.php\">Log Off</a>";
  }


  function link_alarms()
  {
    if($this->user->hasAccessLevel("Customer")) {
      return "<a href=\"showAlarm.php?noclose=1\">Show Alarms</a>";
    }
  }


  function link_database()
  {
    if($this->user->hasAccessLevel("User")) {
      return "<a href=\"links.php\">Select Database</a>";
    }
  }


  function link_outage_proc()
  {
  	if(isset($_REQUEST["customer"])) {
  		$extras = "?fcustomerxxx=" . $_REQUEST["customer"] . "&filter=Filter";
  	}
  
  	if(isset($_REQUEST["tid_id"])&& isset($_REQUEST["interface_id"])) {
  		$customer = $this->dbh->SelectSingleValue("customer_id", "tid_facility_map tfm, facilities f", "tfm.facility_id = f.id and tfm.tid_id = " . $_REQUEST["tid_id"] . " and tfm.interface_id = " . $_REQUEST["interface_id"]);
  		$extras = "?fcustomerxxx=$customer&filter=Filter";
  	}
  
    if($this->user->hasAccessLevel("User")) {
      return "<a href=\"outage_proc_list.php$extras\">Outage Procedures</a>";
    }
  }


  function link_help()
  {
    if($this->user->hasAccessLevel("InternalUser")) {
      return "<a href=\"/paging/pagingcgi.php\">Help</a>";
    }
  }


  function link_home()
  {
    if($this->user->hasAccessLevel("Customer")) {
      return "<a href=\"/geonetmonitor/colorBlock.php\">GeoNet Home</a>";
    }
  }


  function link_outage_report()
  {
    if($this->user->hasAccessLevel("Customer")) {
      return "<a href=\"/geonetmonitor/outageReport.php\">Outage Report</a>";
    }
  }


  function link_outage_clock()
  {
    if($this->user->hasAccessLevel("User")) {
      return "<a href=\"/geonetmonitor/outageClock.php\">Schedule Outage</a>";
    }
  }


  function link_tracepath()
  {
  	$hastp = $this->dbh->SelectSingleValue("count(1)", "customers c", "tracepath = 't' and id in (" . join(",", array_keys($this->user->getInfo("customerlist"))) . ")");
  	 
    if($hastp >= 1) {
      return "<a href=\""
					. $this->config->getAttribute("TracePathMainURL")
					. "\">Tracepath Tools</a>";
    }
  }


  function link_edit()
  {
    if(   $GLOBALS["oper"] == "view"
       && $this->user->hasAccessLevel("User")
      ) {
      return "<a href=\"/geonetmonitor/update.php?" . $GLOBALS["delete_string"] . "\">Edit Entry</a>";
    }
  }


  function link_delete()
  {
    if(   $GLOBALS["oper"] == "view"
       && $this->user->hasAccessLevel("User")
       && isset($GLOBALS["delete_string"])
      ) {
      return "<a href=\"/geonetmonitor/update.php?" . $GLOBALS["delete_string"] . "&oper=delete\">Delete Entry</a>";
    }
  }


  function link_new()
  {
    if(   $GLOBALS["table"] != ""
       && $this->user->hasAccessLevel("User")) {
      return "<a href=\"/geonetmonitor/update.php?table=" . urlencode($GLOBALS["table"]) . "\">New Entry</a>";
    }
  }


  function link_table()
  {
    if($GLOBALS["table"] != "" && $this->user->hasAccessLevel("User")) {
      return "<a href=\"/geonetmonitor/update.php?oper=report&table=" . urlencode($GLOBALS["table"]) . "\">Table View</a>";
    }
  }


  function link_search()
  {
    if($GLOBALS["table"] != "" && $this->user->hasAccessLevel("User")) {
      return "<a href=\"/geonetmonitor/search.php?table=" . $GLOBALS["table"] . "\">Table Search</a>";
    }
  }


  function link_primus()
  {
    if($this->user->lookupPrimusUserName() != "") {
      $primusURL = $this->config->getAttribute("primusURL") . "?Resource=LASSIE";

      foreach($this->PrimusInfo as $k=>$v) {
        if($this->debug >= 3) {
          print("$k -- $v<br>\n");
        }

        if($k == "cause") {
          $v = preg_replace ("/([^ ]+) (r)/", "\\1 received", $v);
          $v = preg_replace ("/([^ ]+) (t)/", "\\1 transmitted", $v);
          $v = "GeoNet - $v";

          $primusURL .= "&symptom=" . urlencode($v);
        } elseif($k == "transport") {
          $primusURL .= "&fact=" . urlencode($v);
        } elseif($k == "element_type") {
          $primusURL .= "&fact=" . urlencode($v);
        } elseif($k == "customer") {
          $primusURL .= "&fact=" . urlencode($v);
        } elseif($k == "user") {
          $primusURL .= "&user=" . urlencode($v);
        }
      }
    } else {
      $primusURL = "addPrimusUsername.php";
    }

    if($this->user->hasAccessLevel("User")) {
      return "<a href=\"$primusURL\">Primus</a>";
    }
  }


  function set_Primus_info($infoArray)
  {
    foreach($infoArray as $k=>$v) {
      $this->PrimusInfo[$k] = $v;
    }
  }

  function leftside_notloggedin_links()
  {
    return array("help", "home");
  }

  function leftside_loggedin_links()
  {
    return array("logoff", "database", "alarms", "outage_report", "outage_clock", "primus", "tracepath", "help", "home");
  }

  function leftside_links()
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::leftside_links<br>\n");
    }

    $links = array();
    if($this->user->IsLoggedIn()) {
      $links = $this->leftside_loggedin_links();
    } else {
      $links = $this->leftside_notloggedin_links();
    }

    $html = "";

    foreach($links as $v) {
      eval("\$x = \$this->link_$v();");

      if($x != "") {
        $html .= "<tr><td class=\"leftside\">$x</td></tr>\n";
      }
    }

    $html .= "<tr><td><hr></td></tr>\n";

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::leftside_links<br>\n");
    }

    return $html;
  }









  #########
  # Facilities Listing Functions

  function customer_facility_list($cust, $facs, $customer = -1)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::customer_facility_list<br>\n");
    }

    if($customer == -1) {
      return $this->all_customers_facility_list($cust, $facs);
    } else {
      return $this->single_customer_facility_list($cust, $facs, $customer);
    }
  }


  function all_customers_facility_list($custObj, $facsObj, $dflt = -1)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::all_customers_facility_list<br>\n");

      print("custObj - $custObj<br>\n");
    }

    if(is_array($custObj->customersInfo)) {
      $html = "<script language=\"JavaScript\">\n<!--\n";

      $cust = array();

      foreach($custObj->customersInfo as $k=>$v) {
        if($k == "") {
          continue;
        }

        if($this->debug >= 5) {
          print("CustomerID: $k<br>\n");
        }

        $cust[$k] = $custObj->customersInfo[$k]["name"];

        $html .= "  vals[$k] = new Array();\n";
        foreach($custObj->customersInfo[$k]["facilities"] as $i) {
          $html .= "  temp = vals[$k].length;\n  vals[$k][temp] = new Option('" . $facsObj->get_Facility_Name($i) . "', $i);\n";

          if($this->debug >= 5) {
            print("Fac $i Flag " . $facsObj->facilitiesInfo[$i]["flag"] . "<br>\n");
          }

          if($facsObj->facilitiesInfo[$i]["flag"] == "R" || $facsObj->facilitiesInfo[$i]["flag"] == "r") {
          	$r = $this->colors[$facsObj->facilitiesInfo[$i]["flag"]];
						$html .=<<<EOS
						
  if(vals[$k][temp].style && vals[$k][temp].style.setProperty) {
    vals[$k][temp].style.setProperty('fontWeight', 'bold', '');
    vals[$k][temp].style.setProperty('background-color', '$r', '');
    vals[$k][temp].style.setProperty('color', 'white', '');
  } else {
    vals[$k][temp].style.fontWeight = 'bold';
    vals[$k][temp].style.backgroundColor = '$r';
    vals[$k][temp].style.color = 'white';
  }
  
EOS;
          }

        }
      }

      $html .= "// -->\n</script>\n";

      $html .= "<tr>\n<td class=\"leftside\">\n<form id=\"circuitList\" name=\"circuitList\" action=\"map.php\" method=\"get\">\n";
      $html .= "<table border=\"0\">\n<tr>\n<td class=\"leftside\">\n";

      $html .= array_menu("customer",$cust,$dflt,"","","onChange=\"updateFacList(this.options[this.selectedIndex].value);\"");

      $html .= "</td>\n</tr>\n<tr>\n<td>\n<select name=\"facility[]\" multiple size=\"5\">\n";
      $html .= "</select>\n</td>\n</tr>\n<tr>\n<td>\n<input type=\"submit\" value=\"Go\">\n&nbsp; <input type=\"button\" value=\"History\" onClick=\"this.form.action='facility_history.php';this.form.submit();\">\n";
      $html .= "</td>\n</tr>\n</table>\n</form>\n</td>\n</tr>\n";
    }

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::all_customers_facility_list<br>\n");
    }

    return $html;
  }



  function single_customer_facility_list($cust, $facs, $customer)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::single_customer_facility_list<br>\n");
    }

    $html = "<tr>\n<td class=\"leftside\">\n<form id=\"circuitList\" name=\"circuitList\" action=\"map.php\" method=\"get\">\n";
    $html .= "<input type=\"hidden\" name=\"customer\" value=\"$customer\">\n";
    $html .= "<table border=\"0\">\n<tr>\n<td class=\"leftside\">All Circuits</td>\n</tr>\n<tr>\n<td class=\"leftside\">\n";

    $html .= "<select name=\"facility[]\" multiple size=\"3\">\n";

    $html .= $this->generate_facility_dropdown_options($customer, $cust, $facs);

    $html .= "</select>\n</td>\n</tr>\n<tr>\n<td>\n<input type=\"submit\" value=\"Go\">\n &nbsp; <input type=\"button\" value=\"History\" onClick=\"this.form.action='facility_history.php';this.form.submit();\">\n";
    $html .= "</td>\n</tr>\n</table>\n</form>\n</td>\n</tr>\n";

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::single_customer_facility_list<br>\n");
    }

    return $html;
  }


  function generate_facility_dropdown_options($customer, $customerInfo, $facilities)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::generate_facility_dropdown_options<br>\n");
    }

    $html = "";

    if($this->debug >= 3) {
      print("Getting facilities list for customerid: $customer<br>\n");
      print($customerInfo->customersInfo[$customer]["facilities"] . "<Br>\n");
    }

    if(is_array($customerInfo->customersInfo[$customer]["facilities"])) {
    	
    	foreach($customerInfo->customersInfo[$customer]["facilities"] as $k) {
    		$fflist[$k] = $facilities->get_Facility_Name($k);
    	}
    	
			asort($fflist);
			
      # Build the option list.
      foreach($fflist as $k=>$v) {
        if($this->debug >= 5) {
          print("Got facilityid: $k<br>\n");
        }

        $style = "";
        if($facilities->get_Facility_Flag($k) == "r") {
          $style = "background-color:" . $this->colors["r"] . ";font-weight:bold;color:white;";
        } elseif($facilities->get_Facility_Flag($k) == "R") {
          $style = "background-color:" . $this->colors["R"] . ";font-weight:bold;color:white;";
        } else {
          #print("  vals[$k][temp].style = 'leftside';\n");
        }

        $html .= "<option value=\"$k\"";

        if($style != "") {
          $html .= " style=\"$style\"";
        }

        $html .= ">$v</option>\n";
      }
    }

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::generate_facility_dropdown_options<br>\n");
    }

    return $html;
  }





  #########
  # Ticket ACKing Functions

  function ack_ticket_list($customerInfo, $facilities, $customer)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::ack_ticket_list<br>\n");
    }

    if(!$this->user->isLoggedIn()) {
      return;
    }

    $html = "<tr><td><hr></td></tr>\n<tr>\n<td class=\"leftside\">\n";
    $html .= "<form id=\"ackAlarm\" name=\"ackAlarm\" action=\"addAlarmTicket.php\" method=\"post\">\n";
    $html .= "<input type=\"hidden\" name=\"ackFacility\" value=\"Add Record\">\n";
    $html .= "<input type=\"hidden\" name=\"dontClose\" value=\"1\">\n";
    $html .= "<table border=\"0\">\n<tr><td class=\"leftside\">Alarm Circuits</td></tr>\n";
    $html .= "<tr><td class=\"leftside\">\n<select name=\"facilityid[]\" multiple size=\"4\">\n";

    $xxhtml = $this->generate_alarm_dropdown_options($customer, $customerInfo, $facilities);

		if($xxhtml == "") {
			return "";
		} else {
			$html .= $xxhtml;
		}
		
    $html .= "</select>\n</td></tr>\n<tr><td class=\"leftside\">Ticket Number</td></tr>\n";
    $html .= "<tr><td class=\"leftside\">\n";

    $html .= text_field("TICKETNO");

    $html .= "</td></tr>\n<tr><td><input type=\"submit\" value=\"Ack\"></td></tr>\n";
    $html .= "</table>\n</form>\n</td>\n</tr>\n";

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::ack_ticket_list<br>\n");
    }

    return $html;
  }



  function generate_alarm_dropdown_options($customer, $customerInfo, $facilities)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenu::generate_alarm_dropdown_options<br>\n");
      print("customer: $customer<br>\n");
    }

    $html = "";

    $facs = array();

		$xxfacs = $this->dbh->SelectMap("facility_id, 1", "alarms_to_acknowledge_view", "customerid = $customer");
		
		if(isset($xxfacs) && is_array($xxfacs)) {
	    foreach($xxfacs as $v => $xxxx) {
  	    if($this->debug >= 5) {
    	    print "Checking facid: $v - flag: " . $facilities->get_Facility_Flag($v) . " - shown: " . $facilities->get_Facility_Shown($v) . "<br>\n";
      	}

	      if($facilities->get_Facility_Shown($v) != 1) {
  	      continue;
    	  }

	      if($this->debug >= 5) {
  	      print("Dispaying facid: $v - name: " . $facilities->get_Facility_Name($v) . "<br>\n");
    	  }

      	$facs[$v] = $facilities->get_Facility_Name($v);
	    }
		}

    asort($facs);

    foreach($facs as $k=>$v) {
      $html .= "<option value=\"$k\">$v</option>\n";
    }

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::generate_alarm_dropdown_options<br>\n");
    }

    return $html;
  }



  function display_leftside($cust, $facs, $customer)
  {
    if($this->debug >= 5) {
      print("Entering LeftMenuIndex::display_leftside<br>\n");
    }

    $html = $this->leftside_links();
    $html .= $this->customer_facility_list($cust, $facs, $customer);

    if($this->debug >= 5) {
      print("Exiting LeftMenuIndex::display_leftside<br>\n");
    }

    return $html;
  }


  function display_legend()
  {
    $html =<<<EOS

    <tr>
      <td class="leftside"><a href="#" onClick="window.open('colors.html', 'legend', 'width=400,height=400');">Colors</a></td>
    </tr>

    <tr>
      <td class="leftside"><a href="#" onClick="window.open('levels.html', 'legend', 'width=400,height=400');">Access Levels</a></td>
    </tr>

    <tr>
      <td class="leftside"><a href="#" onClick="window.open('acronyms.html', 'legend', 'width=400,height=400');">Acronyms</a></td>
    </tr>


EOS;

    return $html;
  }
}
