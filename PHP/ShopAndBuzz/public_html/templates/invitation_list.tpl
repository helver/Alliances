{include file="header.tpl" title=foo}

<h2>Sent Invitations</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext"><a href="/users/{$user}/inviteothers/">Click Here</a> to invite someone new!</p>

<table border="0" cellpadding="6" cellspacing="8" width="850">
<p class="whitetext">
<tr><th>&nbsp;</th><th class="whitetext">Name</th><th class="whitetext">Email</th><th class="whitetext">Date</th><th class="whitetext">Status</tr></tr>

{section name=invite loop=$invitations}
<tr><td><a href="{$invitations[invite].id}/">Detail</a></td><td class="whitetext">{$invitations[invite].name}</td><td class="whitetext">{$invitations[invite].email}</td><td class="whitetext">{$invitations[invite].date}</td><td class="whitetext">{$invitations[invite].status}</td></tr>
{sectionelse}
	<tr><td align="center" colspan="5" class="whitetext">No invitations sent.</td></tr>
{/section}
</p>
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
