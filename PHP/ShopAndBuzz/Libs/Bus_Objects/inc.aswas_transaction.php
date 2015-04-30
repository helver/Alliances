<?php

  include_once ("PG_DBWrapper.inc");
  include_once ("inc.commission.php");

//
//  **  Needs ...
//  Purchase:
//     amount, date of purchase, date of payment, referral id, seller id,
//     buyer id, cleared UPI, processed
//
//  Referral:
//     seller id, buyer id, referer id, expiration??, date added
//     commission id, rebate id
//
//  Seller Fee:
//    seller id, amount, date invoice sent, invoice paid, full name to,
//    email addr to, purchase id
//
//  Commission Paid:
//    buzz user id, amount, purchase id, payable, paid date
//
///////////////////////////////////////////////////////////////////////////////////
//
// ** function pull_purchases:
//  if (purchase.date_of_payment)  
//    => use referal id to get commission and rebate objects
//       fee = commission + rebate
//       insert (Seller Fee: fee, purchase id, seller id)
//       insert (Commission Paid: commission, purchase id, referer id)
//       insert (Commission Paid: rebate, purchase id, buyer id)
//

  function pull_purchases ($dbh) {
    //
    $cols = ('id, buyer_id, seller_id, referral_id, amount, trans_date');
    $where = "paid_date != NULL AND processed = 'false'";
    $purchases = $dbh->Select ($cols, "purchases", $where);

    foreach ($purchases as $p_row) {
      $p_id   = $p_row['id'];
      $r_id   = $p_row['referral_id'];
      $buyer  = $p_row['buyer_id'];
      $seller = $p_row['seller_id'];
      $amount = $p_row['amount'];
      $date   = Commission::SQL2Epoch($p_row['trans_date']);

      $referral = $dbh->Select("comm_id, rebate_id, referrer_id", "referral", "id=$r_id");
      $comm_id = $referral[0]['comm_id'];
      $rebt_id = $referral[0]['rebate_id'];
      $referrer = $referral[0]['referrer_id'];

      $commission = new Commission($dbh, $comm_id);
      $rebate = new Commission($dbh, $rebt_id);

      $c_amount = $commission->make_payment ($amount, $date);
      $r_amount = $rebate->make_payment ($amount, $date);

      $fee = $c_amount + $r_amount;

      $f_insert = array ("seller_id"    => $seller,
                         "purchase_id"  => $p_id,
                         "amount"       => $fee);

      $c_insert = array ("buzz_user_id" => $referrer,
                         "purchase_id"  => $p_id,
                         "referral_id"  => $r_id,
                         "amount"       => $c_amount);

      $r_insert = array ("buzz_user_id" => $buyer,
                         "purchase_id"  => $p_id,
                         "referral_id"  => $r_id,
                         "amount"       => $r_amount);
                    
      $p_update = array ("processed" => 'true');
      $p_where  = "id=$p_id";

      $dbh->Insert ("seller_fee", $f_insert);
      $dbh->Insert ("open_comm", $c_insert);
      $dbh->Insert ("open_comm", $r_insert);
      $dbh->Update ("purchases", $p_update, $p_where); 
    }
  }


//
//  ** function set_payable:
//  if (purchase.cleared & seller_fee.invoice_paid)
//    => use purchase_id to find entries in Commission Paid table
//       set Commission_Paid.payable to 'true'
//

  function set_payable ($dbh) {
    $cols = "purchases.purchase_id";
    $tabs = "purchases, seller_fee, open_comms";
    $where = "open_comms.purchase_id=seller_fee.purchase_id AND " .
             "open_comms.purchase_id=purchases.purchase_id AND " .
             "open_comms.payable='false' AND " .
             "seller_fee.invoice_paid='true' AND " .
             "purchases.cleared_upi='true'";

    $commissionable = $dbh->Select($cols, $tabs, $where);

    $update = array ("payable" => 'true');
    foreach ($commissions as $row) {
      $p_id = $row['purchase_id'];
      $where  = "purchase_id=$p_id";
      $dbh->Update("open_comms", $update, $where);
    }
  }

