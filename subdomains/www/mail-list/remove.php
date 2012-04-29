<html>
<head></head>
<body>
<?php
require('config.php');

$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

if ((isset($_GET['u'])) and (isset($_GET['ml'])))
{
 $sql = "DELETE FROM ml_subscriptions " .
     "WHERE user_id=" . $_GET['u'] .
     " AND ml_id=" . $_GET['ml'];
     
 //echo 'remove - u- ' . $_GET['u'] . ' ml- ' . $_GET['ml'] . ' sql ' . $sql . "<br />\n";
     
 $result = mysql_query($sql,$conn);
} else {
 die("Incorrect parameters passed for deletion");
}

if ($result) {
 $msg = "<h2>Removal Successful</h2>";
} else {
 $msg = "<h2>Removal Failed</h2>";
}

$ml_id = $_GET['ml'];
$sql = "SELECT * FROM ml_lists WHERE ml_id = '" . $ml_id . "';";
$result = mysql_query($sql)
 or die('Invalid query: ' . mysql_error());
if (mysql_num_rows($result)) {
 $row = mysql_fetch_array($result);
 $msg .= "You have been removed from the <i>" .
     $row['listname'] . "</i> mailing list.<br />";
} else {
 $msg .= "Sorry, could not find Mailing List id#{$ml_id}";
}

$msg .= "<a href='http://www.overpopulation.org'>" .
    "Return to Overpopulation.org</a>";
echo $msg;
?>

</body></html>