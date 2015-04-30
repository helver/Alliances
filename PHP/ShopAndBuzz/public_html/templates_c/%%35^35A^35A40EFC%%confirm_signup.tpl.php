<?php /* Smarty version 2.6.16, created on 2007-08-10 22:22:33
         compiled from confirm_signup.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Welcome To Shop & Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">You're Done!  Your account is now confirmed.  From here, you should probably go ahead
and visit your profile page:</p>

<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/">Your Profile</a></p>
<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/private/">Your Account</a></p>

<?php if (! $this->_tpl_vars['user_obj']->IsSeller()): ?>
<p class="whitetext">To register as a seller click here: <a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/seller_profile/">Register As A Seller</a>.</p>
<?php endif; ?>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>