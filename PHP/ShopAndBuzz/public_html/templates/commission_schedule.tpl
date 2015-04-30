{include file="header.tpl" title=foo} 

<h2>{$user}'s Commission Schedules</h2> 

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856"> 
<tr align="center" valign="top"> 
<td> 
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850"> 
<tr><td> 

<form method="POST" action="/users/{$user}/commission_schedule/"> 
<input type="hidden" name="comm_level" value="2"> 
<table border="0"> 
<tr><td class="whitetext" align="center" colspan="2"><h4>Commissions to Your Buzzing Buyers</h4></td></tr> 

<tr><td class="whitetext" align="right"><b>Commission Type:</b></td><td>{$referer_pay_type}</td></tr> 
<tr><td class="whitetext" align="right"><b>Commission Amount:</b></td><td>{$referer_amount} (leave out $ or %)</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, a 2% commission (use percent) or a flat $3 commission (use flatrate).</td></tr>
<tr><td class="whitetext" align="right"><b>Limit:</b></td><td>{$referer_max_limit}</td></tr> 
<tr><td class="whitetext" align="right"><b>Limit Type:</b></td><td>{$referer_limit_type}</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, give these buzzing people this commission for their referred buyers' first <i>3 purchases</i> with you,<br>&nbsp; &nbsp; or the commission is available to them for 20 days from the time they make the referral.</td></tr>
<tr><td class="whitetext" align="right"><b>Minimum Purchase Amount:</b></td><td class="whitetext">${$referer_min_pay_threshold}</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, give these buzzing people this commission if the referred sale is over $50.</td></tr>
<tr><td class="whitetext" align="right"><b>Maximum Payment Amount:</b></td><td class="whitetext">${$referer_max_amount}</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, do not pay a commission for one purchase where the commission would be over $20.</td></tr>
<tr><td colspan="2"><input type="submit" value="Update Commission Schedule for Your Buzzing Buyers"></td></tr> 
</table> 
</form><br><hr>

<form method="POST" action="/users/{$user}/commission_schedule/"> 
<input type="hidden" name="comm_level" value="1"> 
<table border="0"> 
<tr><td class="whitetext" align="center" colspan="2"><h4>Commissions to Referred Buyers</h4></td></tr>  
<tr><td class="whitetext" align="right"><b>Commission Type:</b></td><td>{$buyer_pay_type}</td></tr> 
<tr><td class="whitetext" align="right"><b>Commission Amount:</b></td><td>{$buyer_amount} (leave out $ or %)</td></tr>
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, a 2% commission (use percent) or a flat $3 commission (use flatrate).</td></tr>
<tr><td class="whitetext" align="right"><b>Limit:</b></td><td>{$buyer_max_limit}</td></tr>  
<tr><td class="whitetext" align="right"><b>Limit Type:</b></td><td>{$buyer_limit_type}</td></tr>
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, give these buyers this commission for their first <i>3 purchases</i> with you,<br>or the commission is available to them for 20 days from the time their friend makes the referral.</td></tr>

<tr><td class="whitetext" align="right"><b>Minimum Purchase Amount:</b></td><td class="whitetext">${$buyer_min_pay_threshold}</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, give these buyers this commission if the referred sale is over $50.</td></tr>
<tr><td class="whitetext" align="right"><b>Maximum Payment Amount:</b></td><td class="whitetext">${$buyer_max_amount}</td></tr> 
<tr><td class="whitetext" colspan=2>&nbsp; &nbsp; For example, do not pay a commission for one purchase where the commission would be over $20.</td></tr>
<tr><td colspan="2"><input type="submit" value="Update Commission Schedule for Referred Buyers"></td></tr> 
</table> 
</form> 

</td></tr></table> 
</td></tr></table> 

{include file="footer.tpl"} 
