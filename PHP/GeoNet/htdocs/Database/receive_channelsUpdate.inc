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
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-05-25 14:40:28 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class receive_channelsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Receive Channels";
  var $table_name = "receive_channels";
  var $seq = "receive_channel_id_seq";
  var $report_label = "Receive Channels Database";
  var $cols_for_display = 2;
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
                                "name" => "Receive Channel ID #",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Receive Channel",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"20")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function receive_channelsUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name",

      $this->table_name . " this",

      "1=1$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Receive Channel");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name " .

      "FROM " . $this->table_name . " this " .

      "WHERE 1=1$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Receive Channel");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
