<?php /* Smarty version 2.6.16, created on 2007-07-24 16:11:16
         compiled from nickTest.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
 

<?php if ($this->_tpl_vars['user'] == $this->_tpl_vars['me_user']):  $this->assign('userlabel', 'My');  endif; ?>
<h2><?php echo $this->_tpl_vars['userlabel']; ?>
 Shop And Buzz Dashboard</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">
<table border="0">

<tr><td class="whitetext"><br><b>Seller Description:</b><br><?php echo $this->_tpl_vars['seller_profile']['description']; ?>
</td></tr>
</table>

<p class="whitetext">
<?php $this->assign('t_list', 'hive');  $this->assign('list_label', 'Hive');  $this->assign('first', 1); ?>
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="<?php echo $this->_tpl_vars['hive_size']; ?>
" class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/<?php echo $this->_tpl_vars['t_list']; ?>
/"><img border="0" src="/thematics/web-headline-hive.jpg" title="<?php echo $this->_tpl_vars['userlabel']; ?>
 Hive" alt="<?php echo $this->_tpl_vars['userlabel']; ?>
 Hive"></a></td>
<?php unset($this->_sections['friend']);
$this->_sections['friend']['name'] = 'friend';
$this->_sections['friend']['loop'] = is_array($_loop=$this->_tpl_vars['random_from_hive']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
	<?php $this->assign('thisuser', $this->_tpl_vars['random_from_hive'][$this->_sections['friend']['index']]['user']); ?>
	<?php $this->assign('reco', $this->_tpl_vars['random_from_hive'][$this->_sections['friend']['index']]['reco']); ?>
	<?php if ($this->_tpl_vars['first'] == 0): ?><tr><?php endif; ?>
	<?php $this->assign('first', 0); ?>
	<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></tr>
<?php endfor; else: ?>
    <td class="whitetext"><h4>No one in <?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
.</h4></td></tr>
<?php endif; ?>
</table></p>

<br>

<p class="whitetext">
<?php $this->assign('t_list', 'honeycomb');  $this->assign('list_label', 'Honeycomb');  $this->assign('first', 1); ?>
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="<?php echo $this->_tpl_vars['honeycomb_size']; ?>
" class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/<?php echo $this->_tpl_vars['t_list']; ?>
/"><img border="0" src="/thematics/web-headline-honeycomb.jpg" title="<?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
" alt="<?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
"></a></td>
<?php unset($this->_sections['seller']);
$this->_sections['seller']['name'] = 'seller';
$this->_sections['seller']['loop'] = is_array($_loop=$this->_tpl_vars['random_from_honeycomb']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
?>
	<?php $this->assign('thisuser', $this->_tpl_vars['random_from_honeycomb'][$this->_sections['seller']['index']]['user']); ?>
	<?php $this->assign('reco', $this->_tpl_vars['random_from_honeycomb'][$this->_sections['seller']['index']]['reco']); ?>
	<?php if ($this->_tpl_vars['first'] == 0): ?><tr><?php endif; ?>
	<?php $this->assign('first', 0); ?>
	<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></tr>
<?php endfor; else: ?>
    <td class="whitetext"><h4>No one in <?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
.</h4></td></tr>
<?php endif; ?>
</table></p>


<br>

<p class="whitetext">
<?php $this->assign('t_list', 'recommendations');  $this->assign('list_label', 'Recommendations');  $this->assign('first', 1); ?>
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="<?php echo $this->_tpl_vars['news_size']; ?>
" class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/<?php echo $this->_tpl_vars['t_list']; ?>
/"><img border="0" src="/thematics/web-headline-news.jpg" title="<?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
" alt="<?php echo $this->_tpl_vars['userlabel']; ?>
 <?php echo $this->_tpl_vars['list_label']; ?>
"></a></td>
<?php unset($this->_sections['recommend']);
$this->_sections['recommend']['name'] = 'recommend';
$this->_sections['recommend']['loop'] = is_array($_loop=$this->_tpl_vars['random_from_reco']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
	<?php $this->assign('thisuser', $this->_tpl_vars['random_from_reco'][$this->_sections['recommend']['index']]['user']); ?>
	<?php $this->assign('reco', $this->_tpl_vars['random_from_reco'][$this->_sections['recommend']['index']]['reco']); ?>
	<?php if ($this->_tpl_vars['first'] == 0): ?><tr><?php else: ?><td class="whitetext">Recently Recommended<br><hr></td></tr><tr><?php endif; ?>
	<?php $this->assign('first', 0); ?>
	<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "display_user_item.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?></tr>
<?php endfor; endif; ?>

<?php if ($this->_tpl_vars['first'] == 0): ?><tr><?php endif;  $this->assign('first', 0); ?>
<td class="whitetext">Buzz Updates<br><hr></td></tr>
<?php unset($this->_sections['item']);
$this->_sections['item']['name'] = 'item';
$this->_sections['item']['loop'] = is_array($_loop=$this->_tpl_vars['latest_updates']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['item']['show'] = true;
$this->_sections['item']['max'] = $this->_sections['item']['loop'];
$this->_sections['item']['step'] = 1;
$this->_sections['item']['start'] = $this->_sections['item']['step'] > 0 ? 0 : $this->_sections['item']['loop']-1;
if ($this->_sections['item']['show']) {
    $this->_sections['item']['total'] = $this->_sections['item']['loop'];
    if ($this->_sections['item']['total'] == 0)
        $this->_sections['item']['show'] = false;
} else
    $this->_sections['item']['total'] = 0;
if ($this->_sections['item']['show']):

            for ($this->_sections['item']['index'] = $this->_sections['item']['start'], $this->_sections['item']['iteration'] = 1;
                 $this->_sections['item']['iteration'] <= $this->_sections['item']['total'];
                 $this->_sections['item']['index'] += $this->_sections['item']['step'], $this->_sections['item']['iteration']++):
$this->_sections['item']['rownum'] = $this->_sections['item']['iteration'];
$this->_sections['item']['index_prev'] = $this->_sections['item']['index'] - $this->_sections['item']['step'];
$this->_sections['item']['index_next'] = $this->_sections['item']['index'] + $this->_sections['item']['step'];
$this->_sections['item']['first']      = ($this->_sections['item']['iteration'] == 1);
$this->_sections['item']['last']       = ($this->_sections['item']['iteration'] == $this->_sections['item']['total']);
?>
    <tr><td class="whitetext"><?php echo $this->_tpl_vars['latest_updates'][$this->_sections['item']['index']]; ?>
</a></td></tr>
<?php endfor; endif; ?>


</table></dd>


</tr></table></p>

</td></tr></table>
</td></tr></table>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>