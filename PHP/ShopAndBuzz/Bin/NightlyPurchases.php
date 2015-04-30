#!/usr/bin/php
<?php

  define ('NOT_A_WEB_PAGE', 1);

  $DEBUG = 0;

// HAVEN'T REALLY HAD A CHANCE TO TEST THIS. SORRY!
// It runs .. but there don't seem to be any sellers
// selling anytning in Dev at the moment.

// This will generate an error if you run it from the Bin directory by hand.
// It is expected that this will run from cron, which expects to be in the 
// home directory for the account.

chdir ("Bin");

include_once ("../Libs/common.inc");
include_once ("Bus_Objects/inc.aswas_user.php");
include_once ("Bus_Objects/inc.ebay_functions.php");
include_once ("Bus_Objects/inc.commission.php");

if (!$dbh->validConnection()) {
  print "Connection database failed attempting to run NightlyPurchases.php";
  exit;
} 

  //
  // First thing we need to do is create a list of our buyers. Anyone
  // who buys from one of our sellers, but isn't in this list, we
  // don't care about.
  //
$res = $dbh->Select ("username", "buzz_user");

$buyer_list = array();

foreach ($res as $row) {
  $user = new aswas_user($dbh);
  $user->LoadUser($row[0]);
  $buyer_list[] = $user->eBay_get_username();
}

  //
  // OK, now we find out who our sellers are.
  //
$where = "seller_profile.buzz_user_id = buzz_user.id";
$res = $dbh->Select ("buzz_user.username", "buzz_user,seller_profile", $where);
$dbh->debug = 0;

  // 
  // Now, for each seller, we need to find out if anyone of our members
  // bought something since since the last time we ran.
  //

if ($DEBUG) {
  print "Got the list of sellers ...\n";
  print_r ($res);
  print "\n-----------------------\n";
}  

