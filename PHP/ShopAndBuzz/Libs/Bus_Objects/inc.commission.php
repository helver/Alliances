<?php

//
// Commission object
// 
// constructor requires an id (primary key in the database)
// of the requested commission
//
// >>>>  __construct ($dbh, $id)
//
// **** So it's best to use the following static methods to 
// **** retrieve a commission object:
//
// In all of these static methods:
//    $dbh    -> active database handle
//    $seller -> either seller object or database id of seller
//
// ** These will create new entries in the database and make
//    them active. Return success or failure.
//
// >>>>   Commission::new_commission ($data)  -- NOT IMPLEMENTED
// >>>>   Commission::new_rebate ($data)      -- NOT IMPLEMENTED
//
// ** These return an array of Commission objects, in
//    order of creation (first one is the oldest, last one
//    is current. Zero on failure.
//
// >>>>   Commission::get_all_commissions ($dbh, $seller)
// >>>>   Commission::get_all_rebates ($dbh, $seller)
//
// ** These return the active commission, as a Commission object.
//    Returns Zero on failure.
// 
// >>>>   Commission::get_current_commission ($dbh, $seller) {
// >>>>   Commission::get_current_rebate ($dbh, $seller) {
//
// ** These return the active commission id, as an int. You can
//    pass this directly to the constructor to create the instance
//    at a later time.
//    Returns Zero on failure.
// 
// >>>>   Commission::get_current_commission_id ($dbh, $seller) {
// >>>>   Commission::get_current_rebate_id ($dbh, $seller) {
//
// ** Methods available to Commission objects:
//
//   Inform the commissioning system that a payment is being made.
//   This method actually checks the limits (dates, remaining
//   purchases) to verify that the commission is allowed, returns
//   Zero if the commission is not allowed for any reason, returns
//   commission amount on success.
//  
// >>>> make_payment ($sale_amount, $trans_date)
//
//   Calculate how much commission/rebate is due based on a
//   sale amount:
// >>>> get_payment_amount ($sale_amount)
//
//   Get the attributes of the commission (like for displaying on
//   an info page. Note: you cannot update the commission. You must
//   create a new one. Returns an associative array:
//
//      $retval['amount']
//      $retval['max_limit']
//      $retval['remain']
//      $retval['min_pay_threshold']
//      $retval['max_amount']
//      $retval['pay_type']
//      $retval['limit_type']
//      $retval['add_date']
//
// >>>> get_attributes ()
//
//   Get the Commission ID for recreating instances.
//
// >>>> get_id ()
//

// internal notes:

