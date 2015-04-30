<?php

include_once("TableUpdate.inc");

class ebayUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "buzz_user_id";
  var $label = "Buzz Users Ebay Profile Information";
  var $table_name = "ebay";
  var $class_name = "Ebay";
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
                  'ebay_auth' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Auth&Auth Token",
                                "admin" => 0,
                                "widget" => "display_text_area",
                                "args" => array("cols"=> 50, "rows"=>3)),
                  'entry_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Entry Date",
                                "admin" => 0,
                                "widget" => "display_time_field",
                                "args" => array()),
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function ebayUpdate($con, $dbg = 0, $app = "")
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
