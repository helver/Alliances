<?php

include_once ('ConfigFileReader.inc');

class eBayRequest {

  private $headers;
  private $response;

  private $config;

  public $debug;

  public function __construct ($verb, $myconfig = 0) {
    if ($myconfig) {
      $this->config = $myconfig;
    } else {
      $this->config = new ConfigFileReader("aswas");
    }

    $this->debug = 0;

    $devID = $this->config->getAttribute('devID');
    $appID = $this->config->getAttribute('appID');
    $certID = $this->config->getAttribute('certID');
    $siteID = $this->config->getAttribute('siteID');
    if (!$siteID) {
      $siteID = 0;  // default to U.S.
    }
    $version = $this->config->getAttribute('ebay_version');

    $this->headers = $this->build_headers($devID, $appID, $certID, 
                                          $version , $siteID, $verb);

    $this->response = array(); 
  }

  //
  // Author: Michael Hawthornthwaite
  //         - Acid Computer Services (www.acidcs.co.uk)
  // Edited: Bret Robideaux
  //         - Alliances Dot Org, LLC (www.alliances.org)
  //
  // sendHttpRequest
  //   Sends a HTTP request to the specified server with the 
  //   body and headers passed
  //     Input:  $requestBody, $serverUrl, $headers
  //
  //     Output: 1 on Success, 0 on Failure
  // 
  //     Side Effects: sets attribute $response to result of call
  //
  // Issue:
  //   eBay only returns a default of 200 entries per 'page'. That
  //   means we have to write code to handle the possibility that
  //   we may need to request multiple pages of data.
  //
  // Fields in the request:
  //   <Pagination>
  //     <PageNumber> int </PageNumber>
  //   </Pagination>
  //
  // Fields in the response:
  //   <PageNumber> int </PageNumber>
  //   <TotalNumberOfPages> int </TotalNumberOfPages>
  // 
  // Method:
  //   I'm going to expect a _PAGINATION_ flag in the $template
  // of any request where multiple pages may be an issue. I can
  // use that to rewrite and resend any template with a multiple
  // page response.
  //

