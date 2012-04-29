<?php
require('config.php');

global $conn;

$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

$from_name  = 'WOAs Pop Newsletter';
$from_email = 'popnewsletter@overpopulation.org';
 
$action = $_REQUEST['action'];

if (isset($_REQUEST['action']))
{
 switch ($_REQUEST['action'])
 {
  case 'Remove':
   $sql = "SELECT user_id FROM ml_users " .
       "WHERE e_mail='" . $_POST['e_mail'] . "';";
   $result = mysql_query($sql,$conn);

   if (mysql_num_rows($result))
   {
    $row = mysql_fetch_array($result);
    $user_id = $row['user_id'];
    $url = SCRIPT_PATH .
       "/remove.php?u=" . $user_id .
       "&ml=" . $_POST['ml_id'];
    header("Location: $url");
    exit();
   }
   $redirect = 'user.php';
   break;
   
  case 'Subscribe':
   $sql = "SELECT user_id FROM ml_users " .
       "WHERE e_mail='" . $_POST['e-mail'] . "';";
   $result = mysql_query($sql,$conn);

   if (!mysql_num_rows($result))
   {
    $sql = "INSERT INTO ml_users " .
        "(firstname,lastname,e_mail) ".
        "VALUES ('" . $_POST['firstname'] . "'," .
        "'" . $_POST['lastname'] . "'," .
        "'" . $_POST['e_mail'] . "');";
    $result = mysql_query($sql, $conn);
    $user_id = mysql_insert_id($conn);
   }
   else
   {
    $row = mysql_fetch_array($result);
    $user_id = $row['user_id'];
   }

   $sql = "INSERT INTO ml_subscriptions (user_id,ml_id) " .
       "VALUES ('" . $user_id . "','" . $_POST['ml_id'] . "')";
   mysql_query($sql,$conn);

   $sql = "SELECT listname FROM ml_lists " .
       "WHERE ml_id=" . $_POST['ml_id'];
   $result = mysql_query($sql,$conn);
   $row = mysql_fetch_array($result);
   $listname = $row['listname'];

   $url = SCRIPT_PATH . 'user_transact.php?u=' . $user_id .
      '&ml=' . $_POST['ml_id'] . '&action=confirm';

   $subject = ' -' . $listname . '- Mail list confirmation';
   $body = "Hello " . $_POST['firstname'] . "\n" .
      "Our records indicate that you have subscribed to the " .
      $listname . " mailing list.\n\n" .
      "If you did not subscribe, please accept our apologies. " .
      "You will not be subscribed if you do not visit the " .
      "confirmation URL.\n\n" .
      "If you subscribed, please confirm this by visiting the " .
      "following URL:\n" . $url;

   $email = $_POST['e_mail'];
   $to_name = trim($_POST['firstname'] . ' ' . $_POST['lastname']);

   require('send_email.php');  
   send_email($to_name,$email,$from_name,$from_email,$subject,$body);
       
   $redirect = "thanks.php?u=" . $user_id . "&ml=" .
      $_POST['ml_id'] . "&t=s";
   break;


  case 'confirm':

   if (isset($_GET['u']) & isset($_GET['ml']))
   {
    $sql = "UPDATE ml_subscriptions SET pending=0 " .
        "WHERE user_id=" . $_GET['u'] .
        " AND ml_id=" . $_GET['ml'];
    mysql_query($sql, $conn);

    $sql = "SELECT listname FROM ml_lists " .
        "WHERE ml_id=" . $_GET['ml'];
    $result = mysql_query($sql,$conn);

    $row = mysql_fetch_array($result);
    $listname = $row['listname'];

    $sql = "SELECT * FROM ml_users " .
        "WHERE user_id='" . $_GET['u'] . "';";
    $result = mysql_query($sql,$conn);
    $row = mysql_fetch_array($result);
    $firstname = $row['firstname'];
    $lastname = $row['lastname'];
    
    $to_name = trim("$firstname $lastname");
    
    $email = $row['e_mail'];
    
    $url = SCRIPT_PATH . "/remove.php?u=" . $_GET['u'] .
        "&ml=" . $_GET['ml'];

    // Send out confirmed e-mail
    $subject = 'Mailing List Subscription Confirmed';
    $body = "Hello " . $firstname . ",\n" .
       "Thank you for subscribing to the " .
       $listname . " mailing list. Welcome!\n\n" .
       "If you did not subscribe, please accept our apologies.\n".
       "You can remove this subscription immediately by ".
       "visiting the following URL:\n" . $url;
    require('send_email.php');  
    send_email($to_name,$email,$from_name,$from_email,$subject,$body);

    $redirect = "thanks.php?u=" . $_GET['u'] . "&ml=" .
       $_GET['ml'] . "&t=s";
   } else {
    $redirect = 'user.php';
   }
   break;

  default:
   $redirect = 'user.php';
 }
}
## echo 'Blocking redirect to Thanks.php ' . '<br>';
header('Location: ' . $redirect);

?>