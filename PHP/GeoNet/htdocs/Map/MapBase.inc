<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: MapBase
 * Author: Eric Helvey
 * Creation Date: 11/7/2002
 *
 * Description: MapBase is an abstract class used to define common 
 *              functionality used by different GeoNet element type.  
 *              You should not use this class directly.
 *
 * Revision: $Revision: 1.13 $
 * Last Change Date: $Date: 2005-03-11 16:21:48 $
 * Last Editor: $Author: eric $
*/

class MapBase
{

  # Constants
  var $colorSet;
  var $colorInd= 0;                   # Last color used.
  var $colors = array();              # Array of colors to use.
  var $pms = array();                 # List of PMs with labels.

  // list of PMs (statistics of errors in the element)
  var $PMs;

  var $user;        # GeoNet User Object
  var $config;      # ConfigFileReader Object.
  var $dbh;         # DBWrapper Object.
  var $debug;       # Debugging Level.
  var $dataSet;     # TID Data Set
  var $transPaths;  # Transmit Link Path Data Set
  var $recvPaths;   # Receive Link Path Data Set
  var $map;         # Image map information
  var $tidInfo;     # Database result set containing TID information.
  var $displayHTML; # HTML that needs to be displayed for the
                    # image to appear and for popups to work.
  var $globalCoord; # Complete set of elements displayed and their
                    # coordinates.
  var $layout;      # Layout Object.

  # Attributes that come from the Config File.
  var $imageName;           # Name of the base image.
  var $pointWidth;          # Width of the Square Icon.
  var $pointHeight;         # Height of the Square Icon.
  var $standardRefreshTime; # Time to reload for non-slide show.
  var $cookieTimeout;       # Height of the grid lines in pixels
  var $imagesFolder;        # Where images are located.
  var $usMapImage;          # Background image for US Map.
  var $layoutName;          # Name of the layout Class to use.

  # Blaine and Leisure City are used to orient and scale the
  # US Map.  They are also used to perform the world to map
  # coordinate conversion.
  var $LONG_BLAINE;         # Longitude of Blaine
  var $LAT_BLAINE;          # Latitude of Blaine
  var $LONG_LEISURECITY;    # Longitude of Leisure City
  var $LAT_LEISURECITY;     # Latitude of Leisure City

  var $Y_BLAINE;            # Y value of Blaine
  var $X_BLAINE;            # X Value of Blaine
  var $Y_LEISURECITY;       # Y Value of Leisure City
  var $X_LEISURECITY;       # X Value of Leisure City

  # Calculated Attributes
  var $MINX;      # Absolute Minimum Time Value
  var $MAXX;      # Absolute Maximum Time Value
  var $MINY;      # Absolute Minimum Error Value
  var $MAXY;      # Absolute Maximum Error Values

  var $minx;      # Minimum X Pixel Location
  var $maxx;      # Maximum X Pixel Location
  var $miny;      # Minimum Y Pixel Location
  var $maxy;      # Maximum Y Pixel Location

  var $COEFX;     # Conversion factor between real X values and pixels.
  var $COEFY;     # Conversion factor between real Y values and pixels.
  var $xLegend;   # X Location of Legend Text.
  var $yLegend;   # Y Location of Legend Text.

  var $nbSecondsInOneDay;  # Maybe not needed
  var $gridIntervalX;      # X Grid Spacing


  function __cleanup()
  {
    unset($this->pms);

    unset($this->dataSet);
    unset($this->map);
    unset($this->globalCoord);

    unset($this->COEFX);
    unset($this->COEFY);

    $this->__init();
  }

