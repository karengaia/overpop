<?php
function send_message($conn, $params=array(), $options=array()) {

  global $conn;
   
  require dirname(__FILE__) . '/htmlMimeMail5/htmlMimeMail5.php';
  
  $mail_type = 'Base64Encoding';
//  $mail_type =  'MimeMail 7bit Encoding';
//  $mail_type = 'MimeMail Quote Print Encoding';
//  $mail_type = 'Old-style mail mode';
  
  echo $mail_type . '<br /><br />';
  
  if ((isset($params['msg'])) and (isset($params['ml_id'])))
  {
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
      $msg_fixed .= " http://" . $_SERVER['HTTP_HOST'] .
          dirname($_SERVER['PHP_SELF']) . "/remove.php?u=";
    }
    else {
      // Footer #2
      $msg_fixed .= " You are receiving this e-mail because you subscribed";
      $msg_fixed .= " to one or more\n mailing lists. Visit the following";
      $msg_fixed .= " URL to change your subscriptions:\n";
      $msg_fixed .= " http://" . $_SERVER['HTTP_HOST'] .
          dirname($_SERVER['PHP_SELF']) . "/user.php?u=";
    }
    
    echo 'Mailing to ------ <br /><br />';
    echo '<div style="margin-left: 7px;">';
    
    while ($row = mysql_fetch_array($result))
    {      
      $email = $row['e_mail'];
      
      if (is_numeric($params['ml_id'])) {
        $msg = $msg_fixed . $row['user_id'] . "&ml=" . $params['ml_id'];
      } else {
        $msg = $msg_fixed . $row['user_id'];
      }

      $subject = stripslashes($params['subject']) . ' - ' . $mail_type;
      $from = "gaiapitts-overpopulation@yahoo.com";
      
      $mail = new htmlMimeMail5();
        
      $mail->setTextEncoding(new Base64Encoding());
//        $mail->setTextEncoding(new SevenBitEncoding());
//       $mail->setTextEncoding(new QPrintEncoding());
        
      $mail->setFrom($from);
      $mail->setSubject($subject);
      $mail->setText($msg);
      
      $mail_success = $mail->send(array($email));
        
      if (!$mail_success) {
          echo "Failed to send (addr=$email)<br />\n";
      }
        
      echo $email . '<br />';
  }
  echo '</div>';
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
