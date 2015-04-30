<?php
/**
 * Project: GeoNet Monitor
 *
 * addPrimusUsername.php
 * Author: Marie Roux
 * Create Date: 8/2/2002
 *
 * Description: If the user clicks on the Primus link on the left menu and
 *              doesn't have a Primus User Name in his user record, he gets
 *              sent here.
 *
 * Revision: $Revision: 1.13 $
 * Last Change Date: $Date: 2005-05-20 12:40:17 $
 * Last Editor: $Author: eric $
*/

	$requireLogin = 1;
	$minLevel = "UserAccessLevel";
  
  include_once("ifc_prefs.inc");

  // update a User
  if (isset($_REQUEST["updateOne"])) {
    if ($debug) {
      print("in updateOne<BR>\n");
    }

    $res = $dbh->Update("users", array("primusUsername" => trim($_REQUEST["primusUsername"])), "id = " . $sess->getThisPersonID());

    __redirector($config->getAttribute("gotoPage"), $debug);
  }

  //////////////////////////////////////////////////////////////
  // FEATURES
  //////////////////////////////////////////////////////////////

  # Here we're loading up the Left Menu for this page.  This is the
  # History page, so we're loading up the LeftMenu for the History page.
  # The LeftMenu classes need to know who we are so they can show the
  # appropriate links.
  include_once("Features/LeftMenuDB.inc");
  $lft = new LeftMenuDB($user, $config, $debug);
  $lft->set_Primus_Info(array("user" => $user->lookupPrimusUserName()));


  # The features array contains a list of all the features that we've
  # loaded.  We do this so we can just run through a loop to handle the
  # CSS, JavaScript and onLoad generation.  This makes it easier to add
  # new features.
  $features = array($lft);

  __loadFeatures($features, $theme);

  $theme->updateAttr("currentLoc", "Users");
  print($theme->generate_pagetop());

  print($lft->generate_Layer());
?>
<p class="pageHead">GeoNet Monitor - Add Primus Username</p>

<form method="POST">
  <table width="80%">
    <tr>
      <td align="center">
        <table align="center" border="0" cellspacing="5" bgcolor="#E1D7AA">
          <tr>
            <td class="content" nowrap align="left">Enter Your Primus Username (case-sensitive)</td>
          </tr>

          <tr>
            <td class="content" nowrap align="left">
              <?= text_field("primusUsername", $user->lookupPrimusUserName(), array("size"=>30, "maxlength"=>30)) ?>
            </td>
          </tr>

          <tr>
            <td align="content" align="left">
              <input type="submit" value="OK" name="updateOne">
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>
<?= $theme->generate_pagebottom() ?>