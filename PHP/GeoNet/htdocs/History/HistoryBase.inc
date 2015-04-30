<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: HistoryBase
 * Author: Eric Helvey
 * Create Date: 11/7/2002
 *
 * Description: HistoryBase is an abstract class used to define common 
 *              functionality used by different GeoNet element type.  You 
 *              should not use this class directly.
 *
 * Revision: $Revision: 1.25 $
 * Last Change Date: $Date: 2005-06-17 14:37:41 $
 * Last Editor: $Author: eric $
*/

class HistoryBase
{

  # Constants
  var $colorSet = array("cRed", "cDkGreen", "cOrange", "cDkBlue", "cHotPink");
  var $colorInd= 0;                   # Last color used.
  var $colors = array();              # Array of colors to use.
  var $pms = array();                 # List of PMs with labels.
  var $PMS = array();
  var $ErrorMinY = 0;                 # Error Range Min Val.
  var $ErrorMaxY = 0;                 # Error Range Max Val.
  var $WarnMinY = 0;                  # Warning Range Min Val.
  var $WarnMaxY = 0;                  # Warning Range Max Val.
  var $createOffset = 3;              # Offset PMS by this much from one another.
  var $xfieldname = "lasttimenumber"; # Field Name for the X-axis
  var $xfieldname2 = "lasttime";      # Alternate Field Name for the X-axis
  var $xlabel = "at";                 # Label for the X-axis
  var $graphOffSet = 0;               # How to offset multiple pms on the same graph.

  var $user;        # GeoNet User Object.
  var $config;      # ConfigFileReader Object.
  var $dbh;         # DBWrapper Object.
  var $debug;       # Debugging Level.
  var $dataSet;     # TID History Data Set
  var $map;         # Image map information
  var $tidInfo;     # Database result set containing TID information.
  var $displayHTML; # HTML that needs to be displayed for the
                    # image to appear and for popups to work.

  # Attributes that come from the Config File.
  var $imageName;           # Name of the base image.
  var $picWidth;            # Width of the base image.
  var $picHeight;           # Height of the base image.
  var $offSet;              # Offset to start on the image.
  var $heightYGridInPixel;  # Height of the grid lines in pixels
  var $ln;                  # Do we use log base 10 for Y values?
  var $inverse_ln;          # Undo log base 10 calculations.
  var $textSpacingX;        # X axis text spacing in pixels
  var $textSpacingY;        # Y axis text spacing in pixels
  var $textFont;            # Font to use for text.
  var $textGraphAxeFont;    # Font to use for Axis labelling.
  var $imagesFolder;        # Where images are located.


  # Calculated Attributes
  var $MINX;      # Absolute Minimum Time Value
  var $MAXX;      # Absolute Maximum Time Value
  var $MINY;      # Absolute Minimum Error Value
  var $MAXY;      # Absolute Maximum Error Values

  var $minx;      # Minimum X Pixel Location
  var $maxx;      # Maximum X Pixel Location
  var $miny;      # Minimum Y Pixel Location
  var $maxy;      # Maximum Y Pixel Location

  var $coeffx;    # Conversion factor between real X values and pixels.
  var $coeffy;    # Conversion factor between real Y values and pixels.
  var $xLegend;   # X Location of Legend Text.
  var $yLegend;   # Y Location of Legend Text.

  var $nbSecondsInOneDay;  # Maybe not needed
  var $gridIntervalX;      # X Grid Spacing


  function __cleanup()
  {
    unset($this->pms);
    $this->createOffset = 3;
    $this->ErrorMinY = 0;
    $this->ErrorMaxY = 0;
    $this->WarnMinY = 0;
    $this->WarnMaxY = 0;
    $this->xfieldname = "lasttimenumber";
    $this->xfieldname2 = "lasttime";
    $this->xlabel = "at";
    $this->colorInd = 0;
    $this->graphOffSet = 0;

    unset($this->dataSet);
    unset($this->map);

    unset($this->MAXX);
    unset($this->MAXY);
    unset($this->MINX);
    unset($this->MINY);
    unset($this->miny);
    unset($this->coeffx);
    unset($this->coeffy);
    unset($this->xLegend);
    unset($this->yLegend);

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
    print(  "minx: " . $this->minx
        . ", maxx: " . $this->maxx
        . ", MINX: " . $this->MINX
        . ", MAXX: " . $this->MAXX
        . ", miny: " . $this->miny
        . ", maxy: " . $this->maxy
        . ", MINY: " . $this->MINY
        . ", MAXY: " . $this->MAXY
        . ", coeffx: " . $this->coeffx
        . ", coeffy: " . $this->coeffy
        . ", WarnMaxY: " . $this->WarnMaxY
        . ", WarnMinY: " . $this->WarnMinY
        . ", ErrorMaxY: " . $this->ErrorMaxY
        . ", ErrorMinY: " . $this->ErrorMinY
        . ", createOffset: " . $this->createOffset
        . ", pms: " . $this->pms
        . ", colors: " . $this->colors
        . ", colorSet: " . $this->colorSet
        . ", nbSecondsInOneDay: " . $this->nbSecondsInOneDay
        . ", xLegend: " . $this->xLegend
        . ", yLegend: " . $this->yLegend
        . ", ln: " . $this->ln
        . ", xfieldname: " . $this->xfieldname
        . ", xfieldname2: " . $this->xfieldname2
        . ", xlabel: " . $this->xlabel
        . ", imageName: " . $this->imageName
        . ", picWidth: " . $this->picWidth
        . ", picHeight: " . $this->picHeight
        . ", offSet: " . $this->offSet
        . ", heightYGridInPixel: " . $this->heightYGridInPixel
        . ", inverse_ln: " . $this->inverse_ln
        . ", textSpacingX: " . $this->textSpacingX
        . ", textSpacingY: " . $this->textSpacingY
        . ", textFont: " . $this->textFont
        . ", textGraphAxeFont: " . $this->textGraphAxeFont
        . ", imagesFolder: " . $this->imagesFolder
        . ", debug: " . $this->debug
#        . ", $ln(MAXY): " . $this->ln($MAXY)
#        . ", $ln(MINY): " . $this->ln($MINY)
        . "<BR>\n");
  }




