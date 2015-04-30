<?php

include_once("TableUpdate.inc");

class seller_categoryUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Seller Categories";
  var $table_name = "seller_category";
  var $class_name = "Seller_category";
  var $seq = "seller_category_id_seq";
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

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "Category ID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                  'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Category Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=> 30, "maxlength"=>50)),
                  'description' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Category Description",
                                "admin" => 0,
                                "widget" => "display_text_area",
                                "args" => array("cols"=>50, "rows"=>4)),
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function seller_categoryUpdate($con, $dbg = 0, $app = "")
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
