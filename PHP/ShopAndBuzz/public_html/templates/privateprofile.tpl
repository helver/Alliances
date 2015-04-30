

{include file="header.tpl" title=foo}

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}
<h2>{$userlabel} Account Page</h2>


<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

{if $error_text != False}
<p class="errortext">Ooops!  We encountered an error trying to process your last request:<Br>
{$error_text}
</p>
{/if}

<h4>{$userlabel} Shop & Buzz Seller Profile</h4>
<p><table border="0">
{if $user_obj->IsSeller()}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Category:</b></td><td class="whitetext">{$seller_profile.category}</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Seller Blurb:</b></td><td class="whitetext">{$seller_profile.description}</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/seller_profile/">Update {$userlabel} Seller Profile</a></td></tr>
</table><br>

<table border="0">
{if $displayMakePayment}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Make Payment:</b></td><td nowrap class="whitetext"><a href="payment/">Pay Invoice</a></td></tr>
{/if}

{if $cs_1_last_update == -1}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Referred Buyers:</b></td><td nowrap class="whitetext">No Commissions to Referred Buyers set.</td></tr>
{else}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Referred Buyers:</b></td><td nowrap class="whitetext">Commission schedule last updated: {$cs_1_last_update}</td></tr>
{/if}
{if $cs_2_last_update == -1}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Your Buzzing Buyers:</b></td><td nowrap class="whitetext">No Commissions to Your Buzzing Buyers set.</td></tr>
{else}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><b>Commissions to Your Buzzing Buyers:</b></td><td nowrap class="whitetext">Commission schedule last updated: {$cs_2_last_update}</td></tr>
{/if}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/commission_schedule/">Update {$userlabel} Commission Schedule</a></td></tr>

{else}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/seller_profile/">Register As A Seller</a></td></tr>

<!--<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext">
<a href="../../../newsellerform.php">Register As A Seller</a></td></tr>-->

{/if}
</table></p>

<p><hr></p>

<h4>Shop and Buzz Search</h4>
<p class="whitetext"><a href="/sellers/">Search For Sellers</a> -- <a href="/users/">Search For Members</a></p>


<h4>{$userlabel} Shop & Buzz Member Profile</h4>
<p class="whitetext"><a href="/users/{$user}/preferences/">Update {$userlabel} Member Profile</a></p>
<p class="whitetext"><a href="/users/{$user}/widgets/">Build Widgets to Promote {$userlabel} Buzz Account</a></p>


<p><h4>Invitation Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b>{$userlabel} Invitation Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/inviteothers/">Send Invite</a>
</td></tr>
<tr>
<td>&nbsp;&nbsp;&nbsp;</td>
<td nowrap class="whitetext"><a href="/users/{$user}/invitations/">View All</a>
<td nowrap class="whitetext">{$invites_count} Invites Sent</td>
</tr>

</table></p>


<p><hr></p>

<p><h4>{$userlabel} eBay Status</h4>

<p><table border="0">
<tr><td>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><b>{$userlabel} eBay Standing:</b></td><td class="whitetext">{$ebay_standing}</td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td class="whitetext"><b>{$userlabel} eBay Seller Status:</b></td><td class="whitetext">{$seller_status}</td></tr>
</table></p>

<p><hr></p>

<p><h4>{$userlabel} Hive Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b>{$userlabel} Hive Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/hive/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$hive_count} Active Buzz Members in {$userlabel} Hive.</td></tr>
<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>{$userlabel} Hive Membership</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/hive_membership/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$userlabel} Account is in {$me_hive_count} Buzz Members' Hives.</td></tr>
</table></p>

<p><hr></p>

<p><h4>{$userlabel} Honeycomb Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b>{$userlabel} Honeycomb Status</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/honeycomb/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$honeycomb_count} Active Buzz Members in {$userlabel} Honeycomb.</td></tr>
<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>{$userlabel} Honeycomb Membership</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/honeycomb_membership/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$userlabel} Account is in {$me_honeycomb_count} Buzz Members' Honeycombs.</td></tr>
</table></p>


 Temporarily Disabling Commission Reporting
<p><hr></p>
<p><h4>{$userlabel} Commission Status</h4>
<table border="0">
<tr><td colspan="3" class="whitetext"><b>Commissions Paid in Last 6 Months</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/payer_commissions_paid/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$paid_count} Referred Purchases resulted in {$paid_amount} paid in Commissions.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Open Commissions To Be Paid</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/payer_commissions_pending/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$pending_paid_count} Commissions are due to be paid by you totalling {$pending_paid_amount}.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Commissions Received in Last 6 Months</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/payee_commissions_paid/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$received_count} Referrals resulted in {$received_amount} received in Commissions.</td></tr>

<tr><td colspan="3" height="3">&nbsp;</td></tr>
<tr><td colspan="3" class="whitetext"><b>Commissions To Be Received</b></td></tr>
<tr><td>&nbsp;&nbsp;&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/payee_commissions_pending/">View All</a>&nbsp;&nbsp;&nbsp;</td><td class="whitetext">{$pending_received_count} Commissions totalling {$pending_received_amount} pending Seller payment and Purchase clearing.</td></tr>
</table></p>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
