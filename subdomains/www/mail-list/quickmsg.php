<?php
require('config.php');
require 'connect.php';
$title = "Quick Message";
?>

<?php require('header.htm'); ?>

<form method="post" action="admin_transact.php">

<p>
 Choose Mailing List:<br />
 <select name="ml_id">
<?php

$sql = "SELECT * FROM ml_lists ORDER BY listname;";
$result = mysql_query($sql)
 or die('Invalid query: ' . mysql_error());

while ($row = mysql_fetch_array($result))
{
 echo "  <option value=\"" . $row['ml_id'] . "\">" . $row['listname']
    . "</option>\n";
}

?>
 </select>
</p>

<p>Compose Message:</p>

<p>
 Subject:<br />
 <input type="text" name="subject" />
</p>

<p>
 Message:<br />
 <textarea name="msg" rows="10" cols="60"></textarea>
</p>

<p>
 <input type="submit" name="action" value="Send Message" />
</p>

</form>

<?php require('footer.htm'); ?>