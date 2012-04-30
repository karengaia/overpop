#!/usr/bin/perl --

# May 7, 2010
#        contributor.pl

##  When cmd = "start_acctapp", this routine sends out the message to verify
##  the info entered by the applicant. 
##  When applicant replies, the info will be sent to the admin email addr for approval
##  The admin will review the info and approve the application by forwarding it 
##  to popnews@population-awareness.net

## Change Log
## 2010 May 7 -- tested for  if(-f "../../karenpittsMac.yes") on all opens for writing and chmod to 777

sub init_contributors
{        #from article.pl
  $print_contributors = 'N';
  $handle = "";
}

sub verify_new_acct
{
   $begin_html = "<blockquote><br><br><br><font face=verdana <b>";
   $end_html   = "</b></font></blockquote>\n";
   
   &get_new_contributor_form_values;
  	
   if($nEmail =~ /\@/ and $nEmail =~ /\./ and $nEmail =~ /[A-Za-z0-9]/) {
        if($nLastname eq "" or $nFirstname eq "" or $nUserid eq "" 
           or $nPin eq "" or $nUsercomment eq "") {
        print "$begin_html Required fields are first and last name, State or Country, Username, Password, and a ";
        print "Reason-why you want to help.<br>\n Hit your BACK button to correct.$end_html";
           exit;
       }
   }
   else {
        print "$begin_html You must supply a valid email address.<br>\n";
        print "Hit your BACK button to correct.$end_html";
        exit;
   }
    
   local($userdata,$access) = &read_contributors(N,N,_,$nEmail,$nUserid,_);
   
   if($nEmail and $userdata eq 'SAMEEMAIL') {
        print "$begin_html You have already applied for an account under this ";
        print "email address - $nEmail.<br>\n";
        print "Please wait for a confirmation request by email and reply to it. <br>\n";
        print "If you wish to make any changes to your information, send the changes ";
        print "with your reply.<br>\n";
        print "Your account will processed within a few days up to two weeks.<br><br>\n";
        print "Thank you.<br><br>\n";
        print "Karen Gaia Pitts .... WOA!!.$end_html";
        exit;
   }
   elsif($nUserid and $userdata eq 'SAMEID') {
        print "$begin_html The user id you have chosen is already in use at WOA!! - ";
        print "user id - $nUserid.<br>\n";
        print "Please hit the Back button and choose another userid. <br>\n";
        print "WOA!!.$end_html";
        exit;
   }  
   
   &email_verify;
   
   print "$begin_html<font size=3 face=verdana>Thank you for volunteering to help with WOA!! articles.<br>\n";
   print "You will receive a request by email to verify your email address. <br>\n";
   print "Please simply 'reply' to it. (reply with the same message you received)<br>\n";
   print "Your account number will be sent by email within a few days.<br><br>\n";
   print "Karen Gaia Pitts.... WOA!!.</font>$end_html";
   return 0;
}


## 0030 
##  Called by a web request - query string 
##  If a new applicant, then email has been sent by the approving admin
##  to popnews email 

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
      print "con92 mailpath $mailpath<br>\n";     
    &process_appmail;
  }

  print "Contrib20 ... No email\n" if($filename !~ /[A-Za-z0-9]/);	
}

sub process_appmail
{
	opendir(APPMAILDIR, "$applymailpath");
  local(@applyfiles) = grep /^.+\.app$/, readdir(APPMAILDIR);
  closedir(APPMAILDIR);
  
  foreach $filefound (@applyfiles) {

      $filename = "$applymailpath\/$filefound";
        	
      if(-f "$filename" and $filename =~ /\.app/ and $filename !~ /email|log|date/) { 
            &process_app_email($filename);       
            &write_new_contributor;   
            &email_applicant_accept;
            unlink "$filename";
      }
  }
}

## 00030

sub get_operator_name
{
 if($userid =~ /[A-Za-z0-9]/) {
   ($userdata, $access) = &read_contributors(N,N,_,_,$op_userid,98989);
   print MIDTEMPL "Current User: $firstname $lastname" if($userdata =~ /GOOD/);
 }
}

sub get_summarizer_name
{
 if($sumAcctnum =~ /[A-Za-z0-9]/) {
   ($userdata, $access) = &read_contributors(N,N,_,_,$sumAcctnum,98989) ; 
   print MIDTEMPL " ..Summarizer: $firstname $lastname" if($userdata =~ /GOOD/);
 }
}

