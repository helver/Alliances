{include file="header.tpl" title=foo}

<h2>Shop and Buzz Sellers</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

{$filter_widgets}

<p class="whitetext">All Sellers or Sellers Matching Your Query:</p>

<p class="whitetext">
{assign var=t_list value="hive"}
{assign var=list_label value="Sellers"}
{assign var=first value=1}
<table border="0" cellspacing="8" width="90%" cellpadding="5">
<tr>
  <th nowrap class="whitetext" align="left">Seller Name</th>
  <th class="whitetext" align="left">Seller Category</th>
  <th class="whitetext" align="left">Open Items</th>
</tr>
{section name=friend loop=$sellers}
	{assign var=thisuser value=$sellers[friend].user}
	{assign var=reco value=$sellers[friend].reco}
	{assign var=ebay_username value=$sellers[friend].ebay_username}
	{assign var=userlabel value="$thisuser's"}
	{if $first == 0}<tr>{/if}
	{assign var=first value=0}
	{include file="display_user_item.tpl"}
	<td nowrap class="whitetext" valign="top" align="left"><a href="/sellers/?cat={$sellers[friend].category_id}">{$sellers[friend].category}</a></td>
    <td nowrap valign="top" class="whitetext">{include file="display_link_to_all_seller_items.tpl"}</td></tr>
    <tr><td colspan="3" class="whitetext" valign="top" align="left">{$sellers[friend].seller_desc}</td></tr height="4"><td colspan="3"><hr></td>
	</tr>
{sectionelse}
    <td class="whitetext"><h4>Nothing matched your query.</h4></td></tr>
{/section}
</table></p>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
