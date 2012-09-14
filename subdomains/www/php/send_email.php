<?php

## this of a copy of send_email.php in /mail-list; We should start referencing this on in /php  and move it from /mail-list

function send_email($to_name,$to_email,$from_name,$from_email,$subject,$msg) {
	
	  $to   =  $to_name . ' <'. $to_email . '>';
	  $from =  $from_name . ' <'. $from_email . '>';
	    
      $eheaders = build_headers($from);
## echo 'mail blocked in send_mail to $to from $from subject $subject eheaders $eheaders';
      mail($to,$subject,$msg,$eheaders) or die('Could not send e-mail.(send_email) to ' . '' . $to);
}

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

function break_up_body($msg) {
  $body = "";
  $articles = explode("\r\n- - - - - - - -\r\n\r\n",$msg);
  foreach($articles as $article) 
  {
    $paragraphs = explode("\r\n\r\n",$article);
    foreach($paragraphs as $paragraph) 
    {
        if(strlen($paragraph) > 900) {
          $sentences = explode(". ",$paragraph);
          foreach($sentences as $sentence) 
          {
            $lt900section .= $sentence . ". ";
            if(strlen($lt900section) > 900) {
              $rebuild_para .= $prev_lt900section . "\r\n\r\n" . $sentence . ". ";
              // echo "lt900section>900 len " . strlen($lt900section) . " .." . $prev_lt900section . "****<br />\n";
              $lt900section = "";
            }
            $prev_lt900section = $lt900section;
          }
          $rebuild_para .= $lt900section;
          // echo "Rebuild_para > 900: " . $rebuild_para;
        }
        else {
          $rebuild_para = $paragraph;
        }
      $article .= $rebuild_para . "\r\n\r\n\r\n";
    }
    $body .= $article . "\r\n- - - - - - - -\r\n\r\n";
  }
  return $body;
}

# http://www.finalwebsites.com/forums/topic/php-e-mail-attachment-script

function mail_attachment($filename, $path, $mailto, $from_mail, $from_name, $replyto, $subject, $message) {
    $file = $path.$filename;
    $file_size = filesize($file);
    $handle = fopen($file, "r");
    $content = fread($handle, $file_size);
    fclose($handle);
    $content = chunk_split(base64_encode($content));
    $uid = md5(uniqid(time()));
    $name = basename($file);
    $header = "From: ".$from_name." <".$from_mail.">\r\n";
    $header .= "Reply-To: ".$replyto."\r\n";
    $header .= "MIME-Version: 1.0\r\n";
    $header .= "Content-Type: multipart/mixed; boundary=\"".$uid."\"\r\n\r\n";
    $header .= "This is a multi-part message in MIME format.\r\n";
    $header .= "--".$uid."\r\n";
    $header .= "Content-type:text/plain; charset=iso-8859-1\r\n";
    $header .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
    $header .= $message."\r\n\r\n";
    $header .= "--".$uid."\r\n";
    $header .= "Content-Type: application/octet-stream; name=\"".$filename."\"\r\n"; // use different content types here
    $header .= "Content-Transfer-Encoding: base64\r\n";
    $header .= "Content-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n";
    $header .= $content."\r\n\r\n";
    $header .= "--".$uid."--";
    if (mail($mailto, $subject, "", $header)) {
        echo "mail send ... OK"; // or use booleans here
    } else {
        echo "mail send ... ERROR!";
    }
}

?>