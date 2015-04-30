<?php

include_once("TableUpdate.inc");

class facility_walk_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Facility Breakdown";
  var $table_name = "if_status_tid_and_cust_view";
  var $listpage = "facilities_list.php";
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

    $this->fields = array("tid" => array ("required" => 0,
                                "display" => 1,
                                "name" => "TID",
                                "sorter" => "tidXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),
 
											    'interface' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Interface",
                                "admin" => 0,
                                "sorter" => "interfaceXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'customer' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer",
                                "admin" => 0,
                                "sorter" => "customerXXX",
                                "excelonly" => 0,
                                "datawrap" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'element_type' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type",
                                "admin" => 0,
                                "sorter" => "element_typeXXX",
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
#                                "listline" => "\"<a href=\\\"update.php?table=facilities&id=\" . \$x[\"ID\"] . \"\\\">Edit</a><br><a href=\\\"update.php?oper=view&table=facilities&id\" . \$x[\"ID\"] . \"\\\">Details</a><br><a href=\\\"build_facility.php?id=\" . \$x[\"ID\"] . \"\\\">Build</a>\"",
                                "listline" => "\"<a href=\\\"map.php?customer=\" . \$x[\"CUSTOMER_ID\"] . \"&facility[]=" . $_REQUEST["fhidfac"] . "\\\"><img src=\\\"images/\" . strtolower(\$x[\"FLAG\"]) . \".png\\\" width=\\\"30\\\" border=\\\"0\\\"></a>\"",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'trans_seq' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Trans Seq",
                                "sorter" => "trans_seqXXX",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
                                "args" => array()),

											    'recv_seq' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Recv Seq",
                                "sorter" => "recv_seqXXX",
                                "admin" => 0,
                                "wrap" => "nowrap ",
                                "excelonly" => 0,
                                "listline" => "nbsp",
                                "widget" => "display_hidden_field",
                                "args" => array()),

                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function facility_walk_list_viewUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificUpdate($id)
  {
  }

  function specificInsert($id)
  {
  }

  function specificDelete($id)
  {
  }

}
?>
