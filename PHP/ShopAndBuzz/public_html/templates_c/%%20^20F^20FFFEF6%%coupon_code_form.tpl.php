<?php /* Smarty version 2.6.16, created on 2007-10-21 22:26:57
         compiled from coupon_code_form.tpl */ ?>
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

This is your opportunity to enter a coupon code to get a discount on your Shop and Buzz 
subscription price.  Once you accept a coupon code (or decline to enter one), you will not
be able to enter a different code - this is your one shot during the seller signup process, so
please make sure you have your coupon code ready!  If you don't have it, please stop what 
you're doing and go get it now.<br><br>

<form method="POST" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/couponcode/">
<table border="0">
<tr><td class="whitetext">Coupon Code</td><td><input type="text" name="coupon_code" size="10" maxlength="15"></td></tr>
<tr><td colspan="2"><br><input type="submit" value="Submit Coupon Code"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>