// define: commission - level 1
// define: rebate     - level 2

  class Commission {

    public  $debug = 0;

    private $db_ref = 0;
    private $comm_id = 0;

    private $amount = 0.0;
    private $max_limit  = 0;
    private $remain = 0;
    private $pay_type = "";  // flatrate, percent
    private $limit_type = "";  // days, buys
    private $add_date = "";  // calculations with Unix epoch are 
                             // easiest. We'll use that as the
                             // object's internal format, and
                             // expect that when interfacing with us.
                             // We'll deal with conversion to/from
                             // SQL silently. 
    private $min_pay_threshold = 0.0;
    private $max_amount = 0.0;

    private $error = 0;
    private $loaded = 0;

    public function __construct ($dbh, $id) {
      $this->comm_id = $id;
      $this->db_ref = $dbh;
      // don't load it here, we can lazy load.
    }

    public function get_id () {
      return $this->comm_id;
    }

    public function make_payment ($sale_amount, $tran_date) {
      if (!$this->loaded) {
        $this->load_from_db();
      }

      $payout = 0.0;

      if ($this->error) {
        return $payout;
      }

      if ($this->remain > 0) {
        $this->remain = $this->remain - 1;
        $where = "id=" . $this->comm_id;
        $new_remain = "remain=" . $this->remain;
        $res = $this->db_ref->Update ("commission_schedule", $new_remain, $where);
      } else {
        $res = 0;
        if ($this->limit_type == "days") { 
          if ($this->add_date + ($this->max_limit * 86400) < time()) { 
            $res = 1;
          }
        }
      }

      if (!$res) {
        return $payout;
      }

      return $this->get_payment_amount($sale_amount);
    }

    public function get_payment_amount ($sale_amount) {
      if (!$this->loaded) {
        $this->load_from_db();
      }

      $payout = 0.0;

      if ($this->error) {
        return $payout;
      }

      if ($this->pay_type == "percent") {
        if ($sale_amount >= $this->min_pay_threshold) {
          if ($this->debug) {
            print "Commission (" . $this->comm_id . ") Percentage Payout <BR>\n";
          }
          $payout = $sale_amount * $this->amount;
        }

        if ($payout > $this->max_amount) {
          if ($this->debug) {
            print "Commission (" . $this->comm_id . ") Max Payout (" . $this->max_amount . ") <BR>\n";
          }
          $payout = $this->max_amount;
        }
      } else {  // flat rate
        if ($sale_amount >= $this->min_pay_threshold) {

          if ($this->debug) {
            print "Commission (" . $this->comm_id . ") Flat Rate Payout<BR>\n";
          }
          $payout = $this->amount;
        }
      } 

      if ($this->debug) {
        print "Commission (" . $this->comm_id . ") Paying out $payout <BR>\n";
      }
      return $payout;
    }

    public function get_attributes () {
      return $this->package();
   }

    private function load_from_db () {
      $list = "amount,max_limit,min_pay_threshold,max_amount," .
              "pay_type,limit_type,add_date";
      $where = "id=$this->comm_id";

      if ($this->debug) {
        $this->db_ref->debug = 2;
      }
      $r = $this->db_ref->Select ($list, "commission_schedule", $where);
      $this->db_ref->debug = 0;

      if ($r && count($r) > 0) {
        $this->loaded = 1;

        $this->amount            = $r[0]['amount'];
        $this->max_limit         = $r[0]['max_limit'];
        $this->min_pay_threshold = $r[0]['min_pay_threshold'];
        $this->max_amount        = $r[0]['max_amount'];
        $this->pay_type          = $r[0]['pay_type'];
        $this->limit_type        = $r[0]['limit_type'];
        $this->add_date          = $r[0]['add_date'];

        $this->remain            = array_key_exists ('remain', $r[0]) ? $r[0]['remain'] : $r[0]['max_limit'];
        $this->add_date = Commission::SQL2Epoch($this->add_date);
      } else {
        if ($this->debug) {
          print "Commission (" . $this->comm_id . ") <BR>\n";
          print "Failed database load on id: " . $this->comm_id . " <BR>\n";
          print_r ($r);
          print "<BR>\n";
        }
        $this->error = 1;
      }
    }

    private function package () {
      if (!$this->loaded) {
        $this->load_from_db();
      }

      if ($this->error) {
        return 0;
      }

      $retval = array();

      $retval['amount']            = $this->amount;
      $retval['max_limit']         = $this->max_limit;
      $retval['remain']            = $this->remain;
      $retval['min_pay_threshold'] = $this->min_pay_threshold;
      $retval['max_amount']        = $this->max_amount;
      $retval['pay_type']          = $this->pay_type;
      $retval['limit_type']        = $this->limit_type;
      $retval['add_date']          = $this->add_date;

      return $retval;
    }

     //
     // *** STATIC FUNCTIONS ***
     //

     //
     // Create new commission/rebates
     //

    public static function new_commission ($dbh, $data, $seller) {
      $s_id = Commission::get_seller_id($seller);
      $level = 1;
      return Commission::new_comm($dbh, $data, $s_id, $level);
    }

    public static function new_rebate ($dbh, $data, $seller) {
      $s_id = Commission::get_seller_id($seller);
      $level = 2;
      return Commission::new_comm($dbh, $data, $s_id, $level);
    }

     //
     // Get all commissions or rebates
     //
     // Returns a list of commission objects
     // 

    public static function get_all_commissions ($dbh, $seller) {
      $s_id = Commission::get_seller_id($seller);
      $level = 1;
      return  Commission::get_all ($dbh, $s_id, $level);
    }

    public static function get_all_rebates ($dbh, $seller) {
      $s_id = Commission::get_seller_id($seller);
      $level = 2;
      return  Commission::get_all ($dbh, $s_id, $level);
    }

    public static function get_current_commission ($dbh, $seller) {
      $id = Commission::get_seller_id($seller);
      $level = 1;
      return Commission::get_current($dbh, $id, $level);
    }

    public static function get_current_rebate ($dbh, $seller) {
      $id = Commission::get_seller_id($seller);
      $level = 2;
      return Commission::get_current($dbh, $id, $level);
    }

   public static function get_current_commission_id ($dbh, $seller) {
      $id = Commission::get_seller_id($seller);
      $level = 1;
      $comm = Commission::get_current($dbh, $id, $level);
      if($comm == -1) {
	return -1;
      } else { 
      	return $comm->get_id();
      }
    }

    public static function get_current_rebate_id ($dbh, $seller) {
      $id = Commission::get_seller_id($seller);
      $level = 2;
      $comm = Commission::get_current($dbh, $id, $level);
      return $comm->get_id();
    }

     //
     // Private utility functions
     //
    public static function Epoch2SQL ($epoch) {
      return date('Y-m-d', $epoch);
    }

     // Note, accepts ISO 8601 format
    public static function SQL2Epoch ($sql) {
      return strtotime($sql);
    }

     //
     // Private function to make the get_all_* functions work
     // 

    private static function get_all ($dbh, $id, $level) {

      $where = "buzz_user_id = $id AND comm_level = $level";
      $order = "order by id ASC";
      $r = $dbh->SelectOneColumn ("id", "commission_schedule", $where, $order);

      $retval = array();

      if ($r && count($r)) {
        foreach ($r as $row) {
          $id = $row['id'];
          $retval[] = new Commission($dbh, $id);
        }
      } else {
        return 0;
      }

      return $retval;
    }

    private static function get_current ($dbh, $id, $level) {
      $where = "buzz_user_id = $id " .
               "AND active = 'true' " .
               "AND comm_level = $level";


      $retval = 0;
      $r = $dbh->Select('id', 'commission_schedule', $where);
      if ($r && count($r) > 0) {
        $retval = new Commission($dbh, $r[0]['id']);
      } else {
	$retval = -1;
      }

      return $retval;
    }
     //
     // Private function to make seller objects interchangable
     // with their database id (which commissions needs)
     // 

    private static function get_seller_id ($seller) {
      $s = 0;

      if (is_object($seller)) {
        $s = $seller->GetMyID();
      }

      if (is_int($seller))  {
        $s = $seller;
      }
   
      return $s; 
    }

     //
     // Private function to create a new commission or rebate.
     //
    private static function new_comm ($dbh, $data, $seller, $level) {
      $where = "comm_level=$level AND buzz_user_id=$seller AND active='true'";

      $res = $dbh->Select('id', 'commission_schedule', $where);
      $res0 = count($res);

      $res1 = ($res0) ? $dbh->Update("commission_schedule", "active='false'", $where) : 1;

      $res2 = 0;
      if ($res1) {
        $into = array();
        foreach ($data as $key=>$item) {
          $into[$key] = $item;
        }
        $into['active'] = 'true';
        $into['buzz_user_id'] = $seller;
        $into['comm_level'] = $level;
        if (array_key_exists('add_date', $into)) {
          $into['add_date'] = Commission::Epoch2SQL($into['add_date']);
        } else {
          $into['add_date'] = Commission::Epoch2SQL(time());
        }

        $res2 = $dbh->Insert("commission_schedule", $into);
      }
      return $res2;
    }

  } // end class
?>
