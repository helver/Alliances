<?php /* Smarty version 2.6.16, created on 2007-06-11 08:33:17
         compiled from thematics_admin.tpl */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>

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
<?php unset($this->_sections['tfile']);
$this->_sections['tfile']['name'] = 'tfile';
$this->_sections['tfile']['loop'] = is_array($_loop=$this->_tpl_vars['image_files']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['tfile']['show'] = true;
$this->_sections['tfile']['max'] = $this->_sections['tfile']['loop'];
$this->_sections['tfile']['step'] = 1;
$this->_sections['tfile']['start'] = $this->_sections['tfile']['step'] > 0 ? 0 : $this->_sections['tfile']['loop']-1;
if ($this->_sections['tfile']['show']) {
    $this->_sections['tfile']['total'] = $this->_sections['tfile']['loop'];
    if ($this->_sections['tfile']['total'] == 0)
        $this->_sections['tfile']['show'] = false;
} else
    $this->_sections['tfile']['total'] = 0;
if ($this->_sections['tfile']['show']):

            for ($this->_sections['tfile']['index'] = $this->_sections['tfile']['start'], $this->_sections['tfile']['iteration'] = 1;
                 $this->_sections['tfile']['iteration'] <= $this->_sections['tfile']['total'];
                 $this->_sections['tfile']['index'] += $this->_sections['tfile']['step'], $this->_sections['tfile']['iteration']++):
$this->_sections['tfile']['rownum'] = $this->_sections['tfile']['iteration'];
$this->_sections['tfile']['index_prev'] = $this->_sections['tfile']['index'] - $this->_sections['tfile']['step'];
$this->_sections['tfile']['index_next'] = $this->_sections['tfile']['index'] + $this->_sections['tfile']['step'];
$this->_sections['tfile']['first']      = ($this->_sections['tfile']['iteration'] == 1);
$this->_sections['tfile']['last']       = ($this->_sections['tfile']['iteration'] == $this->_sections['tfile']['total']);
?>
<option value="<?php echo $this->_tpl_vars['image_files'][$this->_sections['tfile']['index']]['filename']; ?>
"><?php echo $this->_tpl_vars['image_files'][$this->_sections['tfile']['index']]['display']; ?>
</option>
<?php endfor; endif; ?>
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
<?php unset($this->_sections['tfile']);
$this->_sections['tfile']['name'] = 'tfile';
$this->_sections['tfile']['loop'] = is_array($_loop=$this->_tpl_vars['css_files']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['tfile']['show'] = true;
$this->_sections['tfile']['max'] = $this->_sections['tfile']['loop'];
$this->_sections['tfile']['step'] = 1;
$this->_sections['tfile']['start'] = $this->_sections['tfile']['step'] > 0 ? 0 : $this->_sections['tfile']['loop']-1;
if ($this->_sections['tfile']['show']) {
    $this->_sections['tfile']['total'] = $this->_sections['tfile']['loop'];
    if ($this->_sections['tfile']['total'] == 0)
        $this->_sections['tfile']['show'] = false;
} else
    $this->_sections['tfile']['total'] = 0;
if ($this->_sections['tfile']['show']):

            for ($this->_sections['tfile']['index'] = $this->_sections['tfile']['start'], $this->_sections['tfile']['iteration'] = 1;
                 $this->_sections['tfile']['iteration'] <= $this->_sections['tfile']['total'];
                 $this->_sections['tfile']['index'] += $this->_sections['tfile']['step'], $this->_sections['tfile']['iteration']++):
$this->_sections['tfile']['rownum'] = $this->_sections['tfile']['iteration'];
$this->_sections['tfile']['index_prev'] = $this->_sections['tfile']['index'] - $this->_sections['tfile']['step'];
$this->_sections['tfile']['index_next'] = $this->_sections['tfile']['index'] + $this->_sections['tfile']['step'];
$this->_sections['tfile']['first']      = ($this->_sections['tfile']['iteration'] == 1);
$this->_sections['tfile']['last']       = ($this->_sections['tfile']['iteration'] == $this->_sections['tfile']['total']);
?>
<option value="<?php echo $this->_tpl_vars['css_files'][$this->_sections['tfile']['index']]['filename']; ?>
"><?php echo $this->_tpl_vars['css_files'][$this->_sections['tfile']['index']]['display']; ?>
</option>
<?php endfor; endif; ?>
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
<?php unset($this->_sections['tfile']);
$this->_sections['tfile']['name'] = 'tfile';
$this->_sections['tfile']['loop'] = is_array($_loop=$this->_tpl_vars['js_files']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['tfile']['show'] = true;
$this->_sections['tfile']['max'] = $this->_sections['tfile']['loop'];
$this->_sections['tfile']['step'] = 1;
$this->_sections['tfile']['start'] = $this->_sections['tfile']['step'] > 0 ? 0 : $this->_sections['tfile']['loop']-1;
if ($this->_sections['tfile']['show']) {
    $this->_sections['tfile']['total'] = $this->_sections['tfile']['loop'];
    if ($this->_sections['tfile']['total'] == 0)
        $this->_sections['tfile']['show'] = false;
} else
    $this->_sections['tfile']['total'] = 0;
if ($this->_sections['tfile']['show']):

            for ($this->_sections['tfile']['index'] = $this->_sections['tfile']['start'], $this->_sections['tfile']['iteration'] = 1;
                 $this->_sections['tfile']['iteration'] <= $this->_sections['tfile']['total'];
                 $this->_sections['tfile']['index'] += $this->_sections['tfile']['step'], $this->_sections['tfile']['iteration']++):
$this->_sections['tfile']['rownum'] = $this->_sections['tfile']['iteration'];
$this->_sections['tfile']['index_prev'] = $this->_sections['tfile']['index'] - $this->_sections['tfile']['step'];
$this->_sections['tfile']['index_next'] = $this->_sections['tfile']['index'] + $this->_sections['tfile']['step'];
$this->_sections['tfile']['first']      = ($this->_sections['tfile']['iteration'] == 1);
$this->_sections['tfile']['last']       = ($this->_sections['tfile']['iteration'] == $this->_sections['tfile']['total']);
?>
<option value="<?php echo $this->_tpl_vars['js_files'][$this->_sections['tfile']['index']]['filename']; ?>
"><?php echo $this->_tpl_vars['js_files'][$this->_sections['tfile']['index']]['display']; ?>
</option>
<?php endfor; endif; ?>
</select></td>
<td valign="middle"><input type="button" value="View File" onClick="window.open('/thematics/' + this.form.js_file.options[this.form.js_file.selectedIndex].value, 'viewsrc', 'width=500,height=400,scrollbars=1');"></td>
</tr>
<tr><td colspan="2"><input type="file" name="uploadjsfile"></td></tr>
<tr><td><input type="button" value="Upload New JavaScript File" onClick="this.form.op.value='new'; this.form.submit();"></td><td><input type="button" value="Upload Replacement JavaScript File" onClick="this.form.op.value='replace'; this.form.submit();"></td></tr>
</table>
</form>

</td></tr></table>
</td></tr></table>

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>