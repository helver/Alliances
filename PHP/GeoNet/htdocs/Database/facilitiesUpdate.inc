<?php
/**
 * Project: GeoNet Monitor
 *
 * Class: facilitiesUpdate
 * Author: Eric Helvey
 * Create Date: 3/1/2004
 *
 * Description: Table Update class for facilities table.
 *
 * Revision: $Revision: 1.12 $
 * Last Change Date: $Date: 2006-05-25 14:40:26 $
 * Last Editor: $Author: eric $
*/

include_once("TableUpdate.inc");

class facilitiesUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Facilities";
  var $table_name = "facilities";
  var $seq = "facility_id_seq";
  var $report_label = "Facilities Database";
  var $cols_for_display = 5;
  var $return_page;
  var $listpage = "facilities_list.php";
  var $onSubmit = "selectAll(this, 'fac_assoc');";

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
                                "name" => "Facility",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "args" => array("size"=>"12","maxlength"=>"12")),

                          'active' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Active?",
                                "admin" => 0,
                                "widget" => "display_boolean",
                                "args" => array()),
                                
                          'notes' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Notes",
                                "admin" => 0,
                                "widget" => "display_text_area",
                                "cleanse" => array("newline_to_br"),
                                "args" => array("rows"=>"3","cols"=>"50")),


                          'flag' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Status Flag",
                                "admin" => 0,
                                "widget" => "display_text_field",
                                "value" => ($this->getFormVal("flag") == "" ? "4" : $this->getFormVal("flag")),
                                "args" => array("size"=>"1","maxlength"=>"1")),

                          'customer_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Customer",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, name","customers", "", $this->dbh, "", "name")),

                          'speed_id' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Speed Rating",
                                "admin" => 0,
                                "widget" => "display_popup_menu",
                                "args" => array("id, all_speeds_for_speed(id)","speeds", "id in (select distinct relative_id from speeds)", $this->dbh, "All Speeds", "name")),

                          'fac_assoc' => array ("required" => 0,
                                "display" => 1,
                                "nondb" => 1,
                                "name" => "Related Facilities",
                                "admin" => 0,
                                "widget" => "display_format",
                                "args" => array()),

                 );

    $this->return_page = "update.php?table=" . urlencode($this->table_name) . "&oper=view&" . urlencode($this->id) . "=" . urlencode($this->getFormVal($this->id));
    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function facilitiesUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }


  function __fac_assocAssignment($id)
  {
    $this->dbh->Delete("facility_associations", "fac1 = $id");
    $this->dbh->Delete("facility_associations", "fac2 = $id");
    if(isset($_POST["fac_assoc"]) && is_array($_POST["fac_assoc"])) {
      foreach($_POST["fac_assoc"] as $k) {
        $this->dbh->Insert("facility_associations", array("fac1" => $id, "fac2" => $k));
        $this->dbh->Insert("facility_associations", array("fac2" => $id, "fac1" => $k));
      }
    }
  }

  function __fac_assocUnassignment($id)
  {
    $this->dbh->Delete("facility_associations", "fac1 = $id");
    $this->dbh->Delete("facility_associations", "fac2 = $id");
  }

  function specificUpdate($id)
  {
    if($this->fields["active"]["value"] == "f") {
      $this->dbh->Update("tid_interface_status", 
        array("flag" => 2, "cause" => "InAct"),
        "(tid_id, interface_id) in (select tfm.tid_id, tfm.interface_id from tid_facility_map tfm WHERE tfm.facility_id = $id)"
      );
      $this->dbh->Update("facilities", "flag = 2", "id = $id");
    } elseif($this->fields["active"]["value"] == "t") {
      $this->dbh->Update("tid_interface_status", 
        array("flag" => 4, "cause" => "ReAct"),
        "(tid_id, interface_id) in (select tfm.tid_id, tfm.interface_id from tid_facility_map tfm WHERE tfm.facility_id = $id)"
      );
      $this->dbh->Update("facilities", "flag = 4", "id = $id");
    }
    $this->__fac_assocAssignment($id);
  }

  function specificInsert($id)
  {
  	$this->return_page .= urlencode($id);
  	$this->fields["notes"]["value"] = ereg_replace("\n", "<br>", $this->fields["notes"]["value"]); 
    $this->__fac_assocAssignment($id);
  }

  function specificDelete($id)
  {
  	$this->dbh->Delete("tid_facility_map", "facility_id = $id");
    $this->__fac_assocUnassignment($id);
  }

  function get_report_contents()
  {
    $where = $this->where_clause;

    $res = $this->dbh->Select(
      "this.id, this.name, '<a class=\"contentsmalllink\" href=\"build_facility.php?id=' || this.id || '\">Path</a>', DECODE(this.active, 't', 'Yes', 'No') as active, this.flag, c.name, this.notes",

      $this->table_name . " this, customers c",

      "c.id = this.customer_id$where",

      "this.name"
    );

    $labels = array("&nbsp;", "Facility", "Build", "Active?", "Status Flag", "Customer", "Notes");

    return array($res, $labels);
  }


  function get_full_contents_sql()
  {
    $where = $this->where_clause;

    $sql = "SELECT " .
      "this.id, this.name, '<a class=\"contentsmalllink\" href=\"build_facility.php?id=' || this.id || '\">Path</a>', DECODE(this.active, 't', 'Yes', 'No') as active, this.flag, c.name, this.notes " .

      "FROM " . $this->table_name . " this, customers c " .

      "WHERE c.id = this.customer_id$where " .

      "ORDER BY this.name";

    $labels = array("&nbsp;", "Facility", "Build", "Active?", "Status Flag", "Customer", "Notes");

    return array($sql, $labels);
  }


  function get_record_contents()
  {
    $res = $this->dbh->Select(
      "this.id, this.name, DECODE(this.active, 't', 'Yes', 'No') as active, " .
      "this.flag, c.name as customer_id, all_speeds_for_speed(this.speed_id) as speed_id, this.notes",

      $this->table_name . " this, customers c",

      "c.id = this.customer_id and " .
      "this." . $this->id . " = " . $this->getVal($this->id)
    );

    return $res[0];
  }

  function generateFields($edit=0)
  {
    $html = "";
		
    foreach($this->fields as $k=>$v) {
      if($this->fields[$k]["display"] == 1) {
        if($k == "fac_assoc") {
          $used = $this->dbh->SelectMap("s.id, s.name", "facilities s, facility_associations sa", "sa.fac2 = s.id and sa.fac1 = " . $this->fields[$this->id]["value"]);
          $servers = $this->dbh->SelectMap("id, name", "facilities", "id not in (" . $this->fields[$this->id]["value"] . (count($used) > 0 ? "," . join(",", array_keys($used)) : "") . ") and customer_id = (select customer_id from facilities where id = " . $this->fields[$this->id]["value"] . ")", "name");

          $html .= "<tr><td colspan=\"2\"><table border=\"0\"><tr><td class=\"tableHead\">Related Facilities</td></tr>\n";
          $html .= "<tr><td class=\"content\">" . mapAdminSelective("fac_assoc", "Related Facilities", $servers, $used, 10, array("showSelectedOrder"=>0)) . "</td></tr>\n";
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