  #
  # Function: debug_output
  #
  # debug_output dumps the current state of the object.
  #
  # debug_output has no parameters.
  #
  # debug_output has no return value.
  function debug_output()
  {
    print(  "cookieTimeout: " . $this->cookieTimeout
        . ", pointWidth: " . $this->pointWidth
        . ", pointHeight: " . $this->pointHeight
        . ", standardRefreshTime: " . $this->standardRefreshTime
        . ", LONG_BLAINE: " . $this->LONG_BLAINE
        . ", LAT_BLAINE: " . $this->LAT_BLAINE
        . ", LONG_LEISURECITY: " . $this->LONG_LEISURECITY
        . ", LAT_LEISURECITY: " . $this->LAT_LEISURECITY
        . ", Y_BLAINE: " . $this->Y_BLAINE
        . ", X_BLAINE: " . $this->X_BLAINE
        . ", Y_LEISURECITY: " . $this->Y_LEISURECITY
        . ", X_LEISURECITY: " . $this->X_LEISURECITY
        . ", COEFX: " . $this->COEFX
        . ", COEFY: " . $this->COEFY
        . ", debug: " . $this->debug
        . "<BR>\n");
  }




  #
  # Function: MapBase
  #
  # MapBase is the contstuctor for the class.  Basically all we're
  # doing here is setting our ConfigFileReader object and DBWrappr
  # object and then reading configuration values.
  #
  # MapBase has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # MapBase returns on object of type MapBase.
  function MapBase(&$user, $dbh, $config, $debug = 0)
  {
    # Setting Main Attributes.
    $this->config = $config;
    $this->dbh = $dbh;
    $this->debug = $debug;
    $this->user = $user;

    $this->__init();
    $this->__calculate_limits();
  }


  function __init()
  {
    $this->pointWidth = $this->config->getAttribute("pointWidth");
    $this->pointHeight = $this->config->getAttribute("pointHeight");
    $this->standardRefreshTime = $this->config->getAttribute("standardRefreshTime");
    $this->cookieTimeout = $this->config->getAttribute("cookieTimeout");
    $this->usMapImage = $this->config->getAttribute("usMapImage");

    $this->LONG_BLAINE = $this->config->getAttribute("LONG_BLAINE");
    $this->LONG_LEISURECITY = $this->config->getAttribute("LONG_LEISURECITY");
    $this->LAT_BLAINE = $this->config->getAttribute("LAT_BLAINE");
    $this->LAT_LEISURECITY = $this->config->getAttribute("LAT_LEISURECITY");

    $this->Y_BLAINE = $this->config->getAttribute("Y_BLAINE");
    $this->X_BLAINE = $this->config->getAttribute("X_BLAINE");
    $this->Y_LEISURECITY = $this->config->getAttribute("Y_LEISURECITY");
    $this->X_LEISURECITY = $this->config->getAttribute("X_LEISURECITY");

    // contains the list of colors used for the facility path
    $this->colorSet = array("po", "lb", "hp", "o", "db", "dg", "dr");

    // list of PMs (statistics of errors in the element)
    $this->PMs = array ("CV", "ES", "SES", "UAS");

    $this->layoutName = $this->config->getAttribute("LayoutName");
  }

  #
  # Function: __setupColors
  #
  # __setupColors takes various colors defined by us, allocates them in
  # the page, and assigns a label to them.  This way we don't have to keep
  # allocating the colors.
  #
  # __setupColors has no parameters.
  #
  # __setupColors has no return value.
  function __setupColors($usmap)
  {
    # Colors used for the element status indicators.
    $this->colors["r"] = ImageColorAllocate ($usmap, 223, 0, 49);
    $this->colors["R"] = ImageColorAllocate ($usmap, 255, 0, 0);
    $this->colors["g"] = ImageColorAllocate ($usmap, 102, 504, 51);
    $this->colors["y"] = ImageColorAllocate ($usmap, 255, 230, 51);
    $this->colors["n"] = ImageColorAllocate ($usmap, 120, 120, 120);
    $this->colors["t"] = ImageColorAllocate ($usmap, 7, 139, 248);

    # Colors used for the graphics
    $this->colors["b"] = ImageColorAllocate ($usmap, 0, 0, 0);
    $this->colors["w"] = ImageColorAllocate ($usmap, 255, 255, 255);

    # Colors used for the facility paths
    $this->colors["po"] = ImageColorAllocate ($usmap, 255,138,138);
    $this->colors["lb"] = ImageColorAllocate ($usmap, 102,204,255);
    $this->colors["hp"] = ImageColorAllocate ($usmap, 255,102,255);
    $this->colors["o"] = ImageColorAllocate ($usmap, 255,153,0);
    $this->colors["db"] = ImageColorAllocate ($usmap, 51,51,255);
    $this->colors["dg"] = ImageColorAllocate($usmap,0,207,0);
    $this->colors["dr"] = ImageColorAllocate ($usmap,207,0,0);

  }


