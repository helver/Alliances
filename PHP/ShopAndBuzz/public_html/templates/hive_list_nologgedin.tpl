{include file="header.tpl" title=foo}

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}
<h2>{$userlabel} Hive {$title_string}</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>
<table border="0" width="90%" cellpadding="5">
{assign var=t_list value="hive"}
{assign var=list_label value="Hive"}
{section name=friend loop=$hive}
	{assign var=thisuser value=$hive[friend].user}
	{assign var=reco value=$hive[friend].reco}
	<tr><td class="whitetext"><a href="/users/{$thisuser}/">{$thisuser}</a></td></tr>
{sectionelse}
    <tr><td class="whitetext"><h4>No one in {$userlabel} {$list_label} {$title_string}.</h4></td></tr>
{/section}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
