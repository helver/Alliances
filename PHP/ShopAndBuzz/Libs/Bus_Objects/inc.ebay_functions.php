<?php 
  require_once('common.inc');
  require_once ('Bus_Objects/inc.ebay_request.php');
  include_once ('ConfigFileReader.inc');


  function getEbayStatus ($user) {
    $retval = 0;

    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $user->eBay_get_auth();
    $username = $user->eBay_get_username();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetUser';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetUserRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <DetailLevel>ReturnSummary</DetailLevel>
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <UserID>$username</UserID>
</GetUserRequest>
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //

    $req = new eBayRequest($verb, $config);
    $status = $req->send_request($requestXmlBody, $serverUrl);

    #print_r($req->get_response());
    #print("<br>\n");
     
      //
      // CHECK OUR RESULTS
      //
    
    $retval = array();
    if ($status) {  // We got a response from the server.
      $retval['eBayGoodStanding'] = $req->match_results('eBayGoodStanding', "true");
      
      $xxSellerLevel = $req->get_results('SellerLevel');
      $retval['SellerLevel'] = $xxSellerLevel[0]['SellerLevel'];
      
      #print_r($retval['SellerLevel']);
      #print("<Br>\n");
    }
    
    return $retval;
  }

//
// Input:
//  $seller  : aswas_user object
//  $buyer   : aswas_user object
//  $daysago : OPTIONAL: integer, daysago to search.
//
// Return:
//  -1 : error connecting to ebay, no information
//   0 : no relationship
//   1 : has relationship
//
 function hasRelationshipWithBuyer ($seller, $buyer, $daysago=30) {
    $retval = 0;

    $now = time();
    $modFrom_stamp = $now - ($daysago * 86400);
    $modFrom = ebay_formatted_date ($modFrom_stamp);
    $modTo = ebay_formatted_date ($now);

    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $seller->eBay_get_auth();
    $username = $buyer->eBay_get_username();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetSellerTransactions';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetSellerTransactionsRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <ModTimeFrom>$modFrom</ModTimeFrom>
  <ModTimeTo>$modTo</ModTimeTo>
  _PAGINATION_
</GetSellerTransactionsRequest>
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //
    $req = new eBayRequest($verb, $config);
    $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
    if ($status) {  // We got a response from the server.
      $get_item = 'UserID';

      $retval = $req->match_results($get_item, $username);
    }
    return $retval;
  }

  /*
   * Summary:
   *   Looking for transactions between $seller and $buyer
   * that are older than $daysago (45) days, and are not
   * subject to a dispute.
   *
   * Method:
   *      STEP 1: store results in database
   *   Search for all $seller transactions (GetSellerTransactions),
   * where $buyer is the UserID (in response) and transaction date 
   * is older than $daysago (ModTimeTo in request = $daysago days ago).
   * Set ModTimeFrom to $lastrun + $daysago + 2 days ago to ensure all
   * transaction between now and the last run are accounted for.
   * Ensure CompleteStatus (in response) is 'Complete'.
   * Extract TransactionID and TransactionPrice.
   *
   *   Return a hash of hashes:
   *     $username -> 'transactionID' => 'transactionPrice'.
   *
   *      STEP 2: pull data from database 
   *   Search for all $seller disputes (GetUserDisputes), using
   * the same ModTimeTo/From in the request. Must use TransactionID
   * to match responses. Any transactions without disputes will be
   * removed from the result set.
   *
   * PARAMS:
   *   $seller: seller object
   *   $buyer_list: array of $buyer->eBay_get_username()
   *   $daysago: how far back do you want to search.
   * 
   *   Return a hash of hashes:
   *     $buyer_username => 'TransactionID' => 'amount' =>'TransactionPrice'
   *                                        => 'date'   =>'LastTimeModified'
   */
  function qualifiedPurchases ($seller, $buyer_list, $daysago = 45) {
    $temp = array();
    $now = time();
    $modFrom_stamp = $now - ($daysago * 86400);
    $modFrom = ebay_formatted_date ($modFrom_stamp);
    $modTo   = ebay_formatted_date ($now);

    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $seller->eBay_get_auth();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetSellerTransactions';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetSellerTransactionsRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <ModTimeFrom>$modFrom</ModTimeFrom>
  <ModTimeTo>$modTo</ModTimeTo>
  _PAGINATION_
</GetSellerTransactionsRequest>
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //
    $req = new eBayRequest($verb, $config);
    $req->debug = 0;
    $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
    if ($status) {  // We got a response from the server.
      $get_items = array('TransactionID', 
                         'TransactionPrice', 
                         'LastTimeModified');
      $top_node = 'Transaction';
        //
        // Input:
        //   $input     : XML nodes to search for matches (one or a list)
        //   $where_fld : XML node to filter matches (only one)
        //   $where_val : filter values for XML nodes (one or a list)
        //
        // Output:
        //   $hash[value at $where_fld][count][single $input]
        //

      $temp = $req->get_matching_results($get_items, 'UserID', $buyer_list, $top_node);
    }
    $retval = array();

    if (!$temp['error_count']) {

      foreach ($temp as $uid => $temp_1) {

        if (preg_match('/^error/', $uid)) {
          continue;
        }

        $retval[$uid] = array();
        foreach ($temp_1 as $i => $temp_2) {
       
          $tranid  = $temp_2['TransactionID'];
          $tranamt = $temp_2['TransactionPrice'];
          $trandt  = $temp_2['LastTimeModified'];
          $retval[$uid][$tranid] = array('amount' => $tranamt,
                                         'date'   => $trandt);
        }
      }      
    } else {
      print $temp['error_msg'] . "<BR>\n";
    }

    return $retval;
  }

  function checkSellerGotPaid ($seller, $transaction_list, $daysago = 45) {
    $temp = array();
    $now = time();
    $modFrom_stamp = $now - ($daysago * 86400);
    $modFrom = ebay_formatted_date ($modFrom_stamp);

    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $seller->eBay_get_auth();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetSellerTransactions';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetSellerTransactionsRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <ModTimeFrom>$modFrom</ModTimeFrom>
  _PAGINATION_
</GetSellerTransactionsRequest>
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //
    $req = new eBayRequest($verb, $config);
    $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
    if ($status) {  // We got a response from the server.
      $get_items = array('Status.CheckoutStatus',
                         'Status.eBayPaymentStatus',
                         'Status.LastTimeModified');
      $top_node = 'Transaction';
      $temp = $req->get_matching_results($get_items, 'TransactionID',
                                         $transaction_list, $top_node);
    }
    $retval = array();
    foreach ($temp as $tid) {
      $retval[$tid] = array();
      foreach ($temp[$tid] as $i) {
        $checkout  = $temp[$tid][$i]['Status.CheckoutStatus'];
        $payment   = $temp[$tid][$i]['Status.eBayPaymentStatus'];
        $when      = $temp[$tid][$i]['Status.LastTimeModified'];

        if (   $checkout == 'CheckoutComplete'
            && $payment == 'NoPaymentFailure') {
          $retval[$tid] = array('checkout' => $checkout,
                                'date'   => $when);
        }
      }
    }

    return $retval;
  }

  /*
   * Returns $retval[0]['FeedbackScore']
   *         $retval[0]['UniqueNegativeFeedbackCount']
   *         $retval[0]['UniquePositiveFeedbackCount']
   */
  function getFeedbackScores ($seller) {
    $retval = 0;
    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $seller->eBay_get_auth();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetFeedback';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetFeedbackRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
</GetFeedbackRequest>    
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //
    $req = new eBayRequest($verb, $config);
    $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
    if ($status) {  // We got a response from the server.
      $get_items = array('FeedbackScore',
                         'UniqueNegativeFeedbackCount',
                         'UniquePositiveFeedbackCount');
      $retval = $req->get_results($get_items);
    }

    return $retval;
  }

  function checkDisputes ($seller, $transaction_list, $daysago = 45) {
    $temp = array();
    $now = time();
    $modFrom_stamp = $now - ($daysago * 86400);
    $modFrom = ebay_formatted_date ($modFrom_stamp);

    $config = new ConfigFileReader("aswas");
    $userToken = $config->getAttribute('testToken');
    $serverUrl = $config->getAttribute('serverUrl');

    $token = $seller->eBay_get_auth();

      //
      // CALL SPECIFIC DATA
      //
    $verb = 'GetUserDisputes';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetUserDisputesRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <ModTimeFrom>$modFrom</ModTimeFrom>
  _PAGINATION_
</GetUserDisputesRequest>
EOXML;

    $requestXmlBody .= $requestXmlTemplate;

      //
      // BUILD AND PERFORM THE REQUEST
      //
    $req = new eBayRequest($verb, $config);
    $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
    if ($status) {  // We got a response from the server.
      $get_items = array('DisputeID',
		         'DisputeReason');
      $top_node = 'Dispute';
      $temp = $req->get_matching_results($get_items, 'TransactionID',
                                         $transaction_list, $top_node);
    }
    $retval = array();
    foreach ($temp as $tid) {
      $retval[$tid] = array();
      foreach ($temp[$tid] as $i) {
        $dispid  = $temp[$tid][$i]['DisputeID'];
        $reason = $temp[$tid][$i]['DisputeReason'];
        $retval[$tid] = array('disputeid' => $dispid,
                              'reason'   => $reason);
      }
    }

    return $retval;
  }

// dateTime: YYYY-MM-DDTHH:MM:SS.SSSZ (e.g., 2004-08-04T19:09:02.768Z)

  function ebay_formatted_date ($when) {
    $_date = gmdate ("Y-m-d", $when);
    $_time = gmdate ("H:i:s", $when);

    return $_date . 'T' . $_time . '.000Z';
  }

?>
