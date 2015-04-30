<?php

#
# Class: LayoutBase
#
# LayoutBase is an abstract class used to define common functionality
# used by different GeoNet element type.  You should not use this class
# directly.
#
# Author: eric
# Create Date: 11/7/2002
#
# Revision: $Revision: 1.1 $
# Last Change Date: $Date: 2002-11-22 21:25:30 $
# Last Editor: $Author: eric $
#
# Development History:
# $Log: LayoutBase.inc,v $
# Revision 1.1  2002-11-22 21:25:30  eric
# Adding new Layout and map classes.
#
#

class LayoutBase
{

  var $config;      # ConfigFileReader Object.
  var $debug;       # Debugging Level.
  var $map;         # Image map information
  var $displayHTML; # HTML that needs to be displayed for the
                    # image to appear and for popups to work.
  var $pixMap;      # Complete set of used pixels
  var $image;       # Image to use for drawing on.
  var $colors;      # Array of colors allocated for the image.
  var $colorSet;    # Array of colors to use for links.

  #
  # Function: LayoutBase
  #
  # LayoutBase is the contstuctor for the class.  Basically all we're
  # doing here is setting our ConfigFileReader object and DBWrappr
  # object and then reading configuration values.
  #
  # LayoutBase has the following parameters:
  #   $config - ConfigFileReader object.
  #   $debug - Debugging level.
  #
  # LayoutBase returns on object of type LayoutBase.
  function LayoutBase($config, $image, $colors, $colorSet, $debug = 0)
  {
    # Setting Main Attributes.
    $this->config = $config;
    $this->image = $image;
    $this->colors = $colors;
    $this->colorSet = $colorSet;
    $this->debug = $debug || $config->getAttribute("DebugLevel") || 0;

    $this->__init();
  }


  function debug_output()
  {
    $this->__debugOutput();
  }


  function __debugOutput()
  {
  }


  function __init()
  {
  }


  /*
   * avoid the new square to overlap with any preexisting squares on the
   * map. If there is a square with which it would overlap, it adjusts
   * the coordinates of the new square. */
  function findPairNotTooClose($valueX, $valueY)
  {
  }

  /*
   * check if the new square may overlap with an existing square
   * on the map.
   * @param $valueX the x coordinate of the new square
   * @param $valueY the y coordinate of the new square
   * @return the coordinates of the square with which the new one
   *        may overlap, 0 o.w. */
  function isPixelOccupied($valueX, $valueY)
  {
    if(   isset($this->pixMap)
       && is_array($this->pixMap)
       && isset($this->pixMap[$valueX])
       && isset($this->pixMap[$valueX][$valueY])
      ) {
      if ($this->debug >= 3) {
        print("Receive value: $valueX, $valueY, already used.<BR>\n");
      }
      return 1;
    }
    return 0;
  }


  function claimPixel($x, $y)
  {
    if(! isset($this->pixMap) || ! is_array($this->pixMap)) {
      $this->pixMap = array();
    }

    if(! isset($this->pixMap[$x]) || ! is_array($this->pixMap[$x])) {
      $this->pixMap[$x] = array();
    }

    $this->pixMap[$x][$y] = 1;
  }


  function placeIcon($tidObj)
  {
  }


  function placeLink($tid1, $tid2, $color)
  {
  }

  function generatePopup($x1, $y1, $x2, $y2, $tidObj)
  {
    $this->displayHTML .=
    "<area shape=\"rect\" coords=\"$xtop, $ytop, $xbottom, $ybottom\" " .
    "onMouseOver=\"return overlib('". preg_replace("/'/", "\'", $alt) . "', CAPTION, '$tid', OFFSETY, -80 );\" " .
    "onMouseOut=\"nd();\" href=\"" . $tidObj->historyPage . "?tidid=" . $tidObj->tidInfo["tidid"] . "\">\n";
  }

  /*
   * draw a line of color $color between 2 elements to represent a
   * facility path
   * @param $tidid1 the key in the hash of coordinates of the 1st element
   * @param $tidid2 the key in the hash of coordinates of the 2nd element
   * @param $color the color of the line */
  function createPath($tidid1, $tidid2, $color)
  {
    global $globalCoord, $usmap;

    // we have to draw 2 lines distant from 1 pixel
    // for it to be more visible
    // if the line is more horizontal than vertical, the 2nd line is
    // drawn right under it
    if (abs($globalCoord[$tidid1]["x"] - $globalCoord[$tidid2]["x"]) > abs($globalCoord[$tidid1]["y"] - $globalCoord[$tidid2]["y"]))
    {
      $x11 = $globalCoord[$tidid1]["x"];
      $x12 = $globalCoord[$tidid2]["x"];
      $y11 = $globalCoord[$tidid1]["y"] - 1;
      $y12 = $globalCoord[$tidid2]["y"] - 1;
    }
    // if it is more vertical than horizontal, it is drawn on its side
    else
    {
      $x11 = $globalCoord[$tidid1]["x"] - 1;
      $x12 = $globalCoord[$tidid2]["x"] - 1;
      $y11 = $globalCoord[$tidid1]["y"];
      $y12 = $globalCoord[$tidid2]["y"];
    }

    // draw the 2 lines
    ImageLine($usmap, $globalCoord[$tidid1]["x"], $globalCoord[$tidid1]["y"], $globalCoord[$tidid2]["x"], $globalCoord[$tidid2]["y"], $color);
    ImageLine($usmap, $x11, $y11, $x12, $y12, $color);
  }


?>
