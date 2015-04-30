<?php /* Smarty version 2.6.16, created on 2007-08-26 20:06:52
         compiled from widget_tool.tpl */ ?>


<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?> 

<?php if ($this->_tpl_vars['user'] == $this->_tpl_vars['me_user']):  $this->assign('userlabel', 'My');  endif; ?>

<h2><?php echo $this->_tpl_vars['userlabel']; ?>
 Widgets</h2> 

<center><table border="0" bgcolor="#ffffff" cellpadding="3" cellspacing="0" width="856"> 
<tr align="center" valign="top"> 
<td> 
<table border="0" bgcolor="#000000" cellpadding="16" cellspacing="8" width="850"> 
<tr valign=top><td> 

<form method="GET"> 
<input type="hidden" name="comm_level" value="2"> 
<table border="0" cellpadding=0> 
<tr valign=top><td width="40%" class="whitetext" align="center"><h4>Widgets With Text</h4> These are great to drop inside eBay listings! These conform to eBay rules, so you will <b>not</b> get in trouble for adding these to your eBay listing template or individual listings.<br><br></td>
<td width=18 rowspan=2><img src="/thematics/spacer.gif" width="26" height="1" border="0"></td>
    <td class="whitetext" align="center"><h4>Widgets With No Text</h4> These are too big (by eBay rules), so please don't put them in your eBay listings. You can put them on your About Me page, in emails, in your blog, and other places on the web.</td></tr> 

<tr valign=top><td nowrap><p class="whitetext"><b>Choose The Image For Your Widget:</b></p>
  <p class="whitetext"><input type="radio" name="img" value="" onClick="img_name=null; use_text=true; recalc_widget(this.form, '<?php echo $this->_tpl_vars['user']; ?>
