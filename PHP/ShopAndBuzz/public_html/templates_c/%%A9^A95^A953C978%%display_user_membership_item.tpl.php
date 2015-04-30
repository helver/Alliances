<?php /* Smarty version 2.6.16, created on 2007-06-13 01:11:07
         compiled from display_user_membership_item.tpl */ ?>
	<form onSubmit="return false;"><td align="left" id="userdisplay" valign="middle" nowrap><a href="/users/<?php echo $this->_tpl_vars['thisuser']; ?>
/"><?php echo $this->_tpl_vars['thisuser']; ?>
</a>
      <input type="image" align="middle" src="/thematics/<?php echo $this->_tpl_vars['t_list']; ?>
-remove.gif" onClick="do_delete('/users/<?php echo $this->_tpl_vars['thisuser']; ?>
/<?php echo $this->_tpl_vars['t_list']; ?>
/<?php echo $this->_tpl_vars['user']; ?>
/');" alt="Remove Me from <?php echo $this->_tpl_vars['thisuser']; ?>
's <?php echo $this->_tpl_vars['list_label']; ?>
." title="Remove Me from <?php echo $this->_tpl_vars['thisuser']; ?>
's <?php echo $this->_tpl_vars['list_label']; ?>
.">
	</td></form>
	
	