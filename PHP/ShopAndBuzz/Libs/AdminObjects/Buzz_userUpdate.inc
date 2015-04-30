<?php

include_once("TableUpdate.inc");

class buzz_userUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Buzz Users";
  var $table_name = "buzz_user";
  var $class_name = "Buzz_user";
  #var $seq = "buzz_user_id_seq";
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
                                "name" => "UserID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                  'email' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Email Address",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 40, "maxlength" => 70)),
                  'username' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Username",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 70)),
                  'admin_code' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Admin Level",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("code,value", "admin_level", "", $this->dbh, "", "code", "", "")),
                  'last_auth' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Last Auth",
                                "admin" => 0,
                                "widget" => "display_text",
                                "args" => array()),
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function buzz_userUpdate($con, $dbg = 0, $app = "")
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
