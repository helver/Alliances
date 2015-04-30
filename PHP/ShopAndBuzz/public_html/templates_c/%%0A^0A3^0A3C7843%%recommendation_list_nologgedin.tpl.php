<?php /* Smarty version 2.6.16, created on 2007-07-30 11:50:21
         compiled from recommendation_list_nologgedin.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<h2><?php echo $this->_tpl_vars['title']; ?>
</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<table width="70%" border="0" cellspacing="3">
<?php if ($this->_tpl_vars['recommendations']): ?>
	<tr>
		<th class="whitetext">&nbsp;</th>
		<th class="whitetext" width="30%" align="left">Seller Username</th>
		<th class="whitetext" width="10%" align="center">Overall Rating</th>
		<th class="whitetext" width="50%" align="left">Comment</th>
	</tr>
	
	<?php unset($this->_sections['recommend']);
$this->_sections['recommend']['name'] = 'recommend';
$this->_sections['recommend']['loop'] = is_array($_loop=$this->_tpl_vars['recommendations']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['recommend']['show'] = true;
$this->_sections['recommend']['max'] = $this->_sections['recommend']['loop'];
$this->_sections['recommend']['step'] = 1;
$this->_sections['recommend']['start'] = $this->_sections['recommend']['step'] > 0 ? 0 : $this->_sections['recommend']['loop']-1;
if ($this->_sections['recommend']['show']) {
    $this->_sections['recommend']['total'] = $this->_sections['recommend']['loop'];
    if ($this->_sections['recommend']['total'] == 0)
        $this->_sections['recommend']['show'] = false;
} else
    $this->_sections['recommend']['total'] = 0;
if ($this->_sections['recommend']['show']):

            for ($this->_sections['recommend']['index'] = $this->_sections['recommend']['start'], $this->_sections['recommend']['iteration'] = 1;
                 $this->_sections['recommend']['iteration'] <= $this->_sections['recommend']['total'];
                 $this->_sections['recommend']['index'] += $this->_sections['recommend']['step'], $this->_sections['recommend']['iteration']++):
$this->_sections['recommend']['rownum'] = $this->_sections['recommend']['iteration'];
$this->_sections['recommend']['index_prev'] = $this->_sections['recommend']['index'] - $this->_sections['recommend']['step'];
$this->_sections['recommend']['index_next'] = $this->_sections['recommend']['index'] + $this->_sections['recommend']['step'];
$this->_sections['recommend']['first']      = ($this->_sections['recommend']['iteration'] == 1);
$this->_sections['recommend']['last']       = ($this->_sections['recommend']['iteration'] == $this->_sections['recommend']['total']);
?>
	<?php if ($this->_tpl_vars['invert']): ?>
	  <?php $this->assign('xxname', $this->_tpl_vars['recommendations'][$this->_sections['recommend']['index']]['name']); ?>
	  <?php $this->assign('link', "/users/".($this->_tpl_vars['xxname'])."/recommendations/".($this->_tpl_vars['user'])); ?>
	<?php else: ?>
	  <?php $this->assign('link', $this->_tpl_vars['recommendations'][$this->_sections['recommend']['index']]['name']); ?>
	<?php endif; ?>
	  <tr>
		  <td class="whitetext" align="center"><a href="<?php echo $this->_tpl_vars['link']; ?>
/">Detail</a></td>
		  <td class="whitetext" align="left"><?php echo $this->_tpl_vars['recommendations'][$this->_sections['recommend']['index']]['name']; ?>
</td>
		  <td class="whitetext" align="center"><?php echo $this->_tpl_vars['recommendations'][$this->_sections['recommend']['index']]['exp_rating']; ?>
</td>
		  <td class="whitetext" align="left"><?php echo $this->_tpl_vars['recommendations'][$this->_sections['recommend']['index']]['recommend']; ?>
</td>
	  </tr>
	<?php endfor; endif;  else: ?>
	<tr><td class="whitetext" align="center">No Recommendations.</td></tr>
<?php endif; ?>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>