<?php
require('config.php');
$title = "Truncate All Tables";
?>

<?php require('header.htm'); ?>

<?php
$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

$sql = "TRUNCATE TABLE ml_subscriptions";

$result = mysql_query($sql,$conn);

if ($result) {
 echo "<p>Subscriptions Deletion Successful</p>";
} else {
 echo "<p>Subscriptions Deletion Failed</p>";
}

$sql = "TRUNCATE TABLE ml_users";

$result = mysql_query($sql,$conn);

if ($result) {
 echo "<p>Users Deletion Successful</p>";
} else {
 echo "<p>Users Deletion Failed</p>";
}


$sql = "TRUNCATE TABLE ml_lists";
     
$result = mysql_query($sql,$conn);

if ($result) {
 echo "<p>Lists Deletion Successful</p>";
} else {
 echo "<p>Lists Deletion Failed</p>";
}
	
?>


<?php require('footer.htm'); ?>