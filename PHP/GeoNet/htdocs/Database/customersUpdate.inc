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
 * Revision: $Revision: 1.4 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class customersUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Customers";
  var $table_name = "customers";
  var $seq = "customer_id_seq";
  var $report_label = "Customers Database";
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
                                "name" => "Customer ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"40")),

                          'short_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Short Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"10","maxlength"=>"10")),

                          'flag' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Status Flag",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "value" => ($this->getFormVal("flag") == "" ? "4" : $this->getFormVal("flag")),
                                "args" => array("size"=>"1","maxlength"=>"1")),

                          'tracepath' => array ("required" => 0,
                                "display" => 1,
                                "name" => "TracePath Access?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),

                          'customer_type_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","customer_types", "", $this->dbh, "", "name")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function customersUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, this.short_name, this.flag, " .
      "ct.name as customer_type_id",

      $this->table_name . " this, customer_types ct",

      "this.customer_type_id = ct.id$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Customer Name", "Short Name", "Status Flag", "Customer Type");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.short_name, this.flag, " .
      "ct.name as customer_type_id " .

      "FROM " . $this->table_name . " this, customer_types ct " .

      "WHERE this.customer_type_id = ct.id$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Customer Name", "Short Name", "Status Flag", "Customer Type");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.short_name, this.flag, this.tracepath, " .
      "ct.name as customer_type_id",

      $this->table_name . " this, customer_types ct",

      "this.customer_type_id = ct.id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
