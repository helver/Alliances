<?php /* Smarty version 2.6.16, created on 2007-08-25 21:33:52
         compiled from subscribe.tpl */ ?>
<HTML>
<body onLoad="document.forms['subform'].submit();">
<form name="subform" action="<?php echo $this->_tpl_vars['paypalURL']; ?>
" method="POST">
<input type="hidden" name="cmd" value="_xclick-subscriptions">
<input type="hidden" name="business" value="<?php echo $this->_tpl_vars['paypalAccount']; ?>
">
<input type="hidden" name="item_name" value="Shop and Buzz Subscription">
<input type="hidden" name="item_number" value="<?php echo $this->_tpl_vars['item_number']; ?>
">
<input type="hidden" name="return" value="<?php echo $this->_tpl_vars['returnURL']; ?>
/payments/pmt_thank_you.php">
<input type="hidden" name="cancel_return" value="<?php echo $this->_tpl_vars['returnURL']; ?>
/payments/sub_cancel.php">
<input type="hidden" name="no_shipping" value="1">
<input type="hidden" name="no_note" value="1">
<input type="hidden" name="currency_code" value="USD">
<input type="hidden" name="lc" value="US">
<input type="hidden" name="bn" value="PP-SubscriptionsBF">
<input type="hidden" name="a1" value="0.00">
<input type="hidden" name="p1" value="<?php echo $this->_tpl_vars['months_free']; ?>
">
<input type="hidden" name="t1" value="M">
<input type="hidden" name="a3" value="<?php echo $this->_tpl_vars['monthly_rate']; ?>
">
<input type="hidden" name="p3" value="1">
<input type="hidden" name="t3" value="M">
<input type="hidden" name="src" value="1">
<input type="hidden" name="sra" value="1">
</form>
<?php if ($this->_tpl_vars['custom_text']): ?>
<p>Please Wait</p>
<?php else: ?>
<p>Please Wait</p>
<?php endif; ?>
</body>
</HTML>