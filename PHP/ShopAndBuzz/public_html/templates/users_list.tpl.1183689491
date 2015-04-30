{include file="header.tpl" title=foo}

<h2>Who's Got The Buzz?</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

{$filter_widgets}

{if $error_message != ""}<p class="errortext"><b>{$error_message}</b></p>{/if}

<p class="whitetext">All Members Matching Your Query:</p>

<p class="whitetext">
{assign var=t_list value="hive"}
{assign var=list_label value="Members"}
{assign var=first value=1}

<table border="0" width="90%" cellpadding="5">
{assign var=t_list value="hive"}
{assign var=list_label value="Member List"}
{section name=friend loop=$users}
	{assign var=thisuser value=$users[friend].user}
	{assign var=reco value=$hive[friend].reco}
	<tr style="height=25;">{if $invert}{include file="display_user_membership_item.tpl"}{else}{include file="display_user_item.tpl"}{/if}</tr>
{sectionelse}
    <tr><td class="whitetext"><h4>No one matching that Query.</h4></td></tr>
{/section}
</table>

</td></tr></table>
</td></tr></table>


{include file="footer.tpl"}
