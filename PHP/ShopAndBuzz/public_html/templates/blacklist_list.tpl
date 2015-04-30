{include file="header.tpl" title=foo}

<h2>Member Blacklist</h2>

<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<p class="whitetext">
<tr><th>&nbsp;</th><th class="whitetext">Name</th><th class="whitetext">Email</th></tr>

{section name=black loop=$blacklist}
<tr><td><a href="#" onClick="do_delete('/users/{$user}/blacklist/{$blacklist[black].name}/');">Remove</a></td><td class="whitetext">{$blacklist[black].name}</td><td class="whitetext">{$blacklist[black].email}</td></tr>
{sectionelse}
	<tr><td align="center" colspan="5" class="whitetext">No members blacklisted.</td></tr>
{/section}
</p>
</table>


{include file="footer.tpl"}
