<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: element_typesUpdate
 * Author: Eric Helvey
 * Create Date: 1/9/2003
 *
 * Description: Table Update class for element_types table.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2006-05-25 14:40:28 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class alarmsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Alarms";
  var $table_name = "alarms";
  var $seq = "alarm_id_seq";
  var $report_label = "Alarms Database";
  var $cols_for_display = 5;
  var $return_page;

  # Now we''re going to set up some arrays containing information about the
  # the database fields we''ll be playing with.  Basically it''s a list of
  # fields, which fields are required, the labels used on each field, and
  # what kind of person sees which fields.
  var $fields;

  function _init()
  {
    if($this->debug >= 5) {
      print("In _init()<br>\n");
    }

		if ($this->getFormVal("changetype") == 1) {
			if($this->getFormVal($this->id) != "") {
				$this->dbh->Update($this->table_name, "tid_id = " . $_POST["tid_id"], $this->id . " = " . $this->getFormVal($this->id));
			}
    }
  	$tid = $this->dbh->SelectSingleValue("tid_id", "alarms", $this->id . " = " . $this->getFormVal($this->id));
			
    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "Alarm ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'changetype' => array ("required" => 0,
                          			"nondb" => 1,
                                "display" => 1,
                                "name" => "Change Elem Type",
                                "value" => 0,
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'tid_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "TID",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","tids", "name is not null and id is not null", $this->dbh, "", "name", "", "onChange='this.form.changetype.value=1;this.form.submit();'")),

                          'interface_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Interface",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","interface_types", "element_type_id = (select element_type_id from tids where id = $tid)", $this->dbh, "", "name")),

                          'timeentered' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Alarm Date/Time",
                                "admin" => 0,
                                "widget" => "display_time_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'acknowledge_date' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Acknowledgement Date/Time",
                                "admin" => 0,
                                "widget" => "display_time_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'time_cleared' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Date/Time Error Cleared",
                                "admin" => 0,
                                "widget" => "display_time_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'cleared' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Cleared",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                          'cause' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Error Status Cause",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"10","maxlength"=>"10")),

                          'ticketnum' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Ticket Number",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"10","maxlength"=>"10")),

                          'initials' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Acknowledger Intials",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"3","maxlength"=>"3")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function alarmsUpdate($con, $dbg = 0, $app)
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
      "this.id, t.name, i.name, " .
      "to_char(this.timeentered, 'MM-DD-YYYY HH24:MI:SS') as timeentered, " .
      "this.cause, to_char(this.acknowledge_date, 'MM-DD-YYYY HH24:MI:SS') as acknowledge_date, " .
      "this.cleared, to_char(this.time_cleared, 'MM-DD-YYYY HH24:MI:SS') as time_cleared, this.initials, this.ticketnum ",

      $this->table_name . " this, tids t, interface_types i",

      "this.tid_id = t.id and this.interface_id = i.id$where",

      "this.timeentered, this.acknowledge_date"
    );

    $labels = array("&nbsp;", "TID", "Channel", "Time Entered",
                    "Cause", "Time Acknowleged", "Cleared", "Time Cleared",
                    "Acked By", "Ticket #");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, t.name, i.name, " .
      "to_char(this.timeentered, 'MM-DD-YYYY HH24:MI:SS') as timeentered, " .
      "this.cause, to_char(this.acknowledge_date, 'MM-DD-YYYY HH24:MI:SS') as acknowledge_date, " .
      "this.cleared, to_char(this.time_cleared, 'MM-DD-YYYY HH24:MI:SS') as time_cleared, this.initials, this.ticketnum " .

      "FROM " . $this->table_name . " this, tids t, interface_types i " .

      "WHERE this.tid_id = t.id and this.interface_id = i.id$where " .

      "ORDER BY this.timeentered, this.acknowledge_date";

    $labels = array("&nbsp;", "TID", "Channel", "Time Entered",
                    "Cause", "Time Acknowleged", "Cleared", "Time Cleared", 
                    "Acked By", "Ticket #");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "t.name as tid_id, i.name as interface_id, to_char(this.timeentered, 'MM-DD-YYYY HH24:MI:SS') as timeentered, " .
      "this.cause, this.id, " .
      "this.cleared, to_char(this.acknowledge_date, 'MM-DD-YYYY HH24:MI:SS') as acknowledge_date, " .
      "to_char(this.time_cleared, 'MM-DD-YYYY HH24:MI:SS') as time_cleared, this.initials, this.ticketnum",

      $this->table_name . " this, tids t, interface_types i",

      "this.tid_id = t.id and this.interface_id = i.id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
