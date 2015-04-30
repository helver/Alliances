{include file="header.tpl" title=foo}

<p><br><br><h2>Please enter/update your seller information below</h2></p>

<form action="/handle_seller_signup.php" method="POST">
<table border="0">
<tr><td align="right">Ebay Member Name:</td><td><input type="text" name="name" size="25" maxlength="150"></td></tr>
<tr><td align="right">Feedback:</td><td><input type="text" name="feedback" size="25" maxlength="80"></td></tr>
<tr><td align="right">Positive Percentage:</td><td><input type="text" name="positive" size="25" maxlength="80"></td></tr>
<tr><td colspan="2" align="center"><input type="checkbox" name="powerseller" value="1
">: Are you a powerseller?</td></tr>

<tr><td align="right">Paypal:</td><td><input type="text" name="paypal" size="25" maxlength="80"></td></tr>



<tr><td colspan="2" align="center"><input type="submit" value="Register As A Seller"></td></tr>
</table>
</form>



{include file="footer.tpl"}
