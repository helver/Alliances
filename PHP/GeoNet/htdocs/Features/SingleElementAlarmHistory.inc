<?php

#
# Class: SingleElementAlarmHistory
#
# SingleElementAlarmHistory is a class that builds a customizeable alarm history
# page for the GeoNet application.
#
# Author: eric
# Create Date: 12/20/2002
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2003-11-10 20:23:07 $
# Last Editor: $Author: eric $
#
#
#

include_once("Features/GeoNetFeature.inc");

class SingleElementAlarmHistory extends GeoNetFeature
{
  var $dbh;
  var $user;

  function SingleElementAlarmHistory($dbh, $user, $config, $debug)
  {
    $this->GeoNetFeature($config, $debug);

    $this->dbh = $dbh;
    $this->user = $user;
  }


  function generate_Stylesheet()
  {
    $style =<<<EOS

  div.alarm {position:absolute; top: 150; left: 200; text-align: center; font-family:arial,sans-serif; font-size: 32pt; font-weight:bold; color:#ffffff; z-index: 51;}
  .smallContent {font-family:verdana,sans-serif; font-size: 8pt;}
  .smallContentBold {font-family:verdana,sans-serif; font-size: 8pt; font-weight: bold;}
EOS;

    return $style;
  }


  function generate_Layer($age = "", $customer = "")
  {
    $where = "";

    if($customer != "") {
      if($this->user->hasAccessToCustomer($customer)) {
        $where .= " and customerid = $customer";
      }
    } else {
      $where .= " and customerid in (";
      $where .= join(",", array_keys($this->user->getInfo("customerlist")));
      $where .= ")";
    }


    $res = $this->dbh->Select(
      "a.alarm_id, a.tidid, a.description, " .
      "to_char(a.timeentered, 'MM-DD-YYYY HH24:MI:SS') thetime, " .
      "to_char(a.acknowledge_date, 'MM-DD-YYYY HH24:MI:SS') as acktime",

      "single_alarms a, single_element e",

      "e.tidid = a.tidid$where",

      "a.timeentered desc"
    );

    $html = "<div id=\"alarmDiv\" class=\"alarm\">\n";

    if($res[0]) {
      $html .= "<TABLE cellspacing=\"0\" CELLPADDING=\"5\">\n<TR>\n";

      $html .=
        "<TD CLASS=\"smallContentBold\" ALIGN=\"left\">Alarm Time</TD>\n" .
        "<TD CLASS=\"smallContentBold\" ALIGN=\"left\">Acknolwedge Time</TD>\n" .
        "<TD CLASS=\"smallContentBold\" ALIGN=\"left\">Description</TD>\n" .
        "</TR>\n";

      for ($i = 0; $res[$i]; $i++) {
      	if($i >= 15) {
      		break;
      	}
      	
				$html .= "<tr" . ($i % 2 == 1 ? " bgcolor=\"#ccccaa\"" : "") . ">\n";

        $html .=
          "<TD CLASS=\"smallContent\" ALIGN=\"left\">" . $res[$i]["thetime"] . "&nbsp; &nbsp; &nbsp;</TD>\n" .
          "<TD CLASS=\"smallContent\" ALIGN=\"left\">" . $res[$i]["acktime"] . "&nbsp; &nbsp; &nbsp;</TD>\n" .
          "<TD CLASS=\"smallContent\" ALIGN=\"left\">" . $res[$i]["description"] . "</TD>\n";

        $html .= "</tr>\n";
      }
    }

    $html .= "</TABLE>\n";

    $html .= "</div>\n";

    return $html;
  }
}

?>
