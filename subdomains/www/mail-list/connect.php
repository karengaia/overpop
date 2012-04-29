<?php
  global $conn;
  $conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
   or die('Could not connect to MySQL database. ' . mysql_error());

  mysql_select_db(SQL_DB,$conn);
?>