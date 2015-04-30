<?
include_once("TableUpdate.inc");

class admin_referrallistUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Shop & Buzz Referrals";
  var $table_name = "admin_referral_list";
  var $report_label = "Shop & Buzz Referrals List";
  var $cols_for_display = 2;
  var $return_page;
  var $listpage = "/admin/users/referrals/";

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
                                "display" => 1,
                                "name" => "Referral",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/?table=Referral&id=\" . \$x[\"id\"] . \"\\\"><span class=\\\"whitetext\\\">Edit</span></a><Br><a href=\\\"#\\\" onClick=\\\"do_delete('/referrals/\" . \$x[\"id\"] . \"/');\\\"><span class=\\\"whitetext\\\">Remove</span></a>\";",
                                ),

                          'buzz_user_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referrer",
                                "admin" => 0,
                                "sorter" => "referrerXXX",
                                ),

                          'victim_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referree",
                                "admin" => 0,
                                "sorter" => "referreeXXX",
                                ),

                          'seller_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referree",
                                "admin" => 0,
                                "sorter" => "referreeXXX",
                                ),

                          'date_added' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Date Added",
                                "admin" => 0,
                                "sorter" => "date_addedXXX",
                                "align" => "left",
                                ),

                          'commission_schedule_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Comm Sched",
                                "admin" => 0,
                                "xxline" => "\$xx = (\$x[\"commission_schedule_id\"] > 0 ? \"<a href=\\\"/admin/?table=Commission_schedule&id=\" . \$x[\"commission_schedule_id\"] . \"\\\"><span class=\\\"whitetext\\\">View</span></a>\" : \"&nbsp;\");",
                                ),

                          'rebate_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Rebate",
                                "admin" => 0,
                                "xxline" => "\$xx = (\$x[\"rebate_id\"] > 0 ? \"<a href=\\\"/admin/?table=Commission_schedule&id=\" . \$x[\"rebate_id\"] . \"\\\"><span class=\\\"whitetext\\\">View</span></a>\" : \"&nbsp;\");",
                                ),

                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_referrallistUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
