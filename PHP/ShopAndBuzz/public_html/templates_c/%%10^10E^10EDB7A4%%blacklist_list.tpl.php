<?php /* Smarty version 2.6.16, created on 2007-06-30 10:36:47
         compiled from blacklist_list.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>User Blacklist</h2>

<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<p class="whitetext">
<tr><th>&nbsp;</th><th class="whitetext">Name</th><th class="whitetext">Email</th></tr>

<?php unset($this->_sections['black']);
$this->_sections['black']['name'] = 'black';
$this->_sections['black']['loop'] = is_array($_loop=$this->_tpl_vars['blacklist']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['black']['show'] = true;
$this->_sections['black']['max'] = $this->_sections['black']['loop'];
$this->_sections['black']['step'] = 1;
$this->_sections['black']['start'] = $this->_sections['black']['step'] > 0 ? 0 : $this->_sections['black']['loop']-1;
if ($this->_sections['black']['show']) {
    $this->_sections['black']['total'] = $this->_sections['black']['loop'];
    if ($this->_sections['black']['total'] == 0)
        $this->_sections['black']['show'] = false;
} else
    $this->_sections['black']['total'] = 0;
if ($this->_sections['black']['show']):

            for ($this->_sections['black']['index'] = $this->_sections['black']['start'], $this->_sections['black']['iteration'] = 1;
                 $this->_sections['black']['iteration'] <= $this->_sections['black']['total'];
                 $this->_sections['black']['index'] += $this->_sections['black']['step'], $this->_sections['black']['iteration']++):
$this->_sections['black']['rownum'] = $this->_sections['black']['iteration'];
$this->_sections['black']['index_prev'] = $this->_sections['black']['index'] - $this->_sections['black']['step'];
$this->_sections['black']['index_next'] = $this->_sections['black']['index'] + $this->_sections['black']['step'];
$this->_sections['black']['first']      = ($this->_sections['black']['iteration'] == 1);
$this->_sections['black']['last']       = ($this->_sections['black']['iteration'] == $this->_sections['black']['total']);
?>
<tr><td><a href="#" onClick="do_delete('/users/<?php echo $this->_tpl_vars['user']; ?>
/blacklist/<?php echo $this->_tpl_vars['blacklist'][$this->_sections['black']['index']]['name']; ?>
/');">Remove</a></td><td class="whitetext"><?php echo $this->_tpl_vars['blacklist'][$this->_sections['black']['index']]['name']; ?>
</td><td class="whitetext"><?php echo $this->_tpl_vars['blacklist'][$this->_sections['black']['index']]['email']; ?>
</td></tr>
<?php endfor; else: ?>
	<tr><td align="center" colspan="5" class="whitetext">No users blacklisted.</td></tr>
<?php endif; ?>
</p>
</table>


<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>