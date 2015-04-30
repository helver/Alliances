<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBChoice
 * Author: Eric Helvey
 * Create Date: 1/9/2003
 *
 * Description: Allows users to choose the database table they want to update.
 *
 * Revision: $Revision: 1.13 $
 * Last Change Date: $Date: 2006-07-11 19:48:44 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class DBChoice extends GeoNetFeature
{
  var $user;
  var $pages;
  var $skip;
  var $defaultPage = "update.php";

  function DBChoice($user, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);

    $this->user = $user;

    $this->pages = array(
      "tids" => "tids_list.php",
      "facilities" => "facilities_list.php",
      "cities" => "cities_list.php",
      "interface_types" => "interface_types_list.php",
      "element_types" => "element_types_list.php",
      "outage_procedure" => "outage_proc_list.php",
      "alarms" => "showAlarm.php",
    );

    $this->skip = array("user"=>1, "security"=>1, 
                        "tids_list_view"=>1, 
                        "facilities_list_view"=>1,
                        "fiber_routes" => 1,
                        "fiber_segments" => 1, 
                        "facility_walk_list_view"=>1, 
                        "cities_list_view"=>1,
                        "interface_types_list_view" => 1, 
                        "outage_procedure_list_view" => 1, 
                        "element_types_list_view" => 1,
                        "showAlarms_view" => 1
                       );
  }


  function generate_JavaScript()
  {
    $html =<<<EOS

  var formActions = new Array();

  function setFormAction(sel) {
    sel.form.action = formActions[sel.selectedIndex];
    //alert(sel.form);
  }

EOS;

    return $html;
  }



  function generate_Layer()
  {
    $fh = opendir("Database");

    while($name = readdir($fh)) {
      if(!ereg("^(.*)Update.inc$", $name, $match)) {
        continue;
      }

      if($this->skip[$match[1]]) {
        continue;
      }

      $tables[$match[1]] = strtoupper(substr($match[1], 0, 1)) . substr($match[1], 1);
    }

    closedir($fh);


    $html =<<<EOS

  <form name="selectPage" method="post">
    <input type="hidden" name="oper" value="report">
    <table align="center" border=0 cellspacing=0 cellpadding=0 width="100%">
      <tr>
        <td class="pageHead" align="center" colspan="3">
          <br>Select a Database Table :
        </td>
      </tr>

      <TR>
        <TD CLASS="content" ALIGN="center">
        <BR><BR>
EOS;

    asort($tables);

    $html .= "<script language=\"JavaScript\">\n";
    $html .= "  temp = formActions.length;\n";
    $html .= "  formActions[temp] = 'links.php';\n";

    foreach($tables as $k=>$v) {
      $html .= "  temp = formActions.length;\n";
      $html .= "  formActions[temp] = '" . ($this->pages[$k] ? $this->pages[$k] : $this->defaultPage) . "';\n";
    }

    $html .= "</script>\n  <select name=\"table\" onChange=\"setFormAction(this);\">\n    <option value=\"\">\n";

    foreach ($tables as $k=>$v) {
      #print ("k => $k<br>\n");
      if($k != "usergroup" || $this->user->hasAccessLevel("Admin")) {
        $html .= "    <option value=\"$k\">$v</option>\n";
      }
    }

    $html .=<<<EOS

  </select>

    <BR><BR>
        </TD>
      </TR>

      <TR>
        <TD CLASS="content" ALIGN="center"><INPUT TYPE="submit" VALUE="Submit">
        </TD>
      </TR>

    </table>
  </form>
EOS;

    print($html);
  }

}
?>


