{include file="header.tpl" title=foo}

<h2>Template Admin</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<h4>Templates Available To Edit<h4>

<table border="0">
{section name=tfile loop=$template_files}
<form method="GET" action="/admin/files/{$template_files[tfile]}/">
<tr>
  <td valign="top"><input type="button" value="Edit Template" onClick="this.form.method='GET'; this.form.submit();"/></td>
  <td valign="top" class="whitetext">{$template_files[tfile]}</td>
</tr>
</form>
{/section}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
