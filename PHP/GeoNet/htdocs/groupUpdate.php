<?php
/**
 * Project: GeoNet Monitor
 *
 * groupUpdate.php
 * Author: Eric Helvey
 *
 * Description: This page allows an administrator to assign GeoNet customers
 *              to Geonet user groups.
 *
 * Revision: $Revision: 1.11 $
 * Last Change Date: $Date: 2005-05-26 20:12:59 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "AdminAccessLevel";
  
  include_once("ifc_prefs.inc");

  if(!isset($_REQUEST["groupid"])) {
    __redirector("security.php", $debug);
  }
  
  $groupid = $_REQUEST["groupid"];
  
  if($_REQUEST["oper"] != "") {
    $dbh->Delete("customer_group_map", "user_group_id = $groupid");

    if(isset($_REQUEST["customers"]) && is_array($_REQUEST["customers"])) {
  		$theorder = 0;
      foreach($_REQUEST["customers"] as $v) {
        $res = $dbh->Insert("customer_group_map", array("user_group_id" => $groupid, "customer_id" => $v, "display_order" => $theorder));
        
        if($res <= 0) {
          $err .= $dbh->getErrorMessage();
        } else {
        	$theorder++;
        }
      }
    }
    
    if($err == "") {
      $err = "All Customer Assignments Successful";
    }
  }


  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # History page, so we're loading up the LeftMenu for the History page.
  # The LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug, $dbh);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft);

  $customers = $dbh->SelectMap("id, name", "customers", "", "name");
  
  $selcusts = $dbh->SelectMap("c.id as id, c.name as name", "customer_group_map m, customers c", "m.customer_id = c.id and m.user_group_id = $groupid", "m.display_order");
  
  if(isset($selcusts) && is_array($selcusts)) {
    foreach($selcusts as $id=>$name) {
      unset($customers[$id]);
    }
  }
  
  $name = $dbh->SelectSingleValue("name", "user_groups", "id = $groupid");
  
  __loadFeatures($features, $theme);

  print($theme->generate_pagetop());
  print($lft->generate_Layer($cust, $facs));
  
?>
<form method="POST" name="tgz" onSubmit="selectAll(this, 'customers');">
  <input type="hidden" name="groupid" value="<? print($groupid); ?>">
  <table align="center" border="0" cellspacing="5">

    <tr><td align="center" class="pageHead">Assign Customers to <?= $name ?> Group</td></tr>

    <? if(isset($err)) { ?>
    <tr><td align="center" class="error"><?= $err ?></td></tr>
    <? } ?>
    
    <tr><td align="center" class="content">
      <?= mapAdmin("customers", "Customers", $customers, (isset($selcusts) ? $selcusts : array())) ?>
    </td></tr>

    <tr>
      <td class="content" align="center">
        <input type="submit" value="Add Customers To <?= $name ?> Group" name="oper">
        <input type="button" VALUE="Cancel" NAME="cancel" onClick="window.location.href='adminUser.php'">
      </td>
    </tr>
  </table>
</form>
<?   print($theme->generate_pagebottom()); ?>



