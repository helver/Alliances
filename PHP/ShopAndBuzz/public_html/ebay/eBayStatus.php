<?php 
   require_once('../../Libs/common.inc');
   require_once ('Bus_Objects/inc.ebay_request.php');
   include_once ('ConfigFileReader.inc');

   $config = new ConfigFileReader("aswas");
   $userToken = $config->getAttribute('testToken');
   $serverUrl = $config->getAttribute('serverUrl');

   $sid = 0;

   $page = new Public_Page($dbh, "noone");
   //$page = new Private_Page($dbh, $_REQUEST["user"]);
   if (! $page->user_allowed()) {
     echo "Not Allowed or Not Logged In!<BR>\n";
   //  exit;
   }
   
   $user = $page->get_user();
   $token = $user->eBay_get_auth();
   $username = $user->eBay_get_username();

print $sid . "<BR>\n";
//exit ;
      //
      // CALL SPECIFIC DATA
      //
   $verb = 'GetUser';
   $requestXmlBody = '<?xml version="1.0" encoding="utf-8"?>';

$requestXmlTemplate = <<<EOXML
<GetUserRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <DetailLevel>ReturnSummary</DetailLevel>
  <RequesterCredentials>
    <eBayAuthToken>$token</eBayAuthToken>
  </RequesterCredentials>
  <UserID>$username</UserID>
</GetUserRequest>
EOXML;

$requestXmlBody .= $requestXmlTemplate;

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
     $get_list = array('eBayGoodStanding');

     $results = $req->get_results($get_list);
     
     if ($results['error_count'] == 0) { // HEY! No errors!
       $display = "";
       foreach ($get_list as $get_item) {
         $display .= "$get_item: " . $results[$get_item] . "<BR>\n";
       }
     } else { // Oops! What went wrong?
       $display = "eBay servers returned " . $results['error_count'] . 
                  " errors: " . $results['error_msg'];
     }
   } else {
     $display = "Unable to contact $serverUrl";
   }
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
<HR>
<pre>
<?php echo $requestXmlTemplate;?>
</pre>
</P>

</BODY>
</HTML>

