#!/usr/bin/php
<?php
   require_once('../../Libs/common.inc');
   require_once ('Bus_Objects/inc.ebay_request.php');
   include_once ('ConfigFileReader.inc');

   $config = new ConfigFileReader("aswas");
   $userToken = $config->getAttribute('testToken');
   $serverUrl = $config->getAttribute('serverUrl');

   $devName = $config->getAttribute('devName');
   $devPass = $config->getAttribute('devPass');

      //
      // CALL SPECIFIC DATA
      //

    $verb = 'GetRuName';
    $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlBody .= <<<EOXML
<GetRuNameRequest xmlns="urn:ebay:apis:eBLBaseComponents"> 
  <RequesterCredentials> 
    <Username>$devName</Username> 
    <Password>$devPass</Password> 
  </RequesterCredentials> 
</GetRuNameRequest> 
EOXML;

  $req = new eBayRequest($verb, $config);
  $status = $req->send_request($requestXmlBody, $serverUrl);

    //
    // Check Our Results
    //
  if ($status) {
    $get_list =  array ('Timestamp', 'Version', 'RuName');
    $results = $req->get_results($get_list);

    if ($results['error_count'] == 0) { // HEY! No errors!
      $display = "";

      foreach ($get_list as $get_item) {
        $display .= "$get_item: " . $results[0][$get_item] . "\n";
      }
    } else { // Oop! What went wrong?
      $display = "eBay servers returned " . $results['error_count'] .
                 "errors: " . $results['error_msg'];
    }
  } else {
    $display = "Unable to contact $serverUrl";
  }

  echo "$display\n";

?>

