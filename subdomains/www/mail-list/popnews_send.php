<?php
require('config.php');
require 'connect.php';
$title = "Send Popnewsweekly";

require('header.htm');

$email_msg = file_get_contents(POPNEWS_FILE);
$_POST['msg'] = $email_msg;

$lines = explode("\x0D\x0A",$email_msg);
$subject = $lines[1] . ' - ' . $lines[0];

$_POST['ml_id'] = 1;     //list id - 1= popnewsweekly 3 = testpopnews

echo '<b>Subject:</b> . $subject . <br /><br />';
echo '<b>Sending to list:</b> Popnewsweekly <br /><br />';
echo '<br /><br /><b>Popnews message sent from</b> ' . POPNEWS_FILE . '<br />';

require('send_message.php');
send_message($conn, $_POST);

echo '<br /><b>Done</b>';
require('footer.htm');
?>

