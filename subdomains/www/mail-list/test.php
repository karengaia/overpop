<?php
function test_send_message() {
  require 'config.php';
  require 'admin_transact_functions.php';
  
  // Connect to the database
  global $conn;
  $conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
   or die('Could not connect to MySQL database. ' . mysql_error());
  mysql_select_db(SQL_DB, $conn) or die("Could not access the database '" . SQL_DB . "': " . mysql_error());
  
  // Create a mailing list
  $rs = mysql_query("SELECT * FROM ml_lists WHERE listname='test-list'", $conn);
  if ($row = mysql_fetch_assoc($rs)) {
    mysql_query("DELETE FROM ml_lists WHERE ml_id=" . $row['ml_id'], $conn);
    mysql_query("DELETE FROM ml_subscriptions WHERE ml_id=" . $row['ml_id'], $conn);
  }
  mysql_free_result($rs);
  mysql_query("INSERT INTO ml_lists (listname) VALUES ('test-list')", $conn);
  $ml_id = mysql_insert_id($conn);
  mysql_query("DELETE FROM ml_lists WHERE first='Test'", $conn);
  if (is_string($_POST['addresses'])) {
    $addresses = preg_split("/\r\n|\r|\n/", trim($_POST['addresses']));
  }
  else {
    $addresses = $_POST['addresses'];
  }
  foreach ($addresses as $i=>$address) {
    mysql_query("INSERT INTO ml_users (firstname, lastname, e_mail) VALUES ('Test', 'User$i', '$address')");
    $user_id = mysql_insert_id($conn);
    mysql_query("INSERT INTO ml_subscriptions (ml_id, user_id, pending) VALUES ($ml_id, $user_id, 0)");
  }
  
  $params = array(
    'msg'     => file_get_contents("./test/message.txt"),
    'ml_id'   => $ml_id,
    'subject' => "Test from mail-list"
  );
  
  $options = array(
    'dry_run' => true,
    'verbose' => true
  );
  if (is_array($_POST['options'])) {
    $options = array_merge($options, $_POST['options']);
  }
  send_message($params, $options);
}

function ph($str) {
  echo htmlspecialchars($str);
}

?>
<html>
<head>
  <title>Test</title>
</head>
<body>
  <form method="post" action="test.php">
    <label style="display: block" for="addresses">Enter recipient addresses, one per line</label>
    <textarea name="addresses" id="addresses" cols="40" rows="5"><?php ph(@$_POST['addresses']) ?></textarea>
    <br />
    
    <input type="hidden" name="options[dry_run]" id="options[dry_run]" value="" />
    <input type="checkbox" name="options[dry_run]"<?php echo !isset($_POST['options']) || $_POST['options']['dry_run'] ? ' checked="checked"' : '' ?> />
    <label for="options[dry_run]">Dry run</label>
    <br />
    
    <input type="hidden" name="options[verbose]" id="options[verbose]" value="" />
    <input type="checkbox" name="options[verbose]" id="options[verbose]"<?php echo !isset($_POST['options']) || $_POST['options']['verbose'] ? ' checked="checked"' : '' ?> />
    <label for="options[verbose]">Verbose</label>
    <br />
    
    <input type="submit" value="Run Test" />
  </form>

<?php
  if (@$_POST) {
    echo "<div class=\"margin-top: 2em\">\n";
    test_send_message();
    echo "<p>Done.</p>";
    echo "</div>\n";
  }
?>

</body>
</html>
