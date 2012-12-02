#!/usr/bin/perl --

# Oct 20, 2012   
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
  $footer_template = "plainEnd";
  &clear_users;
  $usersbkppath    = "$bkpcontrolpath/users.html";
  $userspath       = "$controlpath/users.html";
  $users_orig      = "";   #original file is in contributors.html
  $eofline = "0^^^^^^^";

  $dbh = &db_connect() unless($dbh);
  ($usersize,$uidmax) = &read_users_to_array;
  $USER{'uidmax'}   = $uidmax;    ###### WE COULD STORE THIS VALUE IN A FLATFILE like doccount in case database is down. This could be stored when we do a DB add.
  $USER{'usersize'} = $usersize;
}

sub clear_users {
  %USERINDEX    = {};
  %USERemINDEX  = {};
  %USERidINDEX  = {};
  @USERARRAY    = ();
  %USERhandleINDEX = {};
  $uid       = 0;
  $userid    = "";
  $upin      = "";
  $uemail    = "";
  $uapproved = 0;
  $uhandle   = "";
  $ulastdate = "";
}

sub read_users_to_array
{	
 my $usersize = 0;
 my $uidmax = 0;
 if($DB_users eq 1) {
	  ($usersize,$uidmax) = &DB_get_users_2array;
  }
  else {
	  ($usersize,$uidmax) = &flatfile_get_users_2array;
  }
  return($usersize,$uidmax)
}

sub flatfile_get_users_2array
{
   my $useridx = 0;
   my $uidmax = 0;
   $lock_file = "$userspath.busy";
   open(USERS, "$userspath");
   while(<USERS>) {
      chomp;
      my $uline = $_;  
      my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = split_user($uline);
      &set_array_values($useridx,$userid,$uemail,$uid,$uhandle,$uline);
      $useridx = $useridx + 1;
      $uidmax = $uid if($uid > $uidmax);
    }
    close(USERS);
    unlink "$lock_file";
    return($useridx,$uidmax);
}

sub DB_get_users_2array
{
  my $sth = &DB_prepare_select_users_list;
#  my $sth = $dbh->prepare("SELECT * FROM users ORDER BY 'cast(uid as unsigned)'");
  $sth->execute();

  my $useridx = 0;
  my $uidmax = 0;
  while (my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = $sth->fetchrow_array()) {
	  my $uline = "$uid^$userid^$upin^$uemail^$uapproved^$uhandle^$ulastdate"; 
      &set_array_values($useridx,$userid,$uemail,$uid,$uhandle,$uline);
      $useridx = $useridx + 1;
      $uidmax = $uid if($uid > $uidmax);
  }
  $sth->finish;	
  return($useridx,$uidmax);
}

sub set_array_values
{
	my($useridx,$userid,$uemail,$uid,$uhandle,$line) = @_;
    $USERINDEX{$userid}    = $uid;
    $USERemINDEX{$uemail}  = $line;
    $USERidINDEX{$uid}     = $line;
    $USERhandleINDEX{$uhandle} = 'Y';
    $USERARRAY[$useridx]   = $line;	
}


sub get_user_row {
	my $uid = $_[0];
	my $urow = $USERidINDEX{$uid};
	my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = split_user($urow);
	return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);		
}

sub get_user_row_userid {
	my $userid = $_[0];
	my $uid = $USERINDEX{$userid};
	my $urow = $USERidINDEX{$uid};
	my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = split_user($urow);
	return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);		
}

sub get_user_uid {
	my $userid = $_[0];
	my $uid = $USERINDEX{$userid};
	return($uid);		
}

sub get_user_email_handle($uid) {
	my $uid = $_[0];
    $uline = $USERidINDEX{$uid};
	my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) 
	   = split(/^/,$urow,8);
	return($uemail,$uhandle);
}

