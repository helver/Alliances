<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: user_groupsUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for user_groups table.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2006-05-25 14:40:27 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class user_groupsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "User Groups";
  var $table_name = "user_groups";
  var $seq = "user_group_id_seq";
  var $report_label = "User Groups Database";
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
                                "name" => "Group ID",
                                "admin" => 0,
                                "widget" => "display_hidden_field",
                                "args" => array()),

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Group Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"20","maxlength"=>"40")),

                          'short_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Group Short Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"5","maxlength"=>"5")),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function user_groupsUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, this.short_name",

      $this->table_name . " this",

      "1=1$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Group", "Abbrev");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, this.short_name " .

      "FROM " . $this->table_name . " this " .

      "WHERE 1=1$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Group", "Abbrev");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.short_name",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