  #
  # Function: __calculateLimits
  #
  # __calculateLimits caculates all the maximums, minimums and
  # coefficients used in the construction of the graphs.  We calculate
  # maximum and minimum real values, pixels values, and the coefficients
  # to calculte pixel values from real values.
  #
  # __calculateLimits has the following parameters:
  #   $maxClause - Select clause that will pull the max for all pms.
  #   $tidid - The TIDID of the element that we're interested in.
  #
  # __calculateLimits has no return value.
  function __calculate_limits()
  {
    if($this->debug >= 3) {
      print("LONG_BLAINE: " . $this->LONG_BLAINE . "<br>\n");
      print("LONG_LEISURECITY: " . $this->LONG_LEISURECITY . "<br>\n");
      print("LAT_BLAINE: " . $this->LAT_BLAINE . "<br>\n");
      print("LAT_LEISURECITY: " . $this->LAT_LEISURECITY . "<br>\n");
      print("Y_BLAINE: " . $this->Y_BLAINE . "<br>\n");
      print("X_BLAINE: " . $this->X_BLAINE . "<br>\n");
      print("Y_LEISURECITY: " . $this->Y_LEISURECITY . "<br>\n");
      print("X_LEISURECITY: " . $this->X_LEISURECITY . "<br>\n");
    }

    // calculate the coefficient to get nb of pixels from the lat-long
    $this->COEFX = ($this->X_LEISURECITY - $this->X_BLAINE) / ($this->LONG_BLAINE - $this->LONG_LEISURECITY);
    $this->COEFY = ($this->Y_LEISURECITY - $this->Y_BLAINE) / ($this->LAT_BLAINE - $this->LAT_LEISURECITY);

    if($this->debug >= 3) {
      print("COEFX: " . $this->COEFX . "<br>\n");
      print("COEFY: " . $this->COEFY . "<br>\n");
    }
  }


  function createLayout()
  {
    eval("include_once(\"" . $this->layoutName . ".inc\");");
    eval("\$this->layout = new " . $this->layoutName . "(\$this->config, \$this->image, \$this->colors, \$this->colorSet, \$this->debug);");
  }


  //////////////////////////////////////////////////////////////
  // CONSTANTS
  //////////////////////////////////////////////////////////////


  // contains the coordinates of all the squares on the map
  // to avoid overlapping



  /*
   * calculate the coordinates on the map in pixels of an element
   * using its lat-long
   * @param $long longitude of the element
   * @param $lat latitude of the element
   * @param $tidid unique key for this element (it is used to
   *        maintain the hash table of coordinates for all elements)
   * @return the coordinates in pixels */
  function returnCoord($long, $lat, $tidid)
  {
		// first check if we have not already drawn this square:
		if (isset($this->globalCoord[$tidid]))
		{
			return $this->globalCoord[$tidid];	
		}

    // calculate the coordinates in pixel
    $valueX = round($this->X_BLAINE + $this->COEFX * ($this->LONG_BLAINE - $long));
    $valueY = round($this->Y_BLAINE + $this->COEFY * ($this->LAT_BLAINE - $lat));

    // avoid squares to overlap with each other
    $coord = $this->findPairNotTooClose($valueX, $valueY);

    if($coord == "") {
      if(($fh = fopen("placement.log", "a"))) {
        fputs($fh, "Failed placing tidid: $tidid at $lat,$long.  Overlapping original.\n");
        fclose($fh);
      }

      $coord = array("x"=>$valueX, "y"=>$valueY);
    }

    // add the new coordinates to the global hash
    $this->globalCoord[$tidid] = $coord;
    return $coord;
  }


