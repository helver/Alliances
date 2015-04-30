<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: citiesUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for cities table.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class citiesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "City";
  var $table_name = "cities";
  var $seq = "city_id_seq";
  var $report_label = "Cities Database";
  var $cols_for_display = 4;
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
                                "name" => "City ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "City Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"50")),

                          'state' => array ("required" => 0,
                                "display" => 1,
                                "name" => "State",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"2","maxlength"=>"3")),

                          'clli_tid' => array ("required" => 0,
                                "display" => 1,
                                "name" => "CLLI Prefix",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"11","maxlength"=>"11")),

                          'latitude' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Latitude",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                          'longitude' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Longitude",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"20")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function citiesUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificUpdate($id)
  {
    $this->return_page .= urlencode($id);
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
      "this.id, this.name, this.state, this.latitude, this.longitude, this.clli_tid",

      $this->table_name . " this",

      "id is not null$where",

      "this.name"
    );

    $labels = array("&nbsp;", "City", "State", "Latitude", "Longitude", "TID Prefix");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.state, this.latitude, this.longitude, this.clli_tid " .

      "FROM " . $this->table_name . " this " .

      "WHERE this.id is not null$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "City", "State", "Latitude", "Longitude", "TID Prefix");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.state, this.latitude, this.longitude, this.clli_tid",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
