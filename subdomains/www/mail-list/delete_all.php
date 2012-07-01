<?php
require('config.php');
require 'connect.php';
$title = "Truncate All Tables";
?>

<?php require('header.htm'); ?>

<?php
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