{include file="header.tpl" title=foo}

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}

<h2>{$userlabel} Member Preferences Page</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>


<h4>Shop & Buzz Member Profile Settings</h4>
<form method="POST" action="/users/{$user}/preferences/">
<table border="0">
<tr><td class="whitetext">Paypal Account Email:</td><td class="whitetext">Current: {$paypal_email}</td><td>Change To: <input type="text" name="paypal_email" value="{$paypal_email}" size="40" maxlength="120"></td></tr>
<tr><td class="whitetext" colspan="3">Member Description:</td></tr>
<tr><td class="whitetext" colspan="3">Current:<br>{$user_desc}</td></tr>
<tr><td class="whitetext" colspan="3">Change To:<br><textarea name="user_desc" rows="5" wrap="virtual" cols="70">{$user_desc}</textarea></td></tr>
<tr><td class="whitetext" colspan="3">&nbsp;</td></tr>
<tr><td class="whitetext" colspan="3"><input type="submit" value="Update Profile"></td></tr>
</table>
</form>


<h4>Email Blacklist</h4>
<table border="0">
{section name=tool loop=$blacklist}
    <tr><td class="whitetext"><form method="DELETE" action="/users/{$user}/blacklist/{$blacklist[tool].user}/"><input type="submit" value="Remove"> <a href="/users/{$blacklist[tool].user}/">{$blacklist[tool].user}</a></form></td></tr>
{sectionelse}
    <tr><td class="whitetext"><h4>No one in {$userlabel} email blacklist yet.</h4></td></tr>
{/section}
</table>


<h4>Email Delivery Schedule</h4>
<table border="0">
<tr><td class="whitetext">Current: {$delivery_schedule}</td></tr>
<tr><td class="whitetext">Change To:</td></tr>
{section name=sched loop=$delivery_schedules}
    <tr><td class="whitetext"><form method="POST" action="/users/{$user}/emaildelivery/{$delivery_schedules[sched].id}/"><input type="Submit" value="Choose"> {$delivery_schedules[sched].name}</a></form></td></tr>
{sectionelse}
    <tr><td class="whitetext"><h4>This is an error - No available email delivery schedules..</h4></td></tr>
{/section}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