  #
  # Function: HistoryBase
  #
  # HistorBase is the contstuctor for the class.  Basically all we're
  # doing here is setting our ConfigFileReader object and DBWrappr
  # object and then reading configuration values.
  #
  # HistoryBase has the following parameters:
  #   $config - ConfigFileReader object.
  #   $dbh - DBWrapper object.
  #   $debug - Debugging level.
  #
  # HistoryBase returns on object of type HistoryBase.
  function HistoryBase(&$user, $config, $dbh, $debug = 0)
  {
    # Setting Main Attributes.
    $this->config = $config;
    $this->dbh = $dbh;
    $this->user = $user;
    $this->debug = $debug;

    $this->__init();

    if($this->debug >= 5) {
      print("ln: " . $this->ln . "<BR>\n");
    }
  }


  function __init()
  {
    $this->textSpacingY = $this->config->getAttribute("textSpacingY");
    $this->textSpacingX = $this->config->getAttribute("textSpacingX");
    $this->textFont = $this->config->getAttribute("textFont");
    $this->textGraphAxeFont = $this->config->getAttribute("textGraphAxeFont");
    $this->imagesFolder = $this->config->getAttribute("imagesFolder");
    $this->imageName = $this->config->getAttribute("graphImageName");
    $this->picWidth = $this->config->getAttribute("graphWidth");
    $this->picHeight = $this->config->getAttribute("graphHeight");
    $this->offSet = $this->config->getAttribute("graphOffSet");
    $this->heightYGridInPixel = $this->config->getAttribute("heightYGridInPixel");
    $this->ln = $this->config->getAttribute("logarithm");
    $this->inverse_ln = $this->config->getAttribute("inverse_logarithm");

    $this->xLegend = $this->picWidth - (4 * $this->offSet);
    $this->yLegend = round($this->picHeight/2) - (2 * $this->textSpacingY);

    $this->nbSecondsInOneDay = 24 * 60 * 60;
    $this->gridIntervalX = 60 * 60;
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
  function __setupColors($pic)
  {
    $this->colors["cWhite"] = ImageColorAllocate($pic,255,255,255);
    $this->colors["cRed"] = ImageColorAllocate($pic,255,0,0);
    $this->colors["cBlue"] = ImageColorAllocate($pic,0,0,255);
    $this->colors["cBlack"] = ImageColorAllocate($pic,0,0,0);
    $this->colors["cGreen"] = ImageColorAllocate($pic,20,255,20);
    $this->colors["cYellow"] = ImageColorAllocate($pic,255, 230, 51);
    $this->colors["cDkGreen"] = ImageColorAllocate($pic,0,207,0);
    $this->colors["cDkRed"] = ImageColorAllocate ($pic,207,0,0);
    $this->colors["cLtBlue"] = ImageColorAllocate ($pic, 102,204,255);
    $this->colors["cDkBlue"] = ImageColorAllocate ($pic, 51,51,255);
    $this->colors["cHotPink"] = ImageColorAllocate ($pic, 255,102,255);
    $this->colors["cOrange"] = ImageColorAllocate ($pic, 255,153,0);
    //$this->colors["cGrey"] = ImageColorAllocate ($pic, 192,192,192);
    $this->colors["cGrey"] = ImageColorAllocate ($pic, 147,147,147);
    $this->colors["cLightGrey"] = ImageColorAllocate ($pic, 212,212,212);
    $this->colors["cLightPink"] = ImageColorAllocate ($pic, 193,0,0);
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
  function __calculate_limits($tidid, $ifcid)
  {
    // X represents the time in seconds
    // select the minimum date to get the min of X on the graph
    $this->MINX = $this->dbh->SelectSingleValue("to_char(SYSDATE, 'SSSSS')", "DUAL");
    $this->MAXX = $this->MINX + $this->nbSecondsInOneDay;

    // select the max of each PMs to get the max of Y on the graph
    $maxError = $this->dbh->SelectFirstRow("*" ,"History_Max_Error_Counts_View", "tidid = $tidid and ifcid = $ifcid");

    if(!(isset($maxError) && is_array($maxError))) {
      $this->fatalError("No data found for the last 24 hours.");
    }

    foreach($maxError as $k=>$v) {
      if(!ereg("^c[0-9]+$", $k)) {
        continue;
      }

      if(!isset($this->MAXY)) {
        $this->MAXY = $v;
      }
      $this->MAXY = max($this->MAXY, $v);
    }

    if($this->debug >= 3) {
      print ("MAXY: " . $this->MAXY . "<br>\n");
      print ("YVal(MAXY): " . ($this->get_YValue($this->MAXY) * 1000). "<br>\n");
      print ("ceil(YVal(MAXY)): " . ceil($this->get_YValue($this->MAXY)) . "<br>\n");
      print ("ungetY(ceil(YVal(MAXY))): " . $this->unget_YValue(ceil($this->get_YValue($this->MAXY))) . "<br>\n");
    }

    $this->MAXY = $this->unget_YValue(ceil($this->get_YValue($this->MAXY)));


    if($this->ln == "logBase10") {
      $this->MINY = 0;
    } else {
	    // select the max of each PMs to get the max of Y on the graph
  	  $minError = $this->dbh->SelectFirstRow("*" ,"History_Min_Error_Counts_View", "tidid = $tidid and ifcid = $ifcid");

      foreach($minError as $k=>$v) {
        if(!ereg("^c[0-9]+$", $k)) {
          continue;
        }

        if($v == -1 || $v == "") {
          continue;
        }

        if(!isset($this->MINY)) {
          $this->MINY = $v;
        }
        $this->MINY = min($this->MINY, $v);
      }

    }

    if($this->debug >= 2) {
      print("MINX: " . $this->MINX . ", MAXX: " . $this->MAXX . "<BR>\n");
      print("MINY: " . $this->MINY . ", MAXY: " . $this->MAXY . "<BR>\n");
    }

    // coordinates in pixels on the graph are in lower case
    // there is a border of $offSet
    $this->minx = (strlen($this->MAXY) * ImageFontWidth($this->textGraphAxeFont)) + $this->textSpacingX + $this->offSet;

    foreach($this->PMS as $k=>$v) {
      $leg_length = max($leg_length, strlen($v));
    }

    if(isset($this->tps)) {
      foreach($this->tps as $k=>$v) {
        $leg_length = max($leg_length, strlen($this->tps[$k]));
      }
    }

    $this->maxx = $this->picWidth - ($leg_length * ImageFontWidth($this->textGraphAxeFont)) - $this->textSpacingX - $this->offSet - $this->textSpacingY;
    $this->miny = $this->picHeight - (2* $this->offSet);
    $this->maxy = $this->offSet;

    if($this->debug >= 3) {
      $this->debug_output();
    }

    // calculate the coefficient to transform time
    // and number of errors in pixels
    $this->coeffx = ($this->maxx - $this->minx) / ($this->MAXX - $this->MINX);

    if($this->MAXY == $this->MINY) {
      $this->coeffy = 1;
    } else {
      $this->coeffy = ($this->maxy - $this->miny) / ($this->get_YValue($this->MAXY) - $this->get_YValue($this->MINY));
    }

    if($this->debug >= 3) {
      print("YVal(MAXY): " . $this->get_YValue($this->MAXY) . " -- YVal(MINY): " . $this->get_YValue($this->MINY) . "<br>\n");
      $this->debug_output();
    }

  }



  function getNextColor()
  {
    if ($this->colorSet[$this->colorInd + 1]) {
      $this->colorInd += 1;

    } else {
      $this->colorInd = 0;
    }
  }




  function set_error_ranges($ErrorMinY = 0, $ErrorMaxY = 0, $WarnMinY = 0, $WarnMaxY = 0)
  {
    $this->ErrorMinY = $ErrorMinY;
    $this->ErrorMaxY = $ErrorMaxY;
    $this->WarnMinY = $WarnMinY;
    $this->WarnMaxY = $WarnMaxY;
  }


	function sorttime_sort($left, $right)
	{
		if($left["sorttime"] == $right["sorttime"]) {
			return 0;
		} elseif($left["sorttime"] < $right["sorttime"]) {
			return -1;
		}
		return 1;
	}

  function generate_history_graph($tidid, $ifcid)
  {
    $this->__calculate_limits($tidid, $ifcid);

		$this->dataSet = array();
		
    $this->dataSet[] = $this->dbh->SelectFirstRow("*", "History_Old_Counts_View", "tidid = $tidid and ifcid = $ifcid");
    $prev   = $this->dbh->Select("*", "History_Previous_Counts_View", "tidid = $tidid and ifcid = $ifcid");
    $curr   = $this->dbh->SelectFirstRow("*", "History_Current_Counts_View", "tidid = $tidid and ifcid = $ifcid");

    for($i = 0; isset($prev[$i]); $i++) {
      $this->dataSet[] = $prev[$i];
    }

    $this->dataSet[] = $curr;

    if($this->debug >= 5) {
      print("DataSet # of entries: " . count($this->dataSet) . "<br>\n");
    }

    return $this->printGraph();
  }



  function fatalError($msg = "Unknown Error")
  {
    print("<TR><TD CLASS=\"errorMessage\" ALIGN=\"CENTER\">");
    print("$msg</TD></TR></TABLE></BODY></HTML>");
    exit;
  }


  function logBase10($x)
  {
    if ($x > 0)
    {
      if($this->debug >= 6) {
        print ("x: $x -- log10(x): " . log10($x) . "<br>\n");
      }
      return log10($x);
    }
    else
    {
      return 0;
    }
  }

  function inverse_logBase10($x)
  {
     return (pow(10, $x));
  }



  function get_YValue($y)
  {
    $val = $y;

    if($this->ln != "") {
      eval("\$val = \$this->" . $this->ln . "(\$y);");
    }

    if($this->debug >= 6) {
      print "get_YValue($y): $val<br>\n";
    }

    return $val;
  }

  function unget_YValue($y)
  {
    $val = $y;

    if($this->inverse_ln != "") {
      eval("\$val = \$this->" . $this->inverse_ln . "(\$y);");
    }

    if($this->debug >= 6) {
      print "unget_YValue($y): $val<br>\n";
    }

    return $val;
  }

  /*
   * convert nb of errors and time into x and y coordinates for the graph
   * @param $X number of errors (value of CV, ES, SES, or UAS)
   * @param $Y the time (in number of seconds)
   * @param $minx the minimum value of x on the graph
   * @param $miny the minimum value of y on the graph
   * @return the coordinates on the graph */
  function returnCoord($X, $Y)
  {
    if ($this->debug >= 6) {
      print("X: $X, Y: $Y, ln: " . $this->ln . ", ");
    }

    $coord = array();

    $coord["x"] = round(($X - $this->MINX) * $this->coeffx + $this->minx);
    $coord["y"] = round(($this->get_YValue($Y) - $this->get_YValue($this->MINY)) * $this->coeffy + $this->miny);

    if ($this->debug >= 6) {
      print("x: " . $coord["x"] . ", y: " . $coord["y"] . " <BR>\n");
    }

    return $coord;
  }





  /*
   * display a dot on the graph and create the alt tag associated with it
   * @param $base_img the image on which the dot is to be drawn
   * @param $x the x coordinate of the dot
   * @param $y the y coordinate of the dot
   * @param $color the color of the dot
   * @param $value the X value of the dot (number of errors)
   * @param $alt the value of the alt tag to display */
  function displayDot($base_img, $x, $y, $value = 0, $alt="")
  {
    if ($this->debug >= 6) {
      print("x: $x, y: $y <BR>\n");
    }

    // draw the dot (a rectangle)
    ImageFilledRectangle($base_img, $x-1, $y-1, $x+1, $y+1, $this->get_color());

    // add the alt tag for this dot
    // if the number of errors is 0, the dot is less important, the user
    // has a 2x2 pixels area (the size of the dot) to mouse over and see
    // the alt tag. If the number of errors is different than 0, then a
    // 4x4 area is available to mouse over.

    $size = ($value > 0 ? 2 : 1);

    // creating the alt tag
    // it will be added when we insert the map in the html code
    //$map .= "<area shape=\"rect\" alt=\"$alt\" coords=\"$xtop, $ytop, $xbottom, $ybottom\" href=\"$historyPage?tid_id=$tidid\">\n";
    $this->map .= "<area shape=\"rect\" onMouseOver=\"return overlib('". preg_replace("/'/", "\'", $alt) . "', CAPTION, '$x,$y', STICKY, MOUSEOFF, WRAP );\" onMouseOut=\"nd();\" " 
                . "coords=\""
                . ($x - $size) . ", "
                . ($y - $size) . ", "
                . ($x + $size) . ", "
                . ($y + $size). "\" href=\"\">\n ";
  }





  /*
   * display a dot on the graph and create the alt tag associated with it
   * @param $base_img the image on which the dot is to be drawn
   * @param $x the x coordinate of the dot
   * @param $y the y coordinate of the dot
   * @param $color the color of the dot
   * @param $value the X value of the dot (number of errors)
   * @param $alt the value of the alt tag to display */
  function displayUpTriangle($base_img, $x, $y, $value = 0, $alt="")
  {
    if ($this->debug >= 6) {
      print("x: $x, y: $y <BR>\n");
    }

    $f = 8;

    // draw the dot (a rectangle)
    ImageFilledPolygon($base_img, array($x, $y - $f, $x - ($f/2), $y, $x + ($f/2), $y), 3, $this->get_color());

    // add the alt tag for this dot
    // if the number of errors is 0, the dot is less important, the user
    // has a 2x2 pixels area (the size of the dot) to mouse over and see
    // the alt tag. If the number of errors is different than 0, then a
    // 4x4 area is available to mouse over.

    $this->map .= "<area shape=\"poly\" alt=\"$alt\" coords=\""
                . $x . ", " . ($y - $f) . ", "
                . ($x - ($f/2)) . ", " . $y . ", "
                . ($x + ($f/2)) . ", " . $y . ", "
                . $x . ", " . ($y - $f)
                . "\" href=\"\">\n ";

    if($this->debug >= 5) {
      print ($this->map . "<br>\n");
    }
  }





  /*
   * display a dot on the graph and create the alt tag associated with it
   * @param $base_img the image on which the dot is to be drawn
   * @param $x the x coordinate of the dot
   * @param $y the y coordinate of the dot
   * @param $color the color of the dot
   * @param $value the X value of the dot (number of errors)
   * @param $alt the value of the alt tag to display */
  function displayDownTriangle($base_img, $x, $y, $value = 0, $alt="")
  {
    if ($this->debug >= 6) {
      print("x: $x, y: $y <BR>\n");
    }

    $f = 8;

    // draw the dot (a rectangle)
    ImageFilledPolygon($base_img, array($x, $y + $f, $x - ($f/2), $y, $x + ($f/2), $y), 3, $this->get_color());

    // add the alt tag for this dot
    // if the number of errors is 0, the dot is less important, the user
    // has a 2x2 pixels area (the size of the dot) to mouse over and see
    // the alt tag. If the number of errors is different than 0, then a
    // 4x4 area is available to mouse over.

    $this->map .= "<area shape=\"poly\" alt=\"$alt\" coords=\""
                . $x . ", " . ($y + $f) . ", "
                . ($x - ($f/2)) . ", " . $y . ", "
                . ($x + ($f/2)) . ", " . $y . ", "
                . $x . ", " . ($y + $f)
                . "\" href=\"\">\n ";
  }





  function __build_background()
  {
    $pic = ImageCreate($this->picWidth+1,$this->picHeight+1);

    $this->__setupColors($pic);

    // white background of the graph
    ImageFilledRectangle($pic,0,0,$this->picWidth,$this->picHeight,$this->colors["cWhite"]);
    // black border
    ImageRectangle($pic,0,0,$this->picWidth,$this->picHeight,$this->colors["cBlack"]);

    return $pic;
  }




  function __build_color_ranges($pic)
  {
    # If min > max, swap
    if ($this->ErrorMinY > $this->ErrorMaxY) {
      $t = $this->ErrorMaxY; $this->ErrorMaxY = $this->ErrorMinY; $this->ErrorMinY = $t;
    }

    # Shift the ranges to fit the data set.
    if ($this->ErrorMinY < $this->MINY) {
      $this->ErrorMinY = $this->MINY;
    }

    if ($this->ErrorMaxY > $this->MAXY) {
      $this->ErrorMaxY = $this->MAXY;
    }


    # If our range does not completely covers our data set then we're going
    # to fill in the Error ranges.
    if (!($this->ErrorMinY == $this->MINY && $this->ErrorMaxY == $this->MAXY))
    {
      # Calculate the corners for the box.
      $coordRangeMinY = $this->returnCoord($this->MINX, $this->ErrorMinY);
      $coordRangeMaxY = $this->returnCoord($this->MAXX, $this->ErrorMaxY);

      ImageFilledRectangle($pic, $coordRangeMinY["x"], $this->maxy, $coordRangeMaxY["x"], $coordRangeMaxY["y"], $this->colors["cRed"]);
      ImageFilledRectangle($pic, $coordRangeMinY["x"], $coordRangeMinY["y"], $coordRangeMaxY["x"], $this->miny, $this->colors["cRed"]);
    }



    # Fill in the lower Warning Region.
    if ($this->WarnMinY != "" && $this->WarnMinY > $this->ErrorMinY)
    {
      $coordAltRangeMinY = $this->returnCoord($this->MINX, $this->WarnMinY);
      if (!(isset($coordRangeMinY)))
      {
        $coordRangeMinY = $this->returnCoord($this->MINX, $this->ErrorMinY);
      }
      ImageFilledRectangle($pic, $this->minx, $coordAltRangeMinY["y"], $this->maxx, $coordRangeMinY["y"], $this->colors["cYellow"]);
    }




    # Fill in the upper Warning Region
    if ($this->WarnMaxY != "" && $this->WarnMaxY < $this->ErrorMaxY)
    {
      $coordAltRangeMaxY = $this->returnCoord($this->MINX, $this->WarnMaxY);
      if (!(isset($coordRangeMaxY)))
      {
        $coordRangeMaxY = $this->returnCoord($this->MAXX, $this->ErrorMaxY);
      }
      ImageFilledRectangle($pic, $this->minx, $coordRangeMaxY["y"], $this->maxx, $coordAltRangeMaxY["y"], $this->colors["cYellow"]);
    }
  }



  function __draw_horizontal_gridline($baseImage, $x, $y, $gridColor, $legend, $legendColor)
  {
    $coord = $this->returnCoord($x, $y);

    if($this->debug >= 5) {
      print("<br>\n<br>\nDrawing horizontal gridline at $coord[y] from " . $this->minx . " to " . $this->maxx . ".<br>\n");
    }

    ImageLine($baseImage,$this->minx,$coord["y"],$this->maxx,$coord["y"],$gridColor);

    ImageString ($baseImage,
                 $this->textGraphAxeFont,
                 $this->minx - (strlen($y) * ImageFontWidth($this->textGraphAxeFont)) - $this->textSpacingX,
                 $coord["y"] - round(ImageFontHeight($this->textGraphAxeFont)/2),
                 $legend,
                 $legendColor);
  }


  function __draw_vertical_gridline($baseImage, $x, $y, $gridColor, $legend, $legendColor)
  {
    $coord = $this->returnCoord($x, $y);

    if($this->debug >= 5) {
      print("<br>\n<br>\nDrawing vertical gridline at $coord[x] from " . $this->miny . " to " . $this->maxy . ".<br>\n");
    }

    ImageLine($baseImage,$coord["x"],$this->miny,$coord["x"],$this->maxy,$gridColor);

    $orig_miny = $this->miny;
    $this->miny = $this->miny - 2 * $this->offSet;
    $coord = $this->returnCoord($x, $y);

    $this->miny = $orig_miny;

    ImageString ($baseImage,
                 $this->textGraphAxeFont,
                 $coord["x"] - (2 * ImageFontWidth($this->textGraphAxeFont)),
                 $this->miny + round(ImageFontHeight($this->textGraphAxeFont)/2),
                 $legend,
                 $legendColor);
  }


  /*
   * draw a grid:
   * horizontally draw $numberOfLines lines with their legend
   * on the y axis
   * vertically draw a line every $increment hours and the legend
   * @param $baseImage the image on which we draw
   * @param $gridColor the color of the grid
   * @param $numberOfLines the number of horizontal lines
   * @param $legendColor the color of the legend
   * @param $legendFont the font used for the legend */
  function drawGrid($baseImage, $gridColor, $legendColor)
  {
    $intervaly = floor(abs($this->heightYGridInPixel / $this->coeffy));
    if($intervaly == 0) {
      $intervaly = $this->get_YValue($this->MAXY);
    }

    if($this->debug >= 3) {
      $this->debug_output();
      print("IntervalY: $intervaly<br>\n");
    }

    $flag = 1;

    for ($i=0; $flag; $i++) {
      if($this->debug >= 6) {
        print("YVal: " . $this->get_YValue($this->MINY) . " + "
           . ($i * $intervaly) . " <= " . $this->get_YValue($this->MAXY) . "<br>\n");
      }

      if (ceil($this->get_YValue($this->MINY) + ($i * $intervaly)) >= $this->get_YValue($this->MAXY)) {
        $flag = 0;
      }

      $realY = $this->unget_YValue($this->get_YValue($this->MINY) + ($i * $intervaly));

      if(($i == 0) && ($realY > $this->MINY)) {
        $realY = $this->MINY;
      }

      if($this->debug >= 5) {
        print("realY for horizontal Gridlines: $realY<br>\n");
      }
      $this->__draw_horizontal_gridline($baseImage, $this->MINX, $realY, $gridColor, $realY, $legendColor);
    }

    $legendTextSize = ImageFontWidth($this->textGraphAxeFont) * 5;
    $intervalCoord = $this->returnCoord($this->MINX + $this->gridIntervalX, $this->MINY);
    $lengthIntervalx = $intervalCoord["x"] - $this->minx;
    $increment = ceil(($legendTextSize + 10) / ($lengthIntervalx));

    if($this->debug >= 3) {
      $this->debug_output();
      print("IntervalX: " . $this->gridIntervalX . "<br>\n");
      print("Increment: $increment<br>\n");
    }

    $anotherDay = 0;
    $initialX = floor(($this->MINX / $this->gridIntervalX)) + 1;
    if ($initialX == 24) { $initialX = 0; $anotherDay = 1; }

    for ($realX = $initialX; (($anotherDay * $this->nbSecondsInOneDay) + ($realX * $this->gridIntervalX)) < $this->MAXX; $realX += $increment)
    {
      if($this->debug >= 3) {
        print("realX: $realX<br>\n");
        print((($anotherDay * $this->nbSecondsInOneDay) + ($realX * $this->gridIntervalX)) . "<" . $this->MAXX . "<br>\n");
      }

      $this->__draw_vertical_gridline($baseImage, (($realX * $this->gridIntervalX) + ($anotherDay * $this->nbSecondsInOneDay)), $this->MINY, $gridColor, $realX . ":00", $legendColor);

      if ($realX >= 24 - $increment) {
        $realX -= 24;
        $anotherDay++;
      }
    }

  }


  function __build_legend($pic, $label)
  {
    // First we create a couple of small lines.
    ImageLine($pic,
              $this->maxx + $this->textSpacingX,
              $this->yLegend,
              $this->maxx + $this->textSpacingX + $this->textSpacingY,
              $this->yLegend,
              $this->get_color());

    ImageLine($pic,
              $this->maxx + $this->textSpacingX,
              $this->yLegend + 1,
              $this->maxx + $this->textSpacingX + $this->textSpacingY,
              $this->yLegend + 1,
              $this->get_color());

    # Now we add the Legend Text.
    ImageString($pic,
                $this->textFont,
                $this->maxx + $this->textSpacingX + $this->textSpacingY + $this->textSpacingX,
                $this->yLegend - round(ImageFontHeight($this->textFont)/2),
                $label,
                $this->colors["cBlack"]);

    // get the y coordinate for the next PM
    $this->yLegend += $this->textSpacingY;
  }


  function get_color()
  {
    return $this->colors[$this->colorSet[$this->colorInd]];
  }

  function __graph_one_pm($pic, $pm)
  {
    if($this->debug >= 5) {
      print("Graphing $pm<br>\n");
    }

    $this->getNextColor();

    $tag = $this->pms[$pm];

    for ($i = 0; isset($this->dataSet[$i]); $i++) {

      if($this->debug >= 5) {
        print($this->dataSet[$i] . "<br>\n");
        print("graph_one_pm: pm = $pm -- $tag -- row $i of dataset -- " . $this->dataSet[$i][$this->xfieldname] . "," . $this->dataSet[$i][$tag] . "<br>\n");
      }

      if (isset($this->dataSet[$i][strtolower($tag)])) {

        $coord = $this->returnCoord($this->dataSet[$i][$this->xfieldname], $this->dataSet[$i][$tag]);
        
        if($this->dataSet[$i][$tag] == 0) {
        	$coord["y"] -= $this->graphOffSet;
        }

        if($this->debug >= 5) {
          print("<br>\n<br>\nDrawing dot at $coord[x] $coord[y]<br>\n");
        }

        // if the coordinates are valid
        if (isset($coord) && is_array($coord))
        {
          // create the alt tag
          $alt = $this->PMS[$tag] . " at ".$this->dataSet[$i][$this->xfieldname2].", count: ".$this->dataSet[$i][$tag];

          if($this->dataSet[$i][strtolower($tag)] == -1) {
            // if a previous dot has been drawn, draw a line between them
            if (isset($previousCoord) && is_array($previousCoord)) {
              ImageLine($pic,$previousCoord["x"],$previousCoord["y"],$coord["x"], $previousCoord["y"],$this->get_color());
            }

            unset($previousCoord);
            continue;

          } else {

            // if a previous dot has been drawn, draw a line between them
            if (isset($previousCoord) && is_array($previousCoord)) {
              ImageLine($pic,$previousCoord["x"],$previousCoord["y"],$coord["x"], $previousCoord["y"],$this->get_color());
              #ImageLine($pic,$previousCoord["x"],$previousCoord["y"]+1,$coord["x"], $previousCoord["y"]+1,$this->get_color());
              #ImageLine($pic,$previousCoord["x"],$previousCoord["y"]-1,$coord["x"], $previousCoord["y"]-1,$this->get_color());
              ImageLine($pic,$coord["x"],$previousCoord["y"],$coord["x"], $coord["y"],$this->get_color());
            }

            // draw the dot
            $this->displayDot($pic, $coord["x"], $coord["y"], $this->dataSet[$i][$tag], $alt);

            // remember the coordinates of the previous dot
            $previousCoord = $coord;
          }
        }
      }
    }

    $this->__build_legend($pic, $this->PMS[$tag]);
  }




  function __graph_one_tp($pic, $tp)
  {
    if($this->debug >= 5) {
      print("Graphing $tp<br>\n");
    }

    $this->getNextColor();

    $tag = $this->tps[$tp];

    for ($i = 0; $this->dataSet[$i]; $i++) {

      if($this->debug >= 5) {
        print($this->dataSet[$i] . "<br>\n");
        print("tp = $tp -- " . $this->dataSet[$i][$tp] . "<br>\n");
      }

      if (isset($this->dataSet[$i][strtolower($tp)]) && $this->dataSet[$i][strtolower($tp)] != 0) {

        $coord = $this->returnCoord($this->dataSet[$i][$this->xfieldname], 1);
        $coord["y"] = $this->maxy + $this->graphOffSet;

        if($this->debug >= 5) {
          print("<br>\n<br>\nDrawing triangle at $coord[x] $coord[y]<br>\n");
        }

        // if the coordinates are valid
        if (isset($coord) && is_array($coord))
        {
          // create the alt tag
          $alt = "$tag at ".$this->dataSet[$i][$this->xfieldname2].", count: ".$this->dataSet[$i][$tp];

          if($this->dataSet[$i][strtolower($tp)] == -1) {
            // draw the dot
            $this->displayDownTriangle($pic, $coord["x"], $coord["y"], $this->dataSet[$i][$tp], $alt);
          } else {
            // draw the dot
            $this->displayUpTriangle($pic, $coord["x"], $coord["y"], $this->dataSet[$i][$tp], $alt);
          }
        }
      }
    }

    $this->__build_legend($pic, $this->tps[$tp]);
  }




  /**
   * create a graph as a png image and display it in an html table
   * @param createOffset the size of the offset between several curves
   *        in pixels
   * @param rangeMinY: draw a red zone of the width of the graph,
   *        starting at $rangeMinY, ending at $MINY
   * @param rangeMaxY: draw a red zone of the width of the graph,
   *        starting at $rangeMaxY, ending at $MAXY
   * @param alternateRangeMinY: draw a yellow zone of the width of the graph,
   *        starting at $alternateRangeMinY, ending at $rangeMinY
   * @param alternateRangeMaxY: draw a yellow zone of the width of the graph,
   *        starting at $alternateRangeMaxY, ending at $rangeMaxY */
  function printGraph()
  {
    if ($this->debug > 3) {
      $this->debug_output();
    }

    // create the image
    $pic = $this->__build_graph();

    // create the png file and display it
    ImagePNG($pic, $this->imageName.".png");
    ImageDestroy($pic);

    $this->displayHTML = "<img src=\"" . $this->imageName . ".png"
       . "?changingvalue=" . date("G:i:s") . "\" border=\"0\" usemap=\"#graph" . $this->imageName . "\">\n"
       . "<map name=\"graph" . $this->imageName . "\">\n" . $this->map . "</map>\n";

    $this->__cleanup();

    return $this->displayHTML;
  }


  function __build_graph()
  {
    // create the image
    $pic = $this->__build_background();

    // eventually create yellow and red range zones
    if ($this->ErrorMinY != 0 && $this->ErrorMaxY != 0 && $this->WarnMinY != 0 && $this->WarnMaxY != 0) {
      $this->__build_color_ranges($pic);
    }

    // draw the grid
    $this->drawGrid($pic, $this->colors["cGrey"], $this->colors["cBlack"]);

    #$this->debug_output();

    // print the axes
    ImageLine($pic,$this->minx,$this->miny,$this->minx,$this->maxy,$this->colors["cBlack"]);
    ImageLine($pic,$this->minx,$this->miny,$this->maxx,$this->miny,$this->colors["cBlack"]);
    ImageLine($pic,$this->maxx,$this->miny,$this->maxx,$this->maxy,$this->colors["cBlack"]);
    ImageLine($pic,$this->minx,$this->maxy,$this->maxx,$this->maxy,$this->colors["cBlack"]);

    #$this->debug_output();

    $orig_miny = $this->miny;

    // draw a graph for each field
    foreach($this->pms as $k => $v) {
      #$this->miny = $orig_miny - $this->graphOffSet;
      $this->graphOffSet += $this->createOffset;

			#print("Going to graph one pm:  k: $k -- v: $v -- offset:" . $this->graphOffSet . "<br><br><br>\n");
			
      $this->__graph_one_pm($pic, $k);
    }


    if(isset($this->tps)) {
      // draw a graph for each field
      foreach($this->tps as $k => $v) {
        $this->graphOffSet += ($this->createOffset * 6);
        $this->__graph_one_tp($pic, $k);
      }
    }

    $this->miny = $orig_miny;

    return $pic;
  }




  function graphLightLevel($tidid)
  {
    unset($this->ln);
    unset($this->inverse_ln);
    $this->MAXY = $this->WarnMaxY;
    $this->MINY = $this->WarnMinY;
    $this->picWidth = $this->picWidth/2;

    return $this->generate_history_graph($tidid);
  }





  function ATM_Element_Info($tidid)
  {
    // select the general info on this element (TID, IP address,
    // Facility, ...)
    unset($dbTidInfo);
    $dbTidInfo = $this->dbh->Select(
        "d.tidid, d.tid, ipaddress, channel, trans_facility_path, shelf, flag, cause, "
      . "Slot_Transmitter, Slot_Receiver, c.city, to_char(d.timeentered, 'MM-DD-YYYY HH24:MI:SS') lasttime, "
      . "e.element_type",

        "TID d, city c, element_type e",

        "d.cityid = c.cityid and d.element_typeid = e.element_typeid and "
      . "tidid = $tidid");

		$newest = $dbTidInfo[0];
		for($i = 1; isset($dbTidInfo[$i]); $i++) {
			if($dbTidInfo[$i]["sorttime"] > $newest["sorttime"]) {
				$newest = $dbTidInfo[$i];
			}
		}
		
    $this->tidInfo = $newest;

    $res = $this->dbh->Select("f.facility as facility, c.customer, c.customerid",
      "facility_map fm, facility f, customer c",
      "$tidid = fm.tidid and fm.facilityid = f.facilityid and f.customerid = c.customerid");

    for($i = 0; $res[$i]; $i++) {
      $this->tidInfo["facility"] .= $res[$i][0] . " ";
      $this->tidInfo["customer"] = $res[$i][1];
      $this->tidInfo["customerid"] = $res[$i][2];
    }

    $query_fields = join(",", array("transmit_cv, transmit_es, transmit_ses, receive_cv, receive_es, receive_ses"));

    $shelf = $dbTidInfo[0]["shelf"];
    $channel = $dbTidInfo[0]["channel"];

    $port = substr($shelf, 0, 1) . (pack("C", (ord('A') + substr($shelf, 1, 1)))) . substr($shelf, 2);

    if($channel != "") {
      $port .= "[";
      for($j = 0; $j < strlen($channel); $j++) {
        $port .= substr($channel, $j, 1) . ",";
      }
      $port = ereg_replace(",$", "]", $port);
    }

    $this->tidInfo["port"] = $port;

    $this->transportTypes = array("30" => "DS3",
                                  "50" => "Sonet",
                                  "18" => "DS1",
                                 );
  }


  function display_ATM_Info()
  {
    $html = "<TABLE CELLPADDING=\"7\">\n";

    $html .= "<TR>\n<TD CLASS=\"content\" ALIGN=\"left\"><B>" . $this->tidInfo["city"] . "</B></TD>\n";
    $html .= "<TD CLASS=\"content\">NVC IDs: " . $this->tidInfo["facility"] . "</TD>\n</tr>\n";

    $html .= "<TR>\n<TD nowrap CLASS=\"content\">Path Sequence #: " . $this->tidInfo["trans_facility_path"] . "</TD>\n";
    $html .= "<TD CLASS=\"content\">" . $this->tidInfo["tid"] . "</TD>\n</tr>\n";

    if($this->user->hasAccessLevel("InternalUser")) {
      $html .= "<TR>\n<TD CLASS=\"content\">" . $this->tidInfo["ipaddress"] . "</TD>\n";
      $html .= "<TD CLASS=\"content\">Port: " . $this->tidInfo["port"] . "</TD>\n</tr>\n";

      $html .= "<TR>\n<TD CLASS=\"content\">Transport: " . $this->tidInfo["slot_transmitter"] . "</TD>\n";
      $html .= "<TD CLASS=\"content\">Element type: " . $this->tidInfo["element_type"] . "</TD>\n</tr>\n";
    }
    
    if($this->tidInfo["cause"] == "") {
      $html .= "<tr>\n<td colspan=\"2\" class=\"content\">Current Status: <img height=\"14\" src=\"images/" . $this->tidInfo["flag"] . ".png\"></td>\n</tr>\n";
    } else {
      $html .= "<tr>\n<td nowrap class=\"content\">Current Status: <img height=\"14\" src=\"images/" . $this->tidInfo["flag"] . ".png\"></td>\n";
      $html .= "<td class=\"content\">Cause: " . $this->tidInfo["cause"] . "</td>\n</tr>\n";
    }

    $html .= "<TR>\n<TD colspan=\"2\" CLASS=\"content\">Last Updated: " . $this->tidInfo["lasttime"] . " GMT</TD>\n</tr>\n";

    $html .= "</table>\n";

    return $html;
  }




  function DWS_Element_Info($tidid, $ifcid)
  {
    $dbTidInfo = $this->dbh->Select("*", "History_Dataset_View", "tid_id = $tidid and interface_id = $ifcid");

		$newest = $dbTidInfo[0];
		for($i = 1; isset($dbTidInfo[$i]); $i++) {
			if($dbTidInfo[$i]["sorttime"] > $newest["sorttime"]) {
				$newest = $dbTidInfo[$i];
			}
		}
		
    $this->tidInfo = $newest;

    // if the element is on a transmitter path,
    // we'll request the transmit data from the database and
    // we'll show the transmit PM graph
    if (   (   isset($dbTidInfo["trans_facility_path"]) 
            && $dbTidInfo["trans_facility_path"] > 0) 
        || $dbTidInfo["element_type"] == "Alcatel 1640 WM" 
        || $dbTidInfo["element_type"] == "Alcatel 1640 WADM")
    {
      array_push($this->states, "transmit");
    }

    // if the element is on a receiver path,
    // we'll request the receive data from the database and
    // we'll show the receive PM graph
    if (   (   isset($dbTidInfo["recv_facility_path"]) 
            && $dbTidInfo["recv_facility_path"] > 0) 
        || $dbTidInfo["element_type"] == "Alcatel 1640 WM" 
        || $dbTidInfo["element_type"] == "Alcatel 1640 WADM")
    {
      array_push($this->states, "receive");
    }

    $queue_status = $this->dbh->Select("active, to_char(timeentered, 'MM/DD/YYYY HH24:MI:SS') as timeentered", "tid_queue", "tid_id = '" . $this->tidInfo["tid_id"] . "'");

    if(!isset($queue_status[0])) {
      $this->tidInfo["queue_status"] = "Not In Queue";
      $this->tidInfo["queue_add_time"] = "";
    } else {
      $this->tidInfo["queue_status"] = ( isset($queue_status[0]) && isset($queue_status[0]["active"]) && $queue_status[0]["active"] == 1 ? "In Progress" : "In Queue");
      $this->tidInfo["queue_add_time"] = ereg_replace(" ", "&nbsp;", $queue_status[0]["timeentered"]);
    }
  }



  function __display_some_tidinfo($thefields, $numcols)
  {
		$i = 0;
		$html = "";
		
    for($j = 0; isset($thefields[$j]); $j++) {
    	if(   !isset($this->tidInfo[$thefields[$j] . "_lbl"]) 
    	   || (   !isset($this->tidInfo[$thefields[$j]])
    	       && !isset($this->tidInfo[$thefields[$j] . "_val"])
    	  )) {
    	  continue;
    	}
    	
    	if(($i % $numcols) == 0) {
    		$html .= "<tr>\n";
    	}
    	
      $html .= "<TD nowrap CLASS=\"content\">" . $this->tidInfo[$thefields[$j] . "_lbl"] . ": " . (isset($this->tidInfo[$thefields[$j]]) ? $this->tidInfo[$thefields[$j]] : $this->tidInfo[$thefields[$j] . "_val"]) . "</TD>";

    	if(($i % $numcols) == ($numcols - 1)) {
    		$html .= "</tr>\n";
    	}
    	
    	$i++;
    }

		if(($i % $numcols) != ($numcols - 1)) {
			while(($i % $numcols) != ($numcols - 1)) {
				#print("$i<br>\n");
				$html .= "<td>&nbsp;</td>\n";
				$i++;
			}
			$html .= "</tr>\n";
		}
		
		return $html;
  }
  		

  function display_DWS_Info()
  {
  	if($this->debug >= 5) {
  		print("<pre>\n");
    	print_r($this->tidInfo);
    	print("</pre>\n");
  	}
  	
    $html = "<TABLE CELLPADDING=\"3\">\n";

    $html .= "<TR>\n<TD CLASS=\"content\"><b>" . $this->tidInfo["tid"] . " / " . $this->tidInfo["ifname"] . "</b></TD>\n";
    $html .= "<TD nowrap CLASS=\"content\" ALIGN=\"left\"><B>" . $this->tidInfo["city"] . ", " . $this->tidInfo["state"] . "</B></TD>\n</tr>\n";

    if($this->user->hasAccessLevel("InternalUser")) {
      $html .= "<TR>\n<TD colspan=\"2\" CLASS=\"content\">" . $this->tidInfo["ipaddress"] . "</TD>\n</tr>\n";
      $html .= "<TR>\n<TD colspan=\"2\" CLASS=\"content\">Element type: " . $this->tidInfo["element_type"] . "</TD>\n</tr>\n";

	  	$html .= $this->__display_some_tidinfo(array("ifname", "e1", "e2", "e3", "e4", "e5"), 2);
    }
    
		$html .= "<tr><td colspan=\"2\"><hr></td></tr>\n";
				
    $html .= "<TR>\n<TD colspan=\"2\" nowrap CLASS=\"content\">Customer: " . $this->tidInfo["customer"] . " &nbsp; <a href=\"map.php?customer=" . $this->tidInfo["customer_id"] . "\">(Customer Map)</a></TD>\n</tr>\n";
    $html .= "<TR>\n<TD colspan=\"2\" nowrap CLASS=\"content\">Facility: " . $this->tidInfo["facility"] . " &nbsp; <a href=\"map.php?customer=" . $this->tidInfo["customer_id"] . "&facility[]=" . $this->tidInfo["facility_id"] . "\">(Facility Map)</a> &nbsp; " . ($this->user->hasAccessLevel("InternalUser") ? "<a href=\"facility_walk_list.php?fhidfac=" . $this->tidInfo["facility_id"] . "\">(Breakdown)</a>" :"") . "</TD>\n</tr>\n";

    $html .= "<TR>\n<TD nowrap CLASS=\"content\">Trans Seq: " . $this->tidInfo["trans_facility_path"] . "</TD>\n";
    $html .= "<TD CLASS=\"content\">Recv Seq: " . $this->tidInfo["recv_facility_path"] . "</TD>\n</tr>\n";

		$html .= "<tr><td colspan=\"2\"><hr></td></tr>\n";
				
    if($this->tidInfo["cause"] == "") {
      $html .= "<tr>\n<td colspan=\"2\" class=\"content\">Current Status: <img height=\"14\" src=\"images/" . strtolower($this->tidInfo["flag"]) . ".png\"></td>\n</tr>\n";
    } else {
      $html .= "<tr>\n<td class=\"content\">Current Status: <img height=\"14\" src=\"images/" . strtolower($this->tidInfo["flag"]) . ".png\"></td>\n";
      $html .= "<td class=\"content\">Cause: " . $this->tidInfo["cause"] . "</td>\n</tr>\n";
    }
    
    if($this->user->hasAccessLevel("InternalUser")) {
      $html .= "<tr>\n<td colspan=\"2\" class=\"content\"><a href=\"resetflag.php?tid_id=" . $this->tidInfo["tid_id"] . "&interface_id=" . $this->tidInfo["interface_id"] . "\">Reset Flag</a></td></tr>\n";
    }
      
    if($this->tidInfo["note"] != "") {
	  	$html .= "<tr><td colspan=\"2\"><hr></td></tr>\n";
      $html .= "<TR>\n<TD colspan=\"2\" CLASS=\"content\">Note: " . $this->tidInfo["note"] . "</TD>\n</tr>\n";
  		$html .= "<tr><td colspan=\"2\"><hr></td></tr>\n";
    }

    $html .= "<TR>\n<TD colspan=\"2\" CLASS=\"content\">Last Updated: " . $this->tidInfo["lasttime"] . " GMT</TD>\n</tr>\n";

    $html .= "<TR>\n<TD CLASS=\"content\">Queue Status:<br>" . $this->tidInfo["queue_status"] . "<TD CLASS=\"content\">In Queue Since:<br>" . ($this->tidInfo["queue_add_time"] == "" ? "" : $this->tidInfo["queue_add_time"] . "&nbsp;GMT") . "</TD>\n</tr>\n";

    if($this->user->hasAccessLevel("InternalUser")) {
      $html .= "<tr><td colspan=\"2\" class=\"content\"><a href=\"runone.php?tid=" . $this->tidInfo["tid"] . "\">Add (or Re-Add) this TID to the Queue</a></td></tr>\n";
    }
    
    $html .= "</table>\n";

    return $html;
  }


  function additionalButtons()
  {
  }

  function graphAdditionals()
  {
  }


  function getTidInfo($field)
  {
    return $this->tidInfo[$field];
  }

}
?>