sub get_suggestor_name
{
 if($suggestAcctnum =~ /[A-Za-z0-9]/) {
   ($userdata, $access) = &read_contributors(N,N,_,_,$suggestAcctnum,98989); ## args=print?, html file?, handle, email, acct# 
   print MIDTEMPL " .. Suggester: $firstname $lastname" if($userdata =~ /GOOD/);
 }
}

sub get_userinfo
{
 if($userid =~ /[A-Za-z0-9]/) {
   ($userdata, $access)= &read_contributors(N,N,_,_,$sumAcctnum,98989); ## args=print?, html file?, handle, email, acct# 
   print MIDTEMPL "$uUserid $firstname $mi $lastname" if($userdata =~ /GOOD/);
 }
}


## 00040

sub process_app_email
{
  local($filename) = $_[0];
    
  local($buffer) = "";
  local(@stuff);

  open(EMAILAPP,$filename);
  @stuff = <EMAILAPP>;
  close(EMAILAPP);
    
  $buffer = join('',@stuff);

  $buffer =~ s/\r\n/\n/g;    #change \r\n to \n
  $buffer =~ s/\n\r/\n/g;    #change \n\r to \n
  
##  local($rest,$message) = split(/\n\n/,$buffer,2);

  $message = $buffer;

  @msglines = split(/\n/,$message);

  &clear_contrib_email_values;
  
  foreach $msgline (@msglines) {
    chomp $msgline;
    last if($msgline =~ /:END/);  
    &get_contributor_email_values;
  }
  
  &populate_email_values;
}

## 00060

sub get_contributor_email_values
{
 $splitter = "";
 foreach $pair (@stdVariables) {
    ($pairname, $splitter) = split(/\^/, $pair);
     if($msgline =~ /$splitter/) {
       last;
    }
 }
 if($msgline =~ /$splitter/) {
       $name = $pairname;
       ($rest,$value) = split(/$splitter/,$msgline);
       $EITEM{$name} = $value;
       print "$splitter $name = $value<br>\n";
 }
 else { 
   $EITEM{$name} = "$EITEM{$name}$msgline";
   $what = $EITEM{$name};
 }
}

## 00100


##            these are globals. eventually change to uHungarian notation
sub get_contributor_form_values
{
  $userid        = $FORM{userid};
  $access        = $FORM{access};
  $pin           = $FORM{pin};
  $useremail     = $FORM{email};
  $lastdate      = $FORM{lastdate};
  $firstname     = $FORM{fname};
  $lastname      = $FORM{lname};
  $addr          = $FORM{addr};
  $city          = $FORM{city};
  $state         = $FORM{state};
  $zip           = $FORM{zip};
  $phone         = $FORM{phone};
  $handle        = $FORM{handle};
  $payrole       = $FORM{payrole};
  $handle        = $FORM{handle};
  $usercomment   = $FORM{usercomment};
  $permissions   = $FORM{permissions};
  $uBlanks       = $FORM{uBlanks};
  $uSeparator    = $FORM{uSeparator};
  $uLocSep       = $FORM{uLocSep};
  $uSkipon       = $FORM{uSkipon};
  $uSkipoff      = $FORM{uSkipoff};
  $uSkip         = $FORM{uSkip};
  $uEmpty        = $FORM{uEmpty};
  $uDateloc      = $FORM{uDateloc};
  $uDateformat   = $FORM{uDateformat};
  $uHeadlineloc  = $FORM{uHeadlineloc};
  $uSourceloc    = $FORM{uSourceloc};
  $uSingleLineFeeds = $FORM{uSingleLineFeeds};
  $uEnd          = $FORM{uEnd};
  return;
}


sub get_new_contributor_form_values
{
  $nUserid        = $FORM{userid};
  $nPin           = $FORM{pin};
  $nEmail         = $FORM{email};
  $nLastdate      = $FORM{lastdate};
  $nFirstname     = $FORM{fname};
  $nLastname      = $FORM{lname};
  $nAddr          = $FORM{addr};
  $nCity          = $FORM{city};
  $nState         = $FORM{state};
  $nZip           = $FORM{zip};
  $nPhone         = $FORM{phone};
  $nHandle        = $FORM{handle};
  $nPayrole       = $FORM{payrole};
  $nHandle        = $FORM{handle};
  $nUsercomment   = $FORM{usercomment};
  return;
}

##00110

