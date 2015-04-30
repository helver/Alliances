<?php

include_once("TableUpdate.inc");

class outage_procedure_list_viewUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "DWS Outage Procedures";
  var $table_name = "outage_procedure_list_view";
  var $listpage = "outage_proc_list.php";
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
                                "wrap" => "nowrap ",
                                "datawrap" => 1,
                                "listline" => "\"<a href=\\\"update.php?table=outage_procedure&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Edit</span></a><br><a href=\\\"update.php?oper=view&table=outage_procedure&id=\" . \$x[\"ID\"] . \"\\\"><span class=\\\"contentsmalllink\\\">Details</span></a>\"",
                                "args" => array()),

                          "label" => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWS Outage Procedure",
                                "sorter" => "labelXXX",
                                "datawrap" => 0,
                                "args" => array()),
 
                          "customers" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customers",
                                "datawrap" => 0,
                                "args" => array()),
 
                          "dws_outage_ticket" => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWS Outage Ticket",
                                "sorter" => "dws_outage_ticketXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "dwdm_unavailability_ticket" => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWDM Unavailability Ticket",
                                "sorter" => "dwdm_unavailability_ticketXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "tsa_super_notification" => array ("required" => 0,
                                "display" => 1,
                                "name" => "TSA Supervisor Notification",
                                "sorter" => "tsa_super_notificationXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "ncc_notification" => array ("required" => 0,
                                "display" => 1,
                                "name" => "NCC Notification",
                                "sorter" => "ncc_notificationXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "nsm_notification" => array ("required" => 0,
                                "display" => 1,
                                "name" => "NSM Notification",
                                "sorter" => "nsm_notificationXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "noc_notification" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer NOC Notification",
                                "sorter" => "noc_notificationXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "ncc_page" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Does NCC Send Page?",
                                "sorter" => "ncc_pageXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "alt_route" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Perform Alt-Route?",
                                "sorter" => "alt_routeXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "notification_interval" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Dispatch Notification Interval",
                                "sorter" => "notification_intervalXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "deferred" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Can Be Deferred?",
                                "sorter" => "deferredXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "dws_outage_report" => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWS Outage Report?",
                                "sorter" => "dws_outage_reportXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "maintenance_window" => array ("required" => 0,
                                "display" => 1,
                                "name" => "Extended Maintenance Window",
                                "sorter" => "maintenance_windowXXX",
                                "datawrap" => 1,
                                "args" => array()),
 
                          "nsm" => array ("required" => 0,
                                "display" => 1,
                                "name" => "NSM",
                                "sorter" => "nsm_idXXX",
                                "datawrap" => 0,
                                "args" => array()),
 
                 );

    if($this->debug > 4) {
      print("this->fields[id][value]: " . $this->fields[$this->id]["value"] .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function management_report_list_viewUpdate($con, $dbg = 0, $app = "")
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
