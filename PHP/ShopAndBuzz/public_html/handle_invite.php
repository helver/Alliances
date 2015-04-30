<?php
$debug = 0;
require_once("../Libs/common.inc");
$page = new Private_Page($dbh, $_REQUEST["user"]);
auth_check($page, $dbh);

$myName = $user->GetDisplayName();

$theId = $user->InviteOthers($_REQUEST["name"],$_REQUEST["invitee_email"]);

$SiteURL = $GLOBALS["SiteURL"];

if($theId != -1) {
    $fields = array("me_name" => $myName, 
                    "me_realname" => $user->GetRealName(), 
                    "ebay_name" => $user->eBay_get_username(),
                    "SiteURL" => $GLOBALS["SiteURL"], 
                    "url_email" => urlencode($_REQUEST["invitee_email"]),
                   );
    $templ = new Template($fields);
                   
    if(isset($_REQUEST["seller"]) && $_REQUEST["seller"] == 1) {
        $body = $templ->load_file($templ->getTemplateName("invite_seller.tpl", "EmailTemplates"));
    } else {
        $body = $templ->load_file($templ->getTemplateName("invite.tpl", "EmailTemplates"));
    }
    
    SendEmail($_REQUEST["invitee_email"], "From: Shop And Buzz Support <support@shopandbuzz.com>", "Shop And Buzz Invitation", $body);

    if($debug <= 1) {
       header("Location: /users/$myName/invitations/$theId/");
    }
    exit();
}

require_once("../Libs/common_smarty.inc");

$smarty->display('noinvite.tpl');

exit();

?>
