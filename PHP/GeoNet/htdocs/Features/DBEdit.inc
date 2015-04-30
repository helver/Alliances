<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBEdit
 * Author: Eric Helvey
 * Create Date: 1/8/2003
 *
 * Description: Feature class for TableUpdate edit pages.
 *
 * Revision: $Revision: 1.7 $
 * Last Change Date: $Date: 2005-07-26 21:33:00 $
 * Last Editor: $Author: eric $
*/


include_once("Features/DBFeatBase.inc");

class DBEdit extends DBFeatBase
{

  function DBEdit($tabUpdate, $config, $debug)
  {
    $this->DBFeatBase($tabUpdate, $config, $debug);
  }


  function generate_Layer()
  {
    $html = $this->__top_of_layer();

    $onsub = ($this->tabUpdate->onSubmit == "" ? "" : " onSubmit=\"" . $this->tabUpdate->onSubmit . "\"");

    $html .=<<<EOS
       <table CELLSPACING="5"  BGCOLOR="#E1D7AA" ALIGN="center">
       <form name="addedit" method="POST"$onsub>
EOS;

		if(isset($_REQUEST["return_page"])) {
			$html .= hidden_field("return_page", $_REQUEST["return_page"]);
		}
		
    $html .= $this->tabUpdate->generateFields();

    $html .= "<tr><td colspan=\"2\">";

    $html .= $this->tabUpdate->generateButtons();

    $html .= "</td></tr></form></table>\n";

    $html .= $this->__bottom_of_layer();

    return $html;
  }

}

?>
