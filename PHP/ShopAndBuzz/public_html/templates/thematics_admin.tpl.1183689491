{include file="header.tpl" title=foo}

<h2>Thematics Admin</h2>

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856">
<tr align="center" valign="top">
<td>
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850">
<tr><td>

<h4>Images:</h4>
<p class="whitetext">To include images posted here, create the following HTML element:<br> <i>&lt;img src="/thematics/XXX.gif"&gt;</i></p>

<form method="POST" enctype="multipart/form-data" action="/admin/thematics/">
<input type="hidden" name="op" value="">
<table border="0">
<tr><td><select size="8" name="image_file" onChange="document.getElementById('dispimage').src='/thematics/'+this.options[this.selectedIndex].value;">
{section name=tfile loop=$image_files}
<option value="{$image_files[tfile].filename}">{$image_files[tfile].display}</option>
{/section}
</select></td>
<td valign="middle" align="center"><img id="dispimage" src="/thematics/black.gif"></td>
</tr>
<tr><td colspan="2"><input type="file" name="uploadimgfile"></td></tr>
<tr><td><input type="button" value="Upload New Image" onClick="this.form.op.value='new'; this.form.submit();"></td><td><input type="button" value="Upload Replacement Image" onClick="this.form.op.value='replace'; this.form.submit();"></td></tr>
</table>
</form>

<hr>
<h4>CSS Files:</h4>
<p class="whitetext">To include the CSS files posted here, create the following HTML element:<br> <i>&lt;link rel="stylesheet" type="text/css" media="all" src="/thematics/XXX.css"&gt;</i></p>

<form method="POST" enctype="multipart/form-data" action="/admin/thematics/">
<input type="hidden" name="op" value="">
<table border="0">
<tr><td><select size="4" name="css_file">
{section name=tfile loop=$css_files}
<option value="{$css_files[tfile].filename}">{$css_files[tfile].display}</option>
{/section}
</select></td>
<td valign="middle"><input type="button" value="View File" onClick="window.open('/thematics/' + this.form.css_file.options[this.form.css_file.selectedIndex].value, 'viewsrc', 'width=500,height=400,scrollbars=1');"></td>
</tr>
<tr><td colspan="2"><input type="file" name="uploadcssfile"></td></tr>
<tr><td><input type="button" value="Upload New CSS File" onClick="this.form.op.value='new'; this.form.submit();"></td><td><input type="button" value="Upload Replacement CSS File" onClick="this.form.op.value='replace'; this.form.submit();"></td></tr>
</table>
</form>

<hr>
<h4>JavaScript Files:</h4>
<p class="whitetext">To include the JavaScript files posted here, create the following HTML element:<br> <i>&lt;script type="text/javascript" language="JavaScript src="/thematics/XXX.js"&gt;</i></p>

<form method="POST" enctype="multipart/form-data" action="/admin/thematics/">
<input type="hidden" name="op" value="">
<table border="0">
<tr><td><select size="4" name="js_file">
{section name=tfile loop=$js_files}
<option value="{$js_files[tfile].filename}">{$js_files[tfile].display}</option>
{/section}
</select></td>
<td valign="middle"><input type="button" value="View File" onClick="window.open('/thematics/' + this.form.js_file.options[this.form.js_file.selectedIndex].value, 'viewsrc', 'width=500,height=400,scrollbars=1');"></td>
</tr>
<tr><td colspan="2"><input type="file" name="uploadjsfile"></td></tr>
<tr><td><input type="button" value="Upload New JavaScript File" onClick="this.form.op.value='new'; this.form.submit();"></td><td><input type="button" value="Upload Replacement JavaScript File" onClick="this.form.op.value='replace'; this.form.submit();"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

{include file="footer.tpl"}
