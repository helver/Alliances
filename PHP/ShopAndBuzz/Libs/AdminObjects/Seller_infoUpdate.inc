<?php

include_once("TableUpdate.inc");

class Seller_infoUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "buzz_user_id";
  var $label = "Seller Profile Information";
  var $table_name = "seller_profile";
  var $class_name = "Seller_info";
  #var $seq = "buzz_user_id_seq";
  var $return_page = "/admin/users/";

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

    if(isset($_REQUEST[$this->id])) {
        $xxname = $this->dbh->SelectSingleValue("username", "buzz_user", "id = " . $_REQUEST[$this->id]);
    } else {
        $xxname = "";
    }

    $this->fields = array($this->id => array ("required" => 1,
                                "display" => 1,
                                "name" => "UserID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'user' => array ("required" => 0,
                                "nondb" => 1,
                                "display" => 1,
                                "name" => "Username",
                                "admin" => 0,
                                "widget" => "display_text",
				                "value" => $xxname,
                                "args" => array()),
                                
                  'category_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Seller Category",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,name", "seller_category", "", $this->dbh, "", "name", "", "")),

                  'description' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Seller Blurb",
                                "admin" => 0,
                                "widget" => "display_text_area",
                                "args" => array("cols" => 40, "rows" => 4)),
                                
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function Seller_infoUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }


}

?>
