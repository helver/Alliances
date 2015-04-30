{include file="header.tpl" title=foo}
{* user: {$user}<br>
me_user: {$me_user}<br>
me_user_obj: {$me_user_obj->getDisplayName()}
*} 

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}
<h2>{$userlabel} Shop And Buzz Dashboard</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

{*
<p class="whitetext">
<table border="0">

<tr><td class="whitetext"><br><b>Seller Description:</b><br>{$seller_profile.description}</td></tr>
</table>
*}

<p class="whitetext">
{assign var=t_list value="hive"}
{assign var=list_label value="Hive"}
{assign var=first value=1}
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="{$hive_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-hive.jpg" title="{$userlabel} Hive" alt="{$userlabel} Hive"></a></td>
{section name=friend loop=$random_from_hive}
	{assign var=thisuser value=$random_from_hive[friend].user}
	<td class="whitetext"><a href="/users/{$thisuser}/">{$thisuser}</a></td>
	{*{assign var=reco value=$random_from_hive[friend].reco}*}
	{if $first == 0}<tr>{/if}
	{assign var=first value=0}
	{*{include file="display_user_item.tpl"}</tr>*}
{sectionelse}
    <td class="whitetext"><h4>No one in {$userlabel} {$list_label}.</h4></td></tr>
{/section}
</table></p>

<br>

<p class="whitetext">
{assign var=t_list value="honeycomb"}
{assign var=list_label value="Honeycomb"}
{assign var=first value=1}
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="{$honeycomb_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-honeycomb.jpg" title="{$userlabel} {$list_label}" alt="{$userlabel} {$list_label}"></a></td>
{section name=seller loop=$random_from_honeycomb}
	{assign var=thisuser value=$random_from_honeycomb[seller].user}
	<td class="whitetext"><a href="/users/{$thisuser}/">{$thisuser}</a></td>
	{*{assign var=reco value=$random_from_honeycomb[seller].reco}*}
	{if $first == 0}<tr>{/if}
	{assign var=first value=0}
	{*{include file="display_user_item.tpl"}</tr>*}
{sectionelse}
    <td class="whitetext"><h4>No one in {$userlabel} {$list_label}.</h4></td></tr>
{/section}
</table></p>


<br>

<p class="whitetext">
{assign var=t_list value="recommendations"}
{assign var=list_label value="Recommendations"}
{assign var=first value=1}
<table border="0" width="90%" cellpadding="5">
<tr><td width="310" valign="middle" rowspan="{$news_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-news.jpg" title="{$userlabel} {$list_label}" alt="{$userlabel} {$list_label}"></a></td>

{section name=recommend loop=$random_from_reco}
	{assign var=thisuser value=$random_from_reco[recommend].user}
	{assign var=reco value=$random_from_reco[recommend].reco}
	{if $first == 0}<tr>{else}<td class="whitetext">Recently Recommended<br><hr></td></tr><tr>{/if}
	{assign var=first value=0}
	<td class="whitetext"><a href="/users/{$thisuser}/">{$thisuser}</a></td>
	{*{include file="display_user_item.tpl"}</tr>*}
{/section}

{if $first == 0}<tr>{/if}
{assign var=first value=0}
<td class="whitetext">Buzz Updates<br><hr></td></tr>
{section name=item loop=$latest_updates}
    <tr><td class="whitetext">{$latest_updates[item]}</a></td></tr>
{/section}


</table></dd>


</tr></table></p>

</td></tr></table>
</td></tr></table>
{include file="footer.tpl"}
