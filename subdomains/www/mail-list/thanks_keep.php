<?php
require('config.php');
$title = "";
require('header_user.htm'); 

$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

if (isset($_GET['u']))
{
 $uid = $_GET['u'];
 $sql = "SELECT * FROM ml_users WHERE user_id = '$uid';";
 $result = mysql_query($sql)
  or die('Invalid query: ' . mysql_error());
 if (mysql_num_rows($result)) {
  $row = mysql_fetch_array($result);
  $msg = "<h2>Thank You, " . $row['firstname'] . "</h2><br /><br />";
  $e_mail = $row['e_mail'];
 } else {
  die("No match for user id " . $uid);
 }
}

if (isset($_GET['ml']))
{
 $ml_id = $_GET['ml'];
 $sql = "SELECT * FROM ml_lists WHERE ml_id = '" . $ml_id . "';";
 $result = mysql_query($sql)
  or die('Invalid query: ' . mysql_error());
 if (mysql_num_rows($result)) {
  $row = mysql_fetch_array($result);
  $msg .= "Thank you for subscribing to the <i>" .
     $row['listname'] . "</i> mailing list.<br />";
 } else {
  die ("Could not find Mailing List $ml_id");
 }
} else {
 die ("Mailing List id missing.");
}

if (!isset($_GET['t'])) die("Missing Type");
switch ($_GET['t'])
{
 case 'c':
  $msg .= "A confirmation request has been sent " .
      "to <b>$e_mail</b>.<br />" .
      "Please follow the confirmation instructions to confirm your subscription.<br /><br />";
  break;
 case 's':
  $msg .= "A subscription notification has been " .
      "sent to you at <b>$e_mail</b>.<br /><br />";
}
$msg .= "If you have a problem or don't receive your confirmation, please send an email to " . ADMIN_EMAIL . '<br><br>' .
        "<a href='http://www.overpopulation.org'>" .
    "Return to Overpopulation.org</a>";
echo $msg;
?>
<?php require('footer.htm'); ?>