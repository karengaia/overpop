<?php
require('config.php');

   $subject = 'WOA test_mail reply';
   $msg = "Hello Karen Tester\n" .
      "This is the message.\n\n" .
    
    $to_email = 'kgp@karengaia.net';
    $to_name = 'Karen Gaia';

    $from_name  = 'WOAs Pop Newsletter';
    $from_email = 'popnewsletter@overpopulation.org';
   
  // sendmail emulation
	$to   =  $to_name . ' <'. $to_email . '>';
	$from =  $from_name . ' <'. $from_email . '>';
	    
    $eheaders = build_headers($from);
         
    mail($to,$subject,$msg,$eheaders) or die('Could not send e-mail.(send_email)');
    
    echo '<b>Thank you. An email in reply has been mailed to: </b><br>';
    echo $to_name . ' &lt;' . $to_email . '&gt;<br>';

    $redirect = 'user.php';

      

function build_headers($from) {
       $from_long = $from;
       list($rest,$domain) = explode('@',$from,2);
       list($domain) = explode('>',$domain,1);
       list($from_name) = explode(' <',$from,1);
       $bounce_email = 'bounce@' . $domain;
       $bounce_long = $from_name . ' <' . $bounce_email . '>';
       $time = time();
       $date = date("r");
       $phpversion = phpversion();
       
       $eheaders = <<<END
From: $from_long
Date: $date
Sender: $from_long
Errors-To: $from_long
Reply-To: $from_long
Return-Path: $bounce_long
Message-ID: <$time-$from_email>
X-Mailer: PHP v.$phpversion
	
END;

return $eheaders;
}

//header('Location: ' . $redirect);

?>