<?php
/*
<?xml version="1.0" encoding="utf-8"?>
<GetUserRequest xmlns="urn:ebay:apis:eBLBaseComponents">
  <!-- Standard Input Fields -->
  <DetailLevel> DetailLevelCodeType </DetailLevel>
  <!-- ... more DetailLevel nodes here ... -->
  <ErrorLanguage> string </ErrorLanguage>
  <MessageID> string </MessageID>
  <Version> string </Version>
  <WarningLevel> WarningLevelCodeType </WarningLevel>
  <!-- Call-specific Input Fields -->
  <IncludeExpressRequirements> boolean </IncludeExpressRequirements>
  <ItemID> string (ItemIDType) </ItemID>
  <UserID> string </UserID>
</GetUserRequest>

<?xml version="1.0" encoding="utf-8"?>
<GetUserResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <!-- Standard Output Fields -->
  <Ack> AckCodeType </Ack>
  <Build> string </Build>
  <CorrelationID> string </CorrelationID>
  <Errors>
    <ErrorClassification> ErrorClassificationCodeType </ErrorClassification>
    <ErrorCode> token </ErrorCode>
    <ErrorParameters ParamID="string">
      <Value> string </Value>
    </ErrorParameters>
    <!-- ... more ErrorParameters nodes here ... -->
    <LongMessage> string </LongMessage>
    <SeverityCode> SeverityCodeType </SeverityCode>
    <ShortMessage> string </ShortMessage>
  </Errors>
  <!-- ... more Errors nodes here ... -->
  <HardExpirationWarning> string </HardExpirationWarning>
  <Timestamp> dateTime </Timestamp>
  <Version> string </Version>
  <!-- Call-specific Output Fields -->
  <User>
    <AboutMePage> boolean </AboutMePage>
    <CharityAffiliations>
      <CharityID type="CharityAffiliationTypeCodeType"> string (CharityIDType) </CharityID>
      <!-- ... more CharityID nodes here ... -->
    </CharityAffiliations>
    <eBayGoodStanding> boolean </eBayGoodStanding>
    <eBayWikiReadOnly> boolean </eBayWikiReadOnly>
    <EIASToken> string </EIASToken>
    <Email> string </Email>
    <FeedbackPrivate> boolean </FeedbackPrivate>
    <FeedbackRatingStar> FeedbackRatingStarCodeType </FeedbackRatingStar>
    <FeedbackScore> int </FeedbackScore>
    <IDVerified> boolean </IDVerified>
    <MotorsDealer> boolean </MotorsDealer>
    <NewUser> boolean </NewUser>
    <PayPalAccountLevel> PayPalAccountLevelCodeType </PayPalAccountLevel>
    <PayPalAccountStatus> PayPalAccountStatusCodeType </PayPalAccountStatus>
    <PayPalAccountType> PayPalAccountTypeCodeType </PayPalAccountType>
    <PositiveFeedbackPercent> float </PositiveFeedbackPercent>
    <RegistrationAddress>
      <CityName> string </CityName>
      <CompanyName> string </CompanyName>
      <Country> CountryCodeType </Country>
      <CountryName> string </CountryName>
      <Name> string </Name>
      <Phone> string </Phone>
      <PostalCode> string </PostalCode>
      <StateOrProvince> string </StateOrProvince>
      <Street> string </Street>
      <Street1> string </Street1>
      <Street2> string </Street2>
    </RegistrationAddress>
    <RegistrationDate> dateTime </RegistrationDate>
    <RESTToken> string </RESTToken>
    <SellerInfo>
      <AllowPaymentEdit> boolean </AllowPaymentEdit>
      <CharityRegistered> boolean </CharityRegistered>
      <CheckoutEnabled> boolean </CheckoutEnabled>
      <CIPBankAccountStored> boolean </CIPBankAccountStored>
      <ExpressEligible> boolean </ExpressEligible>
      <ExpressSellerRequirements>
        <BusinessSeller> boolean </BusinessSeller>
        <CombinedPaymentsAccepted> boolean </CombinedPaymentsAccepted>
        <EligiblePayPalAccount> boolean </EligiblePayPalAccount>
        <ExpressApproved> boolean </ExpressApproved>
        <ExpressSellingPreference> boolean </ExpressSellingPreference>
        <FeedbackAsSellerScore minimum="string"> boolean (FeedbackRequirementsType) </FeedbackAsSellerScore>
        <FeedbackPublic> boolean </FeedbackPublic>
        <FeedbackScore minimum="string"> boolean (FeedbackRequirementsType) </FeedbackScore>
        <GoodStanding> boolean </GoodStanding>
        <PayPalAccountAcceptsUnconfirmedAddress> boolean </PayPalAccountAcceptsUnconfirmedAddress>
        <PositiveFeedbackAsSellerPercent minimum="string"> boolean (FeedbackRequirementsType) </PositiveFeedbackAsSellerPercent>
        <PositiveFeedbackPercent minimum="string"> boolean (FeedbackRequirementsType) </PositiveFeedbackPercent>
      </ExpressSellerRequirements>
      <ExpressWallet> boolean </ExpressWallet>
      <GoodStanding> boolean </GoodStanding>
      <LiveAuctionAuthorized> boolean </LiveAuctionAuthorized>
      <MerchandizingPref> MerchandizingPrefCodeType </MerchandizingPref>
      <ProStoresPreference>
      </ProStoresPreference>
      <QualifiesForB2BVAT> boolean </QualifiesForB2BVAT>
      <RegisteredBusinessSeller> boolean </RegisteredBusinessSeller>
      <SafePaymentExempt> boolean </SafePaymentExempt>
      <SchedulingInfo>
        <MaxScheduledItems> int </MaxScheduledItems>
        <MaxScheduledMinutes> int </MaxScheduledMinutes>
        <MinScheduledMinutes> int </MinScheduledMinutes>
      </SchedulingInfo>
      <SellerGuaranteeLevel> SellerGuaranteeLevelCodeType </SellerGuaranteeLevel>
      <SellerLevel> SellerLevelCodeType </SellerLevel>
      <SellerPaymentAddress>
        <CityName> string </CityName>
        <Country> CountryCodeType </Country>
        <CountryName> string </CountryName>
        <InternationalName> string </InternationalName>
        <InternationalStateAndCity> string </InternationalStateAndCity>
        <InternationalStreet> string </InternationalStreet>
        <Name> string </Name>
        <Phone> string </Phone>
        <PostalCode> string </PostalCode>
        <StateOrProvince> string </StateOrProvince>
        <Street1> string </Street1>
        <Street2> string </Street2>
      </SellerPaymentAddress>
      <StoreOwner> boolean </StoreOwner>
    </SellerInfo>
    <SellerPaymentMethod> SellerPaymentMethodCodeType </SellerPaymentMethod>
    <Site> SiteCodeType </Site>
    <SiteVerified> boolean </SiteVerified>
    <SkypeID> string </SkypeID>
    <!-- ... more SkypeID nodes here ... -->
    <Status> UserStatusCodeType </Status>
    <TUVLevel> int </TUVLevel>
    <UniqueNegativeFeedbackCount> int </UniqueNegativeFeedbackCount>
    <UniquePositiveFeedbackCount> int </UniquePositiveFeedbackCount>
    <UserID> string (UserIDType) </UserID>
    <UserIDChanged> boolean </UserIDChanged>
    <UserIDLastChanged> dateTime </UserIDLastChanged>
    <UserSubscription> EBaySubscriptionTypeCodeType </UserSubscription>
    <!-- ... more UserSubscription nodes here ... -->
    <VATID> string </VATID>
    <VATStatus> VATStatusCodeType </VATStatus>
  </User>
</GetUserResponse>
*/

?>

