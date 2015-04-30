<?php

include_once("TableUpdate.inc");

class admin_levelUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "code";
  var $label = "Admin Levels";
  var $table_name = "admin_level";
  var $class_name = "Admin_level";
  #var $seq = "contacts_id_seq";
  var $return_page = "/admin/";

  # Now we're going to set up some arrays containing information about the
  # the database fields we'll be playing with.  Basically it's a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    if($this->debug > 4) {
      print("In _init()<br>\n");
    }

    $this->fields = array($this->id => array ("required" => 1,
                                "display" => 1,
                                "name" => "Code",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                  'value' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 30)),
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_levelUpdate($con, $dbg = 0, $app = "")
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

  function specific_validate()
  {
  }
}

?>