  /*
   * avoid the new square to overlap with any preexisting squares on the
   * map. If there is a square with which it would overlap, it adjusts
   * the coordinates of the new square. */
  function findPairNotTooClose($valueX, $valueY)
  {
    $originalX = $valueX;
    $originalY = $valueY;
    $iteration = 0;
    $max = 4;

    for($i = 0; abs($i) <= $max; ($i == 0 ? $i++ : ($i > 0 ? $i *= -1 : $i += ((-2) * $i) + 1))) {
      for($j = 0; abs($j) <= ($i ? abs($i) : 1); ($j == 0 ? $j++ : ($j > 0 ? $j *= -1 : $j += ((-2) * $j) + 1))) {
        $iteration++;

        $valueX = $originalX + ($i * $this->pointWidth);
        $valueY = $originalY + ($j * $this->pointHeight);

        if(!$this->isClose($valueX, $valueY)) {
          return array("x" => $valueX, "y" => $valueY);
        }

        if($iteration >= (pow((($max * 2) + 1), 2) - 1)) {
          $j = $max + 1; $i = $max + 1;
          break;
        }

        #print("$iteration: $i, $j<br>\n");
      }
    }

    return;
  }

  /*
   * check if the new square may overlap with an existing square
   * on the map.
   * @param $valueX the x coordinate of the new square
   * @param $valueY the y coordinate of the new square
   * @return the coordinates of the square with which the new one
   *        may overlap, 0 o.w. */
  function isClose($valueX, $valueY)
  {
    if (isset($this->globalCoord) && is_array($this->globalCoord))
    {
      foreach ($this->globalCoord as $j => $v)
      {
        if (abs($valueX - $this->globalCoord[$j]["x"]) < $this->pointWidth
            && abs($valueY - $this->globalCoord[$j]["y"]) < $this->pointHeight)
        {
          if ($this->debug >= 5) {
            print("Receive value: $valueX, $valueY, found: ".$this->globalCoord[$j]["x"].", ".$this->globalCoord[$j]["y"]." <BR>\n");
          }
          return $this->globalCoord[$j];
        }
      }
    }
    return 0;
  }

  /*
   * get the next index in a list of elements. If it is the end
   * of the list, go back to the beginning.
   * @param $colorSet the list of elements
   * @param $colorInd the current index
   * @return the next index */
  function getNextColor($colorInd=0)
  {
  	if($this->debug >= 5) {
      print("colorSet: ");
      print_r($this->colorSet);
      print("<br>colorInd = $colorInd<br>\n");
    }
  	
    if ($this->colorSet[$colorInd + 1]) {
      return $colorInd + 1;
    }
    else return 0;
  }

