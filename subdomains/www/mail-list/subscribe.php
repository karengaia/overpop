<?php
function subscribe($conn, $params=array()) {
   global $conn;
   
   $firstname = $_POST['firstname'];
   $lastname  = $_POST['lastname'];
   $email     = $_POST['email'];
   $sub_id    = $_POST['ml_id'];
   $pending   = $_POST['pending'];

   $sql = "SELECT user_id FROM ml_users WHERE e_mail = '" . $email . "'";
   $result = mysql_query($sql,$conn) or die('Query failed: ' . mysql_error() . "<br />\n$sql"); 

   if (!mysql_num_rows($result))
   {
    $sql = "INSERT INTO ml_users (firstname, lastname, e_mail) " . 
         " VALUES ('" . $firstname . "', '" . $lastname . "', '" . $email . "')";
    $result = mysql_query($sql, $conn)  or die('Query failed: ' . mysql_error() . "<br />\n$sql");
    $user_id = mysql_insert_id($conn)  or die('Query failed: ' . mysql_error() . "<br />\n$sql");
   }
   else
   {
    $row = mysql_fetch_array($result);
    $user_id = $row['user_id'];
   }

   $sql = "INSERT INTO ml_subscriptions (ml_id, user_id, pending) " .
      " VALUES (" . $sub_id . ", '" . $user_id . "', " . $pending . ")";
   mysql_query($sql,$conn)  or die('Query failed: ' . mysql_error() . "<br />\n$sql");
   
   echo $email ."<br />";
}

?>