foreach ($res as $row) {
  $seller = new aswas_user($dbh);
  $seller->LoadUser($row['username']);

  if ($DEBUG) {
    print "Checking " . $row['username'] . " for purchases ...\n";
  }

  $purchase_list = array();
  $purchase_list = qualifiedPurchases($seller, $buyer_list, 1);

  if ($DEBUG) {
    print " ... found " . count($purchase_list) . " qualified purchases.\n";
    print_r ($purchase_list);
  }
  //
  // $purchase_list now looks like this:
  //
  //   $buyer_ebay_username => 'TransactionID' => 'amount' =>'TransactionPrice'
  //                                           => 'date'   =>'LastTimeModified'
  //

  // have: seller_id, buyer_id, trans_date, amount
  $seller_id = $seller->GetMyID();

  foreach ($purchase_list as $buyer_username => $purchase) {
    $dbh->debug=0; 
    $buyer = new aswas_user($dbh);
    $buyer->LoadEbayUser($buyer_username);
    $buyer_id = $buyer->GetMyID();

      if ($DEBUG) {
        print "Processing purchase for $buyer_username ($buyer_id).\n";
        print_r ($purchase);
        print "\n";
      }

    $dbh->debug=0; 
      //
      // OK, we have at least one transaction between this buyer
      // and seller, let's see if there's a referal ...
      //
    $where = "buzz_user_id = $buyer_id AND seller_id = $seller_id";
    
    $dbh->Update("honeycomb", array("recommenable" => "t"), "buzz_user_id = $buyer_id AND member_id = $seller_id");
   
    $ref = $dbh->Select("id, refer_user_id, comm_schedule, rebate_id", "referral", $where);
    $referral_id = 0; $referrer_id = 0;
    $commission_id = 0; $rebate_id = 0;
    if ($ref && count($ref)) {
      $referral_id = $ref[0]['id'];
      $referrer_id = $ref[0]['refer_user_id'];
      $commission_id =  $ref[0]['comm_schedule'];
      $rebate_id = $ref[0]['rebate_id'];

      if ($DEBUG) {
        print "Found a Referral: \n";
        print " * referral id: $referral_id\n";
        print " * referrer id: $referrer_id\n";
        print " * commission id: $commission_id\n";
        print " * rebate id: $rebate_id\n";
      }
    } else {
        //
        // If there's no referral between the seller and buyer, there's no point.
        // Move along.
      if ($DEBUG) {
        print "\n---No referrals---\n";
        print_r ($ref);
        print "\n------------------\n";
      }
      continue;
    }

      //
      // So, if we're here, we have a transaction AND a referral .. now
      // we can do something about it.
      //

    $commission = new Commission($dbh, $commission_id);
    $rebate     = new Commission($dbh, $rebate_id); // yes, they're both commission objects
    
    foreach ($purchase as $transaction_id => $transaction) {

      if ($DEBUG) {
        print "Working transaction number $transaction_id:\n";
        print_r ($transaction);
        print "\n";
      }

      $trans_date = $transaction['date'];
      $amount = $transaction['amount'];

      if ($DEBUG) {
        $commission->debug = 1;
        $rebate->debug = 1;
      }
      $comm_amount = $commission->make_payment($amount, $trans_date);
      $rebate_amount = $rebate->make_payment($amount, $trans_date);

      $invoice_amount = $comm_amount + $rebate_amount;

        //
        // At this point, we know there was a transaction, how much the
        // commission and rebate (if any) are and who the principles are.
        // At least their IDs.
        // Time to make the doughnuts.
        //

        // First, a purchase ...
      $purchase_id = 0;
      $fields = array ("buyer_id" => $buyer_id,
                       "seller_id" => $seller_id,
                       "referral_id" => $referral_id,
                       "trans_date" => $trans_date,
                       "amount" => $amount);
      if ($DEBUG) {
        print "Insert purchases:\n";
        print_r ($fields);
        print "\n-----------------\n";
      } else {
        $dbh->Insert ("purchases", $fields);
        $where = "trans_date='$trans_date' AND buyer_id=$buyer_id AND seller_id=$seller_id";
        $purchase_id = $dbh->SelectSingleValue("max(id)", purchases, $where);
      }

        // Next, an invoice entry ...
      if ($invoice_amount) {
        $fields = array ("seller_id" => $seller_id,
                         "amount" => $invoice_amount,
                         "paypal_trans_id" => $transaction_id,
                         "purchase_id" => $purchase_id);
       
        if ($DEBUG) {
          print "Insert seller_fee:\n";
          print_r ($fields);
          print "\n-----------------\n";
        } else { 
          $dbh->Insert ('seller_fee', $fields);
        }
      }

        // Then, an open_comm entry for the commission, if any ...
      if ($comm_amount) {
        $fields = array ("buzz_user_id" => $referrer_id,
                         "purchase_id" => $purchase_id,
                         "referral_id" => $referral_id,
                         "amount" => $comm_amount);
        if ($DEBUG) {
          print "Insert open_comm (commission):\n";
          print_r ($fields);
          print "\n-----------------\n";
        } else {
          $dbh->Insert ('open_comm', $fields);
        }
      }

        // And, and open_comm entry for the rebate, if any ...
      if ($rebate_amount) {
        $fields = array ("buzz_user_id" => $buyer_id,
                         "purchase_id" => $purchase_id,
                         "referral_id" => $referral_id,
                         "amount" => $rebate_amount);
        if ($DEBUG) {
          print "Insert open_comm (rebate):\n";
          print_r ($fields);
          print "\n-----------------\n";
        } else {
          $dbh->Insert ('open_comm', $fields);
        }
      }
    }
  }
}

//beta=> \d seller_info  -- deprecated, use seller_profile
//buzz_user_id | integer      | not null
// category_id  | integer      |
// feedback     | integer      |
// positive_pct | numeric(5,2) |
// powerseller  | boolean      | not null default false
//
//beta=> \d buzz_user
// id         | integer                     | not null default nextval('buzz_user_id_seq'::regclass)
// email      | character varying(70)       | not null
// username   | character varying(70)       | not null
// password   | text                        | not null
// admin_code | integer                     | not null default 0
// last_auth  | timestamp without time zone |

//beta=> \d purchases
// id          | integer                    | not null default nextval('purchases_id_seq'::regclass)
// buyer_id    | integer                     |
// seller_id   | integer                     |
// referral_id | integer                     |
// trans_date  | timestamp without time zone |
// amount      | numeric(10,2)               |
// paid_date   | timestamp without time zone |
// cleard_upi  | boolean                     | not null default false
// processed   | boolean                     | not null default false

?>
