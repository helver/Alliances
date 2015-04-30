<html>
<head>
<title>Buzz Admin - <? echo($this->label); ?></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<table>
  <tr> 
    <td width="603" valign="top" height="502"> 

    <p class="title"><? echo($this->label); ?> <span class="content"><a href="<? echo($this->return_page); ?>">Back</a></span></p>

    <? if($this->fail) { ?>
    <table width="500" border="1" align="center">
      <tr bgcolor="#ffffff">
        <td valign="top" align="right"><span class="error">The following errors were found:</span></td>
        <td width="75%" align="left"><span class="error"><? $this->displayError(); ?></span></td>
      </tr>
    </table>
    <br><br>
    <? } ?>

    <? if(isset($GLOBALS["view"]) && $GLOBALS["view"] == "view") { ?>
      <p class="content">
        <table noborder>
        <? $this->displayView(); ?>
        </table>
      </p>

    <? } else { ?>

    <form name="addedit" method="POST">
        <? $this->displayIDField(); ?>

      <p class="content">
        <table noborder>
        <? $this->displayFields(); ?>
        </table>
      </p>
        <? $this->displayButtons(); ?>
    </form>
    <? } ?>
  </tr>
</table>
</body>
</html>
