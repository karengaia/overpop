#!/usr/bin/perl --

# Oct 23, 2012

# An editor is a 'user' who helps with summarization, section editor, suggested, etc.


sub init_editors
{        #from article.pl
  $print_editors = 'N';
  $header_template = "plain_top";
  $footer_template = "plainEnd";

  $editorsbkppath    = "$bkpcontrolpath/editors.html";
  $editorspath       = "$controlpath/editors.html";
  $editors_orig      = "";   #original file is in contributors.html
  $editors_eofline   = "0^end^^^^^^^^^^^^^";

  &clear_editors;

  $DBH = &db_connect() unless($DBH);

  &read_editors_to_array;
}

sub clear_editors
{
  $EDITORSIZE  = 0;
  %EDITORINDEX    = {};
  @EDITORARRAY    = ();
  $uaccess        = "";
  $ufirstname     = "";
  $ulastname      = "";
  $umiddle        = "";
  $uaddr          = "";
  $ucity          = "";
  $ustate         = "";
  $uzip           = "";
  $uphone         = "";
  $urole           = "";
  $upay           = 0.00;
  $ucomment       = "";
  $upermissions   = "";
  $e_created_o    = "";
}

sub read_editors_to_array
{	
 if($DB_users > 0) {
	 $EDITORSIZE = &DB_get_editors_2array;
  }
  else {
	 $EDITORSIZE = &flatfile_get_editors_2array;
  }
}

sub flatfile_get_editors_2array
{
   my $editor_idx = 0;
   my $lock_file = "$editorspath.busy";

   open(EDITORS, "$editorspath");
   while(<EDITORS>) {
      chomp;
      my $line = $_;     
      ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) 
          = &split_editor($line);
      $EDITORINDEX{$e_uid} = $line;
      $EDITORARRAY[$editor_idx] = $line;
	  $editor_idx = $editor_idx + 1;
    }
    close(EDITORS);
    unlink "$lock_file";
    return($editor_idx);
}

sub DB_get_editors_2array
{
  my $editor_idx = 0;
  my $sth = &DB_prepare_select_editors_list;

  $sth->execute();
  while (my ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) 
         = $sth->fetchrow_array()) {
	  my $line = "$e_uid^$uaccess^$ulastname^$ufirstname^$umiddle^$uaddr^$ucity^$ustate^$uzip^$uphone^$urole^$upay^$upermissions^$ucomment^$e_created_on";
      $EDITORINDEX{$e_uid} = $line;
      $EDITORARRAY[$editor_idx] = $line;
      $editor_idx = $editor_idx + 1;
  }
  $sth->finish;
  return($editor_idx);	
}

sub split_editor
{
  my $line = $_[0];
  ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)
     = split(/\^/,$line,15);
  return($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
}

sub get_editor_access
{
  my($userid) = $_[0];
  my $uid = &get_user_uid($userid);
  my $row = $EDITORINDEX{$e_uid} = $line;
  ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) 
      = &split_editor($row);
  return($uaccess);
}

