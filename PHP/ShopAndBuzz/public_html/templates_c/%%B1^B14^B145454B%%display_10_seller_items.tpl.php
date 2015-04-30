<?php /* Smarty version 2.6.16, created on 2007-08-01 23:46:08
         compiled from display_10_seller_items.tpl */ ?>
<?php $this->assign('bdrcolor', '000000');  $this->assign('endcolor', 'FF0000');  $this->assign('fbgcolor', 'F1C886');  $this->assign('fntcolor', '000000');  $this->assign('hdrcolor', 'FBAF34');  $this->assign('lnkcolor', '0033CC');  $this->assign('logo', '1');  $this->assign('num', '10');  $this->assign('tbgcolor', 'FFFFFF');  $this->assign('title', "My+next+".($this->_tpl_vars['num'])."+items+ending+on+eBay+are...");  $this->assign('tlecolor', 'F1C886');  $this->assign('tlfcolor', '000000');  $this->assign('width', '750');  $this->assign('sellername', $this->_tpl_vars['ebay_username']); ?>
<script language="JavaScript" src="http://lapi.ebay.com/ws/eBayISAPI.dll?EKServer&ai=alh%7El&bdrcolor=<?php echo $this->_tpl_vars['bdrcolor']; ?>
&cid=0&eksize=1&encode=ISO-8859-1&endcolor=<?php echo $this->_tpl_vars['endcolor']; ?>
&endtime=y&fbgcolor=<?php echo $this->_tpl_vars['fbgcolor']; ?>
&fntcolor=<?php echo $this->_tpl_vars['fntcolor']; ?>
&fs=0&hdrcolor=<?php echo $this->_tpl_vars['hdrcolor']; ?>
&hdrimage=1&hdrsrch=y&img=y&lnkcolor=<?php echo $this->_tpl_vars['lnkcolor']; ?>
&logo=<?php echo $this->_tpl_vars['logo']; ?>
&num=<?php echo $this->_tpl_vars['num']; ?>
&numbid=n&paypal=n&popup=y&prvd=1&r0=1&shipcost=y&si=<?php echo $this->_tpl_vars['sellername']; ?>
&sid=editorkit&siteid=0&sort=MetaEndSort&sortby=endtime&sortdir=asc&srchdesc=n&tbgcolor=<?php echo $this->_tpl_vars['tbgcolor']; ?>
&title=<?php echo $this->_tpl_vars['title']; ?>
&tlecolor=<?php echo $this->_tpl_vars['tlecolor']; ?>
&tlefs=0&tlfcolor=<?php echo $this->_tpl_vars['tlfcolor']; ?>
&track=2502212&width=<?php echo $this->_tpl_vars['width']; ?>
"></script>