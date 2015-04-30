{include file="header.tpl" title=foo}

{if $user == $me_user}
{assign var=userlabel value="My"}
{/if}
<h2>{$userlabel} Account Page</h2>


<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">Login using the login box in the top right corner of the page.


</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
