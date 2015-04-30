<?php /* Smarty version 2.6.16, created on 2007-08-07 22:16:13
         compiled from recommendation.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Recommend <?php echo $this->_tpl_vars['seller']; ?>
</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">
Enter the information about your transacation(s) with <?php echo $this->_tpl_vars['seller']; ?>
.  When you're done click the button below.<br></h4>

<form method="POST" action="/users/<?php echo $this->_tpl_vars['me_user']; ?>
/recommendations/<?php echo $this->_tpl_vars['seller']; ?>
/">
<table border="0">
<tr><td class="whitetext" align="left">Number of times you bought from <?php echo $this->_tpl_vars['seller']; ?>
:</td><td><input type="text" name="numTrans" size="3"></td></tr>
<tr><td class="whitetext" align="left">Speed Of Transaction:</td><td><select name="speed">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="1i0">10</option>
</select></td></tr>
<tr><td class="whitetext" align="left">How Item Met Expectation:</td>
<td><select name="expect">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="1i0">10</option>
</select></td></tr>
<tr><td class="whitetext" align="left">Value (for what you paid):</td>
<td><select name="thevalue">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="1i0">10</option>
</select></td></tr>

<tr><td class="whitetext" align="left">Seller Communication:</td>
<td><select name="communication">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="1i0">10</option>
</select></td></tr>

<tr><td class="whitetext" align="left">Overall Experience:</td>
<td><select name="overall">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
<option value="6">6</option>
<option value="7">7</option>
<option value="8">8</option>
<option value="9">9</option>
<option value="1i0">10</option>
</select></td></tr>

<tr><td class="whitetext" valign="top" align="left">Why do you recommend the <?php echo $this->_tpl_vars['seller']; ?>
? (500 Characters):</td>
<td><textarea rows="5" cols="50" name="why"></textarea>
<tr><td class="whitetext" colspan="2" align="center"><input type="submit" value="Submit Recommendation"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>