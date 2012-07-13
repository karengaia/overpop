<?php
require('config.php');
require 'connect.php';
$title = "Add, Delete Email Lists";
require('header.htm'); 
?>

<form method="post" action="admin_transact.php">

<p>
 Add Mailing List:<br />
 <input type="text" name="listname" maxlength="255" />
 <input type="submit" name="action" value="Add New Mailing List" />
</p>

<p>
 Delete Mailing List:<br />
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
 <input type="submit" name="action" value="Delete Mailing List" />
</p>

</form>

<?php require('footer.htm'); ?>