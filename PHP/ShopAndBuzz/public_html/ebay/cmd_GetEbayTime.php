#!/usr/bin/php
<?php 
   require_once('../../Libs/common.inc');
   require_once ('Bus_Objects/inc.ebay_request.php');
   include_once ('ConfigFileReader.inc');

   $config = new ConfigFileReader("aswas");
   $userToken = $config->getAttribute('testToken');
   $serverUrl = $config->getAttribute('serverUrl');

      //
      // CALL SPECIFIC DATA
      //
   $verb = 'GeteBayOfficialTime';
   $requestXmlBody = '<?xml version="1.0" encoding="utf-8" ?>';

$requestXmlBody .= <<<EOXML
<GeteBayOfficialTimeRequest xmlns="urn:ebay:apis:eBLBaseComponents">
<RequesterCredentials>
  <eBayAuthToken>$userToken</eBayAuthToken>
</RequesterCredentials>
</GeteBayOfficialTimeRequest>
EOXML;

      //
      // BUILD AND PERFORM THE REQUEST
      //
   $req = new eBayRequest($verb, $config);
   $status = $req->send_request($requestXmlBody, $serverUrl);

      //
      // CHECK OUR RESULTS
      //
   if ($status) {  // We got a response from the server.
     $get_list = array('Timestamp');
     $results = $req->get_results($get_list);
     
     if ($results['error_count'] == 0) { // HEY! No errors!
       $display = "";
       foreach ($get_list as $get_item) {
         $display .= "$get_item: " . $results[0][$get_item] . "\n";
       }
     } else { // Oops! What went wrong?
       $display = "eBay servers returned " . $results['error_count'] . 
                  " errors: " . $results['error_msg'];
     }
   } else {
     $display = "Unable to contact $serverUrl";
   }

   echo "$serverUrl\n";
   print_r ($results);
   echo "\n$verb\n";
   echo $display;
?>


