{include file="header.tpl" title=foo}

<h2>EmailTemplate Admin</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td class="whitetext">

Upload New Version:<br>
<form method="POST" enctype="multipart/form-data" action="/admin/emails/{$template}/">
<input type="file" name="template_contents">
<input type="submit" value="Upload New Template Contents">
</form>
<br>

Versions of the {$template} Template:<br>

<table border="0">
{section name=tfile loop=$template_files}
<form method="GET" action="/admin/emails/{$template_files[tfile].uri}">
<tr>
  <td valign="top"><input type="submit" value="Download This Version" /></td>
  <td valign="top"><input type="button" value="Make This Version Current" onClick="this.form.method='POST'; this.form.submit();"/></td>
  <td valign="top" class="whitetext">{$template}</td>
  <td valign="top" class="whitetext">@ {$template_files[tfile].date}</td>
</tr>
</form>
{/section}
</table>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
