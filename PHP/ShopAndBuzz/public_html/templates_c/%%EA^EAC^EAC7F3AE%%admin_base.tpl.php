<?php /* Smarty version 2.6.16, created on 2007-08-10 21:29:11
         compiled from admin_base.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2>Admin Functions</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext"><a href="/admin/files/">Click Here</a> to administer templates.</p>
<p class="whitetext"><a href="/admin/emails/">Click Here</a> to administer email bodies.</p>
<p class="whitetext"><a href="/admin/thematics/">Click Here</a> to administer theme elements.</p>

<h4>Member Admin Section</h2>

<p class="whitetext"><a href="/admin/users/">Click Here</a> to administer member data.</p>

<h4>Table Admin Section</h2>

<?php unset($this->_sections['table']);
$this->_sections['table']['name'] = 'table';
$this->_sections['table']['loop'] = is_array($_loop=$this->_tpl_vars['tablefields']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['table']['show'] = true;
$this->_sections['table']['max'] = $this->_sections['table']['loop'];
$this->_sections['table']['step'] = 1;
$this->_sections['table']['start'] = $this->_sections['table']['step'] > 0 ? 0 : $this->_sections['table']['loop']-1;
if ($this->_sections['table']['show']) {
    $this->_sections['table']['total'] = $this->_sections['table']['loop'];
    if ($this->_sections['table']['total'] == 0)
        $this->_sections['table']['show'] = false;
} else
    $this->_sections['table']['total'] = 0;
if ($this->_sections['table']['show']):

            for ($this->_sections['table']['index'] = $this->_sections['table']['start'], $this->_sections['table']['iteration'] = 1;
                 $this->_sections['table']['iteration'] <= $this->_sections['table']['total'];
                 $this->_sections['table']['index'] += $this->_sections['table']['step'], $this->_sections['table']['iteration']++):
$this->_sections['table']['rownum'] = $this->_sections['table']['iteration'];
$this->_sections['table']['index_prev'] = $this->_sections['table']['index'] - $this->_sections['table']['step'];
$this->_sections['table']['index_next'] = $this->_sections['table']['index'] + $this->_sections['table']['step'];
$this->_sections['table']['first']      = ($this->_sections['table']['iteration'] == 1);
$this->_sections['table']['last']       = ($this->_sections['table']['iteration'] == $this->_sections['table']['total']);
 echo $this->_tpl_vars['tablefields'][$this->_sections['table']['index']]; ?>

<?php endfor; endif; ?>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
