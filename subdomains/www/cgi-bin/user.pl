#!/usr/bin/perl --

# Aug 3, 2012               # TODO -----------> 1) call init_users from article.pl 2) integrate users.pl with contributors.pl
#        user.pl

##  When cmd = "start_acctapp", this routine sends out the message to verify
##  the info entered by the applicant. 
##  When applicant replies, the info will be sent to the admin email addr for approval
##  The admin will review the info and approve the application by forwarding it 
##  to popnews@population-awareness.net


sub init_users   ## call this in article.pl <--------------- TODO ###############
{        #from article.pl
  $print_users = 'N';
  $header_template = "plain_top";
  $footer_template = "plain_end";
  &clear_users;
  $usersfile  = "$controlpath/users.html";
}

sub clear_users {
  $userid    = "";
  $upin      = "";
  $uemail    = "";
  $ulastdate = "";
}

sub verify_new_user  ## keeping most of code in contributor.pl  
{ 
 my($ckuserid,$ckpin,$ckemail) = @_;

   &process_template($header_template,'Y','N','N');

   $ckuserid = &trim($ckuserid);
   unless($ckuserid =~ /\@/ and $ckuserid =~ /\./ and $ckuserid =~ /[A-Za-z0-9]/) {
        print "<p> You must supply a valid email address. $ckuserid is invalid <br>\n";
        print "Hit your BACK button to correct.</p>";
        exit;
   }
    
   my ($userdata) = &read_users(N,N,_,$ckemail,$ckuserid,_);
   
   if($ckemail and $userdata =~ /SAMEEMAIL/) {
        print "<p> You have already applied for an account under this ";
        print "email address - $ckemail.<br>\n";
        print "Please wait for a confirmation request by email and reply to it. <br>\n";
        print "If you wish to make any changes to your information, send the changes ";
        print "with your reply.<br>\n";
        print "Your account will processed within a few days up to two weeks.<br><br>\n";
        print "Thank you.<br><br>\n";
        print "Karen Gaia Pitts .... WOA!!.</p>";
        exit;
   }
   elsif($nUserid and $userdata =~ /SAMEID/) {
        print "<p>The user id you have chosen is already in use at WOA!! - ";
        print "user id - $ckuserid.<br>\n";
        print "Please hit the Back button and choose another userid. <br>\n";
        print "WOA!!.</p>";
        exit;
   }  
   
   &user_email_verify;
   
   print "<p>Thank you for applying for a WOA account.<br>\n";
   print "You will receive a request by email to verify your email address. <br>\n";
   print "Please simply 'reply' to it.<br>\n";
   print "Your account will be approved within a few days.<br><br>\n";
   print "Karen Gaia Pitts.... WOA!!.</p>";

   &process_template($footer_template,'Y', 'N','N');

   return 0;
}

sub user_email_verify
{
 $sender  = $GLVARS{'contactEmail'};
 $recipient = $uemail;
 $subject  = "WOA: Please confirm your email address.";
 $email_msg = "Your submittal has been received by WOA!!. \n\n Please reply";
 $email_msg = "$email_msg to this email to verify that you are the one that";
 $email_msg = "$email_msg submitted it.\n\n";
 $email_msg = "$email_msg :END\n\n";
 $email_msg = "$email_msg $GLVARS{'std_headtop'} ";

 &do_email($email_msg);    # in send_email.pl
}

