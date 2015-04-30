<?php /* Smarty version 2.6.16, created on 2007-08-22 23:36:23
         compiled from honeycomberror.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
 

<?php $this->assign('userlabel', ($this->_tpl_vars['user'])."'s");  $this->assign('ebay_username', $this->_tpl_vars['user_obj']->eBay_get_username()); ?>
<h2>Honycomb Add Error</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr align=left valign=top><td>

<p class="whitetext">Ooops!, it appears that there was a problem adding <?php echo $this->_tpl_vars['user']; ?>
 to your
honeycomb.  The most likely problem is that you haven't actually bought anything from <?php echo $this->_tpl_vars['user']; ?>
 on
which we can legitimately base your honeycomb addition.  On the positive side, that's an easy
thing to fix: Buy something from <?php echo $this->_tpl_vars['user']; ?>
!</p>

<tr align=left valign=top><td align="center"><br><?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_10_seller_items.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></td></tr>

</tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>