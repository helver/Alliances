<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: protocolsUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for protocols table.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class protocolsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Protocols";
  var $table_name = "protocols";
  var $seq = "protocols_id_seq";
  var $report_label = "Protocols Database";
  var $cols_for_display = 5;
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
                                "name" => "Protocol ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Protocol Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'e1' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element 1 Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e2' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element 2 Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e3' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element 3 Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e4' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element 4 Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e5' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Element 5 Label",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function protocolsUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, this.e1, this.e2, this.e3, this.e4, this.e5",

      $this->table_name . " this",

      "1=1$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Protocol", "Element 1", "Element 2", "Element 3", "Element 4", "Element 5");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.e1, this.e2, this.e3, this.e4, this.e5 " .

      "FROM " . $this->table_name . " this " .

      "WHERE 1=1$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Protocol", "Element 1", "Element 2", "Element 3", "Element 4", "Element 5");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.e1, this.e2, this.e3, this.e4, this.e5",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
