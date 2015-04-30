<?php
$debug = 5;
include('../../Libs/common.inc');
include('Bus_Objects/inc.aswas_transaction.php');
include('Bus_Objects/class.Email.php');

include_once("ConfigFileReader.inc");
$config = new ConfigFileReader("aswas");

//*** read the post from PayPal system and add 'cmd'
$req = 'cmd=_notify-validate';

if($debug > 0) {
  $outfile = "./outfile/subscription.txt";
  $dfh = fopen($outfile, "a+");

  fwrite($dfh, "New Notification Received:\n");
  //*** Go through each variable and write it to the outfile
  foreach($_POST as $k=>$v) {
  	fwrite ($dfh, "  $k: $v\n");
  }
}

if(isset($_POST["txn_type"]) && $_POST["txn_type"] != "") {
    if(   $_POST["txn_type"] != "subscr_signup" 
       && $_POST["txn_type"] != "subscr_cancel"
       && $_POST["txn_type"] != "web_accept"
      ) {
        fwrite ($dfh, "Unknown transaction type.<br>\n");
        exit();
    }
    $oper = $_POST["txn_type"];
} else {
    fwrite ($dfh, "No transaction type.<br>\n");
    exit();
}

$argstring = array('cmd=_notify-validate');
foreach ($_POST as $k=>$v) {
  $argstring[] = "$k=" . urlencode(stripslashes($v));
}
$req = join('&', $argstring);

$validate_conn = curl_init();
curl_setopt($validate_conn, CURLOPT_URL, $config->getAttribute("paypalURL"));

//stop CURL from verifying the peer's certificate
curl_setopt($validate_conn, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($validate_conn, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($validate_conn, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($validate_conn, CURLOPT_HEADER, ($debug > 3 ? 1 : 0));
curl_setopt($validate_conn, CURLOPT_VERBOSE, ($debug > 5 ? 1 : 0));

//set the headers using the array of headers
#curl_setopt($validate_conn, CURLOPT_HTTPHEADER, $_POST);
curl_setopt($validate_conn, CURLOPT_HTTPHEADER, Array("Content-Type: application/x-www-form-urlencoded", "Content-Length: " . strlen($req)));
curl_setopt($validate_conn, CURLOPT_POSTFIELDS, $req);

//set method as POST
curl_setopt($validate_conn, CURLOPT_POST, 1);

//set it to return the transfer as a string from curl_exec
curl_setopt($validate_conn, CURLOPT_RETURNTRANSFER, 1);

$curl_resp = curl_exec($validate_conn);
fwrite ($dfh, "curl_resp: $curl_resp<br>\n");

curl_close($validate_conn);

if(!ereg('VERIFIED', $curl_resp)) {
    fwrite ($dfh, "Not Verified<br>\n");
    exit();
}
fwrite ($dfh, "Verified<br>\n");

if(isset($_POST["item_number"]) && $_POST["item_number"] != "") {
    $nonce = $_POST["item_number"];
}

if(isset($_POST["payer_email"]) && $_POST["payer_email"] != "") {
    $paypal_email = $_POST["payer_email"];
}

if(isset($_POST["subscr_id"]) && $_POST["subscr_id"] != "") {
    $subscription_id = $_POST["subscr_id"];
}

if(isset($_POST["payment_status"]) && $_POST["payment_status"] != "") {
    $payment_status = $_POST["payment_status"];
}

if($oper == "subscr_signup") {
    fwrite ($dfh, "subscr_signup<br>\n");
    $buid = $dbh->SelectSingleValue("buzz_user_id", "seller_profile", "subscription_signup_nonce = '$nonce'");

    $fields = array(
        "subscription_active" => 't',
        "subscription_id" => $subscription_id,
        "subscription_start_date" => $_POST["subscr_date"],
        "subscription_ended_date" => "NULL",
    );
    
    $dbh->Update("seller_profile", $fields, "buzz_user_id = $buid");
} elseif ($oper == "subscr_cancel") {
    fwrite ($dfh, "subscr_cancel<br>\n");
    $buid = $dbh->SelectSingleValue("buzz_user_id", "seller_profile", "subscription_id = '$subscription_id'");

    $fields = array(
        "subscription_active" => 'f',
        "subscription_ended_date" => $_POST["subscr_date"],
    );
    
    $dbh->Update("seller_profile", $fields, "buzz_user_id = $buid");
} elseif ($oper == "web_accept") {
    fwrite ($dfh, "web_accept<br>\n");
    if($payment_status == "Completed") {
        $dbh->Update("seller_fee", array("invoice_paid" => 't'), "paypal_trans_id = '$nonce'");
    }
} else {
    fwrite ($dfh, "oper didn't match: $oper<br>\n");
}    

///////////////////////////////////////////////////////////////////////////////////////////////////////
function email_payment_completed($item_name, $item_number, $payment_amount, $payer_email, $receiver_email) {
	
	$Sender = "$receiver_email";
	$Subject = "$item_name : PAID";
	
	//*** for debugging purposes only, comment out when going live
	//$To = "td@homenet.tzo.com";
	//*** uncomment when going live
	$To = "$payer_email";
	
	//print "Sender: $Sender<br>";
	//print "Subject: $Subject<br>";
	//print "Recipient: $To<br>";
    
	$textVersion = "Your $item_name payment has been processed.\r\n" .
					"Amount Paid: $payment_amount\r\n";
	$htmlVersion = "
	<html>
	<head>
	<title>$Subject</title>
	</head>
	<body>
	  <p>Your $item_name payment has been processed.</p>
	  <p>Amount Paid: $payment_amount</p>
	</body>
	</html>
	";
	
	//print "Text Version: $textVersion<p>";
	//print "HTML Version: $htmlVersion<p>";
    
	unset($msg);

	$msg = new Email($To, $Sender, $Subject);
	$msg->SetMultipartAlternative($textVersion, $htmlVersion);
	$msg->Send();
}

?>
