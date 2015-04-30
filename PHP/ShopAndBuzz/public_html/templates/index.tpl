
{include file="header.tpl" title=foo}

<h2>Welcome to Shop And Buzz</h2>

{if $error_message != ""}<p class="errortext"><b>{$error_message}</b></p>{/if}

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>{include file="display_random_sellers.tpl"}</td><td valign="top" class="whitetext">

Shop And Buzz (S&amp;B) is a ground-breaking new system that gives happy eBay buyers discounts 
and/or commissions for buying from the same seller again or recommending a favorite eBay seller to 
friends.

<ul>
  <li>Sellers can choose any discount or commission structure, and let the system run itself. 
      S&amp;B even sends 1099s to buzzing buyers who earn enough commissions here. 
      <b>Let S&amp;B and your buyers do all the work!</b>
  <li>Buyers can join for free, and create a "Hive" of friends and a "Honeycomb" of their favorite sellers.
</ul>

To learn more, or to <a href="/signup/">sign up</a>, read <a href="/about/buzz_for_sellers/">Buzz For Sellers</a> or <a href="/about/buzz_for_buyers/">Buzz For Buyers</a>, whichever applies to you!<br><br>

Already have an account here?  Login Here: <a href="/login/">Login</a><br><br>

Want to look around?  Search For Sellers: <a href="/sellers/">Seller Search</a><br>



</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}

