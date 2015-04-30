<?php

include_once("TableUpdate.inc");

class showAlarms_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "tid";
  var $label = "GeoNet Alarm History";
  var $table_name = "Alarm_History_View";
  var $listpage = "showAlarm.php";
#  var $detailspage = "outagedetail.php";

  # Now we're going to set up some arrays containing information about the
  # the database fields we'll be playing with.  Basically it's a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    global $sess;

    if($this->debug > 4) {
      print("In _init()<br>\n");
    }

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "TID",
                                "datawrap" => 0,
                                "sorter" => "tidXXX",
                                "listline" => "\"<a href=\\\"pre_history.php?tid_id=\" . \$x[\"TID_ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">\" . \$x[\"TID\"] . \"</span></a>\"",
                                ),

                          "ifname" => array ("required" => 0,
                                "display" => 1,
                                "name" => "INTERFACE",
                                "datawrap" => 0,
                                "sorter" => "ifnameXXX",
                                ),
 
                          "customer" => array ("required" => 0,
                                "display" => 1,
                                "name" => "CUSTOMER",
                                "datawrap" => 0,
                                "sorter" => "customerXXX",
                                ),

											    'facility' => array ("required" => 0,
                                "display" => 1,
                                "name" => "FACILITY",
                                "sorter" => "facilityXXX",
                                "datawrap" => 0,
                                ),

											    'cause' => array ("required" => 0,
                                "display" => 1,
                                "name" => "CAUSE",
                                "sorter" => "causeXXX",
                                "datawrap" => 0,
                                ),

											    'ticketnum' => array ("required" => 0,
                                "display" => 1,
                                "name" => "TICKET NUM",
                                "sorter" => "ticketnumXXX",
                                "datawrap" => 0,
                                "listline" => "nbsp",
                                ),

											    'thetime' => array ("required" => 0,
                                "display" => 1,
                                "name" => "ALARM TIME",
                                "sorter" => "thetimeXXX",
                                "datawrap" => 0,
                                ),

											    'acktime' => array ("required" => 0,
                                "display" => 1,
                                "name" => "ACK TIME",
                                "sorter" => "acktimeXXX",
                                "datawrap" => 0,
                                "listline" => "nbsp",
                                ),

											    'initials' => array ("required" => 0,
                                "display" => 1,
                                "name" => "INITIALS",
                                "sorter" => "initialsXXX",
                                "datawrap" => 0,
                                "listline" => "nbsp",
                                ),

                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function showAlarms_viewUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificUpdate($id)
  {
  }

  function specificInsert($id)
  {
  }

  function specificDelete($id)
  {
  }

}
?>
