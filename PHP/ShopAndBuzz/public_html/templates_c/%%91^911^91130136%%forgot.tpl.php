<?php /* Smarty version 2.6.16, created on 2007-08-21 21:32:21
         compiled from forgot.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Recover Member Name/Password</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr align=left valign=top><td class="whitetext">

<form action="/forgot/" method="POST">
Enter your member name and your password will be emailed to your email address.<Br>

<input type="text" name="username" size="20" maxlength="50">
<input type="submit" name="lost" value="Lost Password">

<hr>

Enter your email address and your member name will be emailed to your email address.<Br>

<input type="text" name="emailaddy" size="20" maxlength="50">
<input type="submit" name="lost" value="Lost Member Name">
</form>

<hr>

Still can't figure it out?  Create a new account by clicking <a href="/signup/">here</a>.<br>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>