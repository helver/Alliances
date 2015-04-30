{include file="header.tpl" title=foo}

<h2>Admin Functions</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<p class="whitetext"><a href="/admin/files/">Click Here</a> to administer templates.</p>
<p class="whitetext"><a href="/admin/emails/">Click Here</a> to administer email bodies.</p>
<p class="whitetext"><a href="/admin/thematics/">Click Here</a> to administer theme elements.</p>

<h4>Member Admin Section</h2>

<p class="whitetext"><a href="/admin/users/">Click Here</a> to administer member data.</p>

<h4>Table Admin Section</h2>

{section name=table loop=$tablefields}
{$tablefields[table]}
{/section}

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}

