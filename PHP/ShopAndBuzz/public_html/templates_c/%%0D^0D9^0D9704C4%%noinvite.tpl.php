<?php /* Smarty version 2.6.16, created on 2007-07-08 08:58:22
         compiled from noinvite.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
<br><br>
<h2>Failed Delivery</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">The invitation you just attempted to deliver was not delivered.  The
person you tried to invite was already invited to join Shop and Buzz, but they declined.
He or she will need to register for Shop and Buzz without the benefit of a generated
invitation.<br><br> While Shop and Buzz has let the user know that we won't be sending
him or her anymore email, there's nothing stopping you from sending an email outside
our system. :)
</p>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>