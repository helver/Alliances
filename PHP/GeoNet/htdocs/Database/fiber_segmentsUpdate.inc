<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: fiber_segmentsUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for fiber_segments table.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-05-25 14:40:28 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class fiber_segmentsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Fiber Segments";
  var $table_name = "fiber_segments";
  var $seq = "fiber_segment_id_seq";
  var $report_label = "Fiber Segments Database";
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
                                "name" => "Facility ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Fiber Segment Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"12","maxlength"=>"12")),

                          'system' => array ("required" => 0,
                                "display" => 1,
                                "name" => "System",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"1","maxlength"=>"1")),

                          'seq' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Sequence",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"3","maxlength"=>"3")),

                          'signal' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Signal",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"3","maxlength"=>"3")),

                          'channel' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Channel",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"3","maxlength"=>"3")),

                          'asite_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "A Site",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","tids", "", $this->dbh, "", "name")),

                          'zsite_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Z Site",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","tids", "", $this->dbh, "", "name")),

                          'fiber_route_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Fiber Route",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","fiber_routes", "", $this->dbh, "", "name")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function fiber_segmentsUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, fr.name, asite.name, zsite.name",

      $this->table_name . " this, fiber_routes fr, tids asite, tids zsite",

      "fr.id = this.fiber_route_id and asite.id = this.asite_id and zsite.id = this.zsite_id$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Fiber Segment", "Fiber Route", "A Site", "Z Site");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, fr.name, asite.name, zsite.name " .

      "FROM " . $this->table_name . " this, fiber_routes fr, tids asite, tids zsite " .

      "WHERE fr.id = this.fiber_route_id and asite.id = this.asite_id and zsite.id = this.zsite_id$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Fiber Segment", "Fiber Route", "A Site", "Z Site");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.system, this.seq, this.signal, this.channel, fr.name as fiber_route_id, asite.name as asite_id, zsite.name as zsite_id",

      $this->table_name . " this, fiber_routes fr, tids asite, tids zsite",

      "fr.id = this.fiber_route_id and asite.id = this.asite_id and zsite.id = this.zsite_id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
