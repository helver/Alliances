<?php /* Smarty version 2.6.16, created on 2007-08-08 00:02:25
         compiled from privateprofile.tpl */ ?>


<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

<?php if ($this->_tpl_vars['user'] == $this->_tpl_vars['me_user']):  $this->assign('userlabel', 'My');  endif; ?>
<h2><?php echo $this->_tpl_vars['userlabel']; ?>
 Account Page</h2>


<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<?php if ($this->_tpl_vars['error_text'] != False): ?>
<p class="errortext">Ooops!  We encountered an error trying to process your last request:<Br>
<?php echo $this->_tpl_vars['error_text']; ?>

</p>
<?php endif; ?>

<h4><?php echo $this->_tpl_vars['userlabel']; ?>
 Shop & Buzz Seller Profile</h4>
<p><table border="0">
<?php if ($this->_tpl_vars['user_obj']->IsSeller()): ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Category:</b></td><td class="whitetext"><?php echo $this->_tpl_vars['seller_profile']['category']; ?>
</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Seller Blurb:</b></td><td class="whitetext"><?php echo $this->_tpl_vars['seller_profile']['description']; ?>
</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/seller_profile/">Update <?php echo $this->_tpl_vars['userlabel']; ?>
 Seller Profile</a></td></tr>
</table><br>

<table border="0">
<?php if ($this->_tpl_vars['displayMakePayment']): ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Make Payment:</b></td><td nowrap class="whitetext"><a href="payment/">Pay Invoice</a></td></tr>
<?php endif; ?>

<?php if ($this->_tpl_vars['cs_1_last_update'] == -1): ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Referred Buyers:</b></td><td nowrap class="whitetext">No Commissions to Referred Buyers set.</td></tr>
<?php else: ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Referred Buyers:</b></td><td nowrap class="whitetext">Commission schedule last updated: <?php echo $this->_tpl_vars['cs_1_last_update']; ?>
</td></tr>
<?php endif;  if ($this->_tpl_vars['cs_2_last_update'] == -1): ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Your Buzzing Buyers:</b></td><td nowrap class="whitetext">No Commissions to Your Buzzing Buyers set.</td></tr>
<?php else: ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Your Buzzing Buyers:</b></td><td nowrap class="whitetext">Commission schedule last updated: <?php echo $this->_tpl_vars['cs_2_last_update']; ?>
</td></tr>
<?php endif; ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/commission_schedule/">Update <?php echo $this->_tpl_vars['userlabel']; ?>
 Commission Schedule</a></td></tr>

<?php else: ?>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/seller_profile/">Register As A Seller</a></td></tr>

<!--<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext">
<a href="../../../newsellerform.php">Register As A Seller</a></td></tr>-->

<?php endif; ?>
</table></p>

<p><hr></p>

<h4>Shop and Buzz Search</h4>
<p class="whitetext"><a href="/sellers/">Search For Sellers</a> -- <a href="/users/">Search For Members</a></p>


<h4><?php echo $this->_tpl_vars['userlabel']; ?>
 Shop & Buzz Member Profile</h4>
<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/preferences/">Update <?php echo $this->_tpl_vars['userlabel']; ?>
 Member Profile</a></p>
<p class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/widgets/">Build Widgets to Promote <?php echo $this->_tpl_vars['userlabel']; ?>
 Buzz Account</a></p>


<p><h4>Invitation Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 Invitation Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/inviteothers/">Send Invite</a>
</td></tr>
<tr>
<td>&nbsp;&nbsp;&nbsp;</td>
<td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/invitations/">View All</a>
<td nowrap class="whitetext"><?php echo $this->_tpl_vars['invites_count']; ?>
 Invites Sent</td>
</tr>

</table></p>


<p><hr></p>

<p><h4><?php echo $this->_tpl_vars['userlabel']; ?>
 eBay Status</h4>

<p><table border="0">
<tr><td>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 eBay Standing:</b></td><td class="whitetext"><?php echo $this->_tpl_vars['ebay_standing']; ?>
</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 eBay Seller Status:</b></td><td class="whitetext"><?php echo $this->_tpl_vars['seller_status']; ?>
</td></tr>
</table></p>

<p><hr></p>

<p><h4><?php echo $this->_tpl_vars['userlabel']; ?>
 Hive Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 Hive Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/hive/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['hive_count']; ?>
 Active Buzz Members in <?php echo $this->_tpl_vars['userlabel']; ?>
 Hive.</td></tr>
<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 Hive Membership</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/hive_membership/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['userlabel']; ?>
 Account is in <?php echo $this->_tpl_vars['me_hive_count']; ?>
 Buzz Members' Hives.</td></tr>
</table></p>

<p><hr></p>

<p><h4><?php echo $this->_tpl_vars['userlabel']; ?>
 Honeycomb Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 Honeycomb Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/honeycomb/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['honeycomb_count']; ?>
 Active Buzz Members in <?php echo $this->_tpl_vars['userlabel']; ?>
 Honeycomb.</td></tr>
<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b><?php echo $this->_tpl_vars['userlabel']; ?>
 Honeycomb Membership</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/honeycomb_membership/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['userlabel']; ?>
 Account is in <?php echo $this->_tpl_vars['me_honeycomb_count']; ?>
 Buzz Members' Honeycombs.</td></tr>
</table></p>


 Temporarily Disabling Commission Reporting
<p><hr></p>
<p><h4><?php echo $this->_tpl_vars['userlabel']; ?>
 Commission Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b>Commissions Paid in Last 6 Months</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/payer_commissions_paid/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['paid_count']; ?>
 Referred Purchases resulted in <?php echo $this->_tpl_vars['paid_amount']; ?>
 paid in Commissions.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Open Commissions To Be Paid</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/payer_commissions_pending/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['pending_paid_count']; ?>
 Commissions are due to be paid by you totalling <?php echo $this->_tpl_vars['pending_paid_amount']; ?>
.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Commissions Received in Last 6 Months</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/payee_commissions_paid/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['received_count']; ?>
 Referrals resulted in <?php echo $this->_tpl_vars['received_amount']; ?>
 received in Commissions.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Commissions To Be Received</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/<?php echo $this->_tpl_vars['user']; ?>
/payee_commissions_pending/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><?php echo $this->_tpl_vars['pending_received_count']; ?>
 Commissions totalling <?php echo $this->_tpl_vars['pending_received_amount']; ?>
 pending Seller payment and Purchase clearing.</td></tr>
</table></p>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>