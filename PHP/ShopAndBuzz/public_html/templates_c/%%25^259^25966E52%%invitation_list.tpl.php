<?php /* Smarty version 2.6.16, created on 2007-07-08 08:14:30
         compiled from invitation_list.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Sent Invitations</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/inviteothers/">Click Here</a> to invite someone new!</p>

<table border="0" cellpadding="6" cellspacing="8" width="850">
<p class="whitetext">
<tr><th>&nbsp;</th><th class="whitetext">Name</th><th class="whitetext">Email</th><th class="whitetext">Date</th><th class="whitetext">Status</tr></tr>

<?php unset($this->_sections['invite']);
$this->_sections['invite']['name'] = 'invite';
$this->_sections['invite']['loop'] = is_array($_loop=$this->_tpl_vars['invitations']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['invite']['show'] = true;
$this->_sections['invite']['max'] = $this->_sections['invite']['loop'];
$this->_sections['invite']['step'] = 1;
$this->_sections['invite']['start'] = $this->_sections['invite']['step'] > 0 ? 0 : $this->_sections['invite']['loop']-1;
if ($this->_sections['invite']['show']) {
    $this->_sections['invite']['total'] = $this->_sections['invite']['loop'];
    if ($this->_sections['invite']['total'] == 0)
        $this->_sections['invite']['show'] = false;
} else
    $this->_sections['invite']['total'] = 0;
if ($this->_sections['invite']['show']):

            for ($this->_sections['invite']['index'] = $this->_sections['invite']['start'], $this->_sections['invite']['iteration'] = 1;
                 $this->_sections['invite']['iteration'] <= $this->_sections['invite']['total'];
                 $this->_sections['invite']['index'] += $this->_sections['invite']['step'], $this->_sections['invite']['iteration']++):
$this->_sections['invite']['rownum'] = $this->_sections['invite']['iteration'];
$this->_sections['invite']['index_prev'] = $this->_sections['invite']['index'] - $this->_sections['invite']['step'];
$this->_sections['invite']['index_next'] = $this->_sections['invite']['index'] + $this->_sections['invite']['step'];
$this->_sections['invite']['first']      = ($this->_sections['invite']['iteration'] == 1);
$this->_sections['invite']['last']       = ($this->_sections['invite']['iteration'] == $this->_sections['invite']['total']);
?>
<tr><td><a href="<?php echo $this->_tpl_vars['invitations'][$this->_sections['invite']['index']]['id']; ?>
/">Detail</a></td><td class="whitetext"><?php echo $this->_tpl_vars['invitations'][$this->_sections['invite']['index']]['name']; ?>
</td><td class="whitetext"><?php echo $this->_tpl_vars['invitations'][$this->_sections['invite']['index']]['email']; ?>
</td><td class="whitetext"><?php echo $this->_tpl_vars['invitations'][$this->_sections['invite']['index']]['date']; ?>
</td><td class="whitetext"><?php echo $this->_tpl_vars['invitations'][$this->_sections['invite']['index']]['status']; ?>
</td></tr>
<?php endfor; else: ?>
	<tr><td align="center" colspan="5" class="whitetext">No invitations sent.</td></tr>
<?php endif; ?>
</p>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>