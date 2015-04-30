<?
include_once("TableUpdate.inc");

class admin_honeycomblistUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Shop & Buzz Users' Honeycomb";
  var $table_name = "admin_honeycomb_list";
  var $report_label = "Shop & Buzz Users' Honeycomb List";
  var $cols_for_display = 2;
  var $return_page;
  var $listpage = "/admin/users/honeycomb/";

  # Now we''re going to set up some arrays containing information about the
  # the database fields we''ll be playing with.  Basically it''s a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    if($this->debug >= 5) {
      print("In _init()<br>\n");
    }

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 0,
                                "name" => "ID",
                                "sorter" => "idXXX",
                                ),

                          'drop' => array ("required" => 0,
                                "nondb" => 1,
                                "display" => 1,
                                "name" => "Remove",
                                "admin" => 0,
                                "xxline" => "\$xx = \"<a href=\\\"#\\\" onClick=\\\"do_delete('/users/\" . \$x[\"honeycomb_owner\"] . \"/honeycomb/\" . \$x[\"honeycomb_member\"] . \"/');\\\"><span class=\\\"whitetext\\\">Remove</span></a>\";",
                                ),

                          'honeycomb_owner' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Honeycomb Owner",
                                "admin" => 0,
                                "sorter" => "honeycomb_ownerXXX",
                                ),

                          'honeycomb_member' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Honeycomb Member",
                                "admin" => 0,
                                "sorter" => "honeycomb_memberXXX",
                                ),

                          'date_added' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Date Added",
                                "admin" => 0,
                                "sorter" => "date_addedXXX",
                                ),

                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_honeycomblistUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
