<?php
  require_once('../../Libs/common.inc');
  require_once ('Bus_Objects/inc.commission.php');

  $seller_id = 1;
/*
     $r = array();

     $r['amount']            = 5;
     $r['max_limit']         = 2;
     $r['min_pay_threshold'] = 2.0;
     $r['max_amount']        = 5.0;
     $r['pay_type']          = 'amount';
     $r['limit_type']        = 'days';

     $success = Commission::new_rebate ($dbh, $r, $seller_id);
     print "$success<BR>\n";
*/
     $id = Commission::get_current_rebate_id($dbh, $seller_id);
     print "$id<BR>\n";

     $comm = new Commission($dbh, $id);

     print_r ($comm->get_attributes());

     print "<BR>\n";

     $val = $comm->get_payment_amount (1.99);

     print "$val<BR>\n";
?>
