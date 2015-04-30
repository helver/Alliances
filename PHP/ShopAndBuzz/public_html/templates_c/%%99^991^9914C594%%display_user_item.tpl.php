<?php /* Smarty version 2.6.16, created on 2007-08-07 22:21:30
         compiled from display_user_item.tpl */ ?>
	<?php $this->assign('in_hive', $this->_tpl_vars['me_user_obj']->UserInHive($this->_tpl_vars['thisuser'])); ?>
	<?php $this->assign('in_honeycomb', $this->_tpl_vars['me_user_obj']->UserInHoneycomb($this->_tpl_vars['thisuser'])); ?>
	<?php $this->assign('is_seller', $this->_tpl_vars['me_user_obj']->IsUserSeller($this->_tpl_vars['thisuser'])); ?>
	
	<form method="POST" onSubmit="return really_submit(this.elements['do_submit'].value);"><td align="left" id="userdisplay" valign="middle" nowrap><a href="/users/<?php echo $this->_tpl_vars['thisuser']; ?>
/"><?php echo $this->_tpl_vars['thisuser']; ?>
</a>
	<input type="hidden" name="do_submit" value="0">
	<?php if ($this->_tpl_vars['me_user'] != $this->_tpl_vars['thisuser']): ?>
	
    <?php if ($this->_tpl_vars['in_hive'] == 0): ?>
	  <input type="image" align="middle" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/<?php echo $this->_tpl_vars['me_user']; ?>
/hive/<?php echo $this->_tpl_vars['thisuser']; ?>
/';" src="/thematics/hive-add.gif" alt="Add <?php echo $this->_tpl_vars['thisuser']; ?>
 to My Hive." title="Add <?php echo $this->_tpl_vars['thisuser']; ?>
 to My Hive.">
	<?php else: ?>
      <input type="image" align="middle" src="/thematics/hive-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/<?php echo $this->_tpl_vars['me_user']; ?>
/hive/<?php echo $this->_tpl_vars['thisuser']; ?>
/');" alt="Remove <?php echo $this->_tpl_vars['thisuser']; ?>
 from My Hive." title="Remove <?php echo $this->_tpl_vars['thisuser']; ?>
 from My Hive.">
	<?php endif; ?>

    <?php if ($this->_tpl_vars['is_seller']): ?>
    <?php if ($this->_tpl_vars['in_honeycomb'] == 0): ?>
	  <input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/<?php echo $this->_tpl_vars['me_user']; ?>
/honeycomb/<?php echo $this->_tpl_vars['thisuser']; ?>
/';" src="/thematics/honeycomb-add.gif" alt="Add <?php echo $this->_tpl_vars['thisuser']; ?>
 to My Honeycomb." title="Add <?php echo $this->_tpl_vars['thisuser']; ?>
 to My Honeycomb.">
	<?php else: ?>
	  <?php if ($this->_tpl_vars['me_user_obj']->CheckMyReco($this->_tpl_vars['thisuser']) > 0): ?>
	    <input type="image" align="center" src="/thematics/recommend-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/<?php echo $this->_tpl_vars['me_user']; ?>
/recommendations/<?php echo $this->_tpl_vars['thisuser']; ?>
/');" title="Rescind your recommendation of <?php echo $this->_tpl_vars['thisuser']; ?>
." alt="Rescind your recommendation of <?php echo $this->_tpl_vars['thisuser']; ?>
.">
	  <?php else: ?>
	    <input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/<?php echo $this->_tpl_vars['thisuser']; ?>
/recommendations/';" src="/thematics/recommend-add.gif" alt="Recommend <?php echo $this->_tpl_vars['thisuser']; ?>
 as a quality Seller." title="Recommend <?php echo $this->_tpl_vars['thisuser']; ?>
 as a quality Seller.">
	  <?php endif; ?>
      <input type="image" align="center" src="/thematics/honeycomb-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/<?php echo $this->_tpl_vars['me_user']; ?>
/honeycomb/<?php echo $this->_tpl_vars['thisuser']; ?>
/');" alt="Remove <?php echo $this->_tpl_vars['thisuser']; ?>
 from My Honeycomb." title="Remove <?php echo $this->_tpl_vars['thisuser']; ?>
 from My Honeycomb.">
	<?php endif; ?>
	<?php endif; ?>
	
	<input type="image" align="center" onClick="this.form.elements['do_submit'].value=1; this.form.action='/users/<?php echo $this->_tpl_vars['me_user']; ?>
/blacklist/<?php echo $this->_tpl_vars['thisuser']; ?>
/';" src="/thematics/blacklist-add.gif" alt="Blacklist <?php echo $this->_tpl_vars['thisuser']; ?>
." title="Blacklist <?php echo $this->_tpl_vars['thisuser']; ?>
.">

	<?php else: ?>
      <input type="image" align="middle" src="/thematics/<?php echo $this->_tpl_vars['t_list']; ?>
-remove.gif" onClick="this.form.elements['do_submit'].value=0;do_delete('/users/<?php echo $this->_tpl_vars['user']; ?>
/<?php echo $this->_tpl_vars['t_list']; ?>
/<?php echo $this->_tpl_vars['thisuser']; ?>
/');" alt="Remove Me from <?php echo $this->_tpl_vars['user']; ?>
's <?php echo $this->_tpl_vars['list_label']; ?>
." title="Remove Me from <?php echo $this->_tpl_vars['user']; ?>
's <?php echo $this->_tpl_vars['list_label']; ?>
.">
	<?php endif; ?>
	</td></form>
	
	