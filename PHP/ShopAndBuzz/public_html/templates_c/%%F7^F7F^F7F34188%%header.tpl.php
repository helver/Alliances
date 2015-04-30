<?php /* Smarty version 2.6.16, created on 2007-08-02 21:25:17
         compiled from header.tpl */ ?>
<HTML>
<HEAD>
<TITLE>Shop And Buzz</TITLE>
<script language="JavaScript">
var SiteURL = "<?php echo $this->_tpl_vars['SiteURL']; ?>
";
</script>
<script language="JavaScript" src="/buzz_main_lib.js" type="text/javascript"></script>
<?php if (isset ( $this->_tpl_vars['js_libs'] )):  unset($this->_sections['i']);
$this->_sections['i']['name'] = 'i';
$this->_sections['i']['loop'] = is_array($_loop=$this->_tpl_vars['js_libs']) ? count($_loop) : max(0, (int)$_loop); unset($_loop);
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
<script language="JavaScript" src="/<?php echo $this->_tpl_vars['js_libs'][$this->_sections['i']['index']]; ?>
" type="text/javascript"></script>
<?php endfor; endif;  endif; ?>
<link rel="stylesheet" href="/thematics/style.css" type="text/css">
<link rel="shortcut icon" href="/thematics/favicon.ico">
</HEAD>
<body bgcolor="#000000" text="#000000" marginheight="0" topmargin="0" bottommargin="0">
<center><br>
<table border=0 cellpadding=3 cellspacing=0 width=976 bgcolor=ffffff>
<tr align=center valign=top>
<td>

	<table border=0 cellpadding=0 cellspacing=0 width=970 bgcolor=f1c886>

	<tr align=left valign=top>
	<td class="bkg-header"><img src="/thematics/spacer.gif" width="1" height="179" border="0" align=left><img src="/thematics/spacer.gif" width="1" height="4" border="0"><br>
<?php if ($this->_tpl_vars['loggedin'] != 1): ?>
  <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "login.tpl", 'smarty_include_vars' => array('title' => 'foo')));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
  endif; ?>
	</td></tr>
	<tr align=left valign=top>
<?php if ($this->_tpl_vars['loggedin'] != 1): ?>
  <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "menu.notloggedin.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
  else: ?>
  <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "menu.loggedin.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
  endif; ?>
        </tr>
	<tr align=left valign=top>
	<td class="bkg-main">
		<table border=0 cellpadding=0 cellspacing=0 width=970>
		<tr align=left valign=top>

		<td width=16><img src="/thematics/spacer.gif" width="16" height="1" border="0"><td>
<td><br><br>