sub populate_email_values
{
  $userid        = $EITEM{userid};
  $pin           = $EITEM{pin};
  $useremail     = $EITEM{useremail};
  $lastdate      = $EITEM{lastdate};
  $firstname     = $EITEM{firstname};
  $mi            = $EITEM{mi};
  $lastname      = $EITEM{lastname};
  $addr          = $EITEM{addr};
  $city          = $EITEM{city};
  $state         = $EITEM{state};
  $zip           = $EITEM{zip};
  $phone         = $EITEM{phone};
  $handle        = $EITEM{handle};
  $roles         = $EITEM{payrole};
    
  $payrole = &get_payrole($roles);
  
  $handle        = $EITEM{handle};
  $permissions   = $EITEM{permissions};  
  
  &get_nowdate;
} 


sub clear_contrib_email_values
{
  $EITEM{userid}      = "";
  $EITEM{pin}         = "";
  $EITEM{email}       = "";
  $EITEM{lastdate}    = "";
  $EITEM{firstname}   = "";
  $EITEM{mi}          = "";
  $EITEM{lastname}    = "";
  $EITEM{addr}        = "";
  $EITEM{city}        = "";
  $EITEM{state}       = "";
  $EITEM{zip}         = "";
  $EITEM{phone}       = "";
  $EITEM{handle}      = "";
  $EITEM{payrole}     = "";
  $EITEM{handle}      = "";
  $EITEM{permissions} = "";  	
	
}
##   not used
           
sub clear_contributor_values
{
  $uAccess       = "";
  $uUserid       = "";
  $uPin          = "";
  $useremail     = "";
  $lastdate      = "";
  $firstname     = "";
  $lastname      = "";
  $mi            = "";
  $addr          = "";
  $city          = "";
  $state         = "";
  $zip           = "";
  $phone         = "";
  $handle        = "";
  $payrole       = "";
  $pay           = "";
  $usercomment   = "";
  $permissions   = "";
  $uBlanks       = "";
  $uSeparator    = "";
  $uLocSep       = "";
  $uSkipon       = "";
  $uSkipoff      = "";
  $uSkip         = "";
  $uEmpty        = "";
  $uDateloc      = "";
  $uDateformat   = "";
  $uHeadlineloc  = "";
  $uSourceloc    = "";
  $uSingleLineFeeds     = "";
  $uEnd          = "";
  return;
}

         
## 150

sub check_user
{ 
  local($ckuserid,$ckpin) = @_;
  if($ckuserid =~ /^\+/) {
    $user_visable = 'Y';
    ($rest,$ckuserid) = split(/\+/,$ckuserid,2);
##  ($rest,$acctnum) = split(/\+/,$acctnum,2);
  }
  else {
    $user_visable = 'N';
  }	
  
  if($ckuserid !~ /[A-Za-z0-9]{2}/ or $ckuserid =~ /Userid/ or $ckpin !~ /[A-Za-z0-9]{2}/) {
      &printUserMsgExit("You must supply a userid and password, or, if you do not have one, you must register.<br /> Hit your BACK button to correct.");
      exit;
  }


 ($userdata,$uAccess,$permissions) = &read_contributors(N,N,_,_,$ckuserid,$ckpin);    ## args=print?, html file?, handle, email, acct# ;

 if($userdata =~ /BAD/) {
      &printUserMsgExit("Sorry. The userID ($ckuserid) or password you gave is not valid.<br />Hit your BACK button to correct.");
      exit;
 }
 return($userdata,$uAccess,$permissions);
}

##180

sub email_verify
{
	 
 $roles_expanded = &do_roles(email);
 
## print "Contrib 180  userid $nUserid useremail $nEmail roles $roles_expanded<br>\n";
 $sender  = "$contactEmail";
 $recipient = $nEmail;
 $subject  = "WOA APP:: ... Please confirm your account application.";
 $email_msg = "Your submittal has been received by WOA!!. \n\n Please reply";
 $email_msg = "$email_msg to this email to verify that you are the one that";
 $email_msg = "$email_msg submitted it.\n\n Please leave the following application \n";
 $email_msg = "$email_msg information in your reply.\n\n";
 $email_msg = "$email_msg Firstname::$nFirstname\n";
 $email_msg = "$email_msg Lastname::$nLastname\n";
 $email_msg = "$email_msg Email::$nEmail\n";
 $email_msg = "$email_msg UserID::$nUserid\n";
 $email_msg = "$email_msg Password::$nPin\n";
 $email_msg = "$email_msg City::$nCity\n";
 $email_msg = "$email_msg State::$nState\n";
 $email_msg = "$email_msg Zip::$nZip\n";
 $email_msg = "$email_msg Phone::$nPhone\n"; 
 $email_msg = "$email_msg Roles::$roles_expanded\n";
 $email_msg = "$email_msg Reason::$nUsercomment\n";
 $email_msg = "$email_msg :END\n\n";
 $email_msg = "$email_msg $email_std_end ";
  
 &do_email;
}

