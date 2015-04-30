<?php /* Smarty version 2.6.16, created on 2007-08-21 22:13:52
         compiled from hive_list.tpl */ ?>


<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<?php if ($this->_tpl_vars['user'] == $this->_tpl_vars['me_user']):  $this->assign('userlabel', 'My');  endif; ?>
<h2><?php echo $this->_tpl_vars['userlabel']; ?>
 Hive <?php echo $this->_tpl_vars['title_string']; ?>
</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td><a href="http://www.shopandbuzz.com/users/">Search for members</a>.<br><br>

<table border="0" width="90%" cellpadding="5">
<?php $this->assign('t_list', 'hive');  $this->assign('list_label', 'Hive');  unset($this->_sections['friend']);
$this->_sections['friend']['name'] = 'friend';
$this->_sections['friend']['loop'] = is_array($_loop=$this->_tpl_vars['hive']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
	<?php $this->assign('thisuser', $this->_tpl_vars['hive'][$this->_sections['friend']['index']]['user']); ?>
	<?php $this->assign('reco', $this->_tpl_vars['hive'][$this->_sections['friend']['index']]['reco']); ?>
	<tr style="height=25;"><?php if ($this->_tpl_vars['invert']):  $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_membership_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
  else:  $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
  endif; ?></tr>
<?php endfor; else: ?>
    <tr><td class="whitetext"><h4>No one in <?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
 <?php echo $this->_tpl_vars['title_string']; ?>
.</h4></td></tr>
<?php endif; ?>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>