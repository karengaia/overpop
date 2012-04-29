<?php
class DB {
  static function connect() {
    global $conn;
    if (!@$conn) {
      $conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
	or die('Could not connect to MySQL database. ' . mysql_error());
      mysql_select_db(SQL_DB, $conn) or die("Failed to select database: " . mysql_error());
    }
    return $conn;
  }
}

class MailList {
  static function subscribe($subscriber) {
    $conn = DB::connect();

    $sql = "SELECT user_id FROM ml_users " .
      "WHERE e_mail='" . mysql_real_escape_string($subscriber['email']) . "'";
    $result = mysql_query($sql, $conn) or die("Query failed: " . mysql_error());

    if (!mysql_num_rows($result))
      {
	$sql = "INSERT INTO ml_users " .
	  "(firstname, lastname, e_mail) ".
	  "VALUES ('" . mysql_real_escape_string($subscriber['firstname']) . "'," .
	  "'" . mysql_real_escape_string($subscriber['lastname']) . "'," .
	  "'" . mysql_real_escape_string($subscriber['email']) . "')";
	$result = mysql_query($sql, $conn);
	$user_id = mysql_insert_id($conn);
      }
    else
      {
	$row = mysql_fetch_array($result);
	$user_id = $row['user_id'];
      }

    $sql = "INSERT INTO ml_subscriptions (user_id,ml_id,pending) " .
      "VALUES (" . intval($user_id) . ", "
      . intval($subscriber['ml_id']) . ", "
      . intval($subscriber['pending']) .")";
    mysql_query($sql, $conn) or die("Failed INSERT: " . mysql_error());
   
    echo $subscriber['email'] . '<br />';
  }
}
