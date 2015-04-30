<?php /* Smarty version 2.6.16, created on 2007-05-19 09:42:08
         compiled from users_admin.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
 

<h2><?php echo $this->_tpl_vars['user']; ?>
's Admin Page</h2>

<ul>
<li><a href="preferences/">Preferences</a></li>
<li><a href="invitations/">Invitations</a></li>
<li><a href="paypal/">Paypal Profile</a></li>
<li><a href="user_profile/">User Profile</a></li>
<li><a href="ebay/">eBay Profile</a></li>
<li><a href="seller_profile/">Seller Profile</a></li>
<li><a href="hive_mine/">Hive</a></li>
<li><a href="hive_others/">Hive Membership</a></li>
<li><a href="honeycomb_mine/">Honeycomb</a></li>
<li><a href="honeycomb_others/">Honeycomb Membership</a></li>
<li><a href="recommendations_mine/">Recommandations</a></li>
<li><a href="recommnededions_others/">Recommended By</a></li>
<li><a href="blocked_email/">Blocked Emails</a></li>
<li><a href="commission_schedules/">Commission Schedules</a></li>
<li><a href="buyer_transactions/">Transactions As Buyer</a></li>
<li><a href="seller_transactions/">Transactions As Seller</a></li>
<li><a href="referrals_as_seller/">Referrals As Seller</a></li>
<li><a href="referrals_as_buyer/">Referrals As Buyer</a></li>
<li><a href="referrals_as_referer/">Referrals As Referer</a></li>
<li><a href="user_messages/">User Messages</a></li>
</ul>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>