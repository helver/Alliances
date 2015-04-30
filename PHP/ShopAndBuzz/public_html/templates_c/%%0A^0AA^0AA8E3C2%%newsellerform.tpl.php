<?php /* Smarty version 2.6.16, created on 2007-10-21 23:22:28
         compiled from newsellerform.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Generate Your Own Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">

<?php if ($this->_tpl_vars['error_message'] != ""): ?><p class="errortext"><b><?php echo $this->_tpl_vars['error_message']; ?>
</b></p><?php endif; ?>

<?php if ($this->_tpl_vars['broken_seller_profile']): ?>
<p class="errortext">Hi, <?php echo $this->_tpl_vars['user']; ?>
! You're marked as a seller, but we have no S&B subscription
payment on record for you. Your seller account with us will be inactive
until you click the UPdate Seller Profile button below to sign up for our service.</p>
<?php endif; ?>

Fill Out this form, then click the button below to update your Seller Profile.<br>

<form method="POST" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/seller_profile/">
<table border="0">
<tr><td class="whitetext">Seller Category</td><td><?php echo $this->_tpl_vars['category_list']; ?>
</td></tr>
<?php if ($this->_tpl_vars['signed_up']): ?>
<tr><td class="whitetext">Cancel Seller Account</td><td class="whitetext"><a href="<?php echo $this->_tpl_vars['paypalURL']; ?>
?cmd=_subscr-find&alias=<?php echo $this->_tpl_vars['paypalAccount']; ?>
">Click to Cancel Your Seller Account</a></td></tr>
<?php endif;  if (! $this->_tpl_vars['fee_schedule_id']): ?>
<input type="hidden" name="coupon_code" value="<?php echo $this->_tpl_vars['coupon_code']; ?>
">
<?php endif; ?>
<tr><td class="whitetext">Description</td><td><textarea name="description" rows="5" cols="50" wrap="virtual"><?php echo $this->_tpl_vars['cur_desc']; ?>
</textarea></td></tr>
<tr><td colspan="2"><input type="submit" value="Update Seller Profile"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>