sub email_applicant_accept
{
 $subject   = "Volunteering to help with World Population Awareness";
 $sender    = $adminEmail;
 $recipient = $useremail;
 $cc        = $adminEmail;  
# print "180 sender $sender recipient $recipient\n";
 
 $email_msg = "Thank you so much for volunteering to help the World Population Awareness";
 $email_msg = "$email_msg website publication and for helping to inform people about population";
 $email_msg = "$email_msg and related issues.\n\n";

 $email_msg = "$email_msg The instructions for helping are on the volunteer work page at\n";
 $email_msg = "$email_msg http:\/\/www.population-awareness.net\/volunteer_page.html\n\n";

 $email_msg = "$email_msg At some point you will be asked to put in your userID and password,";
 $email_msg = "$email_msg which you have already supplied in your application and was sent";
 $email_msg = "$email_msg in a prior email.\n\n";

 $email_msg = "$email_msg Do not hesitate to contact me if you have questiions or problems";
 $email_msg = "$email_msg or forget your userid or password.\n\n";

 $email_msg = "$email_msg Best regards,\n\n";

 $email_msg = "$email_msg Karen Gaia Pitts\n";
 $email_msg = "$email_msg WOA!! - World Population Awareness\n";
 $email_msg = "$email_msg World Overpopulation Awareness\n";
 $email_msg = "$email_msg www.population-awareness.net\n";
 $email_msg =  "$email_msg www.overpopulation.org\n";
  
 &do_email;
}
	


### 200

sub read_contributors
{
   local($print_contributors,$uHtmlfile,$eHandle,$ckuseremail,$ckuserid,$ckpin) = @_;

   # print "contrib 460 prt $print_contributors  prtHtml $uHtmlfile handle $eHandle email $ckuseremail userid $ckuserid pin $ckpin ..contriFile $contributors ..<br>\n";
   
   $userdata = "BAD";
   
   $uCount = 0;

   $lock_file = "$contributors.busy";
##   &waitIfBusy($lock_file, 'lock'); 
    
   open(CONTRIBUTORS, "$contributors");
   while(<CONTRIBUTORS>) {
      chomp;
      $uLine = $_;     
      $uCount = $uCount + 1;
      &split_contributor;
      &print_contributor if($print_contributors eq 'Y');
      &print_contrib_htmlFile  if($uHtmlfile eq 'Y');

	  ($uAccess,$uUserid,$uPin,$lastdate,$lastname,$firstname,$mi,$addr,
	   $city,$state,$zip,$phone,$useremail,$payrole,$handle,$permissions,
	   $usercomment,$uBlanks,$uSeparator,$uLocSep,$uSkipon,
	   $uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd)
	     = split(/\^/,$uLine,30);		
      if($uUserid !~ /[A-Za-z0-9]{2}/ or $uPin !~ /[A-Za-z0-9]{2}/) {
      }
      elsif($eHandle =~ /[A-Za-z0-9]/) {
         if($eHandle eq $handle) {
            $userdata = "SAMEHANDLE";
#print "contr490 $userdata ..ehandle $eHandle ..ck_email $ckuseremail ..u_email $useremail ..userid $ckuserid ..uUserid $uUserid <br>\n";
           last;
         }
      }
      elsif($ckuserid !~ /[A-Za-z0-9]/ and $ckuseremail =~ /[A-Za-z0-9]/ and $ckuseremail =~ /$useremail/) {
         $userdata = "SAMEEMAIL";
#print "contr496 $userdata ..ehandle $eHandle ..ck_email $ckuseremail ..u_email $useremail ..userid $ckuserid ..uUserid $uUserid <br>\n";
         last;
      }
      elsif($ckuserid =~ /$uUserid/ and $ckuserid =~ /[A-Za-z0-9]{2}/ 
             and ($ckpin =~ /$uPin/ or $ckpin =~ /98989/) ) {
         $userdata = "GOOD";
         last;
      }
      
      elsif($ckuserid =~ /$uUserid/ and $ckuserid =~ /[A-Za-z0-9]/)  {
         $userdata = "SAMEID";
         last;
      }
      elsif($ckuserid =~ /ZZZZ/) {
      	 $userdata = "GOOD";
      } ##  end else   
    }  ## end while
    close(CONTRIBUTORS);

    unlink "$lock_file";
    
    print "</td></table><br>\n" if($print_contributors eq 'Y');
    print PRTCONTRIB "</td></table><br>\n" if($uHtmlfile =~ /Y/);
    close(PRTCONTRIB) if($uHtmlfile =~ /Y/);

    return ($userdata,$uAccess,$permissions);
}


