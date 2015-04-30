{include file="header.tpl" title=foo}

<h2>Get Stung By The Buzz!</h2>

Momentarily, an email will arrive in the INBOX of the email address you 
used to create this account: {$email}.  That email will contain a confirmation
link that you will need to click on in order to confirm the account creation
and to finalize the creation of this account.<br>

{if $debug >= 1}
Debugging Link: <a href="/signup/confirmemail/thisismytoken/">Click Here</a><br>
{/if}

{include file="footer.tpl"}
