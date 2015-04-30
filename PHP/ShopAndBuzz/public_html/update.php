<?php
  $debug = 0;
  require_once("../Libs/common.inc");
  $page = new Admin_Page($dbh, "Admin");
  auth_check($page, $dbh);
  
  include_once("ConfigFileReader.inc");
  $config = new ConfigFileReader("aswas");
  $config->setAttribute("DBApplication", "aswas");
  $config->setAttribute("DBUserName", $GLOBALS["db_user"]);
  $config->setAttribute("DatabaseHost", $GLOBALS["db_server"]);
  $config->setAttribute("DatabaseDB", $GLOBALS["db"]);
  $config->setAttribute("DBPassword", $GLOBALS["db_pass"]);

  $debug = $config->getAttribute("DebugLevel") || 0;
  $debug = (int)$debug;
  #$debug = 3;

  if(isset($_REQUEST["table"])) {
    $table = $_REQUEST["table"];

    include_once("AdminObjects/" . $table . "Update.inc");
    eval ("\$tab = new " . $table . "Update(\$config, \$debug, \"aswas\");");

    $tab->processFormSubmission();

    $tab->template = "template.php";

    $tab->displayPage();
    exit();
  }

  require_once("../Libs/common_smarty.inc");
  include_once("form_elements.inc");
  include_once("TableUpdate.inc");

  $user = $page->get_user();

  $tablefields = array();
  $tables = $dbh->SelectOneColumn("tablename", "pg_tables", "tableowner = '" . $GLOBALS["db_user"] . "'", "tablename");

  $table_cols = array(
    "admin_level" => array("id" => "code", "name" => "value", "label"=>"Admin Levels"),
    "buzz_user" => array("id" => "id", "name" => "username", "label"=>"Buzz Users"),
#    "commission_schedule" => array("id" => "id",  "name" => "mylabel", "label"=>"Commission Schedules"),
    "email_freq" => array("id" => "preference", "name" => "value", "label"=>"Email Delivery Schedules"),
    "fee_frequency" => array("id" => "code", "name" => "value", "label"=>"Fee Frequencies"),
    "fee_schedule" => array("id" => "id",  "name" => "coupon_code", "label"=>"Fee Schedules"),
    "invites" => array("id" => "invite_id", "name"=>"invite_email", "label"=>"Invitations"),
#    "purchases" => array("id" => "id", "name" => "id", "label"=>"eBay Transactions"), #####
#    "paypal_trans" => array("id" => "id", "name" => "id", "label"=>"Transactions"), 
    "seller_category" => array("id" => "id", "name" => "name", "label"=>"Seller Categories"),
    "system_messages" => array("id" => "system_message_id", "name" => "message", "label"=>"Global System Messages"),  #######
    "unconfirmed_user" => array("id" => "token", "name" => "email", "label"=>"Unconfirmed Users"),
  );

  $tab = new TableUpdate($config, $debug, "aswas");

  foreach($tables as $table) {
    if(isset($table_cols[$table])) {
      $tablefields[] = $tab->getExistingList($table_cols[$table]["id"], $table_cols[$table]["name"], $table, $table_cols[$table]["label"], "", $table_cols[$table]["name"]);
    }
  }

  $smarty->assign("tablefields", $tablefields);

  $smarty->display("admin_base.tpl"); 
?>


