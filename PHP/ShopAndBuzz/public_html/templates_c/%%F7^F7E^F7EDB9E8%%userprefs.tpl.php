<?php /* Smarty version 2.6.16, created on 2007-08-26 23:01:52
         compiled from userprefs.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<?php if ($this->_tpl_vars['user'] == $this->_tpl_vars['me_user']):  $this->assign('userlabel', 'My');  endif; ?>

<h2><?php echo $this->_tpl_vars['userlabel']; ?>
 Member Preferences Page</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>


<h4>Shop & Buzz Member Profile Settings</h4>
<form method="POST" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/preferences/">
<table border="0">
<tr><td class="whitetext">Paypal Account Email:</td><td class="whitetext">Current: <?php echo $this->_tpl_vars['paypal_email']; ?>
</td><td>Change To: <input type="text" name="paypal_email" value="<?php echo $this->_tpl_vars['paypal_email']; ?>
" size="40" maxlength="120"></td></tr>
<tr><td class="whitetext" colspan="3">Member Description:</td></tr>
<tr><td class="whitetext" colspan="3">Current:<br><?php echo $this->_tpl_vars['user_desc']; ?>
</td></tr>
<tr><td class="whitetext" colspan="3">Change To:<br><textarea name="user_desc" rows="5" wrap="virtual" cols="70"><?php echo $this->_tpl_vars['user_desc']; ?>
</textarea></td></tr>
<tr><td class="whitetext" colspan="3">&nbsp;</td></tr>
<tr><td class="whitetext" colspan="3"><input type="submit" value="Update Profile"></td></tr>
</table>
</form>


<h4>Email Blacklist</h4>
<table border="0">
<?php unset($this->_sections['tool']);
$this->_sections['tool']['name'] = 'tool';
$this->_sections['tool']['loop'] = is_array($_loop=$this->_tpl_vars['blacklist']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['tool']['show'] = true;
$this->_sections['tool']['max'] = $this->_sections['tool']['loop'];
$this->_sections['tool']['step'] = 1;
$this->_sections['tool']['start'] = $this->_sections['tool']['step'] > 0 ? 0 : $this->_sections['tool']['loop']-1;
if ($this->_sections['tool']['show']) {
    $this->_sections['tool']['total'] = $this->_sections['tool']['loop'];
    if ($this->_sections['tool']['total'] == 0)
        $this->_sections['tool']['show'] = false;
} else
    $this->_sections['tool']['total'] = 0;
if ($this->_sections['tool']['show']):

            for ($this->_sections['tool']['index'] = $this->_sections['tool']['start'], $this->_sections['tool']['iteration'] = 1;
                 $this->_sections['tool']['iteration'] <= $this->_sections['tool']['total'];
                 $this->_sections['tool']['index'] += $this->_sections['tool']['step'], $this->_sections['tool']['iteration']++):
$this->_sections['tool']['rownum'] = $this->_sections['tool']['iteration'];
$this->_sections['tool']['index_prev'] = $this->_sections['tool']['index'] - $this->_sections['tool']['step'];
$this->_sections['tool']['index_next'] = $this->_sections['tool']['index'] + $this->_sections['tool']['step'];
$this->_sections['tool']['first']      = ($this->_sections['tool']['iteration'] == 1);
$this->_sections['tool']['last']       = ($this->_sections['tool']['iteration'] == $this->_sections['tool']['total']);
?>
    <tr><td class="whitetext"><form method="DELETE" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/blacklist/<?php echo $this->_tpl_vars['blacklist'][$this->_sections['tool']['index']]['user']; ?>
/"><input type="submit" value="Remove"> <a href="/users/<?php echo $this->_tpl_vars['blacklist'][$this->_sections['tool']['index']]['user']; ?>
/"><?php echo $this->_tpl_vars['blacklist'][$this->_sections['tool']['index']]['user']; ?>
</a></form></td></tr>
<?php endfor; else: ?>
    <tr><td class="whitetext"><h4>No one in <?php echo $this->_tpl_vars['userlabel']; ?>
 email blacklist yet.</h4></td></tr>
<?php endif; ?>
</table>


<h4>Email Delivery Schedule</h4>
<table border="0">
<tr><td class="whitetext">Current: <?php echo $this->_tpl_vars['delivery_schedule']; ?>
</td></tr>
<tr><td class="whitetext">Change To:</td></tr>
<?php unset($this->_sections['sched']);
$this->_sections['sched']['name'] = 'sched';
$this->_sections['sched']['loop'] = is_array($_loop=$this->_tpl_vars['delivery_schedules']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['sched']['show'] = true;
$this->_sections['sched']['max'] = $this->_sections['sched']['loop'];
$this->_sections['sched']['step'] = 1;
$this->_sections['sched']['start'] = $this->_sections['sched']['step'] > 0 ? 0 : $this->_sections['sched']['loop']-1;
if ($this->_sections['sched']['show']) {
    $this->_sections['sched']['total'] = $this->_sections['sched']['loop'];
    if ($this->_sections['sched']['total'] == 0)
        $this->_sections['sched']['show'] = false;
} else
    $this->_sections['sched']['total'] = 0;
if ($this->_sections['sched']['show']):

            for ($this->_sections['sched']['index'] = $this->_sections['sched']['start'], $this->_sections['sched']['iteration'] = 1;
                 $this->_sections['sched']['iteration'] <= $this->_sections['sched']['total'];
                 $this->_sections['sched']['index'] += $this->_sections['sched']['step'], $this->_sections['sched']['iteration']++):
$this->_sections['sched']['rownum'] = $this->_sections['sched']['iteration'];
$this->_sections['sched']['index_prev'] = $this->_sections['sched']['index'] - $this->_sections['sched']['step'];
$this->_sections['sched']['index_next'] = $this->_sections['sched']['index'] + $this->_sections['sched']['step'];
$this->_sections['sched']['first']      = ($this->_sections['sched']['iteration'] == 1);
$this->_sections['sched']['last']       = ($this->_sections['sched']['iteration'] == $this->_sections['sched']['total']);
?>
    <tr><td class="whitetext"><form method="POST" action="/users/<?php echo $this->_tpl_vars['user']; ?>
/emaildelivery/<?php echo $this->_tpl_vars['delivery_schedules'][$this->_sections['sched']['index']]['id']; ?>
/"><input type="Submit" value="Choose"> <?php echo $this->_tpl_vars['delivery_schedules'][$this->_sections['sched']['index']]['name']; ?>
</a></form></td></tr>
<?php endfor; else: ?>
    <tr><td class="whitetext"><h4>This is an error - No available email delivery schedules..</h4></td></tr>
<?php endif; ?>
</table>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>