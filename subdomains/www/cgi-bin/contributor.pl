#!/usr/bin/perl --

# Oct 20, 2012
#        contributor.pl


sub init_contributors
{        #from article.pl
  $print_contributors = 'N';
  $header_template = "plain_top";
  $footer_template = "plainEnd";
  &clear_contributor_values;
  $header_template = "plain_top";
  $footer_template = "plainEnd";
  $contributors_path     = "$controlpath/contributors.html";
  $contributors_bkppath  = "$bkpcontrolpath/contributors_bkp.html"; 
  $contributor_orig      = "$controlpath/contributors.orig";  #save original file for contributors, editors, and editors - must preserve
  &read_contributors_to_array;  #in users.pl - needed to get index by handle
  
  $contrib_eofline = "0^^^^^^^^^^^^^";
}


sub clear_contributor_values
{
  $CONTRIBSIZE  = 0;
  %CONTRIBINDEX = {};
  @CONTRIBARRAY = ();
  $c_uid         = 0;
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
  $uSingleLineFeeds = "";
  $uEnd          = "";
  return;
}

sub read_contributors_to_array
{
 if($DB_users > 0) {
	 $CONTRIBSIZE = &DB_get_contributors_2array;
  }
  else {
	 $CONTRIBSIZE = &flatfile_get_contributors_2array;
  }
}

sub flatfile_get_contributors_2array
{
  my $contrib_idx = 0;
  my $lock_file = "$contributors_path.busy";
  open(CONTRIBUTORS, "$contributors_path") or die("Can't open contributors flatfile");
  while(<CONTRIBUTORS>)
  {
	  chomp;
	  my $line = $_;     
	  my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
		     = &split_contributor($line);
	  last if($c_uid == 0);
	  $uhandle = $USERhandleINDEX{$c_uid};
	  $CONTRIBINDEX{$c_uid}       = $line;
	  $CONTRIBhandleUID{$uhandle} = $c_uid;
	  $CONTRIBARRAY[$contrib_idx] = $line;
	  $contrib_idx = $contrib_idx + 1;
  }
  close(CONTRIBUTORS);
  unlink "$lock_file";
  return($contrib_idx);
}

sub DB_get_contributors_2array
{
  my $contrib_idx = 0;

  my $sth = &DB_prepare_select_contributors_list;

  $sth->execute();

  while (my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) 
     = $sth->fetchrow_array()) {
	  my $line = "$c_uid^$uBlanks^$uSeparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$c_created_on";

	  $uhandle = $USERhandleINDEX{$c_uid};
	  $CONTRIBINDEX{$c_uid}      = $line;
	  $CONTRIBhandleUID{$uhandle}   = $c_uid;
	  $CONTRIBARRAY[$contrib_idx]   = $line;
	  $contrib_idx = $contrib_idx + 1;
  }
  $sth->finish;	
  return($contrib_idx);
}

sub get_put_contributor_to_docarray 
{
	my($uBlanks,$uSeparator,$uLocsep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd)
	      = &get_contributor_row($uid);
	&put_contributor_to_docarray($uBlanks,$uSeparator,$uLocsep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd);       # in editors.pl
}


sub get_contributor_row {
	my $uid = $_[0];	
	my $row = $CONTRIBINDEX{$uid};
	my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
	   = split_contributor($CONTRIBINDEX{$uid});
	return($uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);		
}

sub get_contributor_row_handle {     ### WILL WE USE THIS????
	my $handle = $_[0];
	my $row = $CONTRIBhandleINDEX{$uhandle};
	my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
	   = split_contributor($row);
	return($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);		
}


