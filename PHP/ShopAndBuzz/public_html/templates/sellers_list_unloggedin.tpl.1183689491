{include file="header.tpl" title=foo}

<h2>Shop and Buzz Sellers</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

{$filter_widgets}

<p class="whitetext">All Sellers or Sellers Matching Your Query:</p>

<table border="0" cellspacing="8" width="90%">
{if $sellers}
<tr>
  <th class="whitetext" align="left">Seller Name</th>
  <th class="whitetext" align="left">Seller Category</th>
  <th class="whitetext" align="left">Open Items</th>
</tr>

{section name=seller loop=$sellers}
{assign var=thisuser value=$sellers[seller].user}
{assign var=ebay_username value=$sellers[seller].ebay_username}
{assign var=userlabel value="$thisuser's"}
<tr>
  <td class="whitetext" valign="top" nowrap align="left"><a href="/users/{$sellers[seller].user}/">{$sellers[seller].user}</a></td>
  <td class="whitetext" valign="top" nowrap align="left"><a href="/sellers/?cat={$sellers[seller].category_id}">{$sellers[seller].category}</a></td>
  <td nowrap valign="top" class="whitetext">{include file="display_link_to_all_seller_items.tpl"}</td></tr>
  <tr><td colspan="3" class="whitetext" valign="top" align="left">{$sellers[seller].seller_desc}</td></tr><tr height="4"><td colspan="3"><hr></td>
</tr>
{/section}
{else}
<tr><td class="whitetext">Nothing matched your query.</td></tr>
{/if}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
