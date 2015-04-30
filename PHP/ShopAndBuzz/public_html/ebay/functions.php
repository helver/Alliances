<?php
        /********************************************************************************
          * AUTHOR: Michael Hawthornthwaite - Acid Computer Services (www.acidcs.co.uk) *
          *******************************************************************************/


        /**     sendHttpRequest
                Sends a HTTP request to the specified server with the body and headers passed
                Input:  $requestBody
                                $serverUrl
                                $headers
                Output: The HTTP Response as a String
        */
        function sendHttpRequest($requestBody, $serverUrl, $headers)
        {

                //initialise a CURL session
                $connection = curl_init();
                //set the server we are using (could be Sandbox or Production server)
                curl_setopt($connection, CURLOPT_URL, $serverUrl);

                //stop CURL from verifying the peer's certificate
                curl_setopt($connection, CURLOPT_SSL_VERIFYPEER, 0);
                curl_setopt($connection, CURLOPT_SSL_VERIFYHOST, 0);

                //set the headers using the array of headers
                curl_setopt($connection, CURLOPT_HTTPHEADER, $headers);

                //set method as POST
                curl_setopt($connection, CURLOPT_POST, 1);

                //set the XML body of the request
                curl_setopt($connection, CURLOPT_POSTFIELDS, $requestBody);

                //set it to return the transfer as a string from curl_exec
                curl_setopt($connection, CURLOPT_RETURNTRANSFER, 1);

                //Send the Request
                $response = curl_exec($connection);

                //close the connection
                curl_close($connection);

                //return the response
                return $response;
        }



        /**     buildEbayHeaders
                Generates an array of string to be used as the headers for the HTTP request to eBay
                Input:  $developerID
                                $applicationID
                                $certificateID
                                $compatLevel
                                $siteID
                                $verb
                Output: String Array of Headers
        */
        function buildEbayHeaders($developerID, $applicationID, $certificateID, $compatLevel, $siteID, $verb)
        {
                $headers = array (
                        //Regulates versioning of the XML interface for the API
                        "X-EBAY-API-COMPATIBILITY-LEVEL: $compatLevel",

                        //set the keys
                        "X-EBAY-API-DEV-NAME: $developerID",
                        "X-EBAY-API-APP-NAME: $applicationID",
                        "X-EBAY-API-CERT-NAME: $certificateID",

                        //te name of the call we are requesting
                        "X-EBAY-API-CALL-NAME: $verb",

                        //SiteID must also be set in the Request's XML
                        //SiteID = 0  (US) - UK = 3, Canada = 2, Australia = 15, ....
                        //SiteID Indicates the eBay site to associate the call with
                        "X-EBAY-API-SITEID: $siteID",
                );

                return $headers;
        }

        /********************************************************************************
          * AUTHOR: Bret Robideaux - Alliances Dot Org, LLC
          *******************************************************************************/

        function get_sid () {
          $key_blocks = 10;
          $keys = array();
          $sid = "";

          for ($i = 0; $i < $key_blocks; $i++) {
            $keys[$i] = mt_rand(10000000,99999999);
          }

          foreach ($keys as $k) {
            $sid .= $k;
          }

          return $sid;
        }
?>
