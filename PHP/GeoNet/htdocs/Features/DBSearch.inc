<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBSearch
 * Author: Eric Helvey
 * Create Date: 1/9/2003
 *
 * Description: DBSearch is a class that builds a form allowing the user
 *              to run an ad-hoc query against a particular database table.
 *
 * Revision: $Revision: 1.6 $
 * Last Change Date: $Date: 2004-03-22 20:30:11 $
 * Last Editor: $Author: eric $
*/

include_once("Features/GeoNetFeature.inc");

class DBSearch extends GeoNetFeature
{
  var $user;
  var $pages;
  var $defaultPage = "update.php";

  function DBSearch($user, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);

    $this->user = $user;
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

  .labelRed {font-family:verdana,sans-serif; font-size: 10pt; font-weight: bold; color: #ff0000}
  .label {font-family:verdana,sans-serif; font-size: 10pt; font-weight: bold;}
EOS;

    return $style;
  }


  function generate_JavaScript()
  {
    $html =<<<EOS

  var formActions = new Array("update.php", "report.php");

  function changeAction(frm) {
    if(frm.format.selectedIndex == 1 || frm.email.checked) {
      frm.action = formActions[1];
    } else {
      frm.action = formActions[0];
    }
  }

  function changeActionF(sel) {
    if(sel.selectedIndex == 0) {
      sel.form.email.checked = false;
    }
    //alert(sel.form);
  }

  function changeActionX(chk) {
    if(chk.checked) {
      chk.form.format.selectedIndex = 1;
    }
  }

  var date_opers = new Array();

  function setOp(oper)
  {
    var name = oper.name.replace(/_operator$/, "");

    //alert(name);

    var t_op = oper.options[oper.selectedIndex].value;

    //alert(t_op);

    date_opers[name] = t_op;

    if(t_op != "btw") {
      document.searchForm.elements["year_post_" + name].selectedIndex = 0;
      document.searchForm.elements["month_post_" + name].selectedIndex = 0;
      document.searchForm.elements["day_post_" + name].selectedIndex = 0;
      document.searchForm.elements["hour_post_" + name].selectedIndex = 0;
      document.searchForm.elements["min_post_" + name].selectedIndex = 0;
      document.searchForm.elements["sec_post_" + name].selectedIndex = 0;
    }
  }


  function checkDateSearch(widg)
  {
    var name = widg.name.replace(/^.*_post_/, "");

    //alert(name);

    if(date_opers[name] != "btw") {
      alert("You must select the 'between' operator to use the second date field.");
      widg.selectedIndex = 0;
    }
  }


  function __fill_time(ttime, name)
  {
    document.searchForm.elements["day_" + name].selectedIndex = ttime.getUTCDate();
    document.searchForm.elements["hour_" + name].selectedIndex = ttime.getUTCHours() + 1;
    document.searchForm.elements["min_" + name].selectedIndex = ttime.getUTCMinutes() + 1;
    document.searchForm.elements["sec_" + name].selectedIndex = ttime.getUTCSeconds() + 1;
    document.searchForm.elements["month_" + name].selectedIndex = ttime.getUTCMonth() + 1;

    for(var i = 0; i < document.searchForm.elements["year_" + name].options.length; i++) {
      if(document.searchForm.elements["year_" + name].options[i].value == ttime.getUTCFullYear()) {
        document.searchForm.elements["year_" + name].selectedIndex = i;
        i = document.searchForm.elements["year_" + name].options.length;
      }
    }
  }


  function populate_time_field(elem, name)
  {
    if(elem.value == 1) {
      return;
    }

    now = new Date();

    if(elem.value == 2) {
      then = new Date(now.getTime() - (1000 * 60 * 60 * 24));
    } else {
      then = new Date(now.getTime() - (1000 * 60 * 60 * 24 * 7));
    }

    __fill_time(then, name);

    __fill_time(now, "post_" + name);
  }

EOS;

    return $html;
  }



