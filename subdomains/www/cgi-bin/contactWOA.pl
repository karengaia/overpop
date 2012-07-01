#!/usr/bin/perl
##/perl/bin/perl

# contactWOA.pl   August 25, 2003
  
require './bootstrap.pl';

$email_std_end = "Thank you.\n\n Karen Gaia Pitts,\n editor and publisher\n World Population Awareness\n P.O. Box 2533\n Placerville CA 95667\n $adminEmail\n";


print "Content-type:text/html\n\n";

&parse_form;

   
$sectsub    = $FORM{sectsub};
$useremail  = $FORM{email};
$username   = $FORM{username};
$comment    = $FORM{comment};

 $subject   = "WOA|$sectsub - Your message has been received.";
 
 $email_msg = "$email_msg * * DO NOT REPLY TO THIS EMAIL * *  \n\n";
 $email_msg = "$email_msg Thank you for contacting WOA!!. If your message requires a reply,";
 $email_msg = "$email_msg you will hear from me in a short time.\n\n";
 $email_msg = "$email_msg $username $useremail said:\n";
 $email_msg = "$email_msg Message: $comment\n\n";
 $email_msg = "$email_msg $email_std_end ";
  
  open(EMAIL, "|$sendmail -t");
  print(EMAIL "From: $adminEmail\n");
  print(EMAIL "Subject: $subject\n");
  print(EMAIL "To: $useremail\n");
  print(EMAIL "CC: $adminEmail\n");
  print(EMAIL "BCC: $bcc\n") if($bcc);
  print(EMAIL "X-Sender: $scriptpath\n\n");
  print(EMAIL "$email_msg");
  close(EMAIL);

print "<p><br><br><font size=3 face=verdana><b>Thank you for contacting WOA!! Your message has been sent</b></font><p><br>\n";
print "Hit your back button to continue or go to <a target=\"_top\" href=\"http:\/\/www.population-awareness.net\"> WOA!!s home page</a><p><p>\n";

print "$adminEmail<br>\n";
print "$email_msg<br>\n";
exit;

sub do_email 
{
  open(EMAIL, "|$sendmail -t");
  print(EMAIL "From: $sender\n");
  print(EMAIL "Subject: $subject\n");
  print(EMAIL "To: $recipient\n");
  print(EMAIL "CC: $cc\n") if($cc);
  print(EMAIL "BCC: $bcc\n") if($bcc);
  print(EMAIL "X-Sender: $scriptpath\n\n");
  print(EMAIL "$email_msg");
  close(EMAIL);
}

sub parse_form
{
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  @pairs = split(/&/, $buffer);
  foreach $pair (@pairs)
  {
   ($name, $value) = split(/=/, $pair);
   $value =~ tr/+/ /;
   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   $value =~ s/~!/ ~!/g;
   $value =~ s/\n//g;

   if($FORM{$name})
   {
     $FORM{$name} = "$FORM{$name};$value";
   }
   else
   {
     $FORM{$name} = $value;
   }
  }
}
