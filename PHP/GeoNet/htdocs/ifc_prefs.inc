<?php
  include_once("ConfigFileReader.inc");

  $projectName = "GeoNet";
  $config = new ConfigFileReader($projectName);

  if(!isset($debug) || $debug == "") {
  	if(isset($_REQUEST[debug])) {
  	  $debug = $_REQUEST["debug"];
  	} else {
	  	$debug = $config->getAttribute("DebugLevel");
  		if($debug == "") {
    		$debug = 0;
  		}
  	}
  	$debug = (int)$debug;
  }
  
  if($debug >= 5) {
    foreach($_REQUEST as $k=>$v) {
      print("_REQUEST[$k] == $v<br>\n");
    }
  }

  if($config->getAttribute("DatabaseDriver") == "" || $config->getAttribute("PHPAuthFile") == "") {
  	sleep(1);
  	$goto = "Location: " . $_SERVER["PHP_SELF"] . "?" . $_SERVER["QUERY_STRING"];
  	__redirector($goto, $debug);
  }
  
  $confg = new ConfigFileReader("CorporateTheme");

	if(!file_exists($confg->getAttribute("CorporateThemeClassFile"))) {
		sleep(1);
  	$goto = "Location: " . $_SERVER["PHP_SELF"] . "?" . $_SERVER["QUERY_STRING"];
  	__redirector($goto, $debug);
	}
			
  include_once("/work/WADappl/Projects/CorporateTheme/htdocs/CorporateTheme.inc");
  $theme = new CorporateTheme($confg,
     array("title" => $config->getAttribute("Title"),
          "contactEmail" => "eric.l.helvey@mail.sprint.com",
          "keywords" => array("keywords" => "GeoNet"),
          "menuPath" => $config->getAttribute("MenuPath"),
          "displayStocks" => 0,
          "httpmetatag" => array("expires" => -1),
         ));

  $css =<<<EOS
    .frameStockTicker { background-color: #D80000 }
    .bodyStockTicker { background-color: #FFFFFF }
    .subHeadStockTicker { background-color: #E5E7D4 }
    .headerStockTicker { background-color: #CCCCCC }
    .divStockTicker { background-color: #000000 }
    .bottomStockTicker { background-color: #000000 }
    .textStockTicker { font-family: arial,geneva,sans-serif; font-size: 12px; color: #000000; line-height: 14px; font-weight: bold }
    .closeTicker { font-family: arial,geneva,sans-serif; font-size: 11px; color: #000000; line-height: 10px }
    .noteStockTicker { font-family: arial,geneva,sans-serif; font-size: 11px; color: #ffffff; line-height: 10px }
    .contentsmall { font-family: verdana,sans-serif; font-size: 10px; }
    .contentsmalllink { font-family: verdana,sans-serif; font-size: 10px; }
    .contentmedium { font-family: verdana,sans-serif; font-size: 11px; }
    .nextprevious { color:#ffffff; background-color:#000000; font-family: verdana,sans-serif; font-size: 11px; }
    .content { font-family: verdana,sans-serif; font-size: 12px; }   
    .grayhead {font-family: arial,sans-serif; font-size: 10pt; font-weight:bold; color:#000000; background-color:#dddddd;}    
    .redtext { font-family: arial,sans-serif; font-weight: bold; font-size: 12px; color: #cc0000}
    .header {font-family: arial,helvetica,sans-serif; color:#666666; background-color:#E1D7AA; font-weight: bold; font-size: 12pt;}
    .fieldlabels { font-family: verdana,sans-serif; font-size: 12px; }
    .fieldName { font-family: verdana,sans-serif; font-size: 12px; }
    .tableHeader { font-family: verdana,sans-serif; font-weight: bold; font-size: 13px; }
    .error { font-family: verdana,sans-serif; font-weight: bold; font-size: 12px; color: #cc0000}
    .tableContent { font-family: verdana,sans-serif; font-size: 12px; background-color:#E1D7AA; }   
    .tableHead { font-family: verdana,sans-serif; font-size: 12px; background-color:#E1D7AA; font-weight: bold; }   
    .pagehead {font-family: arial,helvetica,sans-serif; font-size: 14pt; color:#000000; font-weight: bold;}
    A:Link { color: d80000; text-decoration:none;}
    A:Hover { color: 0000ff;}
    A:Visited { color: d80000; text-decoration:none;}
    A:Link.normal { color: 000000; text-decoration:none;}
    A:Hover.normal { color: d80000;}
    A:Visited.normal { color: 000000; text-decoration:none;}
    A:Link.contentsmalllink { color: 0000ff; text-decoration:none;}
    A:Hover.contentsmalllink { color: d80000; text-decoration:underline;}
    A:Visited.contentsmalllink { color: 0000ff; text-decoration:none;}
    A:link.nextprevious {color: #ffffff;}
    A:visited.nextprevious {color: #ffffff;}
    A:hover.nextprevious {color: #ff0000;}

  A:link {color:#0000ff;}
  A:visited {color:#0000ff;}
  A:hover {color:#ff0000;}

  .hdr_lrg { font-family: Arial, sans-serif; font-size: 20; color: #666666; }
  .hdr_nrm { font-family: Arial, sans-serif; font-size: 15; color: #666666; }
  .hdr_sml { font-family: Arial, sans-serif; font-size: 9; color: #666666; }

  .fieldlabels { font-family: verdana, sans-serif; font-size: 10; }
  .tableHeader { font-family: verdana, sans-serif; font-size: 11; font-weight:bold; }
  .tableHeader_sml { font-family: verdana, sans-serif; font-size: 9; font-weight: bold; }

  .content9 { font-family: verdana, sans-serif; font-size: 9; }
  .eventnochange { font-family: verdana, sans-serif; font-size: 9; }
  .eventrecentchange { font-family: verdana, sans-serif; font-size: 9; background-color: #ff9999; }

EOS;
  
  $javascriptForLayer =<<<EOS
  // 
  // These three functions will SHOW, HIDE or FLIP the visibility 
  // of the specified division. 
  // 
  if (document.all) 
  { 
    // Explorer (4.x) 
    layerRef='document.all' 
    styleRef='.style.' 
  } 
  else if (document.layers) 
  { 
    // Netscape (4.x) 
    layerRef='document.layers' 
    styleRef='.' 
  } 
  
  
  function show(divid) 
  { 
    eval(layerRef + '["' + divid + '"]' + styleRef + 'visibility="visible"') 
  } 
  function hide(divid) 
  { 
    eval(layerRef + '["' + divid + '"]' + styleRef + 'visibility="hidden"') 
  } 
  function flip(divid) 
  { 
    var state=eval(layerRef + '["' + divid + '"]' + styleRef + 'visibility'); 
    if(state.substring(0,1) == "h") 
    { 
      show(divid); 
    } 
    else 
    { 
      hide(divid); 
    } 
  } 
EOS;

  $theme->updateAttr("localCSS", $css);
  $theme->addToAttr("jscode", $javascriptForLayer);
  $theme->setLastMod($_SERVER["SCRIPT_FILENAME"]);

  include_once($config->getAttribute("DatabaseDriver") . ".inc");

  $dbcall = "\$dbh = new " . $config->getAttribute("DatabaseDriver") . "(\$config, \"" . ($projectName == "" ? $config->getAttribute("DBApplication") : $projectName) . "\", $debug);";
  if($debug) {
    print ("*** $dbcall<br>");
  }
  if (!$dbh) {
    eval($dbcall);
  }

  if (!$dbh->validConnection()) {
  	$x = `hostname`;
  	
#    $newQueryString = preg_replace("/&error=1/", "", $_SERVER["QUERY_STRING"]);
#    print("<html>\n<head>\n<meta http-equiv=\"Refresh\" CONTENT=3;URL=" . $_SERVER["PHP_SELF"] . "?" . $newQueryString . "&error=1>\n</head>\n<body>\n<h3>" . $dbh->getErrorMessage() . "</h3>\n</body></html>\n");
#    exit();
  }

	#$row = $dbh->SelectFirstRow("max(rephost) as host, count(1) as thecount", "replication_partners", "status = 1");
	#if($row["thecount"] <= 1 && $_SERVER["SERVER_NAME"] != $row["host"]) {
	#	__redirector("http://" . $row["host"] . $_SERVER["SCRIPT_URL"] . "?" . $_SERVER["QUERY_STRING"] . "&" . "sessionXX=" . $_COOKIE[$projectName], $debug);
	#	exit;
	#}
	
	if(isset($_GET["sessionXX"])) {
		$_COOKIE[$projectName] = $_GET["sessionXX"];
	}
	 
  # If we're already logged in go to the first page
  if($requireLogin >= 1 || (isset($_COOKIE[$projectName]) && $_COOKIE[$projectName] != "")) {
    include_once($config->getAttribute("PHPAuthFile"));
    
    include_once("GeoNetUser.inc");
    $user = new GeoNetUser($sess, $config, $dbh, $debug);
 
    if(isset($minLevel)) {
    	if($GLOBALS["accessLevel"] < $config->getAttribute($minLevel)) {
				header("Location: " . $config->getAttribute("gotoPage"));
				exit();
    	}
    }
	}
	
  if($GLOBALS["accessLevel"] >= $config->getAttribute("SuperAdminAccessLevel")) {
		$__menu = array(
			"Home" => $config->getAttribute("URLDir") . "/colorBlock.php",
			"Users" => $config->getAttribute("URLDir") . "/security.php",
			"Groups" => $config->getAttribute("URLDir") . "/view_group_assignment.php",
			"Database" => $config->getAttribute("URLDir") . "/links.php",
			"Logout" => $config->getAttribute("URLDir") . "/logOff.php",
		);
  } elseif($GLOBALS["accessLevel"] >= $config->getAttribute("AdminAccessLevel")) {
		$__menu = array(
			"Home" => $config->getAttribute("URLDir") . "/colorBlock.php",
			"Groups" => $config->getAttribute("URLDir") . "/view_group_assignment.php",
			"Database" => $config->getAttribute("URLDir") . "/links.php",
			"Logout" => $config->getAttribute("URLDir") . "/logOff.php",
		);
  } elseif($GLOBALS["accessLevel"] >= $config->getAttribute("UserAccessLevel")) {
		$__menu = array(
			"Home" => $config->getAttribute("URLDir") . "/colorBlock.php",
			"Groups" => $config->getAttribute("URLDir") . "/view_group_assignment.php",
			"Database" => $config->getAttribute("URLDir") . "/links.php",
			"Logout" => $config->getAttribute("URLDir") . "/logOff.php",
		);
  } elseif($GLOBALS["accessLevel"] >= $config->getAttribute("InternalUserAccessLevel")) {
		$__menu = array(
			"Home" => $config->getAttribute("URLDir") . "/colorBlock.php",
			"Groups" => $config->getAttribute("URLDir") . "/view_group_assignment.php",
			"Database" => $config->getAttribute("URLDir") . "/links.php",
			"Logout" => $config->getAttribute("URLDir") . "/logOff.php",
		);
  } else {
		$__menu = array(
			"Home" => $config->getAttribute("URLDir") . "/colorBlock.php",
			"Logout" => $config->getAttribute("URLDir") . "/logOff.php",
		);
		$theme->updateAttr("external", 1);
  }
	
	
	$theme->updateAttr("topMenu", $__menu);
	
  include_once("form_elements.inc");
  include_once("constantsDefinition.inc");

  $_form_elem_class = "content";

  function __loadFeatures($features, &$theme)
  {
    $__localcss = "";
    $__localjscode = "";
    $__localonload = "";

    foreach($features as $f) {
      $__localcss .= $f->generate_Stylesheet();
      $__localjscode .= $f->generate_JavaScript();
      $__localonload .= $f->generate_OnLoad();
    }

    $theme->addToAttr("jscode", $__localjscode);
    $theme->addToAttr("onload", $__localonload);
    $theme->addToAttr("localCSS", $__localcss);
  }

  function __redirector($url, $debug)
  {
    $loc = "Location: $url";
    if($debug >= 1) {
      print("Would have gone to $loc<br>\n");
    } else {
      header($loc);
    }
    exit();
  }

?>