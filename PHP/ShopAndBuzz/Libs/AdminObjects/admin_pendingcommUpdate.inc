<?
include_once("TableUpdate.inc");

class admin_pendingcommUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Pending Commissions";
  var $table_name = "commissions_due_to_me_unpaid";
  var $report_label = "Pending Commissions List";
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

                          'amount' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Amount Due",
                                "admin" => 0,
                                "sorter" => "amountXXX",
                                ),

                          'payable' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Ready To Be Paid",
                                "admin" => 0,
                                "sorter" => "payableXXX",
                                ),

			'referral_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referral ID",
                                "admin" => 0,
                                "sorter" => "referral_idXXX",
                                ),

 			'payee_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Payee",
                                "admin" => 0,
                                "sorter" => "payee_nameXXX",
                                ),
                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_pendingcommUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
