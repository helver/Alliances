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
 * Revision: $Revision: 1.7 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class element_typesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Element Types";
  var $table_name = "element_types";
  var $seq = "element_type_id_seq";
  var $report_label = "Element Types";
  var $cols_for_display = 3;
  var $return_page;
  var $listpage = "element_types_list.php";

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

    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element Type ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Element Type Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"30","maxlength"=>"30")),

                          'windows' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Window Count",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"4","maxlength"=>"4")),

                          'primus_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Primus Element Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"30","maxlength"=>"30")),

                          'pm_doc_link' => array ("required" => 0,
                                "display" => 1,
                                "name" => "PM Document URL",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"40","maxlength"=>"100")),

                          'predefined_ifs' => array ("required" => 0,
                                "display" => 1,
                                "name" => "All Interfaces Predefined?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function element_typesUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, this.windows, this.primus_name, this.predefined_ifs",

      $this->table_name . " this",

      "$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Element Type", "Window Count", "Primus Name", "Predefined Interfaces");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.windows, this.primus_name, this.pm_doc_link, this.predefined_ifs " .

      "FROM " . $this->table_name . " this " .

      "WHERE 1=1$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Element Type", "Window Count", "Primus Name", "PM Document Link", "Predefined Interfaces");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.windows, this.primus_name, this.pm_doc_link, this.predefined_ifs",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
