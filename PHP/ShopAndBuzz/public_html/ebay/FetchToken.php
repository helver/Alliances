<?php 
   $debug = 0;
   
   require_once('../../Libs/common.inc');
   require_once ('Bus_Objects/inc.ebay_request.php');
   require_once ('Bus_Objects/inc.ebay_functions.php');
   include_once ('ConfigFileReader.inc');

   $page = new Open_Page($dbh);
   $user = $page->get_user();

   $config = new ConfigFileReader("aswas");
   $userToken = $config->getAttribute('testToken');
   $serverUrl = $config->getAttribute('serverUrl');

   $sid = 0;

//   if (! $page->user_allowed()) {
//     echo "Not Allowed or Not Logged In!<BR>\n";
//     exit();
//   }

   if(isset($_REQUEST["username"]) && $_REQUEST["username"] != "") {
      $user->eBay_set_username($_REQUEST["username"]);
   }
   
   $sid = $user->eBay_get_sid();
   $username = $user->eBay_get_username();

      //
      // CALL SPECIFIC DATA
      //
   $verb = 'FetchToken';
   $requestXmlBody = '<?xml version="1.0" encoding="utf-8" ?>';

$requestXmlBody .= <<<EOXML
<FetchTokenRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <RequesterCredentials>
    <Username>$username</Username>
  </RequesterCredentials>
  <SecretID>$sid</SecretID>
</FetchTokenRequest>
EOXML;

  //<RequestUserId>noone</RequestUserId>
      //
      // BUILD AND PERFORM THE REQUEST
      //
   $req = new eBayRequest($verb, $config);
   $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
   $token = 0;
   $exp   = 0;
   if ($status) {  // We got a response from the server.
     $get_list = array('eBayAuthToken', 'HardExpirationTime');

     $results = $req->get_results($get_list);
     
     if ($results['error_count'] == 0) { // HEY! No errors!
       $display = "";
       foreach ($get_list as $get_item) {
         $display .= "$get_item: " . $results[0][$get_item] . "<BR>\n";
       }
       $token = $results[0]['eBayAuthToken'];
       $exp   = $results[0]['HardExpirationTime'];

       if ($token) {
         $user->eBay_set_auth($token, $exp);
         
         $value = getEbayStatus($user);
         $dbh->Update("buzz_user_profile", array("ebay_good_standing" => $value['eBayGoodStanding'], 'ebay_power_seller'=>$value['SellerLevel']), "buzz_user_id = " . $user->GetMyID());
         
         $goto = "/users/" . $user->GetDisplayName() . "/confirm_signup/";
         if($debug >= 1) {
           print($goto . "<br>\n");
         }
         if($debug <= 1) {
            header("Location: $goto");
         }
         exit();
       } 
     } else { // Oops! What went wrong?
       $user->eBay_set_sid("");
       $ok = $user->GetMyID();
       $dbh->Insert("suspended_user", "select * from buzz_user where id = $ok");
       $dbh->Delete("buzz_user", "id = $ok");
       $display = "$user/$username<BR>\n$sid<BR>\neBay servers returned " . $results['error_count'] . 
                  " errors: " . $results['error_msg'];
       header("Location: /logout/");
       exit();
     }
   } else {
     $display = "Unable to contact $serverUrl";
   }
   
if(0) {
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
 "http://www.w3.org/TR/html4/loose.dtd">

<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<TITLE><?php echo $verb;?></TITLE>
</HEAD>
<BODY>

<P>
<?php echo $display;?>
</P>

</BODY>
</HTML>

<?php
}

$goto = "/users/" . $user->GetDisplayName() . "/confirm_signup/";

if($debug >= 1) {
  print($goto . "<br>\n");
}
if($debug <= 1) {
   header("Location: $goto");
}
exit();
?>