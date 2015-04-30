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
<tr align=left valign=top><td>

<table border="0">
{if $user != $me_user}
	{assign var=thisuser value=$user}
	{assign var=reco value=$me_user_obj->CheckMyReco($user)}
	<tr align=left valign=top>{include file="display_user_item.tpl"}</tr>
	<tr align=left valign=top><td><br><br></td></tr>
{/if}

{if $user_obj->isSeller()}
{if $user_obj->isEbayPowerSeller()}
<table border="0">
{if $has_seller_profile}
<tr align=left valign=top><td class="whitetext"><b>{$userlabel} Main Category of Items:</b> {$seller_profile.category}.</td></tr>
<tr align=left valign=top><td class="whitetext"><b>Average Rating From Shop and Buzz Members:</b> {$myAvgRating}</tr></td>

{assign var=powerSeller value=$user_obj->GetEbayPowerSeller()}
<tr align=left valign=top><td class="whitetext">{$userlabel} eBay Power Seller Level is {$powerSeller}.</td></tr>

<tr align=left valign=top><td class="whitetext"><br><b>Members Who Have Recommended Me:</b> (<a href="/users/{$user}/recommended_by/">View All</a>)</td></tr>
{section name=friend loop=$my_recos}
  <tr align=left valign=top><td class="whitetext">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="../{$my_recos[friend].name}/recommendations/{$user}/">{$my_recos[friend].name}</a></td></tr> 
{sectionelse}
    <tr align=left valign=top><td class="whitetext">No one has recommended me.</td></tr>
{/section}

<tr align=left valign=top><td class="whitetext"><br><b>Seller Description:</b><br>{$seller_profile.description}</td></tr>

<tr align=left valign=top><td class="whitetext"><br><b>Commission Schedule:</b><br>{$user_obj->getCommScheduleDesc(2)}</td></tr>

<tr align=left valign=top><td align="center"><br>{include file="display_10_seller_items.tpl"}</td></tr>
{/if}
{/if}
{else}
{if $user == $me_user}
<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;</td><td nowrap class="whitetext"><a href="/users/{$user}/seller_profile/">Register As A Seller</a></td></tr>
{/if}
{/if}

{if $user == $me_user}
        <tr align=left valign=top><td><br><br><a href="/users/{$user}/inviteothers/">Invite Others To Shop and Buzz</a>
</td></tr>
{/if}
</table></p>

<p class="whitetext">
{assign var=t_list value="hive"}
{assign var=list_label value="Hive"}
{assign var=first value=1}
<table border="0" width="90%" cellpadding="5">
<tr align=left valign=top><td width="310" valign="middle" rowspan="{$hive_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-hive.jpg" title="{$userlabel} Hive" alt="{$userlabel} Hive"></a></td>
{section name=friend loop=$random_from_hive}
	{assign var=thisuser value=$random_from_hive[friend].user}
	{assign var=reco value=$random_from_hive[friend].reco}
	{if $first == 0}<tr align=left valign=top>{/if}
	{assign var=first value=0}
	{include file="display_user_item.tpl"}</tr>
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
<tr align=left valign=top><td width="310" valign="middle" rowspan="{$honeycomb_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-honeycomb.jpg" title="{$userlabel} {$list_label}" alt="{$userlabel} {$list_label}"></a></td>
{section name=seller loop=$random_from_honeycomb}
	{assign var=thisuser value=$random_from_honeycomb[seller].user}
	{assign var=reco value=$random_from_honeycomb[seller].reco}
	{if $first == 0}<tr align=left valign=top>{/if}
	{assign var=first value=0}
	{include file="display_user_item.tpl"}</tr>
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
<tr align=left valign=top><td width="310" valign="middle" rowspan="{$news_size}" class="whitetext"><a href="/users/{$user}/{$t_list}/"><img border="0" src="/thematics/web-headline-news.jpg" title="{$userlabel} {$list_label}" alt="{$userlabel} {$list_label}"></a></td>
{section name=recommend loop=$random_from_reco}
	{assign var=thisuser value=$random_from_reco[recommend].user}
	{assign var=reco value=$random_from_reco[recommend].reco}
	{if $first == 0}<tr align=left valign=top>{else}<td class="whitetext">Recently Recommended<br><hr></td></tr><tr align=left valign=top>{/if}
	{assign var=first value=0}
	{include file="display_user_item.tpl"}</tr>
{/section}

{if $first == 0}<tr align=left valign=top>{/if}
{assign var=first value=0}
<td class="whitetext"><h4>Buzz Updates</h4><hr></td></tr>
{section name=item loop=$latest_updates}
    <tr align=left valign=top><td class="whitetext">{$latest_updates[item]}</a></td></tr>
{/section}

</table></dd>


</tr></table>
</td></tr></table>

{include file="footer.tpl"}
