<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: interface_typesUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for interface_types table.
 *
 * Revision: $Revision: 1.8 $
 * Last Change Date: $Date: 2006-05-25 14:40:28 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class interface_typesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Interface Types";
  var $table_name = "interface_types";
  var $seq = "interface_type_id_seq";
  var $report_label = "Interface Type Database";
  var $cols_for_display = 3;
  var $return_page;
  var $listpage = "interface_types_list.php";

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
                                "name" => "TIDID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Interface Type Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"50")),

                          'namelbl' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Interface Type Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"50")),

                          'use_accumulators' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Use Data Accumulators?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                          'c1' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 1",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c1red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C1",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c1yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C1",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c1sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C1",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c2' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 2",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c2red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C2",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c2yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C2",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c2sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C2",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c3' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 3",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c3red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C3",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c3yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C3",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c3sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C3",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c4' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 4",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c4red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C4",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c4yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C4",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c4sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C4",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c5' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 5",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c5red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C5",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c5yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C5",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c5sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C5",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c6' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 6",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c6red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C6",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c6yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C6",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c6sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C6",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c7' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 7",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c7red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C7",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c7yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C7",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c7sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C7",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c8' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 8",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c8red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C8",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c8yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C8",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c8sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C8",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c9' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 9",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c9red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C9",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c9yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C9",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c9sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C9",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'c10' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Label for Counter 10",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'c10red' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Red Threshhold for C10",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c10yellow' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Yellow Threshhold for C10",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"2")),

                          'c10sev' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Relative Severity for C10",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"6","maxlength"=>"6")),

                          'speed_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Speed",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","speeds", "", $this->dbh, "", "name")),

                          'protocol_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Protocol",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","protocols", "", $this->dbh, "", "name")),

                          'element_type_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Element Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","element_types", "", $this->dbh, "", "name")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug > 4) {
      print("this->fields[" . $this->id . "][value]: " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function single_if_typesUpdate($con, $dbg = 0, $app)
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
  }

  function get_report_contents()
  {
    $where = $this->where_clause;

    $res = $this->dbh->Select(
      "this.id, this.name, this.namelbl, et.name, p.name",

      $this->table_name . " this, element_types et, protocols p",

      "et.id = this.element_type_id and p.id = this.protocol_id$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Interface Type", "Name Label", "Element Type", "Protocol");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.namelbl, et.name, p.name " .

      "FROM " . $this->table_name . " this, element_types et, protocols p " .

      "WHERE et.id = this.element_type_id and p.id = this.protocol_id$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Interface Type", "Name Label", "Element Type", "Protocol");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.namelbl, this.use_accumulators, " .
      "c1, c1red, c1yellow, c1sev, c2, c2red, c2yellow, c2sev, c3, c3red, c3yellow, c3sev, " . 
      "c4, c4red, c4yellow, c4sev, c5, c5red, c5yellow, c5sev, c6, c6red, c6yellow, c6sev, " . 
      "c7, c7red, c7yellow, c7sev, c8, c8red, c8yellow, c7sev, c9, c9red, c9yellow, c7sev, " . 
      "c10, c10red, c10yellow, c10sev, s.name as speed_id, et.name as element_type_id, p.name as protocol_id" ,

      $this->table_name . " this, element_types et, protocols p, speeds s",

      "s.id = this.speed_id and et.id = this.element_type_id and p.id = this.protocol_id and " .
      "this." . $this->id . " = " . $this->getVal($this->id),

      "this.name"
    );

    return $res[0];
  }


  function generateFields($edit=0)
  {
    $html = "";

    foreach($this->fields as $k=>$v) {
      if(ereg("^c[0-9]+", $k)) {
        continue;
      }

      $html .= $this->display($k, 0);
    }

    $html .= "<tr><td colspan=\"2\"><table border=\"0\"><tr><td class=\"tableHead\">PM Name</td><td class=\"tableHead\">Red Val</td><td class=\"tableHead\">Yellow Val</td><td class=\"tableHead\">Severity Factor</td></tr>\n";
		#$defaults = array(
		#  "c1" => "TRANSMIT_CV",
		#  "c1red" => -1,
		#  "c1yellow" => 2,
		#  "c1sev" => 1,
		#  "c2" => "TRANSMIT_ES",
		#  "c2red" => -1,
		#  "c2yellow" => 7,
		#  "c2sev" => 5,
		#  "c3" => "TRANSMIT_SES",
		#  "c3red" => 1,
		#  "c3yellow" => -1,
    #  "c3sev" => 10,
		#  "c4" => "TRANSMIT_UAS",
		#  "c4red" => 1,
		#  "c4yellow" => -1,
		#  "c4sev" => 20,
		#  "c5" => "RECEIVE_CV",
		#  "c5red" => -1,
		#  "c5yellow" => 2,
		#  "c5sev" => 1,
		#  "c6" => "RECEIVE_ES",
		#  "c6red" => -1,
		#  "c6yellow" => 7,
		#  "c6sev" => 5,
		#  "c7" => "RECEIVE_SES",
		#  "c7red" => 1,
		#  "c7yellow" => -1,
		#  "c7sev" => 10,
		#  "c8" => "RECEIVE_UAS",
		#  "c8red" => 1,
		#  "c8yellow" => -1,
		#  "c8sev" => 20,
		#);
		
    for($i = 1; $i <= 10; $i++) {
      $html .= "<tr>";
      $elem = "c$i";
      $html .= "<td>" .  text_field($elem,($this->fields[$elem]["value"] == "" ? $defaults[$elem] : $this->fields[$elem]["value"]), ($this->fields[$elem]["required"] == 1 ? "<span class=\"error\">*</span>" : "") . $this->fields[$elem]["name"], $this->fields[$elem]["args"]) . "</td>\n";
      $elem = "c$i" . "red";
      $html .= "<td>" .  text_field($elem,($this->fields[$elem]["value"] == "" ? $defaults[$elem] : $this->fields[$elem]["value"]), ($this->fields[$elem]["required"] == 1 ? "<span class=\"error\">*</span>" : "") . $this->fields[$elem]["name"], $this->fields[$elem]["args"]) . "</td>\n";
      $elem = "c$i" . "yellow";
      $html .= "<td>" .  text_field($elem,($this->fields[$elem]["value"] == "" ? $defaults[$elem] : $this->fields[$elem]["value"]), ($this->fields[$elem]["required"] == 1 ? "<span class=\"error\">*</span>" : "") . $this->fields[$elem]["name"], $this->fields[$elem]["args"]) . "</td>\n";
      $elem = "c$i" . "sev";
      $html .= "<td>" .  text_field($elem,($this->fields[$elem]["value"] == "" ? $defaults[$elem] : $this->fields[$elem]["value"]), ($this->fields[$elem]["required"] == 1 ? "<span class=\"error\">*</span>" : "") . $this->fields[$elem]["name"], $this->fields[$elem]["args"]) . "</td>\n";
      $html .= "</tr>\n";
    }

    $html .= "</table></td></tr>\n";

    return $html;
  }


}
?>
