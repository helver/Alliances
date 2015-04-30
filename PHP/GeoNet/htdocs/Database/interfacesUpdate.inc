<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: interfacesUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for interfaces table.
 *
 * Revision: $Revision: 1.3 $
 * Last Change Date: $Date: 2006-05-25 14:40:26 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class interfacesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Interfaces";
  var $table_name = "interfaces";
  var $seq = "interface_id_seq";
  var $report_label = "Interfaces Database";
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

		if ($this->getFormVal("changetype") == 1) {
			if($this->getFormVal($this->id) != "") {
				$this->dbh->Update($this->table_name, "interface_type_id = " . $_POST["interface_type_id"], $this->id . " = " . $this->getFormVal($this->id));
			}
			
			$addrs = $this->dbh->SelectFirstRow("p.e1, p.e2, p.e3, p.e4, p.e5", "protocols p, interface_types it", "p.id = it.protocol_id and it.id = " . $this->getFormVal("interface_type_id"));
		} elseif($this->getFormVal($this->id) != "") {
			$addrs = $this->dbh->SelectFirstRow("a.e1, a.e2, a.e3, a.e4, a.e5", "protocols a, interface_types it, interfaces b", "a.id = it.protocol_id and it.id = b.interface_type_id and b." . $this->id . " = " . $this->getFormVal($this->id));
		}
				
    $this->fields = array($this->id => array ("required" => 0,
                                "display" => 1,
                                "name" => "Interface ID #",
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

                          'name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Interface Name",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"12","maxlength"=>"12")),

                          'interface_type_id' => array ("required" => 1,
                                "display" => 1,
                                "name" => "Interface Type",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","interface_types", "", $this->dbh, "", "name", "", "onChange='this.form.changetype.value=1;this.form.submit();'")),

                          'e1' => array ("required" => 0,
                                "display" => ($addrs["e1"] == "" ? 0 : 1),
                                "name" => $addrs["e1"],
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e2' => array ("required" => 0,
                                "display" => ($addrs["e2"] == "" ? 0 : 1),
                                "name" => $addrs["e2"],
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e3' => array ("required" => 0,
                                "display" => ($addrs["e3"] == "" ? 0 : 1),
                                "name" => $addrs["e3"],
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e4' => array ("required" => 0,
                                "display" => ($addrs["e4"] == "" ? 0 : 1),
                                "name" => $addrs["e4"],
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"15","maxlength"=>"25")),

                          'e5' => array ("required" => 0,
                                "display" => ($addrs["e5"] == "" ? 0 : 1),
                                "name" => $addrs["e5"],
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

  function interfacesUpdate($con, $dbg = 0, $app)
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
      "this.id, this.name, it.name, p.name",

      $this->table_name . " this, protocols p, interface_types it",

      "p.id = it.protocol_id and it.id = this.interface_type_id$where",

      "it.name, to_number(this.name)"
    );

    $labels = array("&nbsp;", "Interface Name", "Interface Type", "Protocol");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, it.name, p.name " .

      "FROM " . $this->table_name . " this, protocols p, interface_types it " .

      "WHERE p.id = it.protocol_id and it.id = this.interface_type_id$where " .

      "ORDER BY it.name, to_number(this.name)";

    $labels = array("&nbsp;", "Interface Name", "Interface Type", "Protocol");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, this.e1, this.e2, this.e3, this.e4, this.e5, it.name as interface_type_id",

      $this->table_name . " this, interface_types it",

      "it.id = this.interface_type_id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }
}
?>
