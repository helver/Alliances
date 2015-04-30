<?php

include_once("TableUpdate.inc");

class tids_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "GeoNet Monitored Elements";
  var $table_name = "tids_list_view";
  var $listpage = "tids_list.php";
  var $detailspage = "outagedetail.php";

  # Now we're going to set up some arrays containing information about the
  # the database fields we'll be playing with.  Basically it's a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    global $sess;

    if($this->debug > 4) {
      print("In _init()<br>\n");
    }

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "datawrap" => 1,
                                "listline" => "\"<a href=\\\"update.php?table=tids&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=tids&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          "tid" => array ("required" => 0,
                                "display" => 1,
                                "name" => "TID",
                                "sorter" => "tidXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
                          "ipaddress" => array ("required" => 0,
                                "display" => 1,
                                "name" => "IP",
                                "sorter" => "ipaddressXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
											    'dwdm_facility' => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWDM Facility",
                                "admin" => 0,
                                "sorter" => "dwdm_facilityXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "listline" => "\"<a href=\\\"tids_list.php?filter=Filter&felementtype=&fstate=&fclli_tid=&fgroupnam=&fdwdmfac=\" . \$x[\"DWDM_FACILITY\"] . \"\\\">\" . \$x[\"DWDM_FACILITY\"] . \"</a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'grouping_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Grouping Name",
                                "admin" => 0,
                                "sorter" => "grouping_nameXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "listline" => "\"<a href=\\\"tids_list.php?filter=Filter&felementtype=&fstate=&fclli_tid=&fdwdmfac=&fgroupnam=\" . \$x[\"GROUPING_NAME\"] . \"\\\">\" . \$x[\"GROUPING_NAME\"] . \"</a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'element_type' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type",
                                "admin" => 0,
                                "sorter" => "element_type_idXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'city' => array ("required" => 0,
                                "display" => 1,
                                "name" => "City",
                                "admin" => 0,
                                "sorter" => "cityXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'flag' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Status",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "\"<a href=\\\"pre_history.php?tid_id=\" . \$x[\"ID\"] . \"\\\"><img src=\\\"images/\" . strtolower(\$x[\"FLAG\"]) . \".png\\\" width=\\\"30\\\" border=\\\"0\\\"></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function tids_list_viewUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }

}
?>