sub check_user
{ 	
   my($ckuserid,$ckpin,$access_name) = @_;
   if($ckuserid =~ /^\+/) {
      my $user_visable = 'Y';
      ($rest,$ckuserid) = split(/\+/,$ckuserid,2);
   }
   else {
      my $user_visable = 'N';
   }

  if($ckuserid !~ /[A-Za-z0-9]{2}/ or $ckuserid =~ /Userid/ or $ckpin !~ /[A-Za-z0-9]{2}/) {
      &printUserMsgExit("You must supply a userid and password, or, if you do not have one, you must register.<br /> Hit your BACK button to correct.");
      exit;
  }

 my ($userdata,$uid) = &validate_users($ckuserid,"","",$ckpin);
 if($userdata =~ /BAD/) {
      &printUserMsgExit("Sorry. The userID ($ckuserid) or password you gave is not valid.<br />Hit your BACK button to correct.  ...usr292");
      exit;
 }
 elsif($access_name eq 'uid') {
     return($uid);
 }
 elsif($access_name eq 'access') {
	 my($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$upayrole,$upermissions,$ucomment,$ulastdate)
	     = &get_editor_row($uid);   #in editor.pl
     return($userdata,$uaccess,$upermissions,$user_visable);
 }	  
 elsif($access_name eq 'name') {
	 my($uaccess,$ulastname,$ufirstname,$umiddle,$uaddr,$ucity,$ustate,$uzip,$uphone,$upayrole,$upermissions,$ucomment,$ulastdate)
	     = &get_editor_row($uid);   #in editor.pl
     return($userdata,$ulastname,$ufirstname,$umiddle,$uid);
 }
}


sub validate_users
{ 
 my($ckuserid,$ckuid,$ckemail,$ckpin,$ckhandle) = @_;
 my $line;
 my $userdata = "";
 my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);

 if($ckuserid and $USERINDEX{$ckuserid}) {
	$uid =  $USERINDEX{$ckuserid};
	$line = $USERidINDEX{$uid};
	($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = &split_user($line) if($line);
	$userdata = 'SAMEID' if($ckuserid eq $userid);
	$userdata = "$userdata;PINOK" if(($ckpin and $ckpin =~ /$upin/) or $ckpin =~ /98989/);
	$userdata = "$userdata;SAMEEMAIL" if(($ckemail and $uemail) and ($ckemail =~ /$uemail/ or $uemail =~ /$ckemail/));
 }
 elsif($ckemail and $USERemINDEX{$chkuemail}) {
   	$line = $USERemINDEX{$chkuemail};
	($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = &split_user($line) if($line);
    $userdata = 'SAMEEMAIL' if($chkemail =~ /$uemail/ or $uemail =~ /$chkemail/);
 }
 elsif($ckuid and $USERidINDEX{$ckuid}) {
   	$line = $USERidINDEX{$chkuid};
	($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = &split_user($line) if($line);
    $userdata = 'SAMEUID' if($ckuid eq $uid);
 }
 elsif($ckhandle and $USERhandleINDEX{$ckhandle}) {
     $userdata = 'SAMEHANDLE';
 }
return ($userdata,$uid);
}


sub print_volunteer_app   ## ONLINE at article.pl?display%app%
{
 my ($op_access,$uid,$form) = @_;
 if($uid > 0) {
	my $cmd = "update_app";
	&get_put_user_to_docarray;

    &get_put_editor_to_docarray;   # in editor.pl
 
    &get_put_contributor_to_docarray;  # in contribuotr.pl
 }
 else {
    my $cmd = "start_acctapp";	
 }
 $DOCARRAY{'cmd'}  = $cmd;
 $DOCARRAY{'form'} = $form;

 $print_it = 'Y';
 &process_template('app','Y','N','N');  #in template_ctrl.pl
 $aTemplate = $qTemplate;
 $print_it = 'N';
}

sub get_put_user_to_docarray
{
   my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate)
     = &get_user_row($uid);
   &put_user_to_docarray($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
}

sub get_user_form_values
{
  my $uid        = $FORM{'uid'};
    ($uid,$rest) = split(/;/,$uid);
 my $userid     = $FORM{'userid'};
  my $upin       = $FORM{'upin'};
  my $uemail     = $FORM{'uemail'};
  my $uapproved  = $FORM{'uapproved'};
     $uapproved  = 0 unless($uapproved == 1);
  my $uhandle    = $FORM{'uhandle'};
  my $ulastdate  = $FORM{'ulastdate'};
     $ulastdate =  &get_nowdate unless($ulastdate);
  my $opax      = $FORM{'opax'};   #operator _access
  return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate,$opax);
}

sub put_user_to_docarray {
	($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = @_;
	$DOCARRAY{'uid'}       = $uid;
	$DOCARRAY{'userid'}    = $userid;
	$DOCARRAY{'upin'}      = $upin;
	$DOCARRAY{'uemail'}    = $uemail; 
	$DOCARRAY{'uapproved'} = $uapproved;
	$DOCARRAY{'uhandle'}   = $uhandle;
	$DOCARRAY{'ulastdate'} = $ulastdate;	
}

sub split_user
{
 my $line = $_[0];

 my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate)
     = split(/\^/,$line,7);
  return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
}

sub DB_print_users
{
  my $uCount = 0;

  my $sth = &DB_prepare_select_users_list;
  $sth->execute();

  my $uCount = 0;
  while (my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) 
     = $sth->fetchrow_array()) {
	      &print_editor($uCount,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
	      $uCount = $uCount + 1;
  }
  $sth->finish;
  print "</td></table><br>\n";
  return($uCount,"");
}

sub print_user
{
 my($uid,$userid,$upin,$uemail,$uapproved,$ulastdate) = @_;
 if($uCount < 2) {	
    print "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    my($mod) = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print  "<tr>";
       print  "<td><b>uid</b></td>\n";
       print  "<td><b>userid</b></td>\n";
       print  "<td><b>pin</b></td>\n";
       print  "<td><b>useremail</b></td>\n";
       print  "<td><b>uapproved</b></td>\n";
       print  "<td><b>uhandle</b></td>\n";
       print  "<td><b>lastdate</b></td>\n";
       print  "\n";
    }
 }
 print "<tr>";
 print "<td>$uid&nbsp;</td>\n";
 print "<td>$userid&nbsp;</td>\n";
 print "<td>$upin&nbsp;</td>\n";
 print "<td>$uemail&nbsp;</td>\n";
 print "<td>$uapproved&nbsp;</td>\n";
 print "<td>$uhandle&nbsp;</td>\n";
 print "<td>$lastdate&nbsp;</td>\n";
 print "<\tr>";
 print "\n";
}

