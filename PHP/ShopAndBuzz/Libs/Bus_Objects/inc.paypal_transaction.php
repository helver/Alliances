<?php

include_once ("PG_DBWrapper.inc");

// Basic PayPal Objects
require_once 'PayPal.php';
require_once 'PayPal/Profile/Handler/Array.php';
require_once 'PayPal/Profile/API.php';
require_once 'PayPal/Type/DoDirectPaymentRequestType.php';
require_once 'PayPal/Type/DoDirectPaymentRequestDetailsType.php';
require_once 'PayPal/Type/DoDirectPaymentResponseType.php';
// All of the PayPal types we'll need
require_once 'PayPal/Type/BasicAmountType.php';
require_once 'PayPal/Type/PaymentDetailsType.php';
require_once 'PayPal/Type/AddressType.php';
require_once 'PayPal/Type/CreditCardDetailsType.php';
require_once 'PayPal/Type/PayerInfoType.php';
require_once 'PayPal/Type/PersonNameType.php';

class paypal_transaction {

  private $dbh;      // database reference
  private $payee_id; // receiver of the cash
  private $payer_id; // payer of the cash

  function __construct ($db, $ee, $er) {
    $this->dbh      = $db;
    $this->payer_id = $er; 
    $this->payee_id = $ee; 

    $this->_load_users();
  }

  function _load_users () {
    // load $payee_id paypal information
    // load $payer_id paypal information
  }
  function transfer ($amount, $currency) {
    // perform paypal transaction
    // if (successful) log transaction in database
  }

  function refund ($amount, $currency) {
    // perform paypal refund -- yes it's a separate item
    // if (successful) log transaction in database
  }

  function _do_transfer ($amount) {
    $dp_request =& PayPal::getType('DoDirectPaymentRequestType');
    if (PayPal::isError($dp_request)) {
      return 0;
    }

    $paymentType = $_POST['paymentType'];  // VAR
    $firstName = $_POST['firstName'];      // PAYER
    $lastName = $_POST['lastName'];        // PAYER
    $creditCardType = $_POST['creditCardType']; // PAYER
    $creditCardNumber = $_POST['creditCardNumber']; // PAYER
    $expDateMonth = $_POST['expDateMonth'];         // PAYER
    // Month must be padded with leading zero
    $padDateMonth = str_pad($expDateMonth, 2, '0', STR_PAD_LEFT);

    $expDateYear = $_POST['expDateYear'];  // PAYER
    $cvv2Number = $_POST['cvv2Number'];    // PAYER
    $address1 = $_POST['address1'];        // PAYER
    $address2 = $_POST['address2'];        // PAYER
    $city = $_POST['city'];                // PAYER
    $state = $_POST['state'];              // PAYER
    $zip = $_POST['zip'];                  // PAYER

    $OrderTotal =& PayPal::getType('BasicAmountType');
    if (PayPal::isError($OrderTotal)) {
      //var_dump($OrderTotal);
      return 0;
    }
    $OrderTotal->setattr('currencyID', 'USD');
    $OrderTotal->setval($amount, 'iso-8859-1');
    $PaymentDetails =& PayPal::getType('PaymentDetailsType');
    $PaymentDetails->setOrderTotal($OrderTotal);
   
    $shipTo =& PayPal::getType('AddressType');
    $shipTo->setName($firstName.' '.$lastName);
    $shipTo->setStreet1($address1);
    $shipTo->setStreet2($address2);
    $shipTo->setCityName($city);
    $shipTo->setStateOrProvince($state);
    $shipTo->setCountry(UNITED_STATES);
    $shipTo->setPostalCode($zip);
    $PaymentDetails->setShipToAddress($shipTo);

    $dp_details =& PayPal::getType('DoDirectPaymentRequestDetailsType');
    $dp_details->setPaymentDetails($PaymentDetails);

    // Credit Card info
    $card_details =& PayPal::getType('CreditCardDetailsType');
    $card_details->setCreditCardType($creditCardType);
    $card_details->setCreditCardNumber($creditCardNumber);
    $card_details->setExpMonth($padDateMonth);
    $card_details->setExpYear($expDateYear);
    $card_details->setCVV2($cvv2Number);

    $card_details->setCardOwner($payer);

    $dp_details->setCreditCard($card_details);
    $dp_details->setIPAddress($_SERVER['SERVER_ADDR']);
    $dp_details->setPaymentAction($paymentType);

    $dp_request->setDoDirectPaymentRequestDetails($dp_details);

    $caller =& PayPal::getCallerServices($profile);

    // Execute SOAP request
    $response = $caller->DoDirectPayment($dp_request);

    $ack = $response->getAck();

    switch($ack) {
      case ACK_SUCCESS:
      case ACK_SUCCESS_WITH_WARNING:
         // Good to break out;
         break;

      default:
         return 0;
    }
 
    return 1; 
  }
}
