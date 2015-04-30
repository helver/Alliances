{include file="header.tpl" title=foo}

<h2>{$title}</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<table width="70%" border="0" cellspacing="3">
{if $recommendations}
	<tr>
		<th class="whitetext">&nbsp;</th>
		<th class="whitetext" width="30%" align="left">Seller Member Name</th>
		<th class="whitetext" width="10%" align="center">Overall Rating</th>
		<th class="whitetext" width="50%" align="left">Comment</th>
	</tr>
	
	{section name=recommend loop=$recommendations}
	{if $invert}
	  {assign var="xxname" value=$recommendations[recommend].name}
	  {assign var="link" value="/users/$xxname/recommendations/$user"}
	{else}
	  {assign var="link" value=$recommendations[recommend].name}
	{/if}
	  <tr>
		  <td class="whitetext" align="center"><a href="{$link}/">Detail</a></td>
		  <td class="whitetext" align="left">{$recommendations[recommend].name}</td>
		  <td class="whitetext" align="center">{$recommendations[recommend].exp_rating}</td>
		  <td class="whitetext" align="left">{$recommendations[recommend].recommend}</td>
	  </tr>
	{/section}
{else}
	<tr><td class="whitetext" align="center">No Recommendations.</td></tr>
{/if}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
