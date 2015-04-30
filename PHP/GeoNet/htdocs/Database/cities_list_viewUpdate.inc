<?php

include_once("TableUpdate.inc");

class cities_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "GeoNet Cities List";
  var $table_name = "cities_list_view";
  var $listpage = "cities_list.php";
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
                                "listline" => "\"<a href=\\\"update.php?table=cities&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=cities&id\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          "city" => array ("required" => 0,
                                "display" => 1,
                                "name" => "City",
                                "sorter" => "cityXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
											    'state' => array ("required" => 0,
                                "display" => 1,
                                "name" => "State",
                                "admin" => 0,
                                "sorter" => "stateXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'clli_tid' => array ("required" => 0,
                                "display" => 1,
                                "name" => "CLLI Prefix",
                                "admin" => 0,
                                "sorter" => "clli_tidXXX",
                                "excelonly" => 0,
                                "wrap" => "nowrap ",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'latitude' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Latitude",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'longitude' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Longitude",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
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