sub get_editor_form_values
{
  $uaccess        = $FORM{'uaccess'};
  $ulastname      = $FORM{'ulastname'};
  $ufirstname     = $FORM{'ufirstname'};
  $umiddle        = $FORM{'umiddle'};
  $uaddr          = $FORM{'uaddr'};
  $ucity          = $FORM{'ucity'};
  $ustate         = $FORM{'ustate'};
  $uzip           = $FORM{'uzip'};
  $uphone         = $FORM{'uphone'};
  $urole          = $FORM{'urole'};
  $upay           = $FORM{'upay'};
  $ucomment       = $FORM{'ucomment'};
  $e_created_on   = $FORM{'e_created_on'};
  $e_created_on   = &get_nowdate unless $e_created_on;
  return($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
}

sub put_editor_to_docarray    #used in template_ctrl to marry templates with data
{
	($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = @_;
	$DOCARRAY{'uaccess'}        = $uaccess;
	$DOCARRAY{'ufirstname'}     = $ufirstname;
	$DOCARRAY{'ulastname'}      = $ulastname;
	$DOCARRAY{'umiddle'}        = $umiddle;
	$DOCARRAY{'uaddr'}          = $uaddr;
	$DOCARRAY{'ucity'}          = $ucity;
	$DOCARRAY{'ustate'}         = $ustate;
	$DOCARRAY{'uzip'}           = $uzip;
	$DOCARRAY{'uphone'}         = $uphone;
	$DOCARRAY{'urole'}          = $urole;
	$DOCARRAY{'upay'}           = $upay;
	$DOCARRAY{'ucomment'}       = $ucomment;
	$DOCARRAY{'upermissions'}   = $upermissions;
	$DOCARRAY{'e_created_on'}   = $e_created_on;
}

sub get_editor_row {
	my $uid = $_[0];
	my $row = $EDITORINDEX{$uid};
	my ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) 
	   = split_editor($row);
	return($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);		
}


sub get_put_editor_to_docarray
{
    my($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$ulastdate)
      = &get_editor_row($uid);
    &put_editor_to_docarray($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$ulastdate);       # in editors.pl
}


sub do_editoracct {  ### Comes here from article.pl to process the volunteer app
	
 $DOCARRAY{'cTitle'} = "Volunteer App Response"; 
 &process_template($header_template,'Y','N','N');
	
 my($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$u_created_on);
 my($uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);
 my $operator_access;

 my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate,$opax) = &get_user_form_values;  #in user.pl

 my($status) = &check_user_exists($uid);   # in user.pl - is it 'new' or 'update' ?

 if($userid or $uemail) {
     ($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$u_created_on)
        = &get_editor_form_values;  #in editor.pl

    ($uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
            = &get_contributor_form_values;  #in contributor.pl

    $operator_access = 'A' if($opax eq 'A3491');

    &verify_editor($status,$operator_access,$userid,$upin,$uemail,$uhandle,$ulastname,$ufirstname,$ustate,$ucity,$ucomment);

    ($uid) = &store_user($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);  #in user.pl

    &store_editor($status,$uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$u_created_on)
       if($ulastname or $ufirstname);

#    print "ed170 uid $uid .. $uBlanks,$uSeparator,$uSkipon,$uSkipoff,$uSkip,$uDateloc,$uDateformat,$uHeadlineloc,$uEnd,$c_created_on<br>\n";
    &store_contributor($status,$uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
       if($uBlanks or $uSeparator or $uSkipon or $uSkipoff or $uDateloc or $uHeadlineloc or $uDateformat or $uEnd);

    if($status eq 'new' and ($ulastname or $ufirstname) and !$opax) {
		&editor_email_verify($uid,$userid,$uemail,$upin,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$ucomment);
		print "<p>&nbsp;</p><p>Thank you, $ufirstname, for applying for a WOA account.</p>\n";
		print "<p>You will receive a request by email to verify your email address.</p>\n";
		print "<p>Please simply 'reply' to it.</p>\n";
		print "<p>Your account will be approved within a few days.</p><br>\n";
		print "<p>Karen Gaia Pitts.... WOA!! ... $GLVARS{'contactEmail'}</p><p>&nbsp;</p>";
    }
    elsif($status eq 'old' and ($ulastname or $ufirstname)) {
	    print "<p>&nbsp;</p><p>Your WOA account has been updated.</p><p>&nbsp;</p>\n";
   }
   elsif($status eq 'new') {
	 	print "<p>&nbsp;</p><p>A new account <label class=\"lavender\">$uid</label> has been added.</p><p>&nbsp;</p>\n";
   }
   elsif($status eq 'old') {
	 	print "<p>&nbsp;</p><p>An old account <label class=\"lavender\">$uid</label> has been updated.</p><p>&nbsp;</p>\n";
   }
 }
 else {
	 print "<p>&nbsp;</p><p>Userid or Email are missing.<br> Hit your BACK button to correct.</p>\n";
	 print "Karen Gaia Pitts.... WOA!!.</p><p>&nbsp;</p>\n";
	 exit;
 }
 &process_template($footer_template,'Y', 'N','N');
}

sub verify_editor  ## from article.pl
{ 
 my($status,$op_access,$userid,$upin,$ckemail,$uhandle,$ulastname,$ufirstname,$ustate,$ucity,$ucomment) = @_;

  $userid = &trim($userid);
   unless($userid) {
       print "<p>&nbsp;</p><p> You must supply a userid.</p>\n";
       print "<p>Hit your BACK button to correct.</p><p>&nbsp;</p>";
       exit;	
   }

   unless($ckemail =~ /\@/ and $ckemail =~ /\./ and $ckemail =~ /[A-Za-z0-9]/) {
        print "<p>&nbsp;</p><p> You must supply a valid email address. $ckemail is invalid </p>\n";
        print "<p>Hit your BACK button to correct.</p><p>&nbsp;</p>";
        exit;
   }
   unless($op_access =~ /[ABCD]/) {
        unless($ulastname and $ufirstname and $ckemail and ($ustate or $ucity) and $upin and $ucomment) {
	        print "<p>&nbsp;</p><p>Required fields are first and last name, password, and a ";
	        print "reason for volunteering</p>\n <p>Hit your BACK button to correct.</p><p>&nbsp;</p>";
	           exit;
	   }
   }

   my($userdata,$uid) = &validate_users($userid,"",$ckemail,"",$uhandle); ## in users.pl

   if($status eq 'new') {
	   if($ckemail and $userid and $userdata =~ /SAMEEMAIL/ and $userdata =~ /SAMEID/) {
	        print "<p>&nbsp;</p><p> You have already applied for an account under this ";
	        print "email address - <label class=\"lavender\"> $ckemail<\/label> , and this userid - <label class=\"lavender\">$userid<\/label>.</p>\n";
	        &end_verify_msg;
	        exit;
	   }
	   elsif($ckemail and $userdata =~ /SAMEEMAIL/) {
	        print "<p>&nbsp;</p><p> You have already applied for an account under this ";
	        print "email address - <label class=\"lavender\">$ckemail.</label></p>\n";
	        &end_verify_msg;
	        exit;
	   }
	   elsif($userid and $userdata =~ /SAMEID/) {
	        print "<p>&nbsp;</p><p>The user id you have chosen - <label class=\"lavender\">$userid</label> - is already in use at WOA!! </p>\n";
	        print "<p>Please hit the Back button and choose another userid. </p>\n";
	        print "<p>Karen Gaia Pitts .... WOA!! .. $GLVARS{'contactEmail'}</p><p>&nbsp;</p>";
	        exit;
	   }
	   elsif($userid and $userdata =~ /SAMEHANDLE/) {
	        print "<p>&nbsp;</p><p>The handle you have chosen - <label class=\"lavender\">$uhandle</label> - is already in use at WOA!! </p>\n";
	        print "<p>Please hit the Back button and choose another userid. </p>\n";
	        print "<p>Karen Gaia Pitts .... WOA!! .. $GLVARS{'contactEmail'}</p><p>&nbsp;</p>";
	        exit;
	   }
   }
}

sub end_verify_msg
{
	print "<p>Please wait for a confirmation request by email and reply to it. </p>\n";
    print "<p>Your account will processed within a few days up to two weeks.</p>\n";
    print "<p>If already received a confirmation request, and want to change your account, please sign in at the top of the form first. Hit your back button to return.</p>\n";
    print "<p>If you do not get a confirmation request, or are experiencing problems, please let me know at $GLVARS{'contactEmail'}.</p>\n";
    print "<p>Thank you.</p><br>\n";
    print "<p>Karen Gaia Pitts .... WOA!!.</p><p>&nbsp;</p>\n";
}

sub editor_email_verify
{
 my($uid,$userid,$uemail,$upin,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$ucomment) = @_;

 $roles_expanded = &do_roles('email',$urole);

 $sender  = $GLVARS{'contactEmail'};
 $recipient = $uemail;
 $subject  = "WOA: Please confirm your email address.";
 $email_msg = "Your submittal has been received by WOA!!. \n\n Please reply";

 $subject  = "WOA APP:: ... Please confirm your account application.";
 $email_msg = "Your submittal has been received by WOA!!. \n\n Please reply";
 $email_msg = "$email_msg to this email to verify that you are the one that";
 $email_msg = "$email_msg submitted it.\n\n Please leave the following application \n";
 $email_msg = "$email_msg information in your reply.\n\n";
 $email_msg = "$email_msg Firstname::$ufirstname\n";
 $email_msg = "$email_msg Lastname::$ulastname\n";
 $email_msg = "$email_msg Middle::$umiddle\n";
 $email_msg = "$email_msg Email::$uemail\n";
 $email_msg = "$email_msg UserID::$userid\n";
 $email_msg = "$email_msg Password::$upin\n";
 $email_msg = "$email_msg City::$ucity\n";
 $email_msg = "$email_msg State::$ustate\n";
 $email_msg = "$email_msg Zip::$uzip\n";
 $email_msg = "$email_msg Phone::$uphone\n"; 
 $email_msg = "$email_msg Roles::$roles_expanded\n";
 $email_msg = "$email_msg Reason::$ucomment\n";
 $email_msg = "$email_msg :END\n\n";
 $email_msg = "$email_msg $email_std_end ";
 $email_msg = "$email_msg $GLVARS{'std_headtop'} ";

 &do_email($email_msg);    # in send_email.pl
}

sub write_acctapp  # use only if we are adding to DB from email stored at popmail  ##########
{	
  print "$Content_type_html";
  
  $std_variables =
  "userid^UserID::`pin^Password::`firstname^Firstname::`lastname^Lastname::`middle^Middle::`useremail^Email::`city^City::`state^State::`zip^Zip::`phone^Phone::`role^Roles::`reason^Reason::`end^END::";
  @stdVariables = split(/`/, $std_variables);

  my $filename = "";
  my $filefound = "";	
  my $applymailpath =  $mailpath;

  opendir(APPMAILDIR, "$applymailpath");
  my(@applyfiles) = grep /^.+\.app$/, readdir(APPMAILDIR);
  closedir(APPMAILDIR);
  
  foreach $filefound (@applyfiles) {

      $filename = "$applymailpath\/$filefound";
        	
      if(-f "$filename" and $filename =~ /\.app/ and $filename !~ /email|log|date/) { 
            &process_app_email($filename);       
            &store_editor('new',$uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);   
            &email_applicant_accept;
            unlink "$filename";
      }
  }
}

sub process_app_email  # Part of emailed app going to database - not used #########################
{
  my($filename) = $_[0];
    
  my($buffer) = "";
  my(@stuff);

  open(EMAILAPP,$filename);
  @stuff = <EMAILAPP>;
  close(EMAILAPP);
    
  $buffer = join('',@stuff);

  $buffer =~ s/\r\n/\n/g;    #change \r\n to \n
  $buffer =~ s/\n\r/\n/g;    #change \n\r to \n

  $message = $buffer;

  @msglines = split(/\n/,$message);

  &clear_editor_email_values;
  
  foreach $msgline (@msglines) {
    chomp $msgline;
    last if($msgline =~ /:END/);  
    &get_editor_email_values;
  }
  
  &populate_email_values;
}

## 00060

sub get_editor_email_values
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

sub clear_editor_email_values
{
  $EITEM{'userid'}      = "";
  $EITEM{'upin'}         = "";
  $EITEM{'uemail'}       = "";
  $EITEM{'ulastdate'}    = "";
  $EITEM{'ufirstname'}   = "";
  $EITEM{'umiddle'}      = "";
  $EITEM{'ulastname'}    = "";
  $EITEM{'uaddr'}        = "";
  $EITEM{'ucity'}        = "";
  $EITEM{'ustate'}       = "";
  $EITEM{'uzip'}         = "";
  $EITEM{'uphone'}       = "";
  $EITEM{'uhandle'}      = "";
  $EITEM{'urole'}        = "";
  $EITEM{'upay'}         = "";
  $EITEM{'uhandle'}      = "";
  $EITEM{'upermissions'} = "";  	
	
}
sub do_roles
{
  my ($action,$urole) = @_;

  @roles = (
   "S=Summarize articles",
   "s=Section Editor",
   "d=Dictionary Editor",
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
  my $selected;
  
  foreach $role_expanded(@roles) {
     my($role,$descr) = split(/=/,$role_expanded,2);
     
     if($action eq 'email') {
     	if($urole =~ /$role/) {
     	   $selected = ' x ';
     	}
     	else {
     	   $selected = '   ';
     	}
        if($roles_expanded) {
           $roles_expanded = "$roles_expanded\n$selected$role_expanded;";
        }
        else {
           $roles_expanded = "\n$selected$role_expanded;"; 
        }   #end_ifelse  	 	
     } #endif    	
  } #end foreach

  return $roles_expanded if($action eq 'email');
}

sub get_role
{
 my $roles = $_[0];
 my @roles = split(/;/,$roles);
 my $xrole;
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

sub print_user_name
{
 my($userid,$usertype) = @_;
 if($userid) {
	my $uid = &get_user_uid($userid);   # in user.pl
    my($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)  
         = &get_editor_row($uid);
    &print_output($printmode, "$usertype: $ufirstname $umiddle $ulastname<br>\n") if($ulastname or $ufirstname or $umiddle);
 }
}

sub get_summarizer_name_not_used
{
 my $sumAcctnum = $_[0];
 if($sumAcctnum) {
   ($userdata, $uaccess) = &read_contributors(N,N,_,_,$sumAcctnum,98989) ; 
   &print_output($printmode, " ..Summarizer: $ufirstname $ulastname") if($userdata =~ /GOOD/);
 }
}


sub get_suggestor_name_not_used
{
 my $suggestAcctnum = $_[0];
 if($suggestAcctnum) {
   ($userdata, $uaccess) = &read_contributors(N,N,_,_,$suggestAcctnum,98989); ## args=print?, html file?, handle, email, acct# 
   &print_output($printmode, " .. Suggester: $ufirstname $ulastname") if($userdata =~ /GOOD/);
 }
}


sub store_editor
{
   my ($status,$uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = @_;

  $e_created_on = &get_nowdate if($status eq 'new' and !$e_created_on);

  &DB_write_editor("",$status,$uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)
      if($DB_users > 0);
	
   &write_editor_flatfile($uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
}


sub write_editor_flatfile    ###### TODO: change this to read old file and insert new before end;
{                 
 my($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = @_;
 
 &backup_setup_flatfile($editorpath,$editorsbkppath,$editors_orig);  # in common.pl

 open(EDITORS, ">>$editorspath");
 for ($editoridx = 0; $editoridx < $EDITORSIZE; $editoridx++) {
	my $found = 'N';
	my $line = $EDITORARRAY[$editoridx];
	unless($line) {
		print "ed520 line is empty<br>\n";
		close(EDITORS);
		exit;
	}
	my ($lineuid,$rest) = split(/^/,$line);
	if($lineuid == $e_uid) {
		 print EDITORS "$e_uid^$uaccess^$ulastname^$ufirstname^$umiddle^$uaddr^$ucity^$ustate^$uzip^$uphone^$urole^$upay^$upermissions^$ucomment^$e_created_on\n";  # update this line
		 $found = 'Y';
	}
	else {
 	   print EDITORS "$line\n";
    }
 }
 print EDITORS "$e_uid^$uaccess^$ulastname^$ufirstname^$umiddle^$uaddr^$ucity^$ustate^$uzip^$uphone^$urole^$upay^$upermissions^$ucomment^$e_created_on\n" unless($found eq 'Y');
 print EDITORS "$editors_eofline\n";
 close(EDITORS);
}


sub DB_write_editor
{
 my($sth,$status,$e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = @_;

  unless($sth) {
    $sth = &DB_prepare_editor_insert($DBH) if($status eq 'new');
    $sth = &DB_prepare_editor_update($DBH) if($status eq 'old');
  }
  $sth->execute($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)
     if($status eq 'new');
  $sth->execute($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on,$e_uid)
     if($status eq 'old');

   $sth->finish();
}

sub DB_print_editors
{
  my $uCount = 0;

  my $sth = $DBH->prepare("SELECT e.e_uid,e.lastname,e.ufirstname,e.umiddle,u.uhandle,u.uemail,e.uaddr,e.ucity,e.ustate,e.uzip,e.uphone,e.urole,e.upay,e.upermissions,'substr(e.ucomment,1,20)',e.e_created_on FROM editors as e, users as u WHERE e.c_uid = u.uid ORDER BY 'cast(u.uid as unsigned)'");
  $sth->execute();

  while (my ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uhandle,$uemail,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) 
     = $sth->fetchrow_array()) {
	      &print_editor($uCount,$e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
	      $uCount = $uCount + 1;
  }
  $sth->finish;
  print "</td></table><br>\n";
  return($uCount,"");
}

sub print_editor
{
 my($sth,$e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = @_;

 if($uCount < 2) {	
    print "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    my $mod = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print  "<tr>";
       print  "<td><b>uid</b></td>\n";
       print  "<td><b>uaccess</b></td>\n";
       print  "<td><b>ulastname</b></td>\n";
       print  "<td><b>ufirstname</b></td>\n";
       print  "<td><b>umiddle</b></td>\n";
       print  "<td><b>uaddr</b></td>\n";
       print  "<td><b>ucity</b></td>\n";
       print  "<td><b>ustate</b></td>\n";
       print  "<td><b>uzip</b></td>\n";
       print  "<td><b>uphone</b></td>\n";
       print  "<td><b>urole</b></td>\n";
       print  "<td><b>upay</b></td>\n";
       print  "<td><b>upermissions</b></td>\n";
       print  "<td><b>ucomment</b></td>\n";
       print  "<td><b>created</b></td>\n";
       print  "\n";
    }
 }
 print "<tr>";
 print "<td>$uid&nbsp;</td>\n";
 print "<td>$uaccess&nbsp;</td>\n";
 print "<td>$ulastname&nbsp;</td>\n";
 print "<td>$ufirstname&nbsp;</td>\n";
 print "<td>$umiddle&nbsp;</td>\n";
 print "<td>$uaddr&nbsp;</td>\n";
 print "<td>$ucity&nbsp;</td>\n";
 print "<td>$ustate&nbsp;</td>\n";
 print "<td>$uzip&nbsp;</td>\n";
 print "<td>$uphone&nbsp;</td>\n";
 print "<td>$urole&nbsp;</td>\n";
 print "<td>$upay&nbsp;</td>\n";
 print "<td>$upermissions&nbsp;</td>\n";
 print "<td>$ucomment&nbsp;</td>\n";
 print "<td>$e_created_on&nbsp;</td>\n";
 print "<\tr>";
 print "\n";
}

###         DATABASE SUBROUTINES

sub DB_prepare_editor_insert
{
  my $DBH = $_[0];
  $sql = "INSERT INTO editors (e_uid,uaccess,ulastname,ufirstname,umiddle,uaddr,ucity,ustate,uzip,uphone,urole,upay,upermissions,ucomment,e_created_on) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
  $sth = $DBH->prepare($sql) or die "Couldn't prepare insert statement: " . $sth->errstr;
  return($sth);
}

sub DB_prepare_get_editor_row
{
  my $DBH = $_[0];
  my $sth = $DBH->prepare( 'SELECT uaccess,ulastname,ufirstname,umiddle,uaddr,ucity,uzip,uphone,urole,upay,upermissions,ucomment,e_created_on FROM users where e_uid = ?' );
  return($sth);
}

sub DB_prepare_editor_update
{
  my $DBH = $_[0];
  my $sth = $DBH->prepare( "UPDATE editors SET uaccess = ?,ulastname = ?,ufirstname = ?,umiddle = ?,uaddr = ?,ucity = ?,ustate = ?,uzip = ?,uphone = ?,urole = ?,upay = ?,upermissions = ?,ucomment = ?,e_created_on = ? WHERE e_uid = ?");
  return($sth);
}

sub DB_prepare_select_editors_list
{
 my $sth = $DBH->prepare("SELECT * FROM editors ORDER BY 'cast(e_uid as unsigned)'");
 return($sth);
}


sub DB_update_editor
{
 my($sth,$e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_updated_on,$e_created_on) = $_[0];
 $sth->execute($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on,$e_uid);
}


sub DB_set_editor_lastactivity      #TODO --- > need to set this in docitem.pl when logging a volunteer
{
  my ($DBH,$userid) = @_;
  my $uid = &get_user_uid($userid);
  $sql = "UPDATE user SET ulastdate = CURDATE()) WHERE uid = '" . $uid . "'";
  $DBH->do($sql);
}


sub DB_get_editor_row     ## Get one row only
{
 my($uid,$sth) = @_;      ## 13 variables plus e_uid
 $sth->execute($uid);
 ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on) = $sth->fetchrow_array();
 $sth->finish();
 return($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
}


sub import_editors   # every time after the first successful import   ---- FIRST TIME IS IN USERS - ALL 3 TABLES DONE AT THE SAME TIME
{ 
  $DBH = &db_connect() unless($DBH);

  &create_editor_table($DBH);   # Drops table

  my $sth = &DB_prepare_editor_insert($DBH);

  my $editorspath = "$controlpath/editors.html";
  print "<b>Import editors from editors flatfile</b> ..editorspath $editorspath<br>\n";

  open(EDITORS, "$editorspath") or die("Can't open editors table/file $editorspath");
  while(<EDITORS>)
  {
	 chomp;
	 $uline = $_;     ## 14 variables
     my($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)	 
          = split_editor($uline);
     last if($e_uid == 0);
     print "$e_uid^$uaccess^$ulastname<br>\n";
     &DB_write_editor($sth,'new',$e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on);
  }
  $sth->finish;

  close(EDITORS);
}


sub export_editors
{
  my $DBH = &db_connect();

  print "<b>Export editors to editors flatfile</b> ..editorsspath $editorspath<br>\n";

  &backup_setup_flatfile($editorspath,$editorsbkppath,$editors_orig);  # in common.pl

  my $sth = &DB_prepare_select_editors_list($DBH);

  $sth->execute();

  open(EDITORS, ">>$editorspath");  
  while (my ($e_uid,$uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$urole,$upay,$upermissions,$ucomment,$e_created_on)
    = $sth->fetchrow_array()) {
      print EDITORS "$e_uid^$uaccess^$ulastname^$ufirstname^$umiddle^$uaddr^$ucity^$ustate^$uzip^$uphone^$urole^$upay^$upermissions^$ucomment^$e_created_on\n";
      print "$e_uid^$uaccess^$ulastname^$ufirstname^$umiddle^$uaddr^$ucity^$ustate^$uzip^$uphone^$urole^$upay^$upermissions^$ucomment^$e_created_on<br>\n";
  }
  print EDITORS "$contrib_eofline\n";   ## signifies last row
  close(EDITORS);
}


sub create_editor_table
{
  my $DBH = &db_connect();

  $DBH->do("DROP TABLE editors");

  print "EDITOR table dropped<br>\n";

  my $EDITOR_SQL = <<ENDEDITOR1;
CREATE TABLE editors (
  e_uid          smallint NOT NULL,
  uaccess        varchar(1)   NOT NULL DEFAULT 'P',
  ulastname      varchar(30)  DEFAULT '',
  ufirstname     varchar(30)  DEFAULT '',
  umiddle        varchar(2)   DEFAULT '',
  uaddr          varchar(32)  DEFAULT '',
  ucity          varchar(32)  DEFAULT '',
  ustate         varchar(2)   DEFAULT '',
  uzip           varchar(10)  DEFAULT '',
  uphone         varchar(35)  DEFAULT '',
  urole          varchar(4)   DEFAULT '',
  upay           decimal(5,2) DEFAULT 0.00,
  upermissions   varchar(60)  DEFAULT '',
  ucomment       varchar(300) DEFAULT '',
  e_created_on   date         DEFAULT '19970101');
ENDEDITOR1

$DBH->do($EDITOR_SQL);

print "EDITOR table created<br>\n";
}


1;