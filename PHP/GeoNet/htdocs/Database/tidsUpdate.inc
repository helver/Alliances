<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: tidsUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for tids table.
 *
 * Revision: $Revision: 1.11 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class tidsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "TIDs";
  var $table_name = "tids";
  var $seq = "tid_id_seq";
  var $report_label = "DWDS TIDs Database";
  var $cols_for_display = 5;
  var $return_page;
  var $listpage = "tids_list.php";

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
                                "name" => "TID ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 1,
                                "display" => 1,
                                "name" => "TID",
                                "admin" => 0,
                                "cleanse" => array("trailing_whitespace"),
                                "widget" => "display_text_field",
                                "args" => array("size"=>"17","maxlength"=>"17")),

                          'is_ring' => array ("required" => 0,
                                "display" => 1,
                                "name" => "TID is a Ring?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),
                                
                          'ipaddress' => array ("required" => 1,
                                "display" => 1,
                                "name" => "IP Address",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"16","maxlength"=>"16")),

                          'flag' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Status Flag",
                                "admin" => 1,
                                "value" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array("size"=>"1","maxlength"=>"1")),

                          'cause' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Error Status Cause",
                                "admin" => 1,
                                "widget" => "display_hidden_field",
                                "args" => array("size"=>"10","maxlength"=>"10")),

                          'grouping_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "DWDM Grouping Name",
                                "admin" => 0,
                                "value" => "UNK",
                                "widget" => "display_text_field",
                                "args" => array("size"=>"14","maxlength"=>"14")),

                          'dwdm_facility' => array ( "required" => 0,
                                "display" => 1,
                                "name" => "DWDM Facility ID",
                                "admin" => 0,
                                "value" => "UNK",
                                "widget" => "display_text_field",
                                "args" => array("size"=>"8","maxlength"=>"8")),

                          'management_port' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Management Port",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>5, "maxlength"=>5)),

                          'directionality' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Directionality",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","receive_channels", "", $this->dbh, " ", "name")),

                          'city_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "City",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name || ', ' || state","cities", "", $this->dbh, "", "name, state")),

                          'element_type_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","element_types", "", $this->dbh, "", "name")),

                          'ring_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "On Ring",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","tids", "is_ring = 't'", $this->dbh, "Direct Access", "name")),


                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function tidsUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificUpdate($id)
  {
  }

  function specificInsert($id)
  {
  	$this->return_page .= urlencode($id);
  }

  function specificDelete($id)
  {
    $this->dbh->Delete("pm_history", "tid_id = $id");
    $this->dbh->Delete("pm_info", "tid_id = $id");
    $this->dbh->Delete("tid_interface_status", "tid_id = $id");
    $this->dbh->Delete("tid_facility_map", "tid_id = $id");
    $this->dbh->Delete("alarms", "tid_id = $id");
    $this->dbh->Delete("fiber_segments", "asite_id = $id or zsite_id = $id or fiber_route_id in (select id from fiber_routes where asite_id = $id or zsite_id = $id)");
    $this->dbh->Delete("fiber_routes", "asite_id = $id or zsite_id = $id");
    
  }

  function get_report_contents()
  {
    $where = $this->where_clause;

    $res = $this->dbh->Select(
      "this.id, this.name, this.ipaddress, this.grouping_name, this.dwdm_facility, " .
      "c.name || ', ' || c.state, e.name",

      $this->table_name . " this, element_types e, cities c",

      "this.element_type_id = e.id and this.city_id = c.id$where",

      "this.name"
    );

    $labels = array("&nbsp;", "TID", "IP", "Grouping Name", "DWDM Facility", "City", "Element Type");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.ipaddress, this.grouping_name, this.dwdm_facility, " .
      "c.name || ', ' || c.state, e.name, this.management_port " .

      "FROM " . $this->table_name . " this, element_types e, cities c " .

      "WHERE this.element_type_id = e.id and this.city_id = c.id$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "TID", "IP", "Grouping Name", "DWDM Facility", "City", "Element Type", "Management Port");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.ipaddress, this.grouping_name, this.dwdm_facility, this.is_ring, rc.name as directionality, " .
      "c.name || ', ' || c.state as city_id, e.name as element_type_id, this.flag, this.cause, this.management_port, ring.name as ring_id",

      $this->table_name . " this, element_types e, cities c, receive_channels rc, tids ring",

      "this.element_type_id = e.id and this.city_id = c.id and this.directionality = rc.id(+) and this.ring_id = ring.id(+) and " . 
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }



}
?>
