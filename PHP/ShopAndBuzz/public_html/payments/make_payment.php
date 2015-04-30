<?php

//*** make_payment.php
//*** Written By Antonio DeLaCruz for Alliances.org
//*** AsWas project
//*** Copyright 2007 Alliances.org

//*** Set up the includes
/////////////////////////
include_once ('../../Libs/common.inc');
include_once ('ConfigFileReader.inc');

$config = new ConfigFileReader("aswas");
$paypal_url = $config->getAttribute("paypalURL");

$local_thanks = $GLOBALS["SiteHTTPURL"] . '/payments/pmt_thank_you.php';
$local_cancel = $GLOBALS["SiteHTTPURL"] . '/payments/cancel_payment.php';

//*** Get the current month and year.
//*** Used for the Item Name for PayPal 
///////////////////////////////////////
$year = date("Y");
$month = date("m");
$item_name_month = date("F");

//*** Get what was passed in and use that to search the seller_fee table
//*** for the amount owed and item_number for PayPal
/////////////////////////////////////////////////////////////////////////
//$sql_key = <get parameter passed into from main site when pushing button>

// make db connection

// *** uncomment these lines when we find out what the $sql_key is
/*
$select = "seller_fee.amount, seller_fee.paypal_trans_id";
$table  = "seller_fee, buzz_user";
$where  = "seller_fee.seller_id='$sql_key' AND seller_fee.invoice_paid='f'";
$order  = "seller_fee.seller_id";

$return_list = $dbh->Select($select, $table, $where, $order);

populate $amount and $item_number(which is paypal_trans_id in the seller_fee table)

*/


?> 

<form action="<?php echo $paypal_url;?>" method="post">
<input type="hidden" name="cmd" value="_xclick">
<input type="hidden" name="business" value="sales@shopandbuzz.com">
<input type="hidden" name="item_name" value="As Was Invoice For <?php echo $item_name_month." ".$year;?>">
<input type="hidden" name="item_number" value="<?php echo $item_number;?>">
<input type="hidden" name="amount" value="<?php echo $amount;?>">
<input type="hidden" name="no_shipping" value="1">
<input type="hidden" name="return" value="<?php echo $local_thanks;?>">
<input type="hidden" name="cancel_return" value="<?php echo $local_cancel;?>">
<input type="hidden" name="no_note" value="1">
<input type="hidden" name="currency_code" value="USD">
<input type="hidden" name="lc" value="US">
<input type="hidden" name="bn" value="PP-BuyNowBF">
<input type="image" src="https://www.paypal.com/en_US/i/btn/x-click-but23.gif" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>