');">No Image</p>
<?php unset($this->_sections['img']);
$this->_sections['img']['name'] = 'img';
$this->_sections['img']['loop'] = is_array($_loop=$this->_tpl_vars['text_images']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['img']['show'] = true;
$this->_sections['img']['max'] = $this->_sections['img']['loop'];
$this->_sections['img']['step'] = 1;
$this->_sections['img']['start'] = $this->_sections['img']['step'] > 0 ? 0 : $this->_sections['img']['loop']-1;
if ($this->_sections['img']['show']) {
    $this->_sections['img']['total'] = $this->_sections['img']['loop'];
    if ($this->_sections['img']['total'] == 0)
        $this->_sections['img']['show'] = false;
} else
    $this->_sections['img']['total'] = 0;
if ($this->_sections['img']['show']):

            for ($this->_sections['img']['index'] = $this->_sections['img']['start'], $this->_sections['img']['iteration'] = 1;
                 $this->_sections['img']['iteration'] <= $this->_sections['img']['total'];
                 $this->_sections['img']['index'] += $this->_sections['img']['step'], $this->_sections['img']['iteration']++):
$this->_sections['img']['rownum'] = $this->_sections['img']['iteration'];
$this->_sections['img']['index_prev'] = $this->_sections['img']['index'] - $this->_sections['img']['step'];
$this->_sections['img']['index_next'] = $this->_sections['img']['index'] + $this->_sections['img']['step'];
$this->_sections['img']['first']      = ($this->_sections['img']['iteration'] == 1);
$this->_sections['img']['last']       = ($this->_sections['img']['iteration'] == $this->_sections['img']['total']);
?>
  <p><input type="radio" name="img" value="<?php echo $this->_tpl_vars['text_images'][$this->_sections['img']['index']]; ?>
" onClick="img_name=this.value; use_text=true; recalc_widget(this.form, '<?php echo $this->_tpl_vars['user']; ?>
');"><img src="/thematics/<?php echo $this->_tpl_vars['text_images'][$this->_sections['img']['index']]; ?>
" /></p>
<?php endfor; endif; ?>
<hr>
<p class="whitetext"><b>Choose The Text For Your Widget:</b></p>
<table width="350">
<?php unset($this->_sections['i']);
$this->_sections['i']['name'] = 'i';
$this->_sections['i']['loop'] = is_array($_loop=$this->_tpl_vars['text_text']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['i']['show'] = true;
$this->_sections['i']['max'] = $this->_sections['i']['loop'];
$this->_sections['i']['step'] = 1;
$this->_sections['i']['start'] = $this->_sections['i']['step'] > 0 ? 0 : $this->_sections['i']['loop']-1;
if ($this->_sections['i']['show']) {
    $this->_sections['i']['total'] = $this->_sections['i']['loop'];
    if ($this->_sections['i']['total'] == 0)
        $this->_sections['i']['show'] = false;
} else
    $this->_sections['i']['total'] = 0;
if ($this->_sections['i']['show']):

            for ($this->_sections['i']['index'] = $this->_sections['i']['start'], $this->_sections['i']['iteration'] = 1;
                 $this->_sections['i']['iteration'] <= $this->_sections['i']['total'];
                 $this->_sections['i']['index'] += $this->_sections['i']['step'], $this->_sections['i']['iteration']++):
$this->_sections['i']['rownum'] = $this->_sections['i']['iteration'];
$this->_sections['i']['index_prev'] = $this->_sections['i']['index'] - $this->_sections['i']['step'];
$this->_sections['i']['index_next'] = $this->_sections['i']['index'] + $this->_sections['i']['step'];
$this->_sections['i']['first']      = ($this->_sections['i']['iteration'] == 1);
$this->_sections['i']['last']       = ($this->_sections['i']['iteration'] == $this->_sections['i']['total']);
?>
  <tr><td class="whitetext"><input type="radio" name="ttext" value='<?php echo $this->_tpl_vars['text_text'][$this->_sections['i']['index']]; ?>
' onClick="text_text=this.value; recalc_widget(this.form, '<?php echo $this->_tpl_vars['user']; ?>
');"><?php echo $this->_tpl_vars['text_text'][$this->_sections['i']['index']]; ?>
<br><img src="/thematics/spacer.gif" width="26" height="3" border="0"><br></td></tr>
<?php endfor; endif; ?>
</table>
</td>

<td nowrap>
<?php unset($this->_sections['img']);
$this->_sections['img']['name'] = 'img';
$this->_sections['img']['loop'] = is_array($_loop=$this->_tpl_vars['notext_images']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
$this->_sections['img']['show'] = true;
$this->_sections['img']['max'] = $this->_sections['img']['loop'];
$this->_sections['img']['step'] = 1;
$this->_sections['img']['start'] = $this->_sections['img']['step'] > 0 ? 0 : $this->_sections['img']['loop']-1;
if ($this->_sections['img']['show']) {
    $this->_sections['img']['total'] = $this->_sections['img']['loop'];
    if ($this->_sections['img']['total'] == 0)
        $this->_sections['img']['show'] = false;
} else
    $this->_sections['img']['total'] = 0;
if ($this->_sections['img']['show']):

            for ($this->_sections['img']['index'] = $this->_sections['img']['start'], $this->_sections['img']['iteration'] = 1;
                 $this->_sections['img']['iteration'] <= $this->_sections['img']['total'];
                 $this->_sections['img']['index'] += $this->_sections['img']['step'], $this->_sections['img']['iteration']++):
$this->_sections['img']['rownum'] = $this->_sections['img']['iteration'];
$this->_sections['img']['index_prev'] = $this->_sections['img']['index'] - $this->_sections['img']['step'];
$this->_sections['img']['index_next'] = $this->_sections['img']['index'] + $this->_sections['img']['step'];
$this->_sections['img']['first']      = ($this->_sections['img']['iteration'] == 1);
$this->_sections['img']['last']       = ($this->_sections['img']['iteration'] == $this->_sections['img']['total']);
?>
  <p><input type="radio" name="img" value="<?php echo $this->_tpl_vars['notext_images'][$this->_sections['img']['index']]; ?>
" onClick="img_name=this.value; use_text=false; recalc_widget(this.form, '<?php echo $this->_tpl_vars['user']; ?>
');"><img src="/thematics/<?php echo $this->_tpl_vars['notext_images'][$this->_sections['img']['index']]; ?>
" align=top /></p>
<?php endfor; endif; ?>
</td></tr>
<tr><td colspan="3"><br><hr></td></tr>

<tr valign=top><td colspan="3" align="center"><h4>Select all of the text below, copy it, and paste it into your emails, website, and anywhere you want to get happy buyers buzzing about you!</h4><textarea name="widget_code" rows="6" cols="100"></textarea></td></tr>

</table> 
</form> 

</td></tr></table> 
</td></tr></table> 

<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?> 