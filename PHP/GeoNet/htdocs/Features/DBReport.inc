<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBEdit
 * Author: Eric Helvey
 * Create Date: 1/8/2003
 *
 * Description: Feature class for TableUpdate report pages.
 *
 * Revision: $Revision: 1.5 $
 * Last Change Date: $Date: 2005-08-30 19:05:26 $
 * Last Editor: $Author: eric $
*/


include_once("Features/DBFeatBase.inc");

class DBReport extends DBFeatBase
{

  function DBReport($tabUpdate, $config, $debug)
  {
    $this->DBFeatBase($tabUpdate, $config, $debug);
  }


  function generate_Layer()
  {
    $html =<<<EOS

  <table noborder width="100%">
  <!-- Left links table -->
  <TR VALIGN="top">
    <TD align="center"><img src="images/geonetmonitorsmall.png"></td>
  </tr>
EOS;

    $html .= $this->tabUpdate->displayError();

    $html .= "<tr>\n<td>\n";

    $html .= $this->tabUpdate->generateReport(6, "tableHead", "contentsmall", "contentsmalllink");

    $html .= "</td>\n</tr>\n</table>\n\n";

    return $html;
  }
}

?>
