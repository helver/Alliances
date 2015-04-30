<?php /* Smarty version 2.6.16, created on 2007-08-10 21:36:59
         compiled from signup.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Get Stung By The Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">View the <a href="/customerservice/">Terms Of Service and Privacy Policy</a></p>

<p class="whitetext">When you're done, fill out this form, then click the button below to create your member account.</p>

<?php if ($this->_tpl_vars['error_text']): ?>
<p class="errortext">Ooops!  We couldn't create an account for you for the following reasons:<br>
<?php echo $this->_tpl_vars['error_text']; ?>

</p>
<?php endif; ?>

<form method="POST" action="/signup/">
<table border="0">
<tr><td class="whitetext" align="left">Member Name:</td><td><input type="text" name="username" value="<?php echo $this->_tpl_vars['username']; ?>
"></td></tr>
<tr><td class="whitetext" align="left">Password:</td><td><input type="password" name="newpass"></td></tr>
<tr><td class="whitetext" align="left">Real Name:</td><td><input type="text" name="name" value="<?php echo $this->_tpl_vars['name']; ?>
"></td></tr>
<tr><td class="whitetext" align="left">Email Address:</td><td><input type="text" name="email" value="<?php echo $this->_tpl_vars['email']; ?>
"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<!-- <tr><td class="whitetext" align="left">eBay Member Name:</td><td><input type="text" name="ebay_username" value="<?php echo $this->_tpl_vars['ebay_username']; ?>
"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr> -->
<tr><td class="whitetext" align="left">Paypal Address:</td><td><input type="text" name="paypal" value="<?php echo $this->_tpl_vars['paypal']; ?>
"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td class="whitetext" colspan="2" align="center"><input type="submit" value="Create Account"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>