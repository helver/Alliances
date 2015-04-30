<?
include_once("TableUpdate.inc");

class admin_usermessageslistUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Shop & Buzz Users' Messages";
  var $table_name = "admin_user_messages_list";
  var $report_label = "Shop & Buzz Users' Messages List";
  var $cols_for_display = 2;
  var $return_page;
  var $listpage = "/admin/users/hive/";

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
                                "xxline" => "\$xx = \"<a href=\\\"#\\\" onClick=\\\"do_delete('/users/\" . \$x[\"buzz_user_name\"] . \"/messages/\" . \$x[\"id\"] . \"/');\\\"><span class=\\\"whitetext\\\">Remove</span></a>\";",
                                ),

                          'buzz_user_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "User",
                                "admin" => 0,
                                "sorter" => "buzz_user_nameXXX",
                                ),

                          'date_added' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Date Added",
                                "admin" => 0,
                                "sorter" => "date_addedXXX",
                                ),

                          'message' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Message",
                                "admin" => 0,
                                "sorter" => "messageXXX",
                                ),

                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_usermessageslistUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
