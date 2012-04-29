#!/usr/bin/perl --

## send_email.pl      sends an email

###        I think we can remove this if we change moveutil.pl and utility.pl to do_email ######

sub init_email
{
  $email_std_end = "Thank you.\n\n Karen Gaia Pitts,\n editor and publisher\n World Population Awareness\n  9580 Oak Ave Pkwy, Ste 7-104,\n Folsom CA 95630\n $adminEmail\n";	
}

sub send_email 
{
  $bcc       = $adminEmail if($adminEmail ne $fromEmail);
  $sender    = $senderEmail;
  $replyto   = "replytoEmail";
  $recipient = $fromEmail;
  &do_email;
}

sub do_popnews_wkly_email
{
 if(-f "debugit.yes") {
   print "$email_msg\n";
 }
 else {
  open(EMAIL, "$sendmail");
  print(EMAIL "Errors-To: $adminEmail\n");
  print(EMAIL "From: karen\@gnatseye.net\n");
  print(EMAIL "Sender: karen\@gnatseye.net\n");  
  print(EMAIL "Subject: $subject\n");
  print(EMAIL "To: popnewsmthly\@world-awareness.net\n");
  print(EMAIL "CC: sub\@karengaia.net\n") if($cc);
  print(EMAIL "BCC: $bcc\n") if($bcc);
  print(EMAIL "X-Sender: $scriptpath\n\n");
  print(EMAIL "$email_msg");
  close(EMAIL);
 }
}

sub do_email
{
 if(-f "debugit.yes") {
   print "$email_msg\n";
 }
 else {
  open(EMAIL, "$sendmail");
  print(EMAIL "Errors-To: $adminEmail\n");
  print(EMAIL "From: $adminEmail\n");
  print(EMAIL "Sender: $adminEmail\n");  
  print(EMAIL "Subject: $subject\n");
  print(EMAIL "To: $recipient\n");
  print(EMAIL "CC: $cc\n") if($cc);
  print(EMAIL "BCC: $bcc\n") if($bcc);
  print(EMAIL "X-Sender: $scriptpath\n\n");
  print(EMAIL "$email_msg");
  close(EMAIL);
 }
}

sub email2list
{
  local($msg,$esubject,$elist) = @_;
  local $found = 'N';
print "<body basefont=arial link=\"blue\" vlink=\"blue\" alink=\"green\"  bgcolor=\"CCFFCC\"><font face=arial>";
  
  $email_msg = $msg;
  $email_msg   =~ s/\r/\n/g;
  $subject = $esubject;
  $elistfile = "$elistpath/$elist.elist"; 
  if(-f $elistfile) {
    print "<p><br>Sending email to: <br>\n";
    open(ELIST, "$elistfile");
    while(<ELIST>)
    {
      chomp;
      $recipient = $_;
      print "&nbsp;&nbsp;&nbsp;&nbsp;<font size=2>$recipient</font><br>\n";
      $found = 'Y';
      &do_email;
    } 
    close(ELIST);
    
    if($found eq 'N') {
    	print "<p><br>List is empty<br>\n";
    }
  }
  else {
    print "<p><br>List $elist not found $elistfile<br>\n";	
  }
}

1;