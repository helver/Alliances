<?php

include_once("TableUpdate.inc");

class System_messagesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "system_message_id";
  var $label = "System Messages";
  var $table_name = "system_messages";
  var $class_name = "System_messages";
  var $seq = "system_messages_system_message_id_seq";
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
                                "name" => "ID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'message' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Message",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 25, "maxlength" => 50)),
                                
                              
                  'entry_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Entry Date",
                                "admin" => 0,
                                "widget" => "display_date_field",
                                "args" => array()),

                  'display' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Display?",
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

  function System_messagesUpdate($con, $dbg = 0, $app = "")
  {
    #$dbg = 5;
    #$this->return_page = $_SERVER["HTTP_REFERER"];
    $this->TableUpdate($con, $dbg, $app);
  }


}

?>
