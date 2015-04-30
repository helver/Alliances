{include file="header.tpl" title=foo}
<br><br>
<h2>{$user}'s Recommendation of {$recommendation.name}</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<table border="0">
<tr><td class="whitetext" align="right">Recommended By:</td><td class="whitetext"><a href="/users/{$user}/">{$user}</a></td></tr>
<tr><td class="whitetext" align="right">Seller's Member Name:</td><td class="whitetext"><a href="/users/{$recommendation.name}/">{$recommendation.name}</a></td></tr>
<tr><td class="whitetext" align="right">Number of Purchases:</td><td class="whitetext">{$recommendation.num_purchases}</td></tr>
<tr><td class="whitetext" align="right">Speed Rating:</td><td class="whitetext">{$recommendation.speed_rating}</td></tr>
<tr><td class="whitetext" align="right">Expectation Rating:</td><td class="whitetext">{$recommendation.expect_rating}</td></tr>
<tr><td class="whitetext" align="right">Value Rating:</td><td class="whitetext">{$recommendation.value_rating}</td></tr>
<tr><td class="whitetext" align="right">Communication Rating:</td><td class="whitetext">{$recommendation.comm_rating}</td></tr>
<tr><td class="whitetext" align="right">Overal Experience Rating:</td><td class="whitetext">{$recommendation.exp_rating}</td></tr>
<tr><td class="whitetext" align="right">Recommendation:</td><td class="whitetext">{$recommendation.recommend}</td></tr>
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
