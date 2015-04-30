{include file="header.tpl" title=foo}

<h2>Get Stung By The Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">View the <a href="/customerservice/">Terms Of Service and Privacy Policy</a></p>

<p class="whitetext">When you're done, fill out this form, then click the button below to create your member account.</p>

{if $error_text}
<p class="errortext">Ooops!  We couldn't create an account for you for the following reasons:<br>
{$error_text}
</p>
{/if}

<form method="POST" action="/signup/">
<table border="0">
<tr><td class="whitetext" align="left">Member Name:</td><td><input type="text" name="username" value="{$username}"></td></tr>
<tr><td class="whitetext" align="left">Password:</td><td><input type="password" name="newpass"></td></tr>
<tr><td class="whitetext" align="left">Real Name:</td><td><input type="text" name="name" value="{$name}"></td></tr>
<tr><td class="whitetext" align="left">Email Address:</td><td><input type="text" name="email" value="{$email}"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<!-- <tr><td class="whitetext" align="left">eBay Member Name:</td><td><input type="text" name="ebay_username" value="{$ebay_username}"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr> -->
<tr><td class="whitetext" align="left">Paypal Address:</td><td><input type="text" name="paypal" value="{$paypal}"></td></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td class="whitetext" colspan="2" align="center"><input type="submit" value="Create Account"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
