{include file="header.tpl" title=foo}

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}
<h2>{$userlabel} Honeycomb {$title_string}</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>
<table border="0" width="90%" cellpadding="5">
{assign var=t_list value="honeycomb"}
{assign var=list_label value="Honeycomb"}
{section name=friend loop=$honeycomb}
	{assign var=thisuser value=$honeycomb[friend].user}
	{assign var=reco value=$honeycomb[friend].reco}
	<tr><td class="whitetext"><a href="/users/{$thisuser}/">{$thisuser}</a></td></tr>
{sectionelse}
    <tr><td class="whitetext"><h4>No one in {$userlabel} {$list_label} {$title_string}.</h4></td></tr>
{/section}
</table>


</td></tr></table>
</td></tr></table>


{include file="footer.tpl"}