  function generate_Layer($table)
  {
    include_once("Database/" . $table . "Update.inc");
    eval ("\$tab = new " . $table . "Update(\$this->config, \$this->debug, \"GeoNet\");");

    $email = $tab->getFormVal("email");
    $join = $tab->getFormVal("join");
    $errorMessage = $tab->getFormVal("errorMessage");
    $format = $tab->getFormVal("format");

    $html =<<<EOS

  <FORM NAME="searchForm" METHOD="POST" onSubmit="changeAction(this)">
    <INPUT TYPE="hidden" NAME="oper" VALUE="report">
    <INPUT TYPE="hidden" NAME="table" VALUE="$table">
    <TABLE BORDER="0" BORDERCOLOR="black" CELLPADDING="10" CELLSPACING="0">
EOS;

    if ($errorMessage) {
      $html .= "<TR><TD CLASS=\"labelRed\" COLSPAN=\"3\" ALIGN=\"center\">$errorMessage</TD></TR>\n";
    }

    $html .=<<<EOS

  <TR>
    <TD CLASS="label" COLSPAN="3" ALIGN="center">
        <INPUT TYPE="submit" VALUE="Submit">
    </TD>
  </TR>

  <TR>
    <TD CLASS="label" COLSPAN="3" ALIGN="center">
      Format:
      <SELECT NAME="format" onChange="changeActionF(this);">
EOS;

    $html .= "<OPTION VALUE=\"HTML\"" . ($format != "EXCEL" ? " SELECTED" : "") . ">HTML</OPTION>\n";
    #$html .= "<OPTION VALUE=\"EXCEL\"" . ($format == "EXCEL" ? " SELECTED" : "") . ">EXCEL</OPTION>\n";


    $html .= "</SELECT>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";

    if($email == 1 || $table == "tid_history") {
      $email = " checked";
    } else {
      $email = "";
    }

    $html .= "<INPUT TYPE=\"checkbox\" NAME=\"email\" onClick=\"changeActionX(this);\" VALUE=\"1\"$email>Receive report by email</TD>\n</TR>\n";

    $html .= "<TR>\n<TD CLASS=\"label\" COLSPAN=\"3\" ALIGN=\"center\">\n";
    $html .= "<INPUT TYPE=\"radio\" NAME=\"join\" VALUE=\"and\" " . ($join != "or" ? "CHECKED" : "") . ">Match all words on page (AND) &nbsp;\n";
    $html .= "<INPUT TYPE=\"radio\" NAME=\"join\" VALUE=\"or\" " . ($join == "or" ? "CHECKED" : "") . ">Match any word on page (OR) &nbsp;\n";

    $html .=<<<EOS

    </TD>
  </TR>

  <TR>
    <TD CLASS="label" ALIGN="center">Field</TD>
    <TD CLASS="label" ALIGN="center">Type</TD>
    <TD CLASS="label" ALIGN="center">Criteria</TD>
  </TR>

EOS;

    // pick up all the fields for this table
    foreach($tab->fields as $k=>$elem) {
      $html .= "<TR><TD CLASS=\"content\">" . $tab->fields[$k]["name"] . "</TD>\n";

      if ($tab->fields[$k]["widget"] == "display_popup_menu") {
        $html .= "<TD CLASS=\"content\">\n";
        $html .= "<input type=\"hidden\" name=\"${k}_operator\" value=\"eq\">in\n</TD>\n";

        $html .= "<TD CLASS=\"content\" ALIGN=\"center\" NOWRAP>\n";

        list($select, $from, $where, $d, $em, $order) = $tab->fields[$k]["args"];

        $html .= popup_menu("${k}[]",$tab->getFormVal($k),$select,$from,$where,$tab->dbh,"",$order,$multiple = 3);

      } elseif (   $tab->fields[$k]["widget"] == "display_date_field"
                || $tab->fields[$k]["widget"] == "display_time_field") {
        $widg = ereg_replace("^display_", "", $tab->fields[$k]["widget"]);

        $html .= "<TD valign=\"top\" CLASS=\"content\">\n";
        $html .= array_menu("${k}_operator", array("btw" => "between", "aton" => "on/at", "lt" => "before", "gt" => "after"), "", "", "", "onChange='setOp(this);'");
        $html .= "<br>and</td>\n<script language=\"JavaScript\"><!--\ndate_opers[\"$k\"] = \"btw\";\ndocument.searchForm.${k}_operator.selectedIdex=0;\n//--></script>\n";

        $html .= "<TD CLASS=\"content\" ALIGN=\"center\" NOWRAP>\n";

        $html .= $widg($k,"", array("allowblank" => 1));

        $html .= "<br>\n";

        $html .= $widg("post_$k","", array("allowblank" => 1, "onChange" => "checkDateSearch(this);"));

        $html .= "<br>";

        $html .= array_buttons("${k}_def", array("1"=>"Manual", "2"=>"Last 24 Hours", "3"=>"Last 7 Days"), "1", array("cols"=>3, "onClick"=>"populate_$widg(this, '$k');"));

      } else {
        $html .= "<TD CLASS=\"content\">\n";
        $html .= $this->printSelectCriteria($tab, "${k}_operator", $tab->getFormVal("${k}_operator"));
        $html .= "</TD>\n";

        $html .= "<TD CLASS=\"content\" ALIGN=\"center\" NOWRAP>\n";
        $html .= text_field($k, $tab->getFormVal($k), $tab->fields[$k]["args"]["size"], $tab->fields[$k]["args"]["maxlength"]);
      }

      $html .= "</TD>\n</TR>\n";
    }

    $html .= "</TABLE>\n</FORM>\n";

    print($html);
  }



  function printSelectCriteria($tab, $fieldName, $operator_value)
  {
    foreach($tab->searchCriteria as $k=>$v) {
      $opts[$k] = $tab->searchCriteria[$k]["label"];
    }

    return array_menu($fieldName, $opts, $operator_value);
  }

}
?>


