<?php /* Smarty version 2.6.16, created on 2007-03-08 10:46:36
         compiled from sent_confirmation_email.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Get Stung By The Buzz!</h2>

Momentarily, an email will arrive in the INBOX of the email address you 
used to create this account: <?php echo $this->_tpl_vars['email']; ?>
.  That email will contain a confirmation
link that you will need to click on in order to confirm the account creation
and to finalize the creation of this account.<br>

<?php if ($this->_tpl_vars['debug'] >= 1): ?>
Debugging Link: <a href="/signup/confirmemail/thisismytoken/">Click Here</a><br>
<?php endif; ?>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>