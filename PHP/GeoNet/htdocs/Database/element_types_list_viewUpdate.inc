<?php

include_once("TableUpdate.inc");

class element_types_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "GeoNet Monitored Element Types";
  var $table_name = "element_types_list_view";
  var $listpage = "element_types_list.php";
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
                                "datawrap" => 0,
                                "listline" => "\"<a href=\\\"update.php?table=element_types&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=element_types&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a><br><a href=\\\"interface_types_list.php?felementtype=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">IF Types</span></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type Name",
                                "admin" => 0,
                                "sorter" => "nameXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          "windows" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Window Count",
                                "sorter" => "windowsXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
											    'predefined_ifs' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Predefined Interfaces?",
                                "sorter" => "predefined_ifsXXX",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'pm_doc_link' => array ("required" => 0,
                                "display" => 1,
                                "name" => "PM Document",
                                "datawrap" => 0,
                                "listline" => "\"<a href=\\\"\" . \$x[\"PM_DOC_LINK\"] . \"\\\"><span class=\\\"contentsmalllink\\\">PM Docs</span></a>\"",
                                ),

                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function element_types_list_viewUpdate($con, $dbg = 0, $app = "")
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
