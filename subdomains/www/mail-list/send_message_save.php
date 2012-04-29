<?php
function send_message($conn, $params=array(), $options=array()) {

  global $conn;
  $domain = "overpopulation.org";

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
      $listname = "Master";
    }
   
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

    $msg_fixed = $params['msg'] . "\n\n--------------\n";

    if (is_numeric($params['ml_id'])) {
      // Footer #1
      $msg_fixed .= " You are receiving this message as a member of the ";
      $msg_fixed .= $listname . "\n mailing list. If you have received ";
      $msg_fixed .= "this e-mail in error, or would like to\n remove your ";
      $msg_fixed .= "name from this mailing list, please visit the";
      $msg_fixed .= "following URL:\n";
      $msg_fixed .= " http://" . $domain .
          dirname($_SERVER['PHP_SELF']) . "/remove.php?u=";
    }
    else {
      // Footer #2
      $msg_fixed .= " You are receiving this e-mail because you subscribed";
      $msg_fixed .= " to one or more\n mailing lists. Visit the following";
      $msg_fixed .= " URL to change your subscriptions:\n";
      $msg_fixed .= " http://" . $domain .
          dirname($_SERVER['PHP_SELF']) . "/user.php?u=";
    }
    
    $headers = build_headers($ml_id,$domain);
    
    echo '<b>Mailing to ------</b> <br /><br />';
    echo '<div style="margin-left: 7px;">';
    
    while ($row = mysql_fetch_array($result))
    {      
      $email = $row['e_mail'];
      
      $to_name = trim($row['firstname'] . ' ' . $row['lastname']);
      
      if (is_numeric($params['ml_id'])) {
        $email_msg = $msg_fixed . $row['user_id'] . "&ml=" . $params['ml_id'];
      } else {
        $email_msg = $msg_fixed . $row['user_id'];
      }

      $subject = stripslashes($params['subject']);
        
      send_email($email,$to_name,$headers,$subject,$email_msg);
    }
  }
    echo '</div>';

    echo '<b>Message:</b> <br />';
    echo $email_msg;
}

function send_email($to_email,$to_name,$headers,$subject,$msg) {

      $to =  $to_name . ' <'. $to_email . '>';

      echo 'To: ' . $to . '\r\n';
      mail($to,$subject,$msg,$headers) or die('Could not send e-mail.');
}


function build_headers($sub_id, $domain) {

      if($sub_id == 1 or $sub_id == 3 or $sub_id == 5) {
        $from_name = 'WOAs Pop Newsletter';
        $from_acct = 'popnewsletter';
      }
      else {
        $from_name = 'Admin';
        $from_acct = 'admin';
      }
           
      $from_email = $from_acct . '@' . $domain;
       $from_long = $from_name . ' <' . $from_email . '>';	
       $bounce_email = 'bounce@' . $domain;
       $bounce_long = $from_name .' <' . $bounce_eail . '>';
       $time = time();
       $date = date("r");
       $phpversion = phpversion();
       
       $headers = <<<END
From: $from_long
Date: $date
Sender: $from_long
Errors-To: $from_long
Reply-To: $from_long
Return-Path: $bounce_long
Message-ID: <$time-$from_email>
X-Mailer: PHP v.$phpversion
	
END;

      echo "<b>Headers:</b><br />";
      echo $headers;

return $headers;
}

function save() {
$eol = "\r\n";
$headers = 'From: '        . $from_long . $eol . 
		  'Sender: '      . $from_email . $eol .
		  'Errors-To: '   . $from_email . $eol .
		  'Reply-To: '    . $from_email . $eol .
	          'Return-Path: ' . $bounce . $eol .
	  	  "Message-ID: <".time()."-" . $from_email . ">" . $eol .
                  "X-Mailer: PHP v". phpversion() . $eol.$eol;	
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
