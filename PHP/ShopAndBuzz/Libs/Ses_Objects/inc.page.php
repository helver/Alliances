<?php

require_once ("Bus_Objects/inc.aswas_user.php");

////////////////////////////////////////////////////////////////
// BASE CLASS: Page
//
// Parent class of the page objects. Any page that needs to 
// be protected/restricted to a class of users, needs to 
// instantiate a child of this class, then check the is_allowed
// method to determine if the user is in the appropriate class.
//
// Public pages, that do not require authentication to view
// do not need to instantiate a Page object.
////////////////////////////////////////////////////////////////

class Page
{
  private $user;
  protected $allowed;
  protected $owner;

  protected function __construct ($dbh) {
    $this->user = new Aswas_User($dbh);
    $this->allowed = 0;
  }

  public function is_user_active () {
    return $this->user->Sess_isAuth();
  }

  public function is_user_admin () {
    return $this->user->IsAdmin();
  }

  public function get_user () {
    return $this->user;
  }

  public function user_allowed () {
    return $this->allowed;
  }
}

////////////////////////////////////////////////////////////////
// CHILD CLASS: User Page
//
// Basic User Page, user merely needs to be logged in to access
// pages of this type.
////////////////////////////////////////////////////////////////
class User_Page extends Page
{
  public function __construct ($dbh, $owner) {
    parent::__construct($dbh);

    $this->owner = $owner;
    if ($this->is_user_active() || $this->is_user_admin()) {
      $this->allowed = 1;
    }
  }
}

////////////////////////////////////////////////////////////////
// CHILD CLASS: Admin Page
//
// Only administrators are allowed to access pages of this type.
////////////////////////////////////////////////////////////////
class Admin_Page extends Page
{
  #public function __construct ($dbh, $owner) {
  public function __construct ($dbh) {
    parent::__construct($dbh);

    #$this->owner = $owner;
    if ($this->is_user_active() && $this->is_user_admin()) {
      $this->allowed = 1;
    }
  }
}

////////////////////////////////////////////////////////////////
// CHILD CLASS: Public Page
//
// This page is a page owned by one user but is viewable by
// another user. The visitor must be logged in to view this
// page, but otherwise no restrictions are made.
////////////////////////////////////////////////////////////////
class Public_Page extends Page
{
  public function __construct ($dbh, $owner) {
    parent::__construct($dbh);

    $this->owner = $owner;
    if ($this->is_user_active() || $this->is_user_admin()) {
      $this->allowed = 1;
    }
  }
}

////////////////////////////////////////////////////////////////
// CHILD CLASS: Private Page
//
// This is a private page, only the owner of the page may
// access this page.
////////////////////////////////////////////////////////////////
class Private_Page extends Page
{
  public function __construct ($dbh, $owner) {
    parent::__construct($dbh);

    $this->owner = $owner;
    if (   (   $this->is_user_active() 
            && !(strcmp($this->get_user()->GetDisplayName(), $owner))
           )
        || $this->is_user_admin()) {
      $this->allowed = 1;
    }
  }
}

////////////////////////////////////////////////////////////////
// CHILD CLASS: Open Page
//
// This page is a open to be viewed by any user, logged in or
// not.
////////////////////////////////////////////////////////////////
class Open_Page extends Page
{
  public function __construct ($dbh) {
    parent::__construct($dbh);

    $this->allowed = 1;
  }
}

?>
