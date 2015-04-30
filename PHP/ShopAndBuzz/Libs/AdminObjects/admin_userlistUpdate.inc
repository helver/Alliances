<?
include_once("TableUpdate.inc");

class admin_userlistUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Shop & Buzz Users";
  var $table_name = "admin_buzz_user_list";
  var $report_label = "Shop & Buzz User List";
  var $cols_for_display = 2;
  var $return_page;
  var $listpage = "/admin/users/";

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
                          'buzz_user_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Username",
                                "admin" => 0,
                                "sorter" => "buzz_user_nameXXX",
                                "xxline" => "\$xx = \"<a href=\\\"/users/\" . \$x[\"buzz_user_name\"] . \"/\\\"><span class=\\\"whitetext\\\">\" . \$x[\"buzz_user_name\"] . \"</span></a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/\" . (\$x[\"active_user\"] == \"t\" ? \"in\" : \"\") . \"activate/\\\"><span class=\\\"whitetext\\\">\" . (\$x[\"active_user\"] == \"t\" ? \"Ina\" : \"A\") . \"ctivate</span></a><br><a href=\\\"/users/\" . \$x[\"buzz_user_name\"] . \"/private/\\\"><span class=\\\"whitetext\\\">Account</span></a><br><a href=\\\"mailto:\" . \$x[\"email\"] . \"\\\"><span class=\\\"whitetext\\\">Email</span></a>\";",
                                ),

                          'public_profile' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Account",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/?table=Ebay&buzz_user_id=\" . \$x[\"id\"] . \"\\\"><span class=\\\"whitetext\\\">eBay&nbsp;Profile</span></a><br><a href=\\\"/admin/?table=Buzz_user_profile&buzz_user_id=\" . \$x[\"id\"] . \"\\\"><span class=\\\"whitetext\\\">User&nbsp;Profile</span></a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/usermessages/\\\"><span class=\\\"whitetext\\\">User&nbsp;Messages</span></a>\";",
                                ),

                          'hive' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Schedules",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/?table=Seller_info&buzz_user_id=\" . \$x[\"id\"] . \"\\\"><span class=\\\"whitetext\\\">Seller&nbsp;Profile</span></a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/commission_schedules/\\\"><span class=\\\"whitetext\\\">Comm&nbsp;Schedules</span></a>\";",
                                ),

                          'honeycomb' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Hive & Honeycomb",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/hive/\\\"><span class=\\\"whitetext\\\">Hive</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/hive_membership/\\\"><span class=\\\"whitetext\\\">Hive&nbsp;Membership</span></a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/honeycomb/\\\"><span class=\\\"whitetext\\\">Honeycomb</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/honeycomb_membership/\\\"><span class=\\\"whitetext\\\">Honeycomb&nbsp;Membership</span></a>\";",
                                ),

                          'referrals' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Referrals",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/referred_by/\\\"><span class=\\\"whitetext\\\">Referred&nbsp;By</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/referrals/\\\"><span class=\\\"whitetext\\\">Referred</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/referred_to/\\\"><span class=\\\"whitetext\\\">Referred&nbsp;To</a>\";",
                                ),

                          'recommendations' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Recommendations",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/recommended_by/\\\"><span class=\\\"whitetext\\\">Recommended&nbsp;By</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/recommendations/\\\"><span class=\\\"whitetext\\\">Recoommended</a>\";",
                                ),

                          'commissions' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Commissions",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/payer_commissions_paid/\\\"><span class=\\\"whitetext\\\">Comms&nbsp;Paid</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/payer_commissions_pending/\\\"><span class=\\\"whitetext\\\">Comms&nbsp;To&nbsp;Be&nbsp;Paid</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/payee_commissions_paid/\\\"><span class=\\\"whitetext\\\">Comms&nbsp;Received</a><br><a href=\\\"/admin/users/\" . \$x[\"buzz_user_name\"] . \"/payee_commissions_pending/\\\"><span class=\\\"whitetext\\\">Comms&nbsp;To&nbsp;Be&nbsp;Recvd</a>\";",
                                ),


                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function listviewUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
