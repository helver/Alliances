<?php

include_once("TableUpdate.inc");

class unconfirmed_userUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "token";
  var $label = "Unconfirmed Users";
  var $table_name = "unconfirmed_user";
  var $class_name = "Unconfirmed_user";
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
                                "name" => "Buzz Token",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 70)),
                  'username' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Username",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 70)),
                  'password' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Password",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 40, "maxlength" => 70)),
                  'email' => array ("required" => 0,
                                "display" => 1,
                                "name" => "User Email",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 30, "maxlength" => 130)),
                  'paypal_user' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Paypal User",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 40, "maxlength" => 130)),
                  'ebay_username' => array ("required" => 0,
                                "display" => 1,
                                "name" => "eBay User",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 40, "maxlength" => 130)),
                  'add_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Date Created",
                                "admin" => 0,
                                "widget" => "display_date_field",
                                "args" => array()),
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function unconfirmed_userUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }

}

?>