## 000300

sub split_contributor
{
  ($uAccess,$uUserid,$uPin,$lastdate,$lastname,$firstname,$mi,$addr,
   $city,$state,$zip,$phone,$useremail,$payrole,$handle,$permissions,
   $usercomment,$uBlanks,$uSeparator,$uLocSep,$uSkipon,
   $uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd)
     = split(/\^/,$uLine,30);

##print "uAccess $uAccess uUserid $uUserid uPin $uPin, uLocSep $uLocSep uDateloc $uDateloc uDateformat $uDateformat uSourceloc $uSourceloc uSingleLineFeeds $uSingleLineFeeds\n";
##       if not a clipping service, then there is a pin and we have to set defaults     
   if($uPin =~ /[A-Za-z0-9]/) {
   	$uLocSep    = 'first' if($uLocSep    !~ /[A-Za-z0-9]/);
   	$uSeparator = '#####' if($uSeparator !~ /[A-Za-z0-9]/  and $uSeparator !~ /.+/);
   	$uBlanks    = '0'     if($uBlanks    !~ /[A-Za-z0-9]/);
   	$uSkipon    = '%NA'   if($uSkipon    !~ /[A-Za-z0-9]/);
   	$uSkipoff   = '%NA'   if($uSkipoff   !~ /[A-Za-z0-9]/);
   	$uEnd       = '%NA'   if($uEnd       !~ /[A-Za-z0-9]/);
   	$uSkip      = '%NA'   if($uSkip      !~ /[A-Za-z0-9]/  and $uSeparator !~ '#####');
   	$uSkip      = '#####' if($uSkip      !~ /[A-Za-z0-9]/  and $uSeparator =~ '#####');		    
   }
    $uStart  = $uSkipoff;  # rename
    $uStop   = $uEnd;
     
##   $uAcctnum = "$access$userid";
   ($srcloc,$srckey,$srcpart,$srcsep) = split(/&/,$uSourceloc,4);
   ($hdloc,$hdkey,$hdpart,$hdsep) = split(/&/,$uHeadlineloc,4);
   ($dtloc,$dtkey,$dtpart,$dtsep) = split(/&/,$uDateloc,4);

	($rest,$c_blank_ct) = split(/=/, $separator, 2) if($separator =~ /blanks/);
	$uBlanks = $c_blank_ct if($c_blank_ct);
	$stop = "@#&#%%@" if(!$stop);  # impossible - but null won't work
	$skip = "@#&#%%@" if(!$skip);  # impossible - but null won't work
	$separator = "########" if(!$separator);
}


## 400

sub write_new_contributor
{
## $countfile = $usercntfile;
## &get_count;
## $usercount = $count;

 $access = 'P';
 $lastdate = $nowdate;

 if($SVRinfo{environment} == 'development') {  ## set permissions if using Karen's Mac as the server
	if(-f '$contributors') {}
	else {
		system('touch $contributors');
		}
	system('chmod 0777, $contributors');
 }
 open(CONTRIBUTORS, ">>$contributors");
 print CONTRIBUTORS "$access^$userid^$pin^$sysdate^$lastname^$firstname^$mi^$addr^";
 print CONTRIBUTORS "$city^$state^$zip^$phone^$useremail^$payrole^";
 print CONTRIBUTORS "$handle^$permissions^$usercomment^";
 print CONTRIBUTORS "$uBlanks^$uSeparator^$uLocSep^";
 print CONTRIBUTORS "$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^";
 print CONTRIBUTORS "$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd\n";
 close(CONTRIBUTORS);
}

