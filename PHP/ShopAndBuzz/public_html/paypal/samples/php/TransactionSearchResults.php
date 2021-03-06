<?php

include 'ppsdk_include_path.inc';

/**
 * PHP code here
 */

require_once 'PayPal.php';
require_once 'PayPal/Profile/Handler/Array.php';
require_once 'PayPal/Profile/API.php';
require_once 'PayPal/Type/TransactionSearchRequestType.php';
require_once 'PayPal/Type/TransactionSearchResponseType.php';
require_once 'SampleLogger.php';
require_once 'lib/constants.inc.php';

session_start();

set_time_limit(60);

$was_submitted = false;

$logger = new SampleLogger('TransactionSearchResults.php', PEAR_LOG_DEBUG);
$logger->_log('POST variables: '. print_r($_POST, true));

$profile = $_SESSION['APIProfile'];

// Verify that user is logged in
if(! isset($profile)) {
   // Not logged in -- Back to the login page
   // TBD:  Continue using sdk-seller?
   $logger->_log('You are not logged in;  return to index.php'); 
   $location = 'index.php';
   header("Location: $location"); 
} 

// Build our request from $_POST
// $trans_search = new TransactionSearchRequestType();
$trans_search =& PayPal::getType('TransactionSearchRequestType');
if (PayPal::isError($trans_search)) {
   $logger->_log('Error in request: '. $trans_search);    
} else {
   $logger->_log('Create request: '. $trans_search);
}

// Set request fields
// $trans_search->setStartDate('2005-01-01T00:00:00Z', 'iso-8859-1');
$start_date_str = $_POST['startDateStr'];
if(isset($start_date_str)) {
   $start_time = strtotime($start_date_str);
   $iso_start = date('Y-m-d\TH:i:s\Z', $start_time);
   $trans_search->setStartDate($iso_start, 'iso-8859-1'); 
}
$end_date_str = $_POST['endDateStr'];
if(isset($end_date_str)) {
   $end_time = strtotime($end_date_str);
   $iso_end = date('Y-m-d\TH:i:s\Z', $end_time);
   $trans_search->setEndDate($iso_end, 'iso-8859-1');     
}
$transaction_ID = $_POST['transactionID'];
if(isset($transaction_ID)) {
   $trans_search->setTransactionId($transaction_ID);    
}

$logger->_log('Initial request: '. print_r($trans_search, true));

$caller =& PayPal::getCallerServices($profile);

$response = $caller->TransactionSearch($trans_search);

$ack = $response->getAck();

$logger->_log('Ack='.$ack);

switch($ack) {
   case ACK_SUCCESS:
   case ACK_SUCCESS_WITH_WARNING:
      // Good to break out;
      break;
   
   default:
      $_SESSION['response'] =& $response;   
      $logger->_log('TransactionSearch failed: ' . print_r($response, true));
      $location = "ApiError.php";
      header("Location: $location");  
}

// Otherwise, load the HTML response

// Load the HTML
require_once 'pages/TransactionSearchResults.html.php';

?>