  /*
   * create a square at the xc and yc coordinates and attach
   * to this area an alt tag
   * @param $xc the x coordinate of the center of the square
   * @param $yc the y coordinate of the center of the square
   * @param $color determines the color of the square and shows the
   *      status of the element
   * @param $tidid is the key of the element in the database,
   *      it is used as parameter for the history page */
  function createSquare($xc,$yc, $color, $tidid, $alt="", $tid, $usmap)
  {
    // calculate the coordinate of the upper left and bottom right
    // corner of the square
    $diameterx = floor ($this->pointWidth / 2);
    $diametery = floor ($this->pointHeight / 2);
    $xtop = $xc - $diameterx;
    $ytop = $yc - $diametery;
    $xbottom = $xc + $diameterx + 1;
    $ybottom = $yc + $diametery + 1;

    if($this->debug >= 3) {
      print("Drawing a Square from ($xtop,$ytop) to ($xbottom,$ybottom)<br>\n");
    }

    // the flag e is displayed as a red X in a white square with a red border
    if ($color == "e" || $color == "i") {
      ImageFilledRectangle ($usmap, $xtop, $ytop, $xbottom, $ybottom, $this->colors["w"]);
      ImageRectangle ($usmap, $xtop, $ytop, $xbottom, $ybottom, $this->colors["r"]);
      ImageLine ($usmap, $xtop, $ytop, $xbottom, $ybottom, $this->colors["r"]);
      ImageLine ($usmap, $xtop, $ybottom, $xbottom, $ytop, $this->colors["r"]);

    } else {
      // each other square has its own color and a black border
      ImageFilledRectangle($usmap, $xtop, $ytop, $xbottom, $ybottom, $this->colors[$color]);
      ImageRectangle ($usmap, $xtop, $ytop, $xbottom, $ybottom, $this->colors["b"]);
    }

    // creating the alt tag
    // it will be added when we insert the map in the html code
    //$map .= "<area shape=\"rect\" alt=\"$alt\" coords=\"$xtop, $ytop, $xbottom, $ybottom\" href=\"$historyPage?tid_id=$tidid\">\n";
    $this->map .= "<area shape=\"rect\" onMouseOver=\"return overlib('". preg_replace("/'/", "\'", $alt) . "', CAPTION, '$tid', STICKY, MOUSEOFF, WRAP );\" onMouseOut=\"nd();\" coords=\"$xtop, $ytop, $xbottom, $ybottom\" href=\"pre_history.php?tid_id=$tidid\">\n";
  }

  /*
   * draw a line of color $color between 2 elements to represent a
   * facility path
   * @param $tidid1 the key in the hash of coordinates of the 1st element
   * @param $tidid2 the key in the hash of coordinates of the 2nd element
   * @param $color the color of the line */
  function createPath($tidid1, $tidid2, $color, $usmap)
  {
    $xdiff = $this->globalCoord[$tidid1]["x"] - $this->globalCoord[$tidid2]["x"];
    $ydiff = $this->globalCoord[$tidid1]["y"] - $this->globalCoord[$tidid2]["y"];

    // we have to draw 2 lines distant from 1 pixel
    // for it to be more visible
    // if the line is more horizontal than vertical, the 2nd line is
    // drawn right under it
    if (abs($xdiff) > abs($ydiff)) {
      $x11 = $this->globalCoord[$tidid1]["x"];
      $x12 = $this->globalCoord[$tidid2]["x"];
      $y11 = $this->globalCoord[$tidid1]["y"] - 1;
      $y12 = $this->globalCoord[$tidid2]["y"] - 1;

    } else {
      // if it is more vertical than horizontal, it is drawn on its side
      $x11 = $this->globalCoord[$tidid1]["x"] - 1;
      $x12 = $this->globalCoord[$tidid2]["x"] - 1;
      $y11 = $this->globalCoord[$tidid1]["y"];
      $y12 = $this->globalCoord[$tidid2]["y"];
    }

    if($this->debug >= 5) {
      print("Drawing a line from (" . $this->globalCoord[$tidid1]["x"] . "," . $this->globalCoord[$tidid1]["y"] . 
            ") to (" . $this->globalCoord[$tidid1]["x"] . "," . $this->globalCoord[$tidid1]["y"] . ")<br>\n");
      print("Drawing a line from ($x11,$y11) to ($x12,$y12)<br>\n");
    }

    // draw the 2 lines
    ImageLine($usmap, $this->globalCoord[$tidid1]["x"], $this->globalCoord[$tidid1]["y"], $this->globalCoord[$tidid2]["x"], $this->globalCoord[$tidid2]["y"], $color);
    ImageLine($usmap, $x11, $y11, $x12, $y12, $color);
  }



  function acquire_dataset($customer, $facility, $where)
  {
    # Must be overridden is sub classes.
  }



  function acquire_link_dataset($customer, $facility, $where)
  {
    # Must be overridden is sub classes.
  }



  function generate_map($customer, $facility)
  {
    set_time_limit(60);

    $where = "customer_id = $customer";
    if(isset($facility)) {
      $where .= " and facility_id in (" . join(",", $facility) . ")";
    }

    if($this->debug >= 5) {
      print("Base Image Name: " . $this->usMapImage . "<br>\n");
    }

    // create the php image from the png image of a US map
    $usmap=imagecreatefrompng($this->usMapImage);

    $this->__setupColors($usmap);

    if($this->debug >= 5) {
      print("DBH: " . $this->dbh . "<br>\n");
    }

    $this->acquire_dataset($where);

    if($this->debug >= 5) {
      print("# Items in Data Set: " . count($this->dataSet) . "<br>\n");
    }

    // place the network elements on the map
    for ($i = 0; $this->dataSet[$i]; $i++) {
      // the coordinates of the element
      $coord = $this->returnCoord($this->dataSet[$i]["longitude"], $this->dataSet[$i]["latitude"], $this->dataSet[$i]["tid_id"]);

      $flag = ($this->dataSet[$i]["flag"] ? $this->dataSet[$i]["flag"] : 'e');

      $alt = $this->generate_popup_info($this->dataSet[$i], $flag);

      $alt .= "Last Updated: " . $this->dataSet[$i]["lasttime"]. " GMT";

      // draw the square
      $this->createSquare($coord["x"], $coord["y"], $flag, $this->dataSet[$i]["tid_id"], $alt, $this->dataSet[$i]["tid"], $usmap);
    }


		if(isset($facility) && is_array($facility) && count($facility) == 1) { 
	    $this->acquire_link_dataset($where);

  	  if($this->debug >= 5) {
    	  print("# Items in Trans Data Set:" . count($this->transPaths) . "<br>\n");
      	print("# Items in Recv Data Set:" . count($this->recvPaths) . "<br>\n");
    	}

	    $this->draw_links($this->transPaths, $usmap);
  	  $this->draw_links($this->recvPaths, $usmap);
		}
		
    if(is_array($facility)) {
      if(count($facility) > 20) {
        for($i = 0; $i < 20; $i++) {
          $fac_string .= ($fac_string == "" ? "" : "_") . $facility[$i];
        }
      } else {
        $fac_string = join("_", $facility);
      }
    } else {
      $fac_string = "";
    }

    $image_name = "images/usa$customer$fac_string.png";

    // create the png image
    ImagePng($usmap, $image_name);
    ImageDestroy($usmap);

    return $image_name;
  }



  function next_link_color($colorInd)
  {
    $colorInd = $this->getNextColor($colorInd);
    $color = $this->colorSet[$colorInd];

    return array($colorInd, $color);
  }


  function draw_links($links, $usmap)
  {
    if($this->debug >= 5) {
      print("# Items in Data Set: " . count($links) ."<br>\n");
    }

    if (isset($links) && is_array($links)) {

      list($this->colorInd, $color) = $this->next_link_color($this->colorInd);

      for ($j = 0; isset($links[$j]); $j++) {
        if ($currFacility)
        {
          // if it is the same facility path as the previous square,
          // draw a line between them
          if ($links[$j]["facility_id"] == $currFacility && isset($previousTidid)) {
				    
				    if($this->debug >= 5) {
				      print("it is the same facility, creating the path between $previousTidid and " 
				      		. $links[$j]["tid_id"] . " with color $color<br>\n");
				    }
				    
            $this->createPath($previousTidid, $links[$j]["tid_id"], $this->colors[$color], $usmap);
          
          } else {
            list($this->colorInd, $color) = $this->next_link_color($this->colorInd);
				    
				    if($this->debug >= 5) {
				      print("new facility, getting another color: $color<br>\n");
				    }
            
          }
        }
        // remember the current facility, and the previous network element
        $currFacility = $links[$j]["facility_id"];
        $previousTidid = $links[$j]["tid_id"];
      }
    }
  }
}

?>