sub print_contributor
{
 if($uCount < 2) {	
    print "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    local($mod) = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print  "<tr>";
       print  "<td><font size=1 face=verdana><b>ac</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>userid</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>pswd</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>lastdate</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>lastname</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>firstname</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>mi</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>addr</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>city</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>state</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>zip</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>phone</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>useremail</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>pay</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>handle</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>permissions</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>usercomment</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uBlanks</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSeparator</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uLocSep</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkipon</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkipoff</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkip</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uEmpty</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uDateloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uDateFormat</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uHeadlineloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSourceloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSingleLineFeeds</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uEnd</b></font></td>\n";
       print  "\n";
    }
 }
 print "<tr>";
 print "<td><font size=1 face=verdana>$uAccess&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uUserid&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uPin&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$lastdate&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$lastname&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$firstname&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$mi&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$addr&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$city&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$state&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$zip&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$phone&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$useremail&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$pay&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$handle&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$permissions&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$usercomment&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uBlanks&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSeparator&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uLocSep&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkipon&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkipoff&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkip&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uEmpty&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uDateloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uDateFormat&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uHeadlineloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSourceloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSingleLineFeeds&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uEnd&nbsp;</font></td>\n";
 print "\n";
}

sub print_contrib_htmlFile
{
 if($uCount < 2) {
    $prt_contributors  = "$controlpath$X"."prt_contributors.html";
    open(PRTCONTRIB, $prt_contributors);
    print PRTCONTRIB "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    
    local($mod) = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print PRTCONTRIB "<tr>";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>ac</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>userid</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>pin</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>lastdate</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>lastname</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>firstname</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>mi</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>addr</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>city</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>state</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>zip</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>phone</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>useremail</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>pay</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>handle</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>permissions</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>usercomment</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uBlanks</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSeparator</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uLocSep</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSkipon</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSkipoff</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSkip</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uEmpty</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uDateloc</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uDateFormat</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uHeadlineloc</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSourceloc</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uSingleLineFeeds</b></font></td>\n";
       print PRTCONTRIB "<td><font size=1 face=verdana><b>uEnd</b></font></td>\n";
       print PRTCONTRIB "\n";
    }
 }
 print PRTCONTRIB "<tr>";
 print PRTCONTRIB "<td><font size=1 face=verdana>$access&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$userid&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$pin&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$lastdate&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$lastname&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$firstname&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$mi&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$addr&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$city&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$state&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$zip&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$phone&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$useremail&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$pay&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$handle&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$permissions&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$usercomment&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uBlanks&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSeparator&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uLocSep&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSkipon&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSkipoff&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSkip&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uEmpty&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uDateloc&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uDateFormat&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uHeadlineloc&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSourceloc&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uSingleLineFeeds&nbsp;</font></td>\n";
 print PRTCONTRIB "<td><font size=1 face=verdana>$uEnd&nbsp;</font></td>\n";
 print PRTCONTRIB "\n";
}


## 000800

sub do_roles
{
  local($action) = $_[0];

  @roles = (
   "S=Summarize articles",
   "s=Section Editor",
   "E=Events Calendar",
   "A=Send us articles",
   "N=News Link Chasing",
   "G=Grassroots Organizer",
   "P=Programs/Presentations",
   "M=Media/Publicity",
   "F=Forum (email) leader",    
   "I=Web Graphics",
   "L=Write Letters"
  );
  local($selected);
  
  foreach $role_expanded(@roles) {
     local($role,$descr) = split(/=/,$role_expanded,2);
     
     if($action eq 'email') {
     	if($nPayrole =~ /$role/) {
     	   $selected = ' x ';
     	}
     	else {
     	   $selected = '   ';
     	}
        if($roles_expanded =~ /[A-Za-z0-9]/) {
           $roles_expanded = "$roles_expanded\n$selected$role_expanded;";
        }
        else {
           $roles_expanded = "\n$selected$role_expanded;"; 
        }   #end_ifelse  	 	
     } #endif    	
  } #end foreach
  
## if($action eq 'form') <input type=checkbox.... see signup.html

  return $roles_expanded if($action eq 'email');
}

sub get_payrole
{
 local($roles) = $_[0];
 local(@roles) = split(/;/,$roles);
 local($xrole);
 foreach $xrole (@roles) {
    if($xrole =~ / x /) {
      ($rest,$xrole) = split(/ x /,$xrole,2);
      ($xrole,$rest) = split(/=/,$xrole,2); 
      if($xroles =~ /[A-Za-z0-9]/) {
         $xroles = "$xroles;$xrole";
      }
      else {
         $xroles = "$xrole"; 
      }   #end_ifelse  
    }	     	
  } #end foreach
    
 return($xroles);	
}

1;