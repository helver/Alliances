<?php

include_once("PG_DBWrapper.inc");

class aswas_user
{
private $debug;
private $config;
private $dbh;
private $username;
private $userid;
private $isSeller;

function aswas_user ($mydbh){
	$this->dbh = $mydbh;
	
	if($this->debug > 0) {
		print "In aswas_user";
	}
	
}


function BuildUser() {
		$this->userid = $this->dbh->SelectSingleValue("id", "buzz_user", "lower(username)=lower('" . $this->username . "')");

}

function LoadUser( $myUser, $mydebug = 0, $myconfig="" ) {
	$this->config = $myconfig;
	$this->debug = $mydebug;
	$this->username = $myUser;
	
	$this->buildUser();

}

function AddUser($username, $password, $name, $email) {
	$token = $this->GenerateToken($username);
	$res = $this->dbh->Insert("unconfirmed_user", array("username" => $username, "email" => $email, "password" => $password, "token" => $token));
	return $token;
}

function GenerateToken($username) {
	return $username;
}

function GetUnconfirmedUserEmail($user) {
	$res = $this->dbh->SelectSingleValue("email", "unconfirmed_user", "lower(username)=lower('$user')");
	return $res;
}

function ConfirmUnconfirmed($token) {
	$username = $this->dbh->SelectSingleValue("username", "unconfirmed_user", "lower(token)=lower('$token')");
	$res = $this->dbh->Insert("buzz_user", " (select nextval('buzz_user_id_seq'), email, username, password,1 from unconfirmed_user where lower(token)=lower('$token'))");
	if ($res == 1) {
		$res2 = $this->dbh->Delete("unconfirmed_user", "lower(token)=lower('$token')");
	}
	
	$this->LoadUser($username);
	
	return $res;
}

function GetUserInfo() {
	
	$res = $this->dbh->SelectFirstRow("*", "buzz_user", "lower(username)=lower('" . $this->username . "')");
	
	return $res;

}

function GetDisplayName() {
	
	//$res = $this->dbh->SelectSingleValue("username", "buzz_user", "lower(username)=lower('" . $this->username . "')");
	$res = $this->username;
	
	return $res;

}

function IsSeller() 
{
  if (!isset($this->isSeller)) {
    $res = $this->dbh->SelectSingleValue("1", "seller_info", "buzz_user_id = " . $this->userid);
    if ($res == 1) {
      $this->isSeller = True;
    } else {
      $this->isSeller = False;
    }
  }
  return $this->isSeller;
}

function UpdateUserInfo($myVals) {
	
	$res = $this->dbh->Update("buzz_user", $myVals, "lower(username=lower('" . $this->username . "')");
	return $res;
}


function DeleteUserInfo() {
	$res = $this->dbh->Delete("buzz_user", "lower(username=lower('" . $this->username . "')");
	return $res;
}

function AddUserInfo($myVals) {
	$res = $this->dbh->Insert("buzz_user", $myVals);
}

function GetMyHive($numUsers = -1) {
	if($numUsers != -1) {
		$top = "limit $numUsers";
	} else {
		$top = "";
	}
	
	$res = $this->dbh->Select("username as user", "hive h, buzz_user bu", "bu.id=h.member_id and h.buzz_user_id=" . $this->userid, "random()" . " $top");
	return $res;

}

function AddUserToMyHive($theirID) {
	if(ConfirmReco($theirID, $this->userid)) {	
		//Need to add constraint to only allow it to be added once (key on buzz_user_id and member_id)
		$res = $this->dbh->Insert("hive", array("buzz_user_id" => $this->userid, "member_id" => $theirID, "date_added" => "sysdate"));
	} else {
		$res = -1;
	}
	return $res;
}


function GetMyHoneycomb($numUsers = -1) {
	if($numUsers != -1) {
		$top = "limit $numUsers";
	} else {
		$top = "";
	}
	
	$res = $this->dbh->Select("username as user", "honeycomb h, buzz_user bu", "bu.id=h.member_id and h.buzz_user_id=" . $this->userid, "random()" . " $top");
	return $res;

}

function AddUserToMyHoneyComb($theirID) {
	if(ConfirmReco($theirID, $this->userid)) {
		//Need to add constraint to only allow it to be added once (key on buzz_user_id and member_id)
		$res = $this->dbh->Insert("honeycomb", array("buzz_user_id" => $this->userid, "member_id" => $theirID, "date_added" => "sysdate"));
	} else {
		$res = -1;
	}
	return $res;
}


function ConfirmReco ($buyer, $seller) {
//NEED TO GET THIS FROM THE EBAY/PAYPAL API
	return 1;
}

function GetCountHive () {
	$res = $this->dbh->SelectSingleValue("count(1)", "hive", "buzz_user_id=" . $this->userid);
	return $res;
}

function GetEbayStatus () {
		return "GOOD";

}

function GetMyStatus() {
	//Need to figure out what we should return here?  What status?
	return "Seller Is An Active Member";
}

function GetSellerProfile () {
	$res = $this->dbh->SelectSingleValue("description", "buzz_user_profile", "buzz_user_id=" . $this->userid);
	return $res;
}

function GetHivesContainsMe($numUsers = -1) {
	if($numUsers != -1) {
		$top = "limit $numUsers";
	} else {
		$top = "";
	}

	$res = $this->dbh->Select("username as user", "hive h, buzz_user bu", "bu.id=h.buzz_user_id and h.member_id=" . $this->userid, "random()" . " $top");
	return $res;

}

function GetCountHivesContainsMe() {
	$res = $this->dbh->SelectSingleValue("count(1)", "hive", "member_id=" . $this->userid);
	return $res;
}

function GetCommissionsPaid($numComms = -1) {
	if($numComms != -1) {
		$top = "limit $numComms";
	} else {
		$top = "";
	}

	$res = $this->dbh->Select("username as user,amount as amount, '/transaction/' || purchase_id || '/' as basis", "paid_comms p, buzz_user bu", "bu.id=p.referral_id and p.payee_id=" . $this->userid, "paid_date" . " $top");
	return $res;

}

function GetCommisionsReceived($numComms = -1) {
	if($numComms != -1) {
		$top = "limit $numComms";
	} else {
		$top = "";
	}

	$res = $this->dbh->Select("username as user,amount as amount, '/transaction/' || purchase_id || '/' as basis", "paid_comms p, buzz_user bu", "bu.id=p.payee_id and p.referral_id=" . $this->userid, "paid_date" . " $top");
	return $res;

}

function GetMyBlacklist() {
	
	$res = $this->dbh->Select("username as user", "blocked_emails b, buzz_user bu", "bu.id=b.from_id and b.to_id=" . $this->userid);
	return $res;

}


function AddBlacklist($blocked) {
	//need to add constraint on from_id and to_id
	$tool = $this->dbh->SelectSingleValue("id", "buzz_user", "lower(username)=lower('$blocked')");
	$res = $this->dbh->Insert("blocked_emails", array("to_id" => $this->userid, "from_id" => $tool));
	return $res;
}

function RemoveBlacklist ($blockID) {
	$res = $this->dbh->Delete("blocked_emails", "from_id=$blockID and to_id=" . $this->userid);
	return $res;
}

function GetMyEmailFreq () {
	$res=$this->dbh->SelectSingleValue("value as delivery_schedule", "buzz_user_profile bup, email_freq ef", "ef.preference=bup.email_pref and bup.buzz_user_id=" . $this->userid);
	return $res;
}

function UpdateEmailFreq ($pref) {
	$res = $this->dbh->Update("buzz_user_profile", "email_pref=$pref", "buzz_user_id=" . $this->userid);
	return $res;

}

function GetMyInvites ($myID = -1) {

	if ($myID != -1) {
		$myWhere = " and invite_id=$myID";
	} else {
		$myWhere = "";
	}
		
	$res = $this->dbh->Select("invite_id as id, invite_name as name, invite_email as email,to_char(invite_date, 'mm/dd/yyyy') as date, invite_status as status", "invites", "buzz_user_id=". $this->userid . "$myWhere");
	return $res;
}


function InviteOthers ($name, $email) {
	$res = $this->dbh->Insert("invites", array(
							"buzz_user_id" => $this->userid,
							"invite_name"  => $name,
							"invite_email" => $email,
							"invite_date" => "now",
							"invite_status" => "'Pending'"
						));
	$results= $this->dbh->SelectSingleValue("invite_id", "invites", "invite_name='$name' and invite_email='$email' and invite_status = 'Pending'");
	return $results;
}


function GetUsersICanSee($where = "") {
   print "where: $where<br>\n";
   $this->dbh->debug(5);
   $res = $this->dbh->Select("username as user", "buzz_user bu left outer join blocked_emails b on bu.id = b.to_id and b.from_id = " . $this->userid, "b.to_id is NULL" . ($where == "" ? "" : " AND " . $where);
   return $res;
}

}
?>