  public function send_request ($template, $url) {
    $page_num = 0;
    $total_pages = 1;
    $do_paging = 1;
    $retval = 0;

    //initialise a CURL session
    $connection = curl_init();
    //set the server we are using (could be Sandbox or Production server)
    curl_setopt($connection, CURLOPT_URL, $url);

    //stop CURL from verifying the peer's certificate
    curl_setopt($connection, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($connection, CURLOPT_SSL_VERIFYHOST, 0);

    //set the headers using the array of headers
    curl_setopt($connection, CURLOPT_HTTPHEADER, $this->headers);

    //set method as POST
    curl_setopt($connection, CURLOPT_POST, 1);

    $do_paging = preg_match ('_PAGINATION_', $template);
    while ($page_num < $total_pages) {
      $send_tmpl = $template;
      if ($do_paging && $page_num > 0) {
        $tag = "<Pagination><PageNumber>$page_num</PageNumber></Pagination>\n";
        $send_tmpl = preg_replace ('_PAGINATION_', $tag, $template);
      }

      //set the XML body of the request
      curl_setopt($connection, CURLOPT_POSTFIELDS, $send_tmpl);

      //set it to return the transfer as a string from curl_exec
      curl_setopt($connection, CURLOPT_RETURNTRANSFER, 1);

      $curl_resp = curl_exec($connection);
      
      if ($this->debug > 4) {
        print "curl_resp: $curl_resp<br>\n";
      }
 
      curl_close($connection);

      $this->response[] = $curl_resp;
      $retval = 1; // assume success, check for failure
      if(stristr($curl_resp, 'HTTP 404') || $curl_resp == '') {
        $retval = 0;
         break;
      }

      if ($do_paging) {
        $list = array ('PageNumber', 'TotalNumberOfPages');
        $page_results = $this->get_results($list);

        $page_num = $page_results['PageNumber'];
        $total_pages = $page_results['TotalNumberOfPages'];
        $page_num++;
      } else {
        $page_num = 0;
        $total_pages = 0;
      }
    }

    
    return $retval;
  }

  //
  // Input:
  //   $input     : XML nodes to search for matches (one or a list)
  //
  // Output:
  //   $hash[count][single $input]
  //
  public function get_results ($input) {
    $retval = array();
    $retval['error_count'] = 0;

    if (is_array($input)) {
      $attributes = $input;
    } else {
      $attributes = array($input);
    }

    foreach ($this->response as $resp) {

      $responseDoc = new DOMDocument();
      $responseDoc->loadXML($resp);

      // Check for errors first 
      $errors = $responseDoc->getElementsByTagName('Errors');

      if($errors->length > 0) {
        $retval['error_count'] = $errors->length;
        $retval['error_msg'] = $this->get_errors($responseDoc, $errors);
        break;
      } else {
        foreach ($attributes as $path) {
          $elem_list = explode ('.', $path);
          $top_elem = array_shift($elem_list);
          $topNodes = $responseDoc->getElementsByTagName($top_elem);
  
          for ($i = 0; $i < $topNodes->length; $i++) {
            $node = $topNodes->item($i);
            $retval[$i][$path] = $this->get_data_from($node, $elem_list);
          }
        }
      }
    }
    return $retval; 
  }

  //
  // Input:
  //   $input     : XML nodes to search for matches (one or a list)
  //   $where_fld : XML node to filter matches (only one, relative to $top_node)
  //                format: X.Y.Z 
  //   $where_val : filter values for XML nodes (one or a list)
  //   $top_node  : Top Node name of Array of entries.
  //
  // Output:
  //   $hash[value at $where_fld][count][single $input]
  //
  public function get_matching_results ($input, $where_fld, $where_val, $top_node) {

    if ($this->debug) {
      print "get_matching_results (enter): <BR>\n";
    }

    $retval = array();
    $retval['error_count'] = 0;

    if (is_array($input)) {
      $attributes = $input;
    } else {
      $attributes = array($input);
    }

    if (is_array($where_val)) {
      $where_vals = $where_val;
    } else {
      $where_vals = array($where_val);
    }

    if ($this->debug) {
      print_r ($attributes);
      print "$where_fld<BR>\n";
      print_r ($where_vals);
      print "$top_node<BR>\n";
    }

    foreach ($this->response as $resp) {

      $responseDoc = new DOMDocument();
      $responseDoc->loadXML($resp);

      // Check for errors first
      $errors = $responseDoc->getElementsByTagName('Errors');

      if($errors->length > 0) {
        $retval['error_count'] = $errors->length;
        $retval['error_msg'] = $this->get_errors($responseDoc, $errors);
        break;
      } else {
        $topNodes = $responseDoc->getElementsByTagName($top_node);

        if ($this->debug) {
          print "Found " . $topNodes->length . " nodes to check <BR>\n";
        }

        for ($i = 0; $i < $topNodes->length; $i++) {
          $node = $topNodes->item($i);

          $where_fld_list = explode ('.', $where_fld);
          $catch = $this->get_data_from($node, $where_fld_list);

          if ($this->debug) {
            print "get_data_from.catch.$i ($where_fld) => $catch <BR>\n";
          }

          if (in_array($catch, $where_vals)) {

            foreach ($attributes as $path) {
              if ($this->debug) {
                print "path => $path <BR>\n";
              }

              $elem_list = explode ('.', $path);

              $retval[$catch][$i][$path] = $this->get_data_from($node, $elem_list);
            }
          }
        }
      }
    }
    return $retval;
  }

  public function match_results ($path, $match) {

    foreach ($this->response as $resp) {
      $responseDoc = new DOMDocument();
      $responseDoc->loadXML($resp);

      // Check for errors first
      $errors = $responseDoc->getElementsByTagName('Errors');

      if($errors->length > 0) {
        //$retval  = $this->get_errors($responseDoc, $errors);
        $retval = -1; 
        break;
      } else {
        $path_list = explode ('.', $path);
        $top_elem = array_shift($path_list);
        $topNodes = $responseDoc->getElementsByTagName($top_elem);
     
        for ($i = 0; $i < $topNodes->length; $i++) {
          $node = $topNodes->item($i);
          $retval[$i] = $this->get_data_from($node, $path_list);
        }

        if ($match) {
          foreach ($retval as $data) {
            $retval = ($data === $match) ? 1 : 0;
            if ($retval) {
              break;
            }
          }
        } 
      } 
    }
    return $retval;
  }


  //
  // Author: Michael Hawthornthwaite 
  //         - Acid Computer Services (www.acidcs.co.uk)
  // Edited: Bret Robideaux
  //         - Alliances Dot Org, LLC (www.alliances.org)
  //
  // buildEbayHeaders
  //   Generates an array of string to be used as the headers 
  //   for the HTTP request to eBay
  //     Input:  $developerID, $applicationID, $certificateID
  //             $compatLevel, $siteID, $verb
  //
  //     Output: String Array of Headers
  //
 
  private function build_headers ($dev, $app, $cert, $compat, $site, $verb) {
    $headers = array (
         //Regulates versioning of the XML interface for the API
         "X-EBAY-API-COMPATIBILITY-LEVEL: $compat",

         //set the keys
         "X-EBAY-API-DEV-NAME: $dev",
         "X-EBAY-API-APP-NAME: $app",
         "X-EBAY-API-CERT-NAME: $cert",

         //the name of the call we are requesting
         "X-EBAY-API-CALL-NAME: $verb",

         //SiteID must also be set in the Request's XML
         //SiteID = 0  (US) - UK = 3, Canada = 2, Australia = 15, ....
         //SiteID Indicates the eBay site to associate the call with
         "X-EBAY-API-SITEID: $site",
        );

    return $headers;
  }

  private function get_errors ($responseDoc, $errors) {
    $retval['error_count'] = $errors->length;
    $Message = "Error List ";
    $shortMsgRef = $responseDoc->getElementsByTagName('ShortMessage');
    if ($shortMsgRef->length > 0) {
      for ($i = 0; $i < $shortMsgRef->length; $i++) {
        $shortMsg = $shortMsgRef->item(0)->nodeValue;
        $shortMsg = str_replace(">", "&gt;", $shortMsg);
        $Message .= "|($i: short)|" . str_replace("<", "&lt;", $shortMsg);
      }
    }
    $longMsgRef = $responseDoc->getElementsByTagName('LongMessage');
    if ($longMsgRef->length > 0) {
      for ($i = 0; $i < $longMsgRef->length; $i++) {
        $longMsg = $longMsgRef->item(0)->nodeValue;
        $longMsg = str_replace(">", "&gt;", $longMsg);
        $Message .= "|($i: long)|" . str_replace("<", "&lt;", $longMsg);
      }
    }

    return $Message;
  }

  private function pull_response_list ($doc, $attr) {
    $retval = array();

    $node = $doc->getElementsByTagName($attr);
    for ($i = 0; $i < $node->length; $i++) {
      $retval[$i] = $node->item($i)->nodeValue;
    }

    return $retval;
  }

  private function get_data_from ($node, $path) {
    if (is_array($path) && count($path)) {  // walk the path
      if ($this->debug) {
        print "get_data_from (enter): \n";
        print_r ($path);
      }

      foreach ($path as $link) {
        $node->normalize();
        $cur_doc = new DOMDocument();

        if ($this->debug) {
          print "get_data_from walking: $link <BR>\n";
        }

        $temp = $cur_doc->importNode($node, 1);
        $cur_doc->appendChild($temp);
        $cur_elem = $cur_doc->getElementsByTagName($link);
        $new_node = $cur_elem->item(0);

        if (!$new_node) {
          print "get_data_from (error) -- old node name: " . $node->nodeName . " <BR>\n";
          break;
        } else {
          $node = $new_node;
        }
      }
    } 
    // we're here

    if ($this->debug) {
      print "get_data_from (exit): " . $node->nodeValue . " <BR>\n";
    }

    return $node->nodeValue;
  }

  public function get_response()
  {
    return $this->response;
  }
  
} // end class eBayRequest

?>
