{include file="header.tpl" title=foo}

<h2>Generate Your Own Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">

{if $error_message != ""}<p class="errortext"><b>{$error_message}</b></p>{/if}

{if $broken_seller_profile}
<p class="errortext">Hi, {$user}! You're marked as a seller, but we have no S&B subscription
payment on record for you. Your seller account with us will be inactive
until you click the UPdate Seller Profile button below to sign up for our service.</p>
{/if}

Fill Out this form, then click the button below to update your Seller Profile.<br>

<form method="POST" action="/users/{$user}/seller_profile/">
<table border="0">
<tr><td class="whitetext">Seller Category</td><td>{$category_list}</td></tr>
{if $signed_up}
<tr><td class="whitetext">Cancel Seller Account</td><td class="whitetext"><a href="{$paypalURL}?cmd=_subscr-find&alias={$paypalAccount}">Click to Cancel Your Seller Account</a></td></tr>
{/if}
{if !$fee_schedule_id}
<input type="hidden" name="coupon_code" value="{$coupon_code}">
{/if}
<tr><td class="whitetext">Description</td><td><textarea name="description" rows="5" cols="50" wrap="virtual">{$cur_desc}</textarea></td></tr>
<tr><td colspan="2"><input type="submit" value="Update Seller Profile"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
