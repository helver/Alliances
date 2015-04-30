{include file="header.tpl" title=foo}

<h2>Get Your Buzz On!</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">

{if $fee_sched == 1}
The coupon code you entered was not recognized as a valid, current coupon code.  This could have 
happened for several reasons including: the coupon has expired; the coupon code was mis-typed; you
intentionally left the coupon code field blank.  You have been temporarily assigned the Default 
coupon code.  If you want to continue with your seller signup using the defult coupon code, 
select the "Accept Coupon Code" button below.  If you want to try to enter your coupon code
again, press the "Decline Coupon Code" button and retry your entry.<br><br>
{/if}

Your coupon code yields the following benefits:<Br>
{$months_free} months free.<br>
${$monthly_rate}/mo after the free period expires.<br>

<p class="whitetext">
<form method="POST" action="/users/{$user}/couponcode/post/">
<input type="hidden" name="coupon_code" value="{$coupon_code}">
<br><input type="submit" value="Accept Coupon Code">
</form></p>

<p class="whitetext">
<form method="GET" action="/users/{$user}/couponcode/">
<input type="submit" value="Decline Coupon Code">
</form></p>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
