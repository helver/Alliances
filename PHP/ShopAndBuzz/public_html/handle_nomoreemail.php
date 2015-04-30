<?php
require_once("../Libs/common.inc");

$email = urlencode("john@smith.com");

header("Location: /nomoreemail/$email/");
exit();

?>
