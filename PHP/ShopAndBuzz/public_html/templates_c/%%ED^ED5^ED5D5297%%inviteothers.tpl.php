<?php /* Smarty version 2.6.16, created on 2007-08-01 23:48:40
         compiled from inviteothers.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Invite Others</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>


<form action="/users/<?php echo $this->_tpl_vars['user']; ?>
/invitations/" method="POST">
<table border="0" cellpadding="6" cellspacing="8" width="850">
<tr><td class="whitetext" align="right">Real Name:</td><td><input type="text" name="name" size="25" maxlength="150"></td></tr>
<tr><td align="right" class="whitetext">Email Address:</td><td><input type="text" name="invitee_email" size="20" maxlength="80"></td></tr>
<tr><td colspan="2" align="center" class="whitetext"><input type="checkbox" name="seller" value="1">: This Person would be interested in registering as a Seller</td></tr>
<tr><td colspan="2" align="center"><input type="submit" value="Send Invitation"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>