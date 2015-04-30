{include file="header.tpl" title=foo}

<h2>Welcome To Shop & Buzz!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext">You're Done!  Your account is now confirmed.  From here, you should probably go ahead
and visit your profile page:</p>

<p class="whitetext"><a href="/users/{$user}/">Your Profile</a></p>
<p class="whitetext"><a href="/users/{$user}/private/">Your Account</a></p>

{if !$user_obj->IsSeller()}
<p class="whitetext">To register as a seller click here: <a href="/users/{$user}/seller_profile/">Register As A Seller</a>.</p>
{/if}

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
