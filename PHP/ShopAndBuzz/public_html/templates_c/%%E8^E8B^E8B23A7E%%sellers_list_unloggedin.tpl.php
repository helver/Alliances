<?php /* Smarty version 2.6.16, created on 2007-08-07 22:44:25
         compiled from sellers_list_unloggedin.tpl */ ?>
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

<table border="0" cellspacing="8" width="90%">
<?php if ($this->_tpl_vars['sellers']): ?>
<tr>
  <th class="whitetext" align="left">Seller Name</th>
  <th class="whitetext" align="left">Seller Category</th>
  <th class="whitetext" align="left">Open Items</th>
</tr>

<?php unset($this->_sections['seller']);
$this->_sections['seller']['name'] = 'seller';
$this->_sections['seller']['loop'] = is_array($_loop=$this->_tpl_vars['sellers']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['seller']['show'] = true;
$this->_sections['seller']['max'] = $this->_sections['seller']['loop'];
$this->_sections['seller']['step'] = 1;
$this->_sections['seller']['start'] = $this->_sections['seller']['step'] > 0 ? 0 : $this->_sections['seller']['loop']-1;
if ($this->_sections['seller']['show']) {
    $this->_sections['seller']['total'] = $this->_sections['seller']['loop'];
    if ($this->_sections['seller']['total'] == 0)
        $this->_sections['seller']['show'] = false;
} else
    $this->_sections['seller']['total'] = 0;
if ($this->_sections['seller']['show']):

            for ($this->_sections['seller']['index'] = $this->_sections['seller']['start'], $this->_sections['seller']['iteration'] = 1;
                 $this->_sections['seller']['iteration'] <= $this->_sections['seller']['total'];
                 $this->_sections['seller']['index'] += $this->_sections['seller']['step'], $this->_sections['seller']['iteration']++):
$this->_sections['seller']['rownum'] = $this->_sections['seller']['iteration'];
$this->_sections['seller']['index_prev'] = $this->_sections['seller']['index'] - $this->_sections['seller']['step'];
$this->_sections['seller']['index_next'] = $this->_sections['seller']['index'] + $this->_sections['seller']['step'];
$this->_sections['seller']['first']      = ($this->_sections['seller']['iteration'] == 1);
$this->_sections['seller']['last']       = ($this->_sections['seller']['iteration'] == $this->_sections['seller']['total']);
 $this->assign('thisuser', $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['user']);  $this->assign('ebay_username', $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['ebay_username']);  $this->assign('userlabel', ($this->_tpl_vars['thisuser'])."'s"); ?>
<tr>
  <td class="whitetext" valign="top" nowrap align="left"><a href="/users/<?php echo $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['user']; ?>
/"><?php echo $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['user']; ?>
</a></td>
  <td class="whitetext" valign="top" nowrap align="left"><a href="/sellers/?cat=<?php echo $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['category_id']; ?>
"><?php echo $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['category']; ?>
</a></td>
  <td nowrap valign="top" class="whitetext"><?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_link_to_all_seller_items.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></td></tr>
  <tr><td colspan="3" class="whitetext" valign="top" align="left"><?php echo $this->_tpl_vars['sellers'][$this->_sections['seller']['index']]['seller_desc']; ?>
</td></tr><tr height="4"><td colspan="3"><hr></td>
</tr>
<?php endfor; endif;  else: ?>
<tr><td class="whitetext">Nothing matched your query.</td></tr>
<?php endif; ?>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>