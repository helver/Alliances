<?php

include_once("TableUpdate.inc");

class ReferralUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Referrals";
  var $table_name = "referral";
  var $class_name = "Referral";
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
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'buzz_user_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Buzz User",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),

                  'refer_user_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referral User",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),

                  'comm_schedule' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Commission Schedule",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,add_date", "commission_schedule", "", $this->dbh, "", "id", "", "")),

                                
                  'rebate_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Rebate Id",
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

  function ReferralUpdate($con, $dbg = 0, $app = "")
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
