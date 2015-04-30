<?php

include_once("TableUpdate.inc");

class interface_types_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "GeoNet Monitored Interface Types";
  var $table_name = "interface_types_list_view";
  var $listpage = "interface_types_list.php";
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
                                "listline" => "\"<a href=\\\"update.php?table=interface_types&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=interface_types&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Interface Type Name",
                                "admin" => 0,
                                "sorter" => "nameXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          "element_type" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type",
                                "sorter" => "element_typeXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "listline" => "\"<a href=\\\"element_types_list.php?filter=Filter&fhidet=\" . \$x[\"ELEMENT_TYPE_ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">\" . \$x[\"ELEMENT_TYPE\"] . \"</span></a>\"",
                                "admin" => 0,
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

											    'ifname' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Identifier",
                                "admin" => 0,
                                "sorter" => "identifierXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'protocol' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Protocol",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "sorter" => "protocolXXX",
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

}
?>
