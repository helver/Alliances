<?
include_once("TableUpdate.inc");

class admin_paidcommUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "comm_id";
  var $label = "Paid Commissions";
  var $table_name = "commissions_due_to_me_paid";
  var $report_label = "Paid Commissions List";
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

            'seller_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Payer",
                                "admin" => 0,
                                "sorter" => "seller_nameXXX",
                                ),

            'payee_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Payee",
                                "admin" => 0,
                                "sorter" => "payee_nameXXX",
                                ),

                          'amount' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Amount Due",
                                "admin" => 0,
                                "sorter" => "amountXXX",
                                ),

                          'paid_date' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Paid Date",
                                "admin" => 0,
                                "sorter" => "paid_dateXXX",
                                ),

			'referral_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Referral ID",
                                "admin" => 0,
                                "sorter" => "referral_idXXX",
                                ),

                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_paidcommUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
