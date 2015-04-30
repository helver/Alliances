<?php
include_once("TableUpdate.inc");

class Fee_scheduleUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Fee Schedules / Coupon Codes";
  var $table_name = "fee_schedule";
  var $class_name = "Fee_schedule";
  var $seq = "fee_schedule_id_seq";
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
                                "name" => "Fee Schedule ID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                  'is_default' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Default?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                  'coupon_code' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Coupon Code",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 18, "maxlength" => 50)),
                                
                              
                  'months_free' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Months Free",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 2)),

                  'monthly_rate' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Monthly Rate",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 6, "maxlength" => 6)),
                                
                  'start_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Start Date",
                                "admin" => 0,
                                "widget" => "display_date_field",
                                "args" => array("allowblank" => 1)),
                                
                  'end_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "End Date",
                                "admin" => 0,
                                "widget" => "display_date_field",
                                "args" => array("allowblank" => 1)),
                                
);

    if($this->debug >= 2) {
      print("this->fields[id][value]: " . (isset($this->fields[$this->id]["value"]) ? $this->fields[$this->id]["value"] : "") .  "<br>\n");
      #print("this->fields[format1][value]: " . $this->fields["format1"]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function Fee_scheduleUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }


}

?>