// **  Paypal Flow ...
//  if (Seller_Fee.date_invoice_sent = NULL)
//    => send invoices
//       set date_invoice_sent to 'now'
//
//  if (Seller pays fee)  // How do we know??
//    => set invoice_paid to 'true'
//
//  if (Commission_Paid.payable = 'true')
//    => pay buzz_user_id
//       delete from open_comms
//       insert into paid_comms 
//

  // return:
  //  $list[seller_id] => array ($paypal_invoice_id, $months_overdue)
  //
  function get_overdue ($dbh) {
    return 1;
  }

  // return: 
  //   $list[seller_id] => array (sum, email_addr, $fee_id_list)
  // e.g.:
  //   $list[seller_id][sum];
  //   $list[seller_id][email_addr];
  //   $list[seller_id][fee_id_list];
  //
  function get_invoice_list ($dbh, $debug=0) {
    $retval = array();

    $select = "seller_fee.id, seller_fee.amount, seller_fee.seller_id, buzz_user.email";
    $table  = "seller_fee, buzz_user";
    $where  = "seller_fee.invoice_sent='f' AND seller_fee.seller_id=buzz_user.id";
    $order  = "seller_fee.seller_id";

    $fee_list = $dbh->Select($select, $table, $where, $order);

    if ($debug) {
      print "** FEE LIST **\n";
      print_r ($fee_list);
      print "\n";
    }

    if ($fee_list && count($fee_list)) {
      foreach ($fee_list as $fee) {
        $seller = $fee['seller_id'];
        if (array_key_exists($seller,$retval)) {
          $retval[$seller]['sum'] += $fee['amount'];
          $retval[$seller]['fee_id_list'][] = $fee['id'];
        } else {
          $retval[$seller] = array();
          $retval[$seller]['email_addr'] = $fee['email'];
          $retval[$seller]['sum'] = $fee['amount'];
          $retval[$seller]['fee_id_list'] = array();
          $retval[$seller]['fee_id_list'][] = $fee['id'];
        }
      }
    }

    if ($debug) {
      print "** RETURNING FROM get_invoice_list **\n";
      print_r ($retval);
      print "\n";
    }

    return $retval;
  }

  function sent_paypal_invoice ($dbh, $paypal_invoice_id, $fee_id_list, $debug=0) {
    foreach ($fee_id_list as $id) {
      sent_invoice ($dbh, $id, $paypal_invoice_id, $debug);
    }
  }

  //
  // return:
  // $list[count] = array (sum, paypal_trans_id)
  //
  function get_unpaid_invoice ($dbh, $userid) {
    $select = "sum, paypal_trans_id";
    $table = "seller_fee";
    $where = "seller_id=$userid AND invoice_paid='false' and invoice_sent='true'";

    $res = $dbh->Select($select, $table, $where);
  
    return $res; 
  }

  function invoice_paid ($dbh, $paypal_invoice_id) {
    $where = "paypal_trans_id=$paypal_invoice_id";
    $update = array ("invoice_paid" => 'true');
    $dbh->Update("seller_fee", $update, $where);
  }

  //
  // Looking for open_comms that have become payable:
  //   purchase has been payed for and cleared UPI
  //   seller's invoice to Aswas has been paid.
  //
  function find_payable ($dbh) {

  }

  // return:
  //   a physical file, csv format containing payouts.
  // layout:
  //   $paypal_id, $amount, 'USD', $buzz_user_name 
  //
  function get_payouts ($dbh) {
    $output = "";

    $select = "buzz_user.email, buzz_user.username, open_comm.amount";
    $table  = "buzz_user, open_comm";
    $where  = "open_comm.payable='t' AND open_comm.buzz_user_id=buzz_user.id";

    $payout_list = $dbh->Select ($select, $table, $where);

    if ($payout_list && count($payout_list)) {
      foreach ($payout_list as $payment) {
        if ($payment['email']) {
          $output .= $payment['email'] . ", " . $payment['amount'] .
                      ", USD, " . $payment['username'] . "\n";
        }
      }
    }

    return $output;
  }

  function paid_commission ($dbh, $id) {
    $where = "open_comms.id=$id AND open_comms.referral_id=referral.id";
    $cols = "open_comm.buzz_user_id, open_comm.amount, open_comm.purchase_id, " .
            "referral.seller_id, open_comm.referral_id, open_comm.id";
    $paid = $dbh->Select ($cols, "open_comms, referral", $where);

    $insert = array ("seller_id"   => $paid[0]['seller_id'],
                     "payee_id"    => $paid[0]['buzz_user_id'],
                     "referral_id" => $paid[0]['referral_id'],
                     "amount"      => $paid[0]['amount'],
                     "purchase_id" => $paid[0]['purchase_id'],
                     "comm_id"     => $paid[0]['id'],
                     "paid_date"   => 'now');
    $dbh->Insert ("paid_comms", $insert);
    $where = "id=$id";
    $dbh->Delete ("open_comms", $where);
  }

  //
  // PRIVATE
  //
  function sent_invoice ($dbh, $fee_id, $tran_id, $debug=0) {
    $where = "id=$fee_id";
    $update = array ('date_sent' => 'now', 
                     'invoice_sent' => 't',
                     'paypal_trans_id' => $tran_id);

    if ($debug) {
      print "Updating seller_fee table with this:\n";
      print_r ($update);
      print "\nwhere: $where\n";
    } else {
      $dbh->Update("seller_fee", $update, $where);
    }
  }

?>
