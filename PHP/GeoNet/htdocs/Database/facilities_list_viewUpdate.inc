<?php

include_once("TableUpdate.inc");

class facilities_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "GeoNet Monitored Facilities";
  var $table_name = "facilities_list_view";
  var $listpage = "facilities_list.php";
  var $detailspage = "outagedetail.php";

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
                                "name" => "",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "datawrap" => 1,
                                "listline" => "\"<a href=\\\"update.php?table=facilities&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=facilities&id\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a><br><a href=\\\"build_facility.php?id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Build</span></a><br><a href=\\\"facility_walk_list.php?fhidfac=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Breakdown</span></a><br><a href=\\\"map.php?customer=\" . \$x[\"CUSTOMER_ID\"] . \"&facility[]=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Map</span></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          "facility" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Facility",
                                "sorter" => "facilityXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
											    'active' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Active?",
                                "admin" => 0,
                                "sorter" => "activeXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'customer' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer",
                                "admin" => 0,
                                "sorter" => "customerXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'flag' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Status",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
#                                "listline" => "\"<a href=\\\"update.php?table=facilities&id=\" . \$x[\"ID\"] . \"\\\">Edit</a><br><a href=\\\"update.php?oper=view&table=facilities&id\" . \$x[\"ID\"] . \"\\\">Details</a><br><a href=\\\"build_facility.php?id=\" . \$x[\"ID\"] . \"\\\">Build</a>\"",
                                "listline" => "\"<a href=\\\"map.php?customer=\" . \$x[\"CUSTOMER_ID\"] . \"&facility[]=\" . \$x[\"ID\"] . \"\\\"><img src=\\\"images/\" . strtolower(\$x[\"FLAG\"]) . \".png\\\" width=\\\"30\\\" border=\\\"0\\\"></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'speed' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Speed Rating",
                                "sorter" => "speed_idXXX",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'notes' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Notes",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "args" => array()),

                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function management_report_list_viewUpdate($con, $dbg = 0, $app = "")
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
