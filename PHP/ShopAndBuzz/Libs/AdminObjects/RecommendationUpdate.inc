<?php

include_once("TableUpdate.inc");

class RecommendationUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "reco_id";
  var $label = "Recommendations";
  var $table_name = "recommendation";
  var $class_name = "Recommendation";
  #var $seq = "contacts_id_seq";
  var $return_page = "/admin/users/recommendations/";

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
                                "name" => "RecoID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size" => 10, "maxlength" => 10)),
                                
                  'buzz_user_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Buzz User",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),
                                
                  'seller_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Seller Name",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id,username", "buzz_user", "", $this->dbh, "", "username", "", "")),

                  'num_purchases' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Number of Purchases",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),
                                
                              
                  'speed_rating' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Speed Rating",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),

                  'expect_rating' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Item As Expected Rating",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),
                          
                  'value_rating' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Value Rating",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),
                          

                  'comm_rating' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Communication Rating",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),
                                
                  'exp_rating' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Overall Experience Rating",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size" => 2, "maxlength" => 5)),

                  'recommend' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Why You Would Recommend",
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

  function RecommendationUpdate($con, $dbg = 0, $app = "")
  {
    #$dbg = 5;
    #$this->return_page = $_SERVER["HTTP_REFERER"];
    $this->TableUpdate($con, $dbg, $app);
  }


}

?>
