<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: DBEdit
 * Author: Eric Helvey
 * Create Date: 1/8/2003
 *
 * Description: Feature class for TableUpdate view record pages.
 *
 * Revision: $Revision: 1.5 $
 * Last Change Date: $Date: 2004-02-27 23:56:16 $
 * Last Editor: $Author: eric $
*/


include_once("Features/DBFeatBase.inc");

class DBView extends DBFeatBase
{
  function DBView($tabUpdate, $config, $debug)
  {
    $this->DBFeatBase($tabUpdate, $config, $debug);
  }


  function generate_Layer()
  {
    $html = $this->__top_of_layer();

    $html .= $this->tabUpdate->generateRecord("tableHead", "contentsmall", $this->tabUpdate->cols_for_display);

    $html .= $this->__bottom_of_layer();

    return $html;
  }

}

?>