sub split_contributor  # from email2docitem.pl --- change name to get_contributor_parameters
{	             
  $line = $_[0];
  ($c_uid,$uBlanks,$useparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
     = split(/\^/,$line,15);
   return($c_uid,$uBlanks,$useparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd);
}


sub check_contributor   #from email2docitem.pl
{
  my($ehandle,$fromemail) = @_;

  my($userResults,$contrib_row) = &read_contributors('N',$ehandle,$fromemail);

  my($c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on) = split(/^/,$contrib_row,17);
	
  if($userResults = "MATCH") {
  }
  else {              # set defauults if none of the above
	  $handle      = 'unk';
	  $uLocSep    = 'first';
	  $uSeparator = '#####';
	  $uBlanks    = '0';
	  $uSkipon    = '%NA';
	  $uSkipoff   = '%NA';
	  $uSkip      = '@#&#%%@';
	  $uEnd = "text\/html|text/html";
  }

  unless($uSkip) {
       if($uSeparator =~ /#####/) {
	       $uSkip      = '#####';
	   }
	   else {
		   $uSkip      = '%NA';
	   }
  }
  $uStart  = $uSkipoff;  # rename
  $uStop   = $uEnd;

  ($srcloc,$srckey,$srcpart,$srcsep) = split(/&/,$uSourceloc,4);  # these are not used anywhere
  ($hdloc,$uHdkey,$uHdpart,$uHdsep)  = split(/&/,$uHeadlineloc,4); # only $uHeadkey is used in smartdata.pl
  ($dtloc,$uDtkey,$dtpart,$dtsep)    = split(/&/,$uDateloc,4);        # only $uDtkey is used in smartdata.pl

  ($rest,$c_blank_ct) = split(/=/, $uSeparator, 2) if($uSeparator =~ /blanks/); ## NOT USED??? $c_blank_cnt not found.  ????################
  $uBlanks = $c_blank_ct if($c_blank_ct);

  $uStop = "@#&#%%@" if(!$uStop);  # impossible - but null won't work
  $uSkip = "@#&#%%@" if(!$uSkip);  # impossible - but null won't work
  $uSeparator = "########" if(!$uSeparator);
	
  $CONTRIB_DATA = "$uemail^$uhandle^$uBlanks^$useparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$uStart^$uStop^$uHeadkey^$uDtkey";       # set a global variable to be used in 
  
  return($uhandle);
}



sub read_contributors
{
   my($print_contributors,$ckhandle,$ckemail) = @_;

   if($DB_users eq 1) {
	  if($print_contributors eq 'Y') {
		  my $uCount = &DB_print_contributors;
		  return ($uCount);
	  }
	  else {
	      my($userResults,$contrib_row) = &DB_get_contributor($ckhandle,$ckemail);
      }
   }
   else {
	  my($uline) = &flatfile_read_contributors($print_contributors,$ckhandle,$ckemail);
   }
   return($userResults,$contrib_row);
}

sub get_contributor_values # from email2docitem.pl --- change name to get_contributor_values
{	             
  $uline = $_[0];
 
  ($c_uid,$uBlanks,$useparator,$uLocSep,$uSkipon,
   $uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
     = split_contributor($uline);

#############   IF NOT a clipping service, then there is a pin and we have to set defaults  
   unless($c_uid) {   
   	$uLocSep    = 'first' unless($uLocSep);
   	$uSeparator = '#####' if($uSeparator !~ /[A-Za-z0-9]/  and $uSeparator !~ /.+/);
   	$uBlanks    = '0'     unless($uBlanks);
   	$uSkipon    = '%NA'   unless($uSkipon);
   	$uSkipoff   = '%NA'   unless($uSkipoff);
   	$uEnd       = '%NA'   unless($uEnd);
    unless($uSkip) {
       if($uSeparator =~ /#####/) {
	       $uSkip      = '#####';
	   }
	   else {
		   $uSkip      = '%NA';
	   }
	}
    $uStart  = $uSkipoff;  # rename
    $uStop   = $uEnd;
     
    ($srcloc,$srckey,$srcpart,$srcsep) = split(/&/,$uSourceloc,4);  # these are not used anywhere
    ($hdloc,$uHdkey,$uHdpart,$uHdsep) = split(/&/,$uHeadlineloc,4); # only $uHeadkey is used in smartdata.pl
    ($dtloc,$uDtkey,$dtpart,$dtsep) = split(/&/,$uDateloc,4);        # only $uDtkey is used in smartdata.pl

	($rest,$c_blank_ct) = split(/=/, $uSeparator, 2) if($uSeparator =~ /blanks/);
	$uBlanks = $c_blank_ct if($c_blank_ct);
	$uStop = "@#&#%%@" if(!$uStop);  # impossible - but null won't work
	$uSkip = "@#&#%%@" if(!$uSkip);  # impossible - but null won't work
	$uSeparator = "########" if(!$uSeparator);
	$CONTRIBDATA = "$uBlanks^$useparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$uStart^$uStop^$uHdkey^$uDtkey";
	return($uBlanks,$useparator,$uLocSep,$uSkipon,
	   $uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$uStart,$uStop,$uHdkey,$uDtkey);
}


sub flatfile_read_contributors
{
  my($print_contributors,$ckhandle,$ckemail) = @_;
  
  $uCount = $uCount + 1;
  $lock_file = "$contributors.busy";
##   &waitIfBusy($lock_file, 'lock'); 
  open(CONTRIBUTORS, "$contributors");
  while(<CONTRIBUTORS>) {
      chomp;
      $uLine = $_;     
      $uCount = $uCount + 1;

	  ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on)
	     = split(/\^/,$uLine,15);

	  my($uemail,$uhandle) = &get_user_email_handle($c_uid);   #in user.pl
		
	  $contrib_row = "$uemail^$uhandle^$uBlanks^$useparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd";
	
      if($print_contributors eq 'Y') {
           &print_contributor($uCount,$c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
		   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on);
      }
      else {
	      if($ckuseremail and $ckuseremail =~ /$contrib_row/) {
	         return('EMAILMATCH',$uline);
	      }
	      elsif($ckhandle and $ckhandle =~ /$contrib_row/) {
	         return('HANDLEMATCH',$uline);
	      }
	  }
  }  ## end while
  close(CONTRIBUTORS);
  unlink "$lock_file";
    
  if($print_contributors eq 'Y') {
      print "</td></table><br>\n" ;
      return ($uCount);
  }
  else {
	  return("NOMATCH","");
  }
}


sub DB_get_contributor {
 my($ckhandle,$ckemail) = @_;
  $ckhandle = 'qwxzty' unless($ckhandle);   #If no handle, make match impossible
  $ckemail  = 'qwxzty' unless($ckemail);    #Ditto for email
  my $sth = $dbh->prepare("SELECT c.c_uid,u.uemail,u.uhandle,c.ublanks,c.useparator,c.ulocsep,c.uskipon,c.uskipoff,c.uskip,c.uempty,c.udateloc,c.udateformat,c.uheadlineloc,c.usourceloc,c.usinglelinefeeds,c.uend,c.c_created_on FROM contributors as c, users as u WHERE u.uemail CONTAINS ? or u.uhandle = ?");
  $sth->execute($ckemail,$ckhandle);
  my($c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on) = $sth->fetchrow_array();
  $sth->finish;

  return('MATCH',$c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on) if($c_uid);
  return('NOMATCH') unless($c_uid);
}


sub DB_print_contributors
{
  my $contrib_idx = 0;

  my $sth = $dbh->prepare("SELECT c.c_uid,u.uemail,u.uhandle,c.ublanks,c.useparator,c.ulocsep,c.uskipon,c.uskipoff,c.uskip,c.uempty,c.udateloc,c.udateformat,c.uheadlineloc,c.usourceloc,c.usinglelinefeeds,c.uend,c.c_created_on FROM contributors as c, users as u WHERE c.c_uid = u.uid");
  $sth->execute();

  $sth->execute();
  my $uCount = 0;
  while (my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) 
     = $sth->fetchrow_array()) {
	      &print_contributor($uCount,$c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
		    $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on);
	      $uCount = $uCount + 1;
  }
  $sth->finish;
  print "</td></table><br>\n";
  return($uCount,"");
}


sub print_contributor
{
 my($c_uid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on) = @_;
## to do: parse through 
 if($uCount < 2) {	
    print "<table cellpadding=1 cellspacing=0 border=1><tr>\n";
    my $mod = $uCount % 20;
    if($mod == 0 or $uCount == 1) {
       print  "<tr>";
       print  "<td><font size=1 face=verdana><b>c_uid</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>email</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>handle</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uBlanks</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSeparator</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uLocSep</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkipon</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkipoff</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSkip</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uEmpty</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uDateloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uDateformat</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uHeadlineloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSourceloc</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uSingleLineFeeds</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>uEnd</b></font></td>\n";
       print  "<td><font size=1 face=verdana><b>c_created_on</b></font></td>\n";
       print  "\n";
    }
 }
 print "<tr>";
 print "<td><font size=1 face=verdana>$c_uid&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uemail&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uhandle&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uBlanks&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSeparator&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uLocSep&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkipon&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkipoff&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSkip&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uEmpty&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uDateloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uDateformat&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uHeadlineloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSourceloc&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uSingleLineFeeds&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$uEnd&nbsp;</font></td>\n";
 print "<td><font size=1 face=verdana>$c_created_on&nbsp;</font></td>\n";
 print "\n";
}

sub put_contributor_to_docarray    #used in template_ctrl to marry templates with data
{
	($uBlanks,$useparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd) = @_;
	$DOCARRAY{'ublanks'}          = $uBlanks;
	$DOCARRAY{'useparator'}       = $useparator;
	$DOCARRAY{'ulocsep'}          = $uLocSep;
	$DOCARRAY{'uskipon'}          = $uSkipon;
	$DOCARRAY{'uskipoff'}         = $uSkipoff;
	$DOCARRAY{'uskip'}            = $uSkip;
	$DOCARRAY{'uempty'}           = $uEmpty;
	$DOCARRAY{'udateloc'}         = $uDateloc;
	$DOCARRAY{'udateformat'}      = $uDateformat;
	$$DOCARRAY{'uheadlineloc'}    = $uHeadlineloc;
	$DOCARRAY{'usourceloc'}       = $uSourceloc;
	$DOCARRAY{'usinglelinefeeds'} = $uSingleLineFeeds;
	$DOCARRAY{'uend'}             = $uEnd;
	$DOCARRAY{'c_created_on'}     = $c_created_on;
}


sub get_contributor_form_values
{
  $uBlanks        = $FORM{'ublanks'};
  $uSeparator     = $FORM{'useparator'};
  $uLocSep        = $FORM{'ulocsep'};
  $uSkipon        = $FORM{'uskipon'};
  $uSkipoff       = $FORM{'uskipoff'};
  $uSkip          = $FORM{'uskip'};
  $uEmpty         = $FORM{'uempty'};
  $uDateloc       = $FORM{'udateloc'};
  $uDateformat    = $FORM{'udateformat'};
  $uHeadlineloc   = $FORM{'uheadlineloc'};
  $uSourceloc     = $FORM{'uSourceloc'};
  $uSingleLineFeeds = $FORM{'usinglelinefeeds'};
  $uEnd           = $FORM{'uend'};
  $c_created_on   = $FORM{'c_created_on'};
  $c_created_on   = &get_nowdate unless $c_created_on;
  return($uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);
}

sub store_contributor
{
   my ($status,$uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) = @_;

   $c_created_on = &get_nowdate if($status eq 'new' and !$c_created_on);

   &DB_write_contributor("",$status,$uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
      if($DB_users > 0);
	
   &write_contributor_flatfile($uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);

   return($uid);
}


sub write_contributor_flatfile
{
 my ($uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) = @_;
 my $found = 'N';
 my $c_created_on = $nowdate;

 $uid = $uidmax + 1 unless($uid);

 &backup_setup_flatfile($contributors_path,$contributors_bkppath,$contributors_orig);  # in common.pl

 open(CONTRIBUTORS, ">>$contributors_path");
 for ($contribidx = 0; $contribidx < $CONTRIBSIZE; $contribidx++) {
	my $line = $CONTRIBARRAY[$contribidx];
	unless($line) {
		print "con451 CONTRIBARRAY line is empty<br>\n";
		close(CONTRIBUTORS);
		exit;
	}
	my ($lineuid,$rest) = split(/^/,$line);
	if($lineuid == $uid) {
	     print CONTRIBUTORS "$uid,$uBlanks^$useparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$c_created_on\n";
		 $found = 'Y';
	}
	else {
 	   print CONTRIBUTORS "$line\n";
    }
 }
 print CONTRIBUTORS "$uid^$uBlanks^$useparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$c_created_on\n"
     unless($found eq 'Y');
 print CONTRIBUTORS "$contrib_eofline\n";          # EOF indicator
 close(CONTRIBUTORS);
}

sub DB_write_contributor   ## NOTE: this must be preceeded by a write to the user table for userid, email, and handle
{
  my($sth,$status,$c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) = @_;

  unless($sth) {
    $sth = &DB_prepare_contributor_insert if($status eq 'new');
    $sth = &DB_prepare_contributor_update if($status eq 'old');
  }
  $created_dt = &get_nowdate;   #in date.pl
# c_uid,ublanks,useparator,ulocsep,uskipon,uskipoff,uskip,uempty,udateloc,udateformat,uheadlineloc,usourceloc,usinglelinefeeds,uend,c_created_on
  $sth->execute($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
     if($status eq 'new');  
		
  $sth->execute($uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on,$c_uid)
     if($status eq 'old');    
 }
 $sth->finish();
}


sub DB_contributor_exists
{
  my($c_uid,$c_created_on) = @_;

  my $sth = $dbh->prepare('SELECT COUNT(*) FROM contributors WHERE c_uid = ? and c_created_on = ?') 
	        or die("Couldn't prepare contributor statement: " . $sth->errstr);	
  $sth->execute($c_uid,$c_created_on);
  my @row = $sth->fetchrow_array();
  $sth->finish;
  print "contrib $c_uid exists<br>\n" if($row > 0);
  return($row);
}

sub DB_get_contrib_info_w_uid
{
 my($c_uid) = $_[0];
 my $sth = $dbh->prepare( 'SELECT * FROM users where c_uid = ?' );
 $sth->execute($c_uid);
 ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on) = $sth->fetchrow_array();
 $sth->finish();
 return($uBlanks,$useparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);
}

sub DB_prepare_get_contributor
{
  my $sth = $dbh->prepare( "SELECT c_uid,ublanks,useparator,ulocsep,uskipon,uskipoff,uskip,uempty,udateloc,udateformat,uheadlineloc,usourceloc,usinglelinefeeds,uend,c_created_on FROM contributors where c_uid  = ? and c_created_on = ?" );
  return($sth);	
}

sub DB_prepare_select_contributors_list
{
  my $sth = $dbh->prepare("SELECT * FROM contributors ORDER BY 'cast(c_uid as unsigned)'");
	 return($sth);
#  my $sth = $dbh->prepare( "SELECT c_uid,ublanks,useparator,ulocsep,uskipon,uskipoff,uskip,uempty,udateloc,udateformat,uheadlineloc,usourceloc,usinglelinefeeds,uend,c_created_on FROM contributors where c_uid  = ? and c_created_on = ?" );
  return($sth);	
}


sub DB_prepare_contributor_insert  
{                          #  15 variables
   my $sth = $dbh->prepare( "INSERT INTO contributors (c_uid,ublanks,useparator,ulocsep,uskipon,uskipoff,uskip,uempty,udateloc,udateformat,uheadlineloc,usourceloc,usinglelinefeeds,uend,c_created_on) 
						  VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" );
						
#	$sth = $dbh->prepare("INSERT IGNORE INTO contributor (c_uid,uBlanks,useparator,ulocsep,uskipon,uskipoff,uskip,uempty,udateloc,udateformat,uheadlineloc,usourceloc,usinglelinefeeds,uend,c_created_on) 
#						           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURDATE()");
						
  return($sth);
}

sub DB_prepare_contributor_update 
{   
  my $sth = $dbh->prepare( "UPDATE contributors SET ublanks=?,useparator=?,ulocsep=?,uskipon=?,uskipoff=?,uskip=?,uempty=?,
	udateloc=?,udateformat=?,uheadlineloc=?,usourceloc=?,usinglelinefeeds=?,uend=?,c_created_on=? WHERE c_uid = ?" );
  return($sth);
}

sub import_contributors   ## called from users.pl after users imported
{ 
  $dbh = &db_connect() unless($dbh);

  &create_contributor_table;   # Drops table

  print "<b>Import contributors from contributors flatfile</b> ..contributors_path $contributors_path<br>\n";

  my $sth = &DB_prepare_contributor_insert;

  open(CONTRIBUTORS, "$contributors_path") or die("Can't open contributors flatfile");
  while(<CONTRIBUTORS>)
  {
    chomp;
    my $line = $_;   

    my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
 	     = split(/\^/,$line,15);

     last if($c_uid == 0);

     print "$line";
	  
	 $sth->execute($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on);
  }
  $sth->finish;
  close(CONTRIBUTORS);
}

sub export_contributors
{
  $dbh = &db_connect() unless($dbh);

  my $sth = &DB_prepare_select_contributors_list;

  $sth->execute();

  &backup_setup_flatfile($contributors_path,$contributors_bkppath,$contributor_orig);  # in common.pl

  print "<b>Export contributors to contributors flatfile</b> ..contributors_path $contributors_path<br>\n";

  open(CONTRIBUTORS, ">>$contributors_path");

  while (my ($c_uid,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$c_created_on)
    = $sth->fetchrow_array()) {
	
	 print CONTRIBUTORS "$c_uid^$uBlanks^$uSeparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$c_created_on\n";
	 print "$c_uid^$uBlanks^$uSeparator^$uLocSep^$uSkipon^$uSkipoff^$uSkip^$uEmpty^$uDateloc^$uDateformat^$uHeadlineloc^$uSourceloc^$uSingleLineFeeds^$uEnd^$c_created_on<br>\n";

  }
  print CONTRIBUTORS "$eofline\n";  #flatfile needs and end 

  close(CONTRIBUTORS);
}


sub create_contributor_table
{
 $dbh->do("DROP TABLE contributors");

print "CONTRIBUTOR table dropped<br>\n";
 
 my $CONTRIBUTOR_SQL = <<ENDCONTRIB1;
CREATE TABLE contributors (
  c_uid            smallint NOT NULL,
  ublanks          varchar(1)  DEFAULT '',
  useparator       varchar(20) DEFAULT '',
  ulocsep          varchar(40) DEFAULT '',
  uskipon          varchar(50) DEFAULT '',
  uskipoff         varchar(50) DEFAULT '',
  uskip            varchar(50) DEFAULT '',
  uempty           varchar(15) DEFAULT '',
  udateloc         varchar(40) DEFAULT '',
  udateformat      varchar(40) DEFAULT '',
  uheadlineloc     varchar(40) DEFAULT '',
  usourceloc       varchar(40) DEFAULT '',
  usinglelinefeeds varchar(1)  DEFAULT '',
  uend             varchar(40) DEFAULT '',
  c_created_on     date        DEFAULT '19970101',
  UNIQUE (c_uid));
ENDCONTRIB1

$dbh->do($CONTRIBUTOR_SQL);

print "CONTRIBUTOR table created<br>\n";
}


1;