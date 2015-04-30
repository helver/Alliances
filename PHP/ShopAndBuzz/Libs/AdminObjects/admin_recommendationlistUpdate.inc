<?
include_once("TableUpdate.inc");

class admin_recommendationlistUpdate extends TableUpdate
{

  #################################################################
  # Configurables
  #################################################################

  var $id = "id";
  var $label = "Shop & Buzz Recommendations";
  var $table_name = "admin_recommendation_list";
  var $report_label = "Shop & Buzz Recommendation List";
  var $cols_for_display = 2;
  var $return_page;
  var $listpage = "/admin/users/recommendations/";

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
                                "name" => "Recommendation",
                                "xxline" => "\$xx = \"<a href=\\\"/admin/?table=Recommendation&reco_id=\" . \$x[\"id\"] . \"\\\"><span class=\\\"whitetext\\\">Edit</span></a><Br><a href=\\\"#\\\" onClick=\\\"do_delete('/users/\" . \$x[\"buzz_user_name\"] . \"/recommendations/\" . \$x[\"victim_name\"] . \"/');\\\"><span class=\\\"whitetext\\\">Remove</span></a>\";",
                                ),

                          'buzz_user_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Recommender",
                                "admin" => 0,
                                "sorter" => "buzz_user_nameXXX",
                                ),

                          'victim_name' => array ("required" => 0,
                                "display" => 1,
                                "name" => "Recommendee",
                                "admin" => 0,
                                "sorter" => "victim_nameXXX",
                                ),

                 );

    if($this->debug >= 5) {
      print("this->getFormVal($this->id): " . $this->getFormVal($this->id) .  "<br>\n");
      print("Leaving _init()<br>\n");
    }

  }

  function admin_recommendationlistUpdate($con, $dbg = 0, $app)
  {
    $this->TableUpdate($con, $dbg, $app);
  }
}
?>
