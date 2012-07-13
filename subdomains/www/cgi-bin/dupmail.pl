#!/usr/bin/perl --

# May 7, 2010
#      dupmail.pl

# dupmail.pl reads all files in popnews_sepmail and eliminates dups

## CHANGES
## 2010 May 7 - pushed path to INC for Karens Mac server

require './bootstrap.pl';
  
  print "Content-type:"."text/"."html\n\n";

  $MAXemailCount = '0200';  ## must be padded to 4 places
  $email_count   = 0;
  
  $buffer    = "";
  @stuff     = "";
  $msgline1  = "";
  $dup_email = 'N';
  $edate     = "";
  $subject   = ""; 
  $from      = "";
  $emessage  = "";  
  
  print "$adminFont Dupmail .. max= $MAXemailCount<br></font>\n";
 
  opendir(POPMAILDIR, "$sepmailpath");
  local(@popnewsfiles) = readdir(POPMAILDIR);
  closedir(POPMAILDIR);

  foreach $filename (@popnewsfiles) {
 
      if(-f "$sepmailpath/$filename" and $filename =~ /\.email/ and $filename !~ /log|date/) {
         $dup_email = 'N';
         
         $email_count = &chk_for_max_count($email_count,$MAXemailCount);
         
         if($email_count eq -1) {
             print "$adminFont dupmail 00 count exceeds $MAXemailCount<br></font>\n";
             last;
         }
             
         &read_emailItem;
     
         $dup_email = &check_for_dups;
              
         unlink "$sepmailpath/$filename" if($dup_email =~ /Y/);
      }
      undef $chkEmail;
      undef $hdrSection;
      undef $message;
      undef $handle;
      undef $msg1;
      undef $ehandle;
      undef $blanklines;
      undef $eSeparator;
      undef $separator_cnt;
      undef $reject_it;
      undef @headers;
      undef $header;
      undef $subject;
      undef $date;
      undef $from;
      undef $replyto;
      undef $to;
      undef $mailuser1;
      undef $domainfrom;
      undef $mailuser;
      undef $fromEmail;
      undef $domainreplyto;
      undef $replyto_email;
  }

 exit;


## 220          Look for duplicate emails   ###
sub check_for_dups
{ 
  if($emessage =~ /[A-Za-z0-9]/ or $edate  =~ /[A-Za-z0-9]/ or $subject  =~ /[A-Za-z0-9]/) {
  }
  else {
     print "dup220 filename $filename empty email<br>";
     return 'N';
  }
  
  ($msgline1,$rest) = split(/\n/,$emessage,2);
   
  local($chkEmail) = "$edate - $subject - $from - $msgline1";
   
  if(@mailline1s) {  	
      foreach $mailline1 (@mailline1s) {
         print "<font size=1>dup225 $email_count arrayline .. $mailline1</font><br>\n";
   	 if($chkEmail =~ /$mailline1/ or $mailline1 =~ /$chkEmail/) {
            print "<font color=red>dup225 DUP FOUND .. $chkEmail</font><br>\n";
   	    return 'Y';
   	 }
      }
      print "dup225 $email_count no dup .. $chkEmail<br>\n";
      push @mailline1s, $chkEmail;
  }
  else {
      @mailline1s = ($chkEmail);
  }
  return 'N'; 
} 

## 225 check for count exceeded ---- Move to common.pl

sub chk_for_max_count
{
 local($count,$max_count) = @_;
 $count = $count + 1;
 $count = &pad_count("$count");
 return -1 if($count > $max_count);
 return $count;
}
 
   
#230 

sub read_emailItem
{
 $name = "";
 $value = "";
 $line = "";
 $emessage = "";
 $from = "";
 undef %EDATA;
 undef $EDATA;
 $EDATA{subject}  = "";
 $EDATA{edate}    = "";
 $EDATA{emessage} = "";
 $EDATA{from}     = "";

 open(EMAILITEM, "$sepmailpath/$filename");

 while(<EMAILITEM>) {
    $line = $_;
    if($line !~ /\^/) {
       $EDATA{$name} = "$EDATA{$name}$line";
    }
    else {
       ($name, $value) = split(/\^/, $line);
       $EDATA{$name} = $value;
    }
  }
  close(EMAILITEM);
  $subject     = $EDATA{subject};
  $from        = $EDATA{from};
  $edate       = $EDATA{edate};
  $emessage    = $EDATA{emessage};
  ($msgline1,$rest) = split(/\n/,$emessage);
}


1;
