#!/usr/bin/php
<?php

//*** send_invoice.php
//*** Written By Antonio DeLaCruz for Alliances.org
//*** AsWas project
//*** Copyright 2007 Alliances.org
//*** All print statements are commented out.  They are for debugging purposes only.

define ('NOT_A_WEB_PAGE', 1);
$DEBUG = 0;

//*** Set up the includes
/////////////////////////
include_once ('../Libs/common.inc');
include_once ('ConfigFileReader.inc');
include_once ('Bus_Objects/inc.aswas_transaction.php');
include_once ('Bus_Objects/class.Email.php');

//*** Get the current month and year.
//*** Used for the paypal invoice ID, subject line of e-mail, and item number for PayPal
////////////////////////////////////////////////////////////////////////////////////////
$year = date("Y");
$month = date("m");
$day   = date("d");
$item_name_month = date("F");

$config = new ConfigFileReader("aswas");
$paypal_invoice_link = $config->getAttribute("paypalInvoiceLink");

//*** Set up arrays used.
//*** invoice_array is what is returned from get_invoice_list in inc.aswas_transaction.php
//////////////////////////////////////////////////////////////////////////////////////////
//  $invoice_array = array ("adelac05" => array ("300", "td@homenet.tzo.com", "1,2,3,4"),
//                          "brobid01" => array ("500", "td@homenet.tzo.com", "1,2,3,4"));

  $invoice_array = get_invoice_list($dbh, $DEBUG);

  if ($DEBUG) {
    print "** INVOICE ARRAY **\n";
    print_r ($invoice_array);
    print "\n";
  }
//*** Go through each item in the invoice_array list
//*** create the item_number
//*** get the amount and e-mail to address from the invoice_array returned
//*** also create the link that will be sent in the e-mail for users to pay their invoice
/////////////////////////////////////////////////////////////////////////////////////////
foreach ($invoice_array as $user=>$details) {
  $item_number = $user.$year.$month.$day."00";
  $amount = $details['sum'];
  $email_to = $details['email_addr'];
  $fee_id_list = $details['fee_id_list'];

  $amount = preg_replace ('/\./', '%2e', $amount);
  $paypal_invoice_link = preg_replace ('/<_AMOUNT_>/', $amount, $paypal_invoice_link); 
  $paypal_invoice_link = preg_replace ('/<_ITEM_NAME_MONTH_>/', $item_name_month, $paypal_invoice_link); 
  $paypal_invoice_link = preg_replace ('/<_YEAR_>/', $year, $paypal_invoice_link); 
  $paypal_invoice_link = preg_replace ('/<_ITEM_NUMBER_>/', $item_number, $paypal_invoice_link); 


  if ($DEBUG) {
    print "user $user invoice item: $item_number \n";
    print "user $user invoice amount: $amount \n";
    print "user $user invoice to: $email_to \n";
    print "user $user invoice fee list: ";
    print_r ($fee_id_list);
    print "\n";
    print "link: $paypal_invoice_link\n";
  } 

    //*** call the email_invoice function below to send the e-mail with the embedded link to the user
  email_invoice($email_to, $paypal_invoice_link, $item_name_month, $year, $DEBUG);

    //*** call the sent_paypal_invoice funtion in inc.aswas_transaction.php to set the time stamp and 
    //    paypal_invoice_id in the database
  sent_paypal_invoice($dbh, $item_number, $fee_id_list, $DEBUG);
}


//*** email_invoice function
//*** uses the class.Email.php file to send a multipart e-mail with the link embedded for users to pay their invoice
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function email_invoice($email_to, $link, $item_name_month, $year, $debug=0) {

	$Sender = "aswas@shopandbuzz.com";
	$Subject = "AsWas Invoice for $item_name_month $year";
	$To = "$email_to";

        if ($debug) {
	  print "Sender: $Sender\n";
	  print "Subject: $Subject\n";
	  print "Recipient: $To\n";
          print "Name Month: $item_name_month\n";
          print "Year: $year\n";
        }

	$textVersion = "Your AsWas Invoice for the month of $item_name_month $year is due.\r\n" .
			"Please copy the entire below URL text into the address bar of your browser.\r\n" .
			$link . "\r\n";
	$htmlVersion = "
	<html>
	<head>
  	<title>$Subject</title>
	</head>
	<body>
	  <p>Your AsWas Invoice for the month of $item_name_month $year is due.</p>
	  <p>Please click on the link below to pay your invoice.</p>
	  <p><a href=\"$link\">Pay my invoice</a>
	  <p>If you are not able to click on the above link, please copy and paste the text below directly into your address bar of your browser.</p>
	  <p>$link</p> 
	</body>
	</html>
	";

        if ($debug) {
	  print "Text Version: ".$textVersion."<p>";
	  print "HTML Version: ".$htmlVersion."<p>";
        }

	unset($msg);

        if (!$debug) {
	  $msg = new Email($To, $Sender, $Subject); 
	  $msg->SetMultipartAlternative($textVersion, $htmlVersion);
	  $msg->Send();
        }
}

?>
