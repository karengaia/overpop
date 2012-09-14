<?php

function send_message($conn, $params=array(), $options=array()) {

  global $conn;
  $from_name  = 'WOAs Pop Newsletter';
  $from_email = 'popnewsletter@overpopulation.org';

  $msg_fixed = $params['msg'] . "\n\n--------------\n";

  if ((isset($params['msg'])) and (isset($params['ml_id'])))
  {
    $ml_id = $params['ml_id'];    
    if (is_numeric($params['ml_id'])) {
      $sql = "SELECT listname FROM ml_lists WHERE ml_id='" .
          $params['ml_id'] . "'";
      $result = mysql_query($sql,$conn) or die(mysql_error());
      $row = mysql_fetch_array($result);
      $listname = $row['listname'];
    } else {
	
##	echo 'send_message .. listid ml_id -- $ml_id -- is invalid<br>';
     echo 'send_message .. listid ml_id -- ' . $ml_id . '-- is invalid<br />';
    }
##    echo 'send_msg listname $listname<br>';
echo "<b>List id/name " . $ml_id . ' ' . $listname . '</b><br /><br />';

    $sql = "SELECT DISTINCT usr.e_mail, usr.lastname, usr.firstname, usr.user_id ".
      "FROM ml_users usr " .
      "INNER JOIN ml_subscriptions mls " .
      "ON usr.user_id = mls.user_id " .
      "WHERE mls.pending=0";
      
    if ($params['ml_id'] != 'all')
    {
      $sql .= " AND mls.ml_id=" . $params['ml_id'];
    }

    $result = mysql_query($sql, $conn) 
      or die('Could not get list of e-mail addresses. '
      . mysql_error());

    if (is_numeric($params['ml_id'])) {
      // Footer #1
      $msg_fixed .= " You are receiving this message as a member of the -";
      $msg_fixed .= $listname . "- mailing list. If you have received ";
      $msg_fixed .= 'this e-mail in error, or would like to remove your ';
      $msg_fixed .= 'name from this mailing list, please visit the ';
      $msg_fixed .= "following URL:\n";
      $msg_fixed .= SCRIPT_PATH . 'remove.php?u=';
    }
    else {
      // Footer #2
      $msg_fixed .= " You are receiving this e-mail because you subscribed";
      $msg_fixed .= " to one or more mailing lists. Visit the following";
      $msg_fixed .= " URL to change your subscriptions:\n";
      $msg_fixed .= SCRIPT_PATH . 'user.php?u=';
    }
        
    echo "<b>Mailing to ------</b> <br /><br />";
    echo '<div style="margin-left: 7px;">';
    
    while ($row = mysql_fetch_array($result))
    {      
      $email = $row['e_mail'];
      
      $to_name = trim($row['firstname'] . ' ' . $row['lastname']);
     $user_id = $row['user_id'];
      if (is_numeric($params['ml_id'])) {
       $email_msg = $msg_fixed . $row['user_id'] . "&ml=" . $params['ml_id'] . '  ' .
          'Please direct any questions to ' . ADMIN_EMAIL;
      } else {
        $email_msg = $msg_fixed . $row['user_id'] . '  ' . 
        'Please direct any questions to ' . ADMIN_EMAIL;
      }

      $subject = stripslashes($params['subject']);
      
##      REQUIRE_DISABLED('send_email.php');  
      send_email($to_name,$email,$from_name,$from_email,$subject,$email_msg);

      echo $to_name . ' ' . $email . '<br />';
    }
  }
    echo '<b>Message:</b> <br />';
    echo $email_msg;
    echo '</div>';
}


function send_email($to_name,$to_email,$from_name,$from_email,$subject,$msg) {
	
	  $to   =  $to_name . ' <'. $to_email . '>';
	  $from =  $from_name . ' <'. $from_email . '>';
	    
      $eheaders = build_headers($from);
## echo '<br />Mail blocked: ';
      mail($to,$subject,$msg,$eheaders) or die('Could not send e-mail. (send_message) to ' . $to . ' subject ' . $subject . ' eheaders ' . $eheaders);
}


function build_headers($from) {
       $from_long = $from;
       list($rest,$domain) = explode('@',$from,2);
       list($domain) = explode('>',$domain,1);
       list($from_name) = explode(' <',$from,1);
       $bounce_email = 'bounce@' . $domain;
       $bounce_long = $from_name . ' <' . $bounce_email;
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


function break_up_body($msg) {
  $body = "";
  $articles = explode("rn- - - - - - - -rnrn",$msg);
  foreach($articles as $article) 
  {
    $paragraphs = explode("rnrn",$article);
    foreach($paragraphs as $paragraph) 
    {
        if(strlen($paragraph) > 900) {
          $sentences = explode(". ",$paragraph);
          foreach($sentences as $sentence) 
          {
            $lt900section .= $sentence . ". ";
            if(strlen($lt900section) > 900) {
              $rebuild_para .= $prev_lt900section . "rnrn" . $sentence . ". ";
              // echo "lt900section>900 len " . strlen($lt900section) . " .." . $prev_lt900section . "****<br />n";
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
      $article .= $rebuild_para . "rnrnrn";
    }
    $body .= $article . "rn- - - - - - - -rnrn";
  }
  return $body;
}

?>