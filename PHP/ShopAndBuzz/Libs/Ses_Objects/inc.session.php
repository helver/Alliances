<?
// Useage:
//
// $Session = new Session();
// $Session->set($key, $value);
// $sessionvalue = $Session->get($key);

class Session
{
  public function __construct() {
    session_start();
  }

  public function __destruct() {
    session_write_close();
  }
  
  public function store ($key, $value) {
    $_SESSION[$key] = $value;
  }

  public function get($key) {
    if (array_key_exists($key, $_SESSION)) {
       return $_SESSION[$key];
     } else {
       return NULL;
     }
  }

  public function activate () {
    $this->store('active', 1);
  }

  public function deactivate () {
    $this->store('active', 0);
  }

  public function is_active () {
    return $this->get('active');
  }
}

?>
