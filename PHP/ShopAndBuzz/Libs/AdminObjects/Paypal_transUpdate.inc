<?php

include_once("TableUpdate.inc");

class Paypal_transUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Transactions";
  var $table_name = "paypal_trans";
  var $class_name = "Paypal_trans";
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
                                "name" => "ID",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'buzz_user_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Buzz User",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),

                  'commission_seller_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Commision Seller Name",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),
                                
                  'sold_to_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Buyer Name",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),
                                                                
                  'email_add_to' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Email Address",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 30)),
                                
                  'full_name_to' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Full Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 20, "maxlength" => 30)),

                  'email_add_to' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Email Address",
                                "admin" => 0,
                                "widget" => "display_text_field",  //NEED TO CHANGE THIS TO BOOLEAN
                                "args" => array("size" => 20, "maxlength" => 30)),
                                
                                
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function Paypal_transUpdate($con, $dbg = 0, $app = "")
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
