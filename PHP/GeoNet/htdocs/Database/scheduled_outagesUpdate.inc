<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: interfacesUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for scheduled_outages table.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-05-25 14:40:26 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class scheduled_outagesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Scheduled Outages";
  var $table_name = "scheduled_outages";
  var $seq = "scheduled_outage_id_seq";
  var $report_label = "Scheduled Outages Database";
  var $cols_for_display = 6;
  var $return_page;

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
                                "name" => "Outage ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'ticketnum' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Outage Ticket #",
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"40")),

                          'customer_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Customer",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","customers", "", $this->dbh, "", "name")),

                          'facility_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Facility",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","facilities", "", $this->dbh, "", "name")),

                          'asite_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "A Site",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name || '. ' || state","cities", "", $this->dbh, "", "name, state")),

                          'zsite_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Z Site",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name || '. ' || state","cities", "", $this->dbh, "", "name, state")),

                          'starttime_string' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Outage Start Time",
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'start_time' => array ("required" => 0,
                                "display" => 0,
                                "name" => "Outage Start Time",
                                "admin" => 1,
                                "value" => "to_date('" . $this->getFormVal("starttime_string") . "', 'DD MON YYYY HH24:MI:SS')",
                                "widget" => "hidden",
                                "args" => array("add_prev_years"=>"1","add_next_years"=>"1")),

                          'endtime_string' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Outage End Time",
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'end_time' => array ("required" => 0,
                                "display" => 0,
                                "name" => "Outage End Time",
                                "admin" => 1,
                                "value" => "to_date('" . $this->getFormVal("endtime_string") . "', 'DD MON YYYY HH24:MI:SS')",
                                "widget" => "hidden",
                                "args" => array("add_prev_years"=>"1","add_next_years"=>"1")),

                          'description' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Description",
                                "admin" => 0,
                                "widget" => "display_text_area",
                                "args" => array("rows"=>"5","cols"=>"40")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function scheduled_outageUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificInsert($id)
  {
  	$this->return_page .= urlencode($id);
  }

  function get_report_contents()
  {
    $where = $this->where_clause;

    $res = $this->dbh->Select(
      "this.id, ".
      "this.ticketnum, ".
      "f.name, ".
      "c.name, ".
      "trunc((this.end_time - this.start_time) * 24) || 'h ' || trunc(((this.end_time - this.start_time) - (trunc((this.end_time - this.start_time) * 24)/24)) * 24 * 60) || 'm ' || trunc(((this.end_time - this.start_time) - ((trunc((this.end_time - this.start_time) * 24)/24)) - ((trunc(((this.end_time - this.start_time) - (trunc((this.end_time - this.start_time) * 24)/24)) * 24 * 60) / 24 / 60))) * 24 * 60 * 60) || 's' as duration, ".
      "a.name || ', ' || a.state, ".
      "z.name || ', ' || z.state, ".
      "to_char(this.start_time, 'MM/DD/YYYY HH24:MI:SS'), " .
      "to_char(this.end_time, 'MM/DD/YYYY HH24:MI:SS')",

      $this->table_name . " this, facilities f, customers c, cities a, cities z",

      "a.id = this.asite_id and z.id = this.zsite_id and this.customer_id = c.id and this.facility_id = f.id$where",

      "this.start_time desc"
    );

    $labels = array("&nbsp;", "Ticket #", "Facility", "Customer", "Duration", "A site", "Z site", "Start Time", "Stop Time");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, ".
      "this.ticketnum, ".
      "f.name, ".
      "c.name, ".
      "trunc((this.end_time - this.start_time) * 24) || 'h ' || trunc(((this.end_time - this.start_time) - (trunc((this.end_time - this.start_time) * 24)/24)) * 24 * 60) || 'm ' || trunc(((this.end_time - this.start_time) - ((trunc((this.end_time - this.start_time) * 24)/24)) - ((trunc(((this.end_time - this.start_time) - (trunc((this.end_time - this.start_time) * 24)/24)) * 24 * 60) / 24 / 60))) * 24 * 60 * 60) || 's' as duration, ".
      "a.name || ', ' || a.state, ".
      "z.name || ', ' || z.state, ".
      "to_char(this.start_time, 'MM/DD/YYYY HH24:MI:SS'), " .
      "to_char(this.end_time, 'MM/DD/YYYY HH24:MI:SS'), " .
      "this.description " .

      "FROM " . $this->table_name . " this, facilities f, customers c, cities a, cities z " .

      "WHERE a.id = this.asite_id and z.id = this.zsite_id and this.customer_id = c.id and this.facility_id = f.id$where " .

      "ORDER BY this.start_time desc";

    $labels = array("&nbsp;", "Ticket #", "Facility", "Customer", "Duration", "A site", "Z site", "Start Time", "Stop Time", "Comment");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, ".
      "this.ticketnum, ".
      "f.name as facility_id, ".
      "c.name as customer_id, ".
      "a.name || ', ' || a.state as asite_id, ".
      "z.name || ', ' || z.state as zsite_id, ".
      "this.starttime_string, ".
      "this.endtime_string, ".
      "to_char(this.start_time, 'MM/DD/YYYY HH24:MI:SS') as start_time, " .
      "to_char(this.end_time, 'MM/DD/YYYY HH24:MI:SS') as end_time, " .
      "this.description",

      $this->table_name . " this, facilities f, customers c, cities a, cities z",

      "a.id = this.asite_id and z.id = this.zsite_id and this.customer_id = c.id and this.facility_id = f.id and " . 
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
