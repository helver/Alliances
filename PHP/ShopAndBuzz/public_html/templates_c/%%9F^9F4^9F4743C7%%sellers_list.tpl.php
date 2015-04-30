<?php /* Smarty version 2.6.16, created on 2007-08-07 22:46:50
         compiled from sellers_list.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Shop and Buzz Sellers</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<?php echo $this->_tpl_vars['filter_widgets']; ?>


<p class="whitetext">All Sellers or Sellers Matching Your Query:</p>

<p class="whitetext">
<?php $this->assign('t_list', 'hive');  $this->assign('list_label', 'Sellers');  $this->assign('first', 1); ?>
<table border="0" cellspacing="8" width="90%" cellpadding="5">
<tr>
  <th nowrap class="whitetext" align="left">Seller Name</th>
  <th class="whitetext" align="left">Seller Category</th>
  <th class="whitetext" align="left">Open Items</th>
</tr>
<?php unset($this->_sections['friend']);
$this->_sections['friend']['name'] = 'friend';
$this->_sections['friend']['loop'] = is_array($_loop=$this->_tpl_vars['sellers']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['friend']['show'] = true;
$this->_sections['friend']['max'] = $this->_sections['friend']['loop'];
$this->_sections['friend']['step'] = 1;
$this->_sections['friend']['start'] = $this->_sections['friend']['step'] > 0 ? 0 : $this->_sections['friend']['loop']-1;
if ($this->_sections['friend']['show']) {
    $this->_sections['friend']['total'] = $this->_sections['friend']['loop'];
    if ($this->_sections['friend']['total'] == 0)
        $this->_sections['friend']['show'] = false;
} else
    $this->_sections['friend']['total'] = 0;
if ($this->_sections['friend']['show']):

            for ($this->_sections['friend']['index'] = $this->_sections['friend']['start'], $this->_sections['friend']['iteration'] = 1;
                 $this->_sections['friend']['iteration'] <= $this->_sections['friend']['total'];
                 $this->_sections['friend']['index'] += $this->_sections['friend']['step'], $this->_sections['friend']['iteration']++):
$this->_sections['friend']['rownum'] = $this->_sections['friend']['iteration'];
$this->_sections['friend']['index_prev'] = $this->_sections['friend']['index'] - $this->_sections['friend']['step'];
$this->_sections['friend']['index_next'] = $this->_sections['friend']['index'] + $this->_sections['friend']['step'];
$this->_sections['friend']['first']      = ($this->_sections['friend']['iteration'] == 1);
$this->_sections['friend']['last']       = ($this->_sections['friend']['iteration'] == $this->_sections['friend']['total']);
?>
	<?php $this->assign('thisuser', $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['user']); ?>
	<?php $this->assign('reco', $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['reco']); ?>
	<?php $this->assign('ebay_username', $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['ebay_username']); ?>
	<?php $this->assign('userlabel', ($this->_tpl_vars['thisuser'])."'s"); ?>
	<?php if ($this->_tpl_vars['first'] == 0): ?><tr><?php endif; ?>
	<?php $this->assign('first', 0); ?>
	<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
	<td nowrap class="whitetext" valign="top" align="left"><a href="/sellers/?cat=<?php echo $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['category_id']; ?>
"><?php echo $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['category']; ?>
</a></td>
    <td nowrap valign="top" class="whitetext"><?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_link_to_all_seller_items.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></td></tr>
    <tr><td colspan="3" class="whitetext" valign="top" align="left"><?php echo $this->_tpl_vars['sellers'][$this->_sections['friend']['index']]['seller_desc']; ?>
</td></tr height="4"><td colspan="3"><hr></td>
	</tr>
<?php endfor; else: ?>
    <td class="whitetext"><h4>Nothing matched your query.</h4></td></tr>
<?php endif; ?>
</table></p>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>