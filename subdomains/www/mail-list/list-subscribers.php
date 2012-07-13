<?php
require('config.php');
require 'connect.php';
$title = "List Subscribers";
?>

<?php require('header.htm'); ?>

<?php
$ml_id = '1';

$sql = "SELECT DISTINCT usr.e_mail, usr.lastname, usr.firstname, usr.user_id ".
        "FROM ml_users usr " .
        "INNER JOIN ml_subscriptions mls " .
        "ON usr.user_id = mls.user_id " .
        "WHERE mls.pending=0";
     if ($ml_id != 'all')
     {
        $sql .= " AND mls.ml_id=" . $ml_id;
     }
             
     
$result = mysql_query($sql,$conn);
?>

<table border="0" cellpadding="5" cellspacing="0">

<?php
while ($row = mysql_fetch_array($result))
{
 echo '<tr><td>&nbsp;' . $row['lastname'] . '</td><td>&nbsp;' . $row['firstname'] . '</td><td>&nbsp;' .  $row['e_mail'] . "</td></tr>\n"	;
}

?>

</table>
<br />


<?php require('footer.htm'); ?>