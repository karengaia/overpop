<?php
function send_message($params=array(), $options=array()) {
  global $conn;
  require dirname(__FILE__) . '/htmlMimeMail5/htmlMimeMail5.php';
  
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

    if (@$options['verbose']) {
      echo "Sending message from <em>" . $listname . "</em>...<br />\n";
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

    $result = mysql_query($sql) or die('Could not get list of'
      . ' e-mail addresses. '
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
    
    while ($row = mysql_fetch_array($result))
    {
      if (is_numeric($params['ml_id'])) {
        $msg = $msg_fixed . $row['user_id'] . "&ml=" . $params['ml_id'];
      } else {
        $msg = $msg_fixed . $row['user_id'];
      }

      $subject = stripslashes($params['subject']);
      $from = "gaiapitts-overpopulation@yahoo.com";
      
      $mail = new htmlMimeMail5();
      $mail->setTextEncoding(new QPrintEncoding());
      $mail->setFrom($from);
      $mail->setSubject($subject);
      $mail->setText($msg);
      
      if (!@$options['dry_run']) {
        $mail_success = $mail->send(array($row['e_mail']));
        
        if (!$mail_success) {
          echo "Failed to send (addr=$row[e_mail])<br />\n";
        }
      }
      
      if (@$options['verbose']) {
        echo "<div style=\"border-top: 2px solid black; border-bottom: 2px solid black; margin-top: 0; padding: 0.5em 0 0.5em\">";
        echo "<strong>To:</strong> $row[e_mail]<br />\n";
        echo "<strong>Subject:</strong> $subject<br />\n";
        echo "<strong>From:</strong> $from<br />\n";
        echo "<pre style=\"margin-top: 0.5em; border-top: 2px solid #aaa; padding-top: 0.5em\">";
        if (!$mail->output) $mail->build();
        echo htmlspecialchars($mail->output);
        echo "\n</pre>";
        echo "</div>\n";
      }
    }
  }
}

function break_up_body($msg) {
  $body = "";
  $articles = explode("\n\n\n",$msg);
  foreach($articles as $article) 
  {
    $paragraphs = explode("\n\n",$article);
    foreach($paragraphs as $paragraph) 
    {
      $lines = explode("\n",$paragraph);
      foreach($lines as $line) 
      {
        if(strlen($line) > 900) {
          $sentences = explode(". ",$line);
          foreach($sentences as $sentence) 
          {
            $lt900section .= $sentence . ". ";
            if(strlen($lt900section) > 900) {
              $rebuild_line .= $prev_lt900section . "\n\n" . $sentence . ". ";
              // echo "lt900section>900 len " . strlen($lt900section) . " .." . $prev_lt900section . "****<br />\n";
              $lt900section = "";
            }
            $prev_lt900section = $lt900section;
          }
          $rebuild_line .= $lt900section;
          // echo "Rebuild_line > 900: " . $rebuild_line;
        }
        else {
          $rebuild_line = $line;
        }
        $paragraph .= $rebuild_line . "\n";
      }
      $article .= $paragraph . "\n";
    }
    $body .= $article . "\n";
  }
  return $body;
}
