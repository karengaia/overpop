<?php
require dirname(__FILE__) . '/htmlMimeMail5/htmlMimeMail5.php';
$mail = new htmlMimeMail5();
$mail->setTextEncoding(new Base64Encoding());
$mail->setFrom("moxley@moxleydata.com");
$mail->setSubject("test 2");
//$filename = "./popnews_doesnt_work.txt";
$filename = "./popnews_works.txt";
//$mail->setText(file_get_contents($filename));
$mail->setText("This is a test.");
//$to = "kgp@karengaia.net";
//$to = "moxley.stratton@gmail.com";
$to = "moxicon72@yahoo.com";
echo "To: $to\n";
$mail_success = $mail->send(array($to));
echo "result: " . var_export($mail_success, true) . "\n";
echo "Done.\n";
