<?php /* Smarty version 2.6.16, created on 2007-08-14 23:50:18
         compiled from recommendation_detail.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
<br><br>
<h2><?php echo $this->_tpl_vars['user']; ?>
's Recommendation of <?php echo $this->_tpl_vars['recommendation']['name']; ?>
</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<table border="0">
<tr><td class="whitetext" align="right">Recommended By:</td><td class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/"><?php echo $this->_tpl_vars['user']; ?>
</a></td></tr>
<tr><td class="whitetext" align="right">Seller's Member Name:</td><td class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['recommendation']['name']; ?>
/"><?php echo $this->_tpl_vars['recommendation']['name']; ?>
</a></td></tr>
<tr><td class="whitetext" align="right">Number of Purchases:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['num_purchases']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Speed Rating:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['speed_rating']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Expectation Rating:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['expect_rating']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Value Rating:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['value_rating']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Communication Rating:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['comm_rating']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Overal Experience Rating:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['exp_rating']; ?>
</td></tr>
<tr><td class="whitetext" align="right">Recommendation:</td><td class="whitetext"><?php echo $this->_tpl_vars['recommendation']['recommend']; ?>
</td></tr>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>