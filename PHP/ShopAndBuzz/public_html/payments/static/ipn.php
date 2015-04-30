<?php
// read the post from PayPal system and add 'cmd'
$req = 'cmd=_notify-validate';

$outfile = "./outfile/outfile.txt";

$handle = fopen($outfile, "a+");

foreach ($_POST as $key => $value) {
	$line = "Key: $key \n\r Value: $value\n\r\n\r";
	fwrite ($handle, $line);
}

foreach ($_POST as $key => $value) {
$value = urlencode(stripslashes($value));
$req .= "&$key=$value";
}

// post back to PayPal system to validate
$header .= "POST /cgi-bin/webscr HTTP/1.0\r\n";
$header .= "Host: www.paypal.com:80\r\n";
$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
$header .= "Content-Length: " . strlen($req) . "\r\n\r\n";
$fp = fsockopen ('www.paypal.com', 80, $errno, $errstr, 30);

// assign posted variables to local variables
$item_name = $_POST['item_name'];
$item_number = $_POST['item_number'];
$payment_status = $_POST['payment_status'];
$payment_amount = $_POST['mc_gross'];
$payment_currency = $_POST['mc_currency'];
$txn_id = $_POST['txn_id'];
$receiver_email = $_POST['receiver_email'];
$payer_email = $_POST['payer_email'];

if (!$fp) {
// HTTP ERROR
} else {
fputs ($fp, $header . $req);
while (!feof($fp)) {
$res = fgets ($fp, 1024);
if (strcmp ($res, "VERIFIED") == 0) {
// check the payment_status is Completed
// check that txn_id has not been previously processed
// check that receiver_email is your Primary PayPal email
// check that payment_amount/payment_currency are correct
// process payment

$mail_From = "From: batman@bacakc.org";
$mail_To = "antonio-delacruz@matrixitsolutions.net";
$mail_Subject = "VERIFIED IPN";
$mail_Body = $req;

foreach ($_POST as $key => $value){
$emailtext .= $key . " = " .$value ."\n\n";
}

//mail($mail_To, $mail_Subject, $emailtext . "\n\n" . $mail_Body, $mail_From);
fwrite ($handle, "\n\n" . $res . "\n\n" . $mail_to . "\n\n" . $mail_Subject. "\n\n" . $emailtext . "\n\n" . $mail_body . "\n\n" . $mail_From);

}
else if (strcmp ($res, "INVALID") == 0) {
// log for manual investigation

$mail_From = "From: batman@bacakc.org";
$mail_To = "antonio-delacruz@matrixitsolutions.net";
$mail_Subject = "INVALID IPN";
$mail_Body = $req;

foreach ($_POST as $key => $value){
$emailtext .= $key . " = " .$value ."\n\n";
}

//mail($mail_To, $mail_Subject, $emailtext . "\n\n" . $mail_Body, $mail_From);
fwrite ($handle, "\n\n" . $res . "\n\n" . $mail_to . "\n\n" . $mail_Subject. "\n\n" . $emailtext . "\n\n" . $mail_body . "\n\n" . $mail_From);

}
}
fclose ($fp);
}

fclose($handle);

?>