sub write_acctapp
{	
  print "$Content_type_html";
  
  $std_variables =
  "userid^UserID::`pin^Password::`firstname^Firstname::`lastname^Lastname::`useremail^Email::`city^City::`state^State::`zip^Zip::`phone^Phone::`payrole^Roles::`reason^Reason::`end^END::";
  @stdVariables = split(/`/, $std_variables);

  local($filename) = "";
  local($filefound) = "";	
  $applymailpath =  $mailpath;

  &process_appmail;  ## see following subroutine

  if($filename !~ /[A-Za-z0-9]/) {
    $applymailpath =  $popnewspath;     
    &process_appmail;
  }

  print "usr20 ... No email\n" if($filename !~ /[A-Za-z0-9]/);	
}


##            these are globals. eventually change to uHungarian notation
sub get_user_form_values
{
  $userid        = $FORM{'userid'};
  $upin          = $FORM{'pin'} if($FORM{pin});
  $uemail        = $FORM{'email'};
  $ulastdate     = $FORM{'ulastdate'};
  return;
}


sub get_new_user_form_values   ###  <-------------- TODO --- do we need?
{
  $userid         = $FORM{'userid'};
  $upin           = $FORM{'pin'};
  $uemail         = $FORM{'email'}; 
  $ulastdate      = $FORM{'ulastdate'};
  return;
}


sub check_user    ###  <------------ TODO : Return $user_visable
{ 
  my($ckuserid,$ckpin) = @_;
  if($ckuserid =~ /^\+/) {
    $user_visable = 'Y';
    ($rest,$ckuserid) = split(/\+/,$ckuserid,2);
  }
  else {
    $user_visable = 'N';
  }	
  
  if($ckuserid !~ /[A-Za-z0-9]{2}/ or $ckuserid =~ /Userid/ or $ckpin !~ /[A-Za-z0-9]{2}/) {
      &printUserMsgExit("You must supply a userid and password, or, if you do not have one, you must register.<br /> Hit your BACK button to correct.");
      exit;
  }


 ($userdata) = &read_users(N,N,_,_,$ckuserid,$ckpin);    ## args=print?, html file?, handle, email, acct# ;

 if($userdata =~ /BAD/) {
      &printUserMsgExit("Sorry. The userID ($ckuserid) or password you gave is not valid.<br />Hit your BACK button to correct.  ...usr292");
      exit;
 }
 return($userdata,$user_visable);
}


### 200

sub read_users
{
   my($print_users,$uHtmlfile,$ckuseremail,$ckuserid,$ckpin) = @_;

   # print "contrib 460 prt $print_contributors  prtHtml $uHtmlfile handle $eHandle email $ckuseremail userid $ckuserid pin $ckpin ..contriFile $contributors ..<br>\n";
   
   $userdata = "BAD";
   
   $uCount = 0;

   $lock_file = "$usersfile.busy";
##   &waitIfBusy($lock_file, 'lock'); 
    
   open(USERS, "$usersfile");
   while(<USERS>) {
      chomp;
      $uLine = $_;     
      $uCount = $uCount + 1;
      &split_user;
      &print_user($uid,$userid,$upin,$uemail,$ulastdate) if($print_users eq 'Y');
		
      if($userid !~ /[A-Za-z0-9]{2}/ or $upin !~ /[A-Za-z0-9]{2}/) {
      }
      elsif($ckuserid !~ /[A-Za-z0-9]/ and $ckuseremail =~ /[A-Za-z0-9]/ and $ckuseremail =~ /$useremail/) {
         $userdata = "SAMEEMAIL";
         last;
      }
      elsif($ckuserid =~ /$userid/ and $ckuserid =~ /[A-Za-z0-9]{2}/ 
             and ($ckpin =~ /$upin/ or $ckpin =~ /98989/) ) {
         $userdata = "GOOD";
         last;
      }
      
      elsif($ckuserid =~ /$userid/ and $ckuserid =~ /[A-Za-z0-9]/)  {
         $userdata = "SAMEID";
         last;
      }
      elsif($ckuserid =~ /ZZZZ/) {
      	 $userdata = "GOOD";
      } ##  end else   
    }  ## end while
    close(USERS);

    unlink "$lock_file";
    
    print "</td></table><br>\n" if($print_users eq 'Y');

    return ($userdata);
}


## 000300

sub split_user
{
  ($uid,$userid,$upin,$uemail,$ulastdate)
     = split(/\^/,$uLine,30);
}

## 400

sub write_new_user_flatfile
{
 $ulastdate = $nowdate;

 if($SVRinfo{environment} == 'development') {  ## set permissions if using Karen's Mac as the server
	if(-f '$usersfile') {}
	else {
		system('touch $usersfile');
		}
	system('chmod 0777, $usersfile');
 }
 open(USERS, ">>$usersfile");
 print USERS "$uid^$userid^$upin^$uemail^$lastdate\n";
 close(USERS);
}

sub print_user
{
 my($uid,$userid,$upin,$uemail,$ulastdate) = @_;
 if($uCount < 2) {	
    print "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    my($mod) = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print  "<tr>";
       print  "<td><b>ac</b></td>\n";
       print  "<td><b>userid</b></td>\n";
       print  "<td><b>pin</b></td>\n";
       print  "<td><b>useremail</b></td>\n";
       print  "<td><b>lastdate</b></td>\n";
       print  "\n";
    }
 }
 print "<tr>";
 print "<td>$uid&nbsp;</td>\n";
 print "<td>$userid&nbsp;</td>\n";
 print "<td>$upin&nbsp;</td>\n";
 print "<td>$uemail&nbsp;</td>\n";
 print "<td>$lastdate&nbsp;</td>\n";
 print "<\tr>";
 print "\n";
}

sub write_new_user_DB
{
 my($uid,$userid,$upin,$uemail,$ulastdate) = @_;
 my $sth_usr = $dbh->prepare( "INSERT INTO users (userid,upin,uemail,ulastdate) VALUES ( ?, ?, ?, ?)" );
 $sth_usr->execute($userid,$upin,$uemail,$ulastdate);
 $sth_usr->finish();
}

sub update_user_DB
{
 my($uid,$userid,$upin,$uemail) = $_[0];

 my $sth_usr = $dbh->prepare( "UPDATE users SET userid = ?, upin = ?, uemail = ?, ulastdate = CURDATE()) WHERE uid = ?");
 $sth_usr->execute($userid,$upin,$uemail,$uid,);
 $sth_usr->finish();
}

sub get_userinfo_w_uid
{
 my($uid) = $_[0];
 my $sth_usr = $dbh->prepare( 'SELECT user,upin,uemail,ulastdate FROM users where userid = ?' );
 $sth_usr->execute($uid);
 ($userid,$upin,$uemail,$ulastdate) = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($userid,$upin,$uemail,$ulastdate);
}

sub get_userinfo  
{
 my($userid) = $_[0];
 my $sth_usr = $dbh->prepare( 'SELECT uid,upin,uemail,ulastdate FROM users where userid = ?' );
 $sth_usr->execute($userid);
 ($uid,$upin,$uemail,$ulastdate) = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($uid,$upin,$uemail,$ulastdate);
}

sub get_uid  
{
 my($userid) = $_[0];
 my $uid = 0;
 my $sth_usr = $dbh->prepare( 'SELECT uid FROM users where userid = ?' );
 $sth_usr->execute($userid);
 $uid = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($uid);
}


sub import_users
{ 
  $dbh = &db_connect() if(!$dbh);
  my $usersctrl = "$controlpath/contrbutors.html";
 print "<b>Import users from contributors</b> ..usersctrl $usersctrl<br>\n";
  my $usr_sth = $dbh->prepare( "INSERT INTO users (userid,upin,uemail,ulastdate) VALUES ( ?, ?, ?, ?)" );

  open(CONTRIBUTORS, "$usersctrl") or die("Can't open regions control");
  while(<CONTRIBUTORS>)
  {
    chomp;
    $uLine = $_;     
    my ($uAccess,$userid,$upin,$ulastdate,$lastname,$firstname,$mi,$addr,
	   $city,$state,$zip,$phone,$uemail,$payrole,$handle,$permissions,
	   $usercomment,$uBlanks,$uSeparator,$uLocSep,$uSkipon,
	   $uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd)
	     = split(/\^/,$uLine,30);
	 $usr_sth->execute(	$userid,$upin,$uemail,$ulastdate) unless($upin =~ /endID/);
  }
  $usr_sth->finish;
  close(CONTRIBUTORS);
}

sub create_user                          
{            
 $USER_SQL = <<ENDUSER
CREATE TABLE `users` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `userid` varchar(15) DEFAULT '',
  `upin` varchar(15) NOT NULL DEFAULT '0000'
  `uemail` varchar(100) DEFAULT '',
  `ulastdate` varchar(15) DEFAULT '',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=latin1;
ENDUSER
}

1;