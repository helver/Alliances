<?php /* Smarty version 2.6.16, created on 2007-08-01 23:48:54
         compiled from invitation_detail.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Invitation Detail Page</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/invitations/">Click Here</a> to view your invitations.</p>
<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/inviteothers/">Click Here</a> to invite someone new!</p>


<table border="0" border="0" cellpadding="6" cellspacing="8" width="850">
<tr><td class="whitetext">Date</td><td class="whitetext"><?php echo $this->_tpl_vars['invitation'][0]['date']; ?>
</td></tr>
<tr><td class="whitetext">Email</td><td class="whitetext"><?php echo $this->_tpl_vars['invitation'][0]['email']; ?>
</td></tr>
<tr><td class="whitetext">Name</td><td class="whitetext"><?php echo $this->_tpl_vars['invitation'][0]['name']; ?>
</td></tr>
<tr><td class="whitetext">Status</td><td class="whitetext"><?php echo $this->_tpl_vars['invitation'][0]['status']; ?>
</td></tr>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>