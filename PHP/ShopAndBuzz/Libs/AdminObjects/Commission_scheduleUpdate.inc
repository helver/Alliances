<?php

include_once("TableUpdate.inc");

class commission_scheduleUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Commission Schedules";
  var $table_name = "commission_schedule";
  var $class_name = "Commission_schedule";
  var $seq = "commission_schedule_id_seq";
  //var $return_page = "/admin/users/commission_schedules/";
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
        $xxname = popup_menu("buzz_user_id", "", "id, username", "buzz_user", "", $this->dbh, "", "username", "");
    }

    $this->fields = array($this->id => array ("required" => 1,
                                "display" => 1,
                                "name" => "CommissionScheduleID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
		  'mylabel' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Commission Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>13, "maxlength"=>13)),

                  'user' => array ("required" => 0,
                                "nondb" => 1,
                                "display" => 1,
                                "name" => "Username",
                                "admin" => 0,
                                "widget" => "display_text",
				                "value" => $xxname,
                                "args" => array()),
                                
                  'comm_level' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Commission Type",
                                "admin" => 0,
                                "widget" => "display_radio_buttons",
                                "args" => array(array("Level 1", "Level 2"), "", "", "", "", "")),
                                
                  'active' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Active?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),
                                
                  'amount' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Amount",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>8, "maxlength"=>13)),
                                
                  'max_limit' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Limit",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>7, "maxlength"=>7)),
                                
                  'remain' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Remaining",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>7, "maxlength"=>7)),
                                
                  'min_pay_threshold' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Min Purchase Amount",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>8, "maxlength"=>13)),
                                
                  'max_amount' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Maximum Commission",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>8, "maxlength"=>13)),
                                
                  'pay_type' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Payment Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("showtext, showtext as name", "pay_type", "", $this->dbh, "", "showtext", "", "")),
                                
                  'limit_type' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Limit Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("showtext, showtext as name", "limit_type", "", $this->dbh, "", "showtext", "", "")),
                                
                  'add_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Date Added",
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

  function commission_scheduleUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }


}

?>
