<?php /* Smarty version 2.6.16, created on 2007-07-16 22:22:34
         compiled from email_admin.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Email Admin</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<h4>Email Templates Available To Edit<h4>

<table border="0">
<?php unset($this->_sections['tfile']);
$this->_sections['tfile']['name'] = 'tfile';
$this->_sections['tfile']['loop'] = is_array($_loop=$this->_tpl_vars['template_files']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['tfile']['show'] = true;
$this->_sections['tfile']['max'] = $this->_sections['tfile']['loop'];
$this->_sections['tfile']['step'] = 1;
$this->_sections['tfile']['start'] = $this->_sections['tfile']['step'] > 0 ? 0 : $this->_sections['tfile']['loop']-1;
if ($this->_sections['tfile']['show']) {
    $this->_sections['tfile']['total'] = $this->_sections['tfile']['loop'];
    if ($this->_sections['tfile']['total'] == 0)
        $this->_sections['tfile']['show'] = false;
} else
    $this->_sections['tfile']['total'] = 0;
if ($this->_sections['tfile']['show']):

            for ($this->_sections['tfile']['index'] = $this->_sections['tfile']['start'], $this->_sections['tfile']['iteration'] = 1;
                 $this->_sections['tfile']['iteration'] <= $this->_sections['tfile']['total'];
                 $this->_sections['tfile']['index'] += $this->_sections['tfile']['step'], $this->_sections['tfile']['iteration']++):
$this->_sections['tfile']['rownum'] = $this->_sections['tfile']['iteration'];
$this->_sections['tfile']['index_prev'] = $this->_sections['tfile']['index'] - $this->_sections['tfile']['step'];
$this->_sections['tfile']['index_next'] = $this->_sections['tfile']['index'] + $this->_sections['tfile']['step'];
$this->_sections['tfile']['first']      = ($this->_sections['tfile']['iteration'] == 1);
$this->_sections['tfile']['last']       = ($this->_sections['tfile']['iteration'] == $this->_sections['tfile']['total']);
?>
<form method="GET" action="/admin/emails/<?php echo $this->_tpl_vars['template_files'][$this->_sections['tfile']['index']]; ?>
/">
<tr>
  <td valign="top"><input type="button" value="Edit Template" onClick="this.form.method='GET'; this.form.submit();"/></td>
  <td valign="top" class="whitetext"><?php echo $this->_tpl_vars['template_files'][$this->_sections['tfile']['index']]; ?>
</td>
</tr>
</form>
<?php endfor; endif; ?>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>