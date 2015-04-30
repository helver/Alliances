<?php /* Smarty version 2.6.16, created on 2007-08-13 22:14:31
         compiled from login.tpl */ ?>
		<table border=0 cellpadding=0 cellspacing=0>
<form action="/handle_login.php" method="POST">
		<tr align=left valign=top>
		<td rowspan=4><img src="/thematics/spacer.gif" width="710" height="1" border="0"><td>
		<td><span class=whitetext>member name:<br>password:</span></td>
		<td><input type="text" name="username" value="<?php echo $this->_tpl_vars['login_username']; ?>
" size="15" maxlength="150" class=formfield><br><input type="password" name="password" size="10" maxlength="20" class=formfield></td></tr>
		<tr align=left valign=top>

		<tr align=left valign=top>
		<td colspan="3" align="right"><span class=whitetext><a href="/forgot/">Forgot Password</a>.</span></td></tr>

		<td colspan=3 align="right"><span class=whitetext><center><input type="image" src="/thematics/web-login.jpg" width=51 height=25 border=0 value="Login"></span></center></td></tr></form></table>
