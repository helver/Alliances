<?php

include_once("TableUpdate.inc");

class InvitesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "invite_id";
  var $label = "Invites";
  var $table_name = "invites";
  var $class_name = "Invites";
  var $seq = "invites_invite_id_seq";
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
                                "name" => "Invite ID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'buzz_user_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Buzz User",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),

                  'invite_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Invitee Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 30, "maxlength" => 130)),

                  'invite_email' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Invitee Email",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 30, "maxlength" => 130)),

                  'invite_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Invited On",
                                "admin" => 0,
                                "widget" => "display_date_field",
                                "args" => array()),

                  'invite_status' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Invite Status",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 12, "maxlength" => 30)),

                  'nomoreemail' => array ("required" => 0,
                                "display" => 1,
                                "name" => "User Request No More Email?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),


);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function InvitesUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }

}

?>
