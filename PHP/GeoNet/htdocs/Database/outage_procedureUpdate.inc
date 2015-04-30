<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: customersUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for customers table.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-07-18 21:31:56 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class outage_procedureUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Outage Procedures";
  var $table_name = "outage_procedure";
  var $seq = "outage_procedure_id_seq";
  var $report_label = "Outage Procedures";
  var $listpage = "outage_proc_list.php";
  var $cols_for_display = 5;
  var $return_page;
  var $onSubmit = "selectAll(this, 'customers');";

  # Now we''re going to set up some arrays containing information about the
  # the database fields we''ll be playing with.  Basically it''s a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    if($this->debug > 4) {
      print("In _init()<br>\n");
    }

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "Outage Proc ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'customers' => array ("required" => 0,
                          			"nondb" => 1,
                                "display" => 1,
                                "name" => "Customers",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","customers", "", $this->dbh, "", "name")),

                          'nsm_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "NSM",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("u.id, u.lastname || ', ' || u.firstname","users u, appladmin.security a", "u.id = a.personid and a.accesslevel = 8", $this->dbh, "N/A", "u.lastname, u.firstname")),

                          'label' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"50")),

                          'dws_outage_ticket' => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWS Outage Ticket",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'dwdm_unavailability_ticket' => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWDM Unavailability Ticket",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'tsa_super_notification' => array ("required" => 0,
                                "display" => 1,
                                "name" => "TSA Super Notification",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                          'ncc_notification' => array ("required" => 0,
                                "display" => 1,
                                "name" => "NCC Notification",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'noc_notification' => array ("required" => 0,
                                "display" => 1,
                                "name" => "NOC Notification",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'nsm_notification' => array ("required" => 0,
                                "display" => 1,
                                "name" => "NSM Notification",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'ncc_page' => array ("required" => 0,
                                "display" => 1,
                                "name" => "NCC Page",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'alt_route' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Alt-Route",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'notification_interval' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Notification Interval",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'deferred' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Deferred",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                          'dws_outage_report' => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWS Outage Report",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                          'maintenance_window' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Maintenance Window",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"80")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=";
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function outage_procedureUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function __customerAssignment($id)
  {
    $this->dbh->Delete("proc_customer_map", "speed_id = $id");
    if(isset($_REQUEST["customers"]) && is_array($_REQUEST["customers"])) {
      foreach($_REQUEST["customers"] as $k) {
        $this->dbh->Insert("proc_customer_map", array("outage_proc_id" => $id, "customer_id" => $k));
      }
    }
  }

  function __customerUnassignment($id)
  {
    $this->dbh->Delete("proc_customer_map", "outage_proc_id = $id");
  }

  function specificInsert($id)
  {
  	$this->return_page .= urlencode($id);
  	$this->__customerAssignment($id);
  }

  function specificUpdate($id)
  {
  	$this->return_page .= urlencode($id);
  	$this->__customerAssignment($id);
  }

  function specificDelete($id)
  {
  	$this->__customerUnassignment($id);
  }

  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, all_customers_for_proc(this.id) as customer_id, u.lastname || ', ' || u.firstname as nsm_id, this.label, this.dws_outage_ticket, this.dwdm_unavailability_ticket, " .
      "this.tsa_super_notification, this.ncc_notification, this.nsm_notification, " .
      "this.noc_notification, this.ncc_page, this.alt_route, this.notification_interval, " .
      "this.deferred, this.dws_outage_report, this.maintenance_window",

      $this->table_name . " this, customers c, users u",

      "this.nsm_id = u.id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
  
  function generateFields($edit=0)
  {
    $html = "";

    foreach($this->fields as $k=>$v) {
      if($this->fields[$k]["display"] == 1) {
        if($k == "customers") {
          $servers = $this->dbh->SelectMap("id, name", "customers", "", "name");
          $used = $this->dbh->SelectMap("s.id, s.name", "customers s, proc_customer_map sa", "sa.customer_id = s.id and sa.outage_proc_id = " . $this->fields[$this->id]["value"]);

          $html .= "<tr><td colspan=\"2\"><table border=\"0\"><tr><td class=\"tableHead\">Customers</td></tr>\n";
          $html .= "<tr><td class=\"content\">" . mapAdminSelective("customers", "Customers", $servers, $used, 4, array("showSelectedOrder"=>0)) . "</td></tr>\n";
          $html .= "</table></td></tr>\n";
        } else {
          $html .= $this->display($k, 0);
        }
      }
    }

    return $html;
  }


}
?>
