<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBFeatBase
 * Author: Eric Helvey
 * Create Date: 2/27/2004
 *
 * Description: Feature class for TableUpdate view record pages.
 *
 * Revision: $Revision: 1.5 $
 * Last Change Date: $Date: 2005-03-24 17:28:53 $
 * Last Editor: $Author: eric $
*/


include_once("Features/GeoNetFeature.inc");

class DBFeatBase extends GeoNetFeature
{
  var $tabUpdate;

  function DBFeatBase($tabUpdate, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);
    $this->tabUpdate = $tabUpdate;
  }


  function __top_of_layer()
  {
    $html =<<<EOS

  <table noborder width="100%">
  <!-- Left links table -->
  <TR VALIGN="top">
    <TD ALIGN="center">
      <TABLE BORDER="0" CELLPADDING="0"  CELLSPACING="0" WIDTH="100%">
EOS;

    $html .= $this->genNavBar($this->tabUpdate);

    if($this->tabUpdate->generateError() != "") {
      $html .= "<tr><td><p class=\"error\">" . $this->tabUpdate->generateError() . "</p></td></tr>\n";
    }

    $html .=<<<EOS

        <TR>
          <TD ALIGN="center">
EOS;

    return $html;
  }


  function __bottom_of_layer()
  {
    $html .=<<<EOS

          </TD>
        </TR>
      </TABLE>
    </TD>
  </TR>
  </TABLE>
EOS;

    return $html;
  }




  function genNavBar(&$tab)
  {
    $html =<<<EOS

        <TR>
          <TD ALIGN="center">
            <TABLE BGCOLOR="#333333" ALIGN="center" BORDER="0" BORDERCOLOR="#ffffff" CELLPADDING="5" CELLSPACING="0" WIDTH="100%">
              <FORM NAME="topForm" METHOD="GET" ACTION="update.php">
EOS;

    $html .= hidden_field("table", $tab->table_name);
    $html .= hidden_field("oper", "view");

    $html .=<<<EOS

              <TR><TD nowrap CLASS="nextprevious" ALIGN="left" WIDTH="20%">
EOS;

    list($count, $min, $max, $prev, $next) = $tab->countExisting();

    if($tab->getVal($tab->id) > $min) {
      $html .= "<A CLASS=\"nextprevious\" HREF=\"update.php?table=" . urlencode($tab->table_name) . "&oper=view&" . $tab->id . "=$prev\">Previous</A>";
    }

    $html .= <<<EOS

                </TD>
                <TD nowrap CLASS="nextprevious" ALIGN="center" WIDTH="60%">
EOS;

    $html .= "Record <INPUT TYPE=\"text\" NAME=\"" . $tab->id . "\" SIZE=\"3\" VALUE=\"" . $tab->getVal($tab->id) . "\">\n";
    $html .= "<INPUT TYPE=\"submit\" VALUE=\"Go\">\n";

    if($count) {
      $html .= " Total Records: $count";
    }

    $html .= "</TD>\n<TD nowrap CLASS=\"nextprevious\" ALIGN=\"right\">\n";

    if($tab->getVal($tab->id) < $max) {
      $html .= "<A CLASS=\"nextprevious\" HREF=\"update.php?table=" . urlencode($tab->table_name) . "&oper=view&" . $tab->id . "=$next\">Next</A>";
    }

    $html .= "</td>\n</tr>\n";

    $html .= "<tr><td nowrap align=\"center\" colspan=\"3\"><A CLASS=\"nextprevious\" HREF=\"update.php?table=" . urlencode($tab->table_name) . "&" . $tab->id . "=" . $tab->getVal($tab->id) . "\">Edit This Record</A>";
    $html .= " &nbsp; &nbsp; &nbsp; &nbsp; <A CLASS=\"nextprevious\" HREF=\"update.php?table=" . urlencode($tab->table_name) . "&" . $tab->id . "=" . $tab->getVal($tab->id) . "&oper=Delete\">Delete This Record</A>";
    $html .= " &nbsp; &nbsp; &nbsp; &nbsp; <A CLASS=\"nextprevious\" HREF=\"update.php?table=" . urlencode($tab->table_name) . "\">Add New Record</A>";
    $html .= " &nbsp; &nbsp; &nbsp; &nbsp; <A CLASS=\"nextprevious\" HREF=\"update.php?oper=view&table=" . urlencode($tab->table_name) . "&" . $tab->id . "=" . $tab->getVal($tab->id) . "\">View Details of This Record</A>";
    $html .= " &nbsp; &nbsp; &nbsp; &nbsp; <A CLASS=\"nextprevious\" HREF=\"" . ($this->tabUpdate->listpage == "" ? "update.php?oper=report&table=" . urlencode($tab->table_name) : $this->tabUpdate->listpage . "?filter=Filter&fhidtidid=" . $tab->getVal($tab->id)) . "\">Table View</A></td></tr>";

    $html .=<<<EOS

              </FORM>
            </TABLE>
          </TD>
        </TR>
EOS;

    return $html;
  }
}

?>
