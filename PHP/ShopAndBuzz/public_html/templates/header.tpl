<HTML>
<HEAD>
{* {popup_init src="/javascripts/overlib.js"} *}
<TITLE>Shop And Buzz</TITLE>
<script language="JavaScript">
var SiteURL = "{$SiteURL}";
</script>
<script language="JavaScript" src="/buzz_main_lib.js" type="text/javascript"></script>
{if isset($js_libs) }
{section name=i loop=$js_libs}
<script language="JavaScript" src="/{$js_libs[i]}" type="text/javascript"></script>
{/section}
{/if}
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
{if $loggedin != 1}
  {include file="login.tpl" title=foo}
{/if}
	</td></tr>
	<tr align=left valign=top>
{if $loggedin != 1}
  {include file="menu.notloggedin.tpl"}
{else}
  {include file="menu.loggedin.tpl"}
{/if}
        </tr>
	<tr align=left valign=top>
	<td class="bkg-main">
		<table border=0 cellpadding=0 cellspacing=0 width=970>
		<tr align=left valign=top>

		<td width=16><img src="/thematics/spacer.gif" width="16" height="1" border="0"><td>
<td><br><br>
