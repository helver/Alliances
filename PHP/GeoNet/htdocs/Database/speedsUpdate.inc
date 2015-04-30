<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: speedsUpdate 
 * Author: Eric Helvey Create Date: 3/1/2004
 *
 * Description: Table Update class for protocols table.
 *
 * Revision: $Revision: 1.2 $
 * Last Change Date: $Date: 2006-05-25 14:40:28 $
 * Last Editor: $Author: eric $
*/


include_once("TableUpdate.inc");

class speedsUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Speeds";
  var $table_name = "speeds";
  var $seq = "speeds_id_seq";
  var $report_label = "Speeds Database";
  var $cols_for_display = 2;
  var $return_page;
  var $onSubmit = "selectAll(this, 'equivalents');";

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
                                "name" => "Speed",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"20")),

                          'equivalents' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "widget" => "display_format",
                                "args" => array("")),
                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function __equivalentAssignment($id)
  {
    $this->dbh->Delete("speed_equivalent_map", "speed_id = $id");
    if(isset($_REQUEST["equivalents"]) && is_array($_REQUEST["equivalents"])) {
      foreach($_REQUEST["equivalents"] as $k) {
        $this->dbh->Insert("speed_equivalent_map", array("speed_id" => $id, "equivalent_id" => $k));
      }
    }
  }

  function __equivalentUnassignment($id)
  {
    $this->dbh->Delete("speed_equivalent_map", "speed_id = $id");
    $this->dbh->Delete("speed_equivalent_map", "equivalent_id = $id");
  }

  function speedsUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function specificInsert($id)
  {
    $this->return_page .= urlencode($id);
    $this->__equivalentAssignment($id);
  }

  function specificUpdate($id)
  {
    $this->__equivalentAssignment($id);
  }

  function specificDelete($id)
  {
    $this->__equivalentUnassignment($id);
  }

  function get_report_contents()
  {
    $where = $this->where_clause;

    $res = $this->dbh->Select(
      "this.id, this.name, all_equivalents_for_speed(this.id)",

      $this->table_name . " this",

      "1=1$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Speed", "Related Speed(s)");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, all_equivalents_for_speed(this.id) " .

      "FROM " . $this->table_name . " this " .

      "WHERE 1=1$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Speed", "Related Speed(s)");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, all_equivalents_for_speed(this.id) as equivalents",

      $this->table_name . " this",

      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
  
  function generateFields($edit=0)
  {
    $html = "";

    foreach($this->fields as $k=>$v) {
      if($this->fields[$k]["display"] == 1) {
        if($k == "equivalents") {
          $servers = $this->dbh->SelectMap("id, name", "speeds", "", "name");
          $used = $this->dbh->SelectMap("s.id, s.name", "speeds s, speed_equivalent_map sa", "sa.equivalent_id = s.id and sa.speed_id = " . $this->fields[$this->id]["value"]);

          $html .= "<tr><td colspan=\"2\"><table border=\"0\"><tr><td class=\"tableHead\">Speed Equivalent</td></tr>\n";
          $html .= "<tr><td class=\"content\">" . mapAdminSelective("equivalents", "Speed Equivalent", $servers, $used, 6, array("showSelectedOrder"=>0)) . "</td></tr>\n";
          $html .= "</table></td></tr>\n";
        } else {
          $html .= $this->display($k, 0);
        }
      }
    }

    return $html;
  }

}
?>