sub store_user
{
   my ($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = @_;

   $ulastdate = &get_nowdate unless($ulastdate);

   $uid = &DB_write_user($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate)
      if($DB_users > 0);
	
   $uid = $USER{'uidmax'} + 1 unless($uid and $uid > 0 and $DB_users > 0);
   &write_user_flatfile($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
   return($uid);
}


sub write_user_flatfile
{
 my ($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = @_;
 $uid = $uidmax + 1 unless($uid);

 &backup_setup_flatfile($userspath,$usersbkppath,$users_orig);  # in common.pl

 open(USERS, ">>$userspath");

 for ($useridx = 0; $useridx <= $usersize; $useridx++) {
	my $found = 'N';
	my $line = $USERARRAY[$useridx];
	my ($lineuid,$rest) = split(/^/,$line);
	if($lineuid == $uid) {
		 print USERS "$uid^$userid^$upin^$uemail^$uapproved^$uhandle^$ulastdate\n";  # update this line
		 $found = 'Y';
	}
	else {
 	   print USERS "$line\n";
    }
 }
 print USERS "$uid^$userid^$upin^$uemail^$uapproved^$uhandle^$ulastdate\n" unless($found eq 'Y');
 print USERS "$eofline\n";          # EOF indicator
 close(USERS);
}


sub DB_write_user
{
   my($status,$uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = @_;
   my $sth;

   if($status eq 'new') {
	   $sth = $dbh->prepare( "INSERT INTO users (userid,upin,uemail,uapproved,uhandle,ulastdate) VALUES ( ?, ?, ?, ?, ?, ?)" );
	   $sth->execute($userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
	   $uid = $dbh->{mysql_insertid};
#	   $uid = $dbh->last_insert_id("", "", "users", "") or die("last_insert_id failed"); 
   }
   else {
	  $sth = $dbh->prepare( "UPDATE users SET userid = ?, upin = ?, uemail = ?, uapproved = ?, uhandle = ?, ulastdate = CURDATE() WHERE uid = ?");
	  $sth->execute($userid,$upin,$uemail,$uapproved,$uhandle,$uid);
   }
   $sth->finish();
   return($uid);
}


sub DB_write_new_user_not_used
{
 my($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = @_;
 my $sth_usr = $dbh->prepare( "INSERT INTO users (userid,upin,uemail,uapproved,uhandle,ulastdate) VALUES ( ?, ?, ?, ?, ?, ?)" );
 $sth_usr->execute($userid,$upin,$uemail,$uapproved,$ulastdate);
 $sth_usr->finish();
}


sub DB_update_user_not_used
{
 my($uid,$userid,$upin,$uemail,$uapproved,$ulastdate) = @_;
 my $sth_usr = $dbh->prepare( "UPDATE users SET userid = ?, upin = ?, uemail = ?, uapproved = ?, uhandle = ?, ulastdate = CURDATE()) WHERE uid = ?");
 $sth_usr->execute($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
 $sth_usr->finish();
}

sub check_user_exists
{                  # called from editors.pl
 my $uid = $_[0];
my $line = $USERidINDEX{$uid};    
    if($uid and $uid != 0 and $USERidINDEX{$uid}) {
        return('old');      # return status 
    }
    else {
	    return('new');
    }
}

sub DB_get_userinfo_w_uid     ########### WHY ARE THERE TWO IDENTICAL SUB ROUTINES?
{
 my($uid) = $_[0];
 my $sth_usr = $dbh->prepare( 'SELECT uid,userid,upin,uemail,uapproved,uhandle,ulastdate FROM users where userid = ?' );
 $sth_usr->execute($uid);
 ($userid,$upin,$uemail,$uapproved,$ulastdate) = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
}

sub DB_get_userinfo  
{
 my($userid) = $_[0];
 my $sth_usr = $dbh->prepare( 'SELECT uid,userid,upin,uemail,uapproved,uhandle,ulastdate FROM users where userid = ?' );
 $sth_usr->execute($userid);
 ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
}

sub get_user_uid
{
  my($userid) = $_[0];
  my $uline = $USERidINDEX{$uid};
  my($uid,$rest) = split(/^/,$uline,2) if($uline);
  $uid = &DB_get_uid($userid) unless($uid);
  return($uid);
}

sub DB_get_uid  
{
 my($userid) = $_[0];
 my $uid = 0;
 my $sth_usr = $dbh->prepare( 'SELECT uid FROM users where userid = ?' );
 $sth_usr->execute($userid);
 $uid = $sth_usr->fetchrow_array();
 $sth_usr->finish();
 return($uid);
}

sub DB_prepare_select_users_list
{
 my $sth = $dbh->prepare("SELECT * FROM users ORDER BY 'cast(uid as unsigned)'");
 return($sth);
}

sub import_users     # every time after the first successful import
{ 
  $dbh = &db_connect() if(!$dbh);

  &create_user_table_2nd_import($dbh);

  my $sth = $dbh->prepare( "INSERT INTO users (uid,userid,upin,uemail,uapproved,uhandle,ulastdate) VALUES ( ?, ?, ?, ?, ?, ?, ?)" );

  my $userspath = "$controlpath/users.html";
  print "<b>Import users from users</b> ..userspath $userspath<br>\n";

  open(USERS, "$userspath") or die("Can't open users table/file");
  while(<USERS>)
  {
	 chomp;
	 my $line = $_;     
	 my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate) = split(/\^/,$line,7);
 
     last if($uid == 0);

     print "$line<br>\n";

	 $sth->execute($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate);
  }
  $sth->finish;

  close(USERS);

  &alter_user_table_after_import($dbh);

  &import_editors($dbh);

  &import_contributors($dbh);

  $dbh->disconnect or warn "Disconnection failed: $DBI::errstr\n";
}


sub export_users
{
  $dbh = &db_connect() unless($dbh);

  my $usersbkppath     = "$bkpcontrolpath/users.html";
  my $userspath        = "$controlpath/users.html";

  &backup_setup_flatfile($userspath,$usersbkppath,$users_orig);  # in common.pl

  print "<b>Export users to users</b> ..userspath $userspath<br>\n";

  my $sth = &DB_prepare_select_users_list;

  $sth->execute();

  open(USERS, ">>$userspath");

  while (my ($uid,$userid,$upin,$uemail,$uapproved,$uhandle,$ulastdate)
    = $sth->fetchrow_array()) {
  
     print "$uid^$userid^$upin^$uemail^$uapproved^$uhandle^$ulastdate<br>\n";
     print USERS "$uid^$userid^$upin^$uemail^$uapproved^$uhandle^$ulastdate\n";
  }
  print USERS "0^^^^^^\n";
  close(USERS);
}


sub create_user_table_1st_import                         
{
 $dbh = &db_connect() unless($dbh);
 $dbh->do("DROP TABLE users");
print "USER table dropped<br>\n";
          
 $USER_SQL = <<ENDUSER1;
CREATE TABLE users (
  uid       smallint     NOT NULL AUTO_INCREMENT,
  userid    varchar(15)  DEFAULT '',
  upin      varchar(15)  DEFAULT '',
  uemail    varchar(100) DEFAULT '',
  uapproved tinyint      NOT NULL DEFAULT '0',
  uhandle   varchar(6)   DEFAULT '',   
  ulastdate date         NOT NULL default '19970101',
  PRIMARY KEY (uid));
ENDUSER1

  $dbh->do($USER_SQL);

print "USER table created<br>\n";
}


sub create_user_table_2nd_import                         
{
 $dbh = &db_connect() unless($dbh);
 $dbh->do("DROP TABLE users");
print "USER table dropped<br>\n";
          
my $USER_SQL = <<ENDUSER2;
CREATE TABLE users (
  uid       smallint     NOT NULL,
  userid    varchar(15)  DEFAULT '',
  upin      varchar(15)  DEFAULT '',
  uemail    varchar(100) DEFAULT '',
  uapproved tinyint      NOT NULL DEFAULT 0,
  uhandle   varchar(6)   DEFAULT '',   
  ulastdate date         NOT NULL default '19970101');
ENDUSER2

$dbh->do($USER_SQL);
}

sub alter_user_table_after_import
{
 $dbh = &db_connect() unless($dbh);
 $dbh->do("ALTER TABLE users ADD PRIMARY KEY(uid);");
 $dbh->do("ALTER TABLE users MODIFY COLUMN uid SMALLINT NOT NULL AUTO_INCREMENT;");	
}

sub import_users_first_time     ## IMPORTS TO users, editors, and contributors the first time.
{ 
  $dbh = &db_connect() if(!$dbh);

  &create_user_table_1st_import($dbh);
  &create_editor_table($dbh);  # Drops and re-creates
  &create_contributor_table($dbh);  # Drops and re-creates

  my $usr_sth         = $dbh->prepare( "INSERT INTO users (userid,upin,uemail,uapproved,uhandle,ulastdate) VALUES ( ?, ?, ?, ?, ?, ?)" );
  my $editor_sth      = &DB_prepare_editor_insert;
  my $contributor_sth = &DB_prepare_contributor_insert;

  my $contributorspath = "$controlpath/contributors.html";
 print "<b>Import users from contributors</b> ..contributorspath $contributorspath<br>\n";

  open(CONTRIBUTORS, "$contributorspath") or die("Can't open users table/file at $contributorspath");
  while(<CONTRIBUTORS>)
  {
	 chomp;
	 $uline = $_;     
	 my ($uaccess,$userid,$pin,$ulastdate,$lastname,$firstname,$middle,$addr,$city,$state,$zip,$phone,$email,$payrole,$handle,$permissions,
		   $usercomment,$ublanks,$useparator,$ulocsep,$uskipon,$uskipoff,$uskip,$uempty,$udateloc,$udateformat, 
		   $uheadlineloc,$usourceloc,$usinglelinefeeds,$uend)
		     = split(/\^/,$uline,30);
		
	print "uaccess $uaccess ..userid $userid ..upin $upin ..lastname $lastname .. firstname $firstname ..handle $handle<br>\n";  
    my $uapproved = 1;

	unless ($userid =~ /endID/) {
	    $usr_sth->execute($userid,$pin,$email,$uapproved,$handle,$ulastdate);
	
	    $uid = &DB_get_uid($userid);

	    $contributor_sth->execute($uid,$ublanks,$useparator,$ulocsep,$uskipon,$uskipoff,$uskip,$uempty,$udateloc,$udateformat,$uheadlineloc,$usourceloc,$usinglelinefeeds,$uend,$ulastdate)
		    if($ublanks or $useparator or $ulocsep or $uskipon or $uskipoff or $uskip or $udateloc or $udateformat or $uheadlineloc or $usourceloc or $usinglelinefeeds or $uend);
        
        $editor_sth->execute($uid,$uaccess,$lastname,$firstname,$middle,$addr,$city,$state,$zip,$phone,$payrole,$permissions,$usercomment,$ulastdate)
            if($uaccess or $lastname or $firstname);
	}
  }
  $usr_sth->finish;
  $editor_sth->finish;
  $contributor_sth>finish;

  close(CONTRIBUTORS);
}


1;