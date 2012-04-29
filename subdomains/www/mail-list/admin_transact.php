<?php
require('config.php');
$title = "Admin Transaction";
require('header.htm'); 
?>

<?php
$msg = "";
$body = "";
$ft1="";
$ft2 = "";
$articles = "";
$paragraphs = "";
$lines = "";
$sentences = "";

global $conn;
$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

if (isset($_POST['action']))
{
 switch ($_POST['action'])
 {
  case 'Add New Mailing List':
   $sql = "INSERT INTO ml_lists (listname) VALUES ('" .
       $_POST['listname'] . "');";
   mysql_query($sql)
    or die('Could not add mailing list. ' . mysql_error());
   echo 'Adding ' . $_POST['listname'] . '<br />';
   break;

//  case 'Delete Mailing List':
//   $sql = "DELETE FROM ml_lists WHERE ml_id=" . '" .$_POST['ml_id'] . "');
//   mysql_query($sql)
//    or die('Could not delete mailing list. ' . mysql_error());
//	$sql = "DELETE FROM ml_subscriptions WHERE ml_id=" . '" .$_POST['ml_id'] . "');
//   mysql_query($sql)
//    or die('Could not delete mailing list subscriptions. ' .
//    mysql_error());
//   echo 'Deleting ' . $_POST['listname'] . '<br />';
//   break;

  case 'Send Message':
    require 'send_message.php';
    send_message($conn,$_POST);
    break;
  }
}

?>

<?php require('footer.htm'); ?>