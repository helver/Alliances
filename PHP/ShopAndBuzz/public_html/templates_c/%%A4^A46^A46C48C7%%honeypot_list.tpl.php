<?php /* Smarty version 2.6.16, created on 2007-02-21 09:59:59
         compiled from honeypot_list.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2><?php echo $this->_tpl_vars['user']; ?>
's Honeypot</h2>

<ul>
<li><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/private/">Private Profile Page</a></li>
<li><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/">Public Profile Page</a></li>
<li><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/preferences/">Preferences</a></li>
</ul>

<table border="0">
<?php unset($this->_sections['friend']);
$this->_sections['friend']['name'] = 'friend';
$this->_sections['friend']['loop'] = is_array($_loop=$this->_tpl_vars['honeypot']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
    <tr><td><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/honeypot/<?php echo $this->_tpl_vars['honeypot'][$this->_sections['friend']['index']]['user']; ?>
/"><?php echo $this->_tpl_vars['honeypot'][$this->_sections['friend']['index']]['user']; ?>
</a></td></tr>
<?php endfor; else: ?>
    <tr><td><h4>Apparently, you have no trusted Sellers.</h4></td></tr>
<?php endif; ?>
</table></dd>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>