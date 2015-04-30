<?php /* Smarty version 2.6.16, created on 2007-10-21 23:21:11
         compiled from coupon_code_form2.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Get Your Buzz On!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">

<?php if ($this->_tpl_vars['fee_sched'] == 1): ?>
The coupon code you entered was not recognized as a valid, current coupon code.  This could have 
happened for several reasons including: the coupon has expired; the coupon code was mis-typed; you
intentionally left the coupon code field blank.  You have been temporarily assigned the Default 
coupon code.  If you want to continue with your seller signup using the defult coupon code, 
select the "Accept Coupon Code" button below.  If you want to try to enter your coupon code
again, press the "Decline Coupon Code" button and retry your entry.<br><br>
<?php endif; ?>

Your coupon code yields the following benefits:<Br>
<?php echo $this->_tpl_vars['months_free']; ?>
 months free.<br>
$<?php echo $this->_tpl_vars['monthly_rate']; ?>
/mo after the free period expires.<br>

<p class="whitetext">
<form method="POST" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/couponcode/post/">
<input type="hidden" name="coupon_code" value="<?php echo $this->_tpl_vars['coupon_code']; ?>
">
<br><input type="submit" value="Accept Coupon Code">
</form></p>

<p class="whitetext">
<form method="GET" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/couponcode/">
<input type="submit" value="Decline Coupon Code">
</form></p>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>