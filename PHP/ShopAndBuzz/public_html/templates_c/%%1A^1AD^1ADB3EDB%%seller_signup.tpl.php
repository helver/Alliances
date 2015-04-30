<?php /* Smarty version 2.6.16, created on 2007-06-11 10:39:20
         compiled from seller_signup.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<p><br><br><h2>Please enter/update your seller information below</h2></p>

<form action="/handle_seller_signup.php" method="POST">
<table border="0">
<tr><td align="right">Ebay Username:</td><td><input type="text" name="name" size="25" maxlength="150"></td></tr>
<tr><td align="right">Feedback:</td><td><input type="text" name="feedback" size="25" maxlength="80"></td></tr>
<tr><td align="right">Positive Percentage:</td><td><input type="text" name="positive" size="25" maxlength="80"></td></tr>
<tr><td colspan="2" align="center"><input type="checkbox" name="powerseller" value="1
">: Are you a powerseller?</td></tr>

<tr><td align="right">Paypal:</td><td><input type="text" name="paypal" size="25" maxlength="80"></td></tr>



<tr><td colspan="2" align="center"><input type="submit" value="Register As A Seller"></td></tr>
</table>
</form>



<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>