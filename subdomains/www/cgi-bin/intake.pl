#!/usr/bin/perl

# intake.pl - Handles the intake of articles, including email and via a form: newItemParse

## escape these meta characters:   .^*+?{}()[]\|  and / if using as a delimiter
##  * Match 0 or more times   + Match 1 or more times    ? Match 1 or 0 times

## July 1, 2011 - Splitting into getmail.pl and new version of sepmail.pl (renamed to intake.pl); 
#                 Not doing Feb 22 below

## Feb 22, 2011 - Reduced functionality, moving most into parsemail.pl, due to large file processing resulting in NO results.
##                Now reading one line at a time. Hope this works on ippf

# 2011 Feb 16 - enlarged functionality: found date, subject, ehandle; did weird character conversion to ascii;
#              chopped off excess at top and bottom; added sepmail functionality

# 2010 July 22 - buffer too small; broke into lines while reading in

#*********************************************************************
# DOCUMENTATION -- The winding trail of Email Processing and Selection
#
#  1. article.pl?display_subsection%%%Suggested_emailedItem%%adminUserID - cmd = display_subsection
#      a. Goes to intake.pl &process_popnews_inbox
#          * Takes emails delivered to overpopulation.org/popnews_inbox by getmail.pl (straight copy to email)
#          * Copies to /popnews_bkp; deletes file from popnews_inbox
#          * Eliminates dups
#          * Separates if more than one article in an email (&parse_email)
#          * Puts email in docitem format (&parse_popnews) and writes to popnews_mail
#        ## not anymore  * writes 'docid' (filename=sent date time + senderid) to index at autosubmit/sections/suggested_emailedItem.idx
#
#      a.1 alternatively, an article comes in from a form named newItemParse, which goes from article.pl 
#            to &pass2_separate_email in intake.pl
#          * Separates if more than one article in an email (&parse_email)
#          * Puts email in docitem format (&parse_popnews) and writes to popnews_mail

#      b. Create_html and print selection list of emails (in article.pl)
#            *Does process_doclist, which directs action to process_popnews_list
#            Gets emails from popnews_mail
#            # Not anymore -  Uses doclist (index) = suggested_emailedItem.idx to generate list.
#            <form post="...article.pl"
#            <input name="cmd" value="select_items" type="hidden">
#            <input name="sdocid0001" value="2011-06-29-746-push-1"> #document id = sent date time + senderid
#  2. article.pl - receives 'post' from 1.b, parses the list for selected items
#       a. &select_email - line 284 of selecteditems_crud.pl
#       b. &process_popnews_email($selectdocid) and- in docitem.pl line 363
#            If selected:
#             * if priority = D, skips the rest; deletes mailpath/selectitem file
#             * assigns a new docid
#             * reads in doc data from overpopulation.org/popnews_mail
#             * assigns to section 'suggested_suggestedItem' and writes docid to suggested_suggestedItem.idx
#             * writes docitem to autosubmit/items/$docid.itm
#            If not selected:  (in article.pl)
#              *unlink mailpath/selectitem file (from /popnews_mail)
#      **      Not anymore sub*delete from suggested_suggestedItem.idx
#  3. article.pl prints <meta for article.pl?display_section%%%Suggested_suggestedItem%%
#        to print an select/update form list of all items on 'suggested' index.
#  4. article.pl - receives 'post' from #3, parses the list for selected & updated items
#  5. From there the article usually goes to the Headlines list, where the summarizer picks it; then to the summarized list;
#     then to the NewsDigest_NewsItem list (which is published as the front page of WOA)
#*******************************************************************************

sub process_popnews_inbox {               #called from article.pl
  $line_cnt = 0;      # Only for debugging
  $email_cnt = 0;     # Only for debugging
  $dupck_stack = "";
  $op_filename = "";      # do it here for scope of entire script file
  &set_default_variables;
  &clear_message_variables;   # clears variables, makes them visable
  &clear_sepmail_variables;

#  $idx_insert_sth = &DB_prepare_idx_insert("") if($DB_indexes > 0);   #in indexes table; prepare only once

print "<div style=\"font-size:70%; font-family:verdana\">\n";

  opendir(INBOXDIR, "$inboxpath");  # overpopulation.org/popnews_inbox <- This is where getmail.pl puts it
  my(@popnewsfiles) = grep /^.+\.email$/, readdir(INBOXDIR);
  closedir(INBOXDIR);
#           FIRST PASS

  foreach $inboxfilename (@popnewsfiles) {
     &do_one_email('E',"$inboxfilename","");
  } # end foreach
print "<\/div>\n";
}

sub do_one_email {    #comes here from article.pl for cmd= emailsimulate
 my($ep_type,$arg2,$handle) = @_;
 $fhandle = $handle;
 &clear_message_variables;
 &clear_msgline_variables;

 if($ep_type =~ /E/) {    # 'E' : email
    $inboxfilename = $arg2;
    $inboxfilepath   = "$inboxpath/$inboxfilename";
    $mailbkpfilepath = "$mailbkppath/$inboxfilename";
    ($receiptdate,$rest) = split(/\./,$inboxfilename);
    unless(-f $inboxfilepath and $inboxfile =~ /\.email/) {
  #	   print "Error: File not found @ $inboxfilepath<br>\n";
  #	   return;
    }
	&firstpass_header('E',$inboxfilepath,'');  #extracts $ehandle,$ext,$subject,$sentdatetm,$sentdate,$fromemail,$message - which are globals to this script file
	$op_filename = "$sentdatetm-$ehandle";  # assign a new file name
	if($ext =~ /app/) {       # if volunteer application, copy it to path and go to next file
		   ($filename,$rest) = split(/\./,$inboxfilename);
	  	   $appfilepath = "$mailpath/$filename.app";
		   system "cp $inboxfilepath $appfilepath";
	}
	elsif($ehandle =~ /goog/   # These Google emails are garbage
		     and ($line =~ /\QContent-Transfer-Encoding: base64\E/ or $line =~ /PT09IE/) ) {
		#skip 
	}		
	elsif(&ck_dup_email($op_filename)) {  ## skip this if duplicate
		 # skip
	}
	elsif($ehandle =~ /grist|goog/) {  # These emails have garbage - bypass parsing
		  $headline = $subject;
	      $fullbody = $message;
	      $pubdate = $sentdate;
	      print "<br>**** INBOX $inboxfilename WRITE_EMAIL -> $op_filename grist or goog - BYPASSING parse ..em114<br>\n";
	      &write_doc_item($op_filename,$idx_insert_sth);   #in docitem.pl
	}
    else {  # FINALLY, a normal email	
	                     ## in contributor.pl - puts $uemail, $uhandle, and contributor data into global $CONTRIB_DATA for later reference  	
         &pass2_separate_email($ep_type,"","","",$message,$receiptdate);   # $ep_type,$handle,$pdfline,$sectsubs,$fullbody,receiptdate
    }
 }
 elsif($ep_type =~ /P/) {
	 my $message = $arg2;
	 $message=~ s/\r\n/\n/g;
	 $message=~ s/\n\r/\n/g;
     $message=~ s/\r/\n/g;
     $message=~ s/\n\s/\n\n/g;
	 $receiptdatetm = &calc_date;             #sysdatetm
     $ehandle = "";
     $subject = "";
	              # $ep_type,$handle,$pdfline,$sectsubs,$fullbody,receiptdat
	  &firstpass_header('P',$message,'');
	  $ehandle = $fhandle if($fhandle and (!$ehandle or $ehandle =~ /unk/) );
	  &pass2_separate_email('P',$ehandle,"","",$message,$receiptdatetm);
 } #end elsif ep_type
 elsif($ep_type =~ /PwasP/) {   #simulate email - currently not used
	  $op_filename = "$receiptdate";  # assign a new file name
      $ehandle = "";
      $ext     ="";
      $subject = "";
      $sentdatetm = substr($receiptdate,0,10);
      $message = $fullbody;   #This is wrong? from form = must be passed on
	              # $ep_type,$handle,$pdfline,$sectsubs,$fullbody,receiptdat
	
	  &pass2_separate_email($ep_type,"","","",$fullbody,$receiptdate);		
 } #end elsif ep_type

 system "cp $inboxfilepath $mailbkpfilepath";  #back it up
 unlink $inboxfilepath;  # in any case, delete the input file (inbox)
}


sub firstpass_header {  # Gets email in $buffer or $message, $ehandle, sentdate, subject, frommail
	#   globals to this script file: $buffer, $message, $sentdatetm, $senddate, $ehandle, $date_line, $subject_line, $from_line, $fromemail 
  my($eptype,$arg2,$handle) = @_;
  $line_ctr = 1;
  my $end_hdr = "";
  my $blanklines = 0;
  my $buffer = "";
  my $msg_ctr = 0;
  my $line = "";

  if($eptype =~ /P/) {
	  my $message = $arg2;
	  my @lines = split(/\n/,$message);
	  foreach $line (@lines) {
	      chomp $line;
	      &header_lines($line);
	  }
  }
  else {
	  my $inboxfilepath = $arg2;
	  open(INBOX, "<$inboxfilepath") or die "Could not open $inboxfilepath<br>\n";
	  while (<INBOX>) 
	  {
	    $line = $_;
	    chomp $line;
	    &header_lines($line);
	  }
	  close(INBOX); 
  }
  $line_cnt = 0;
  ($sentdatetm,$sentdate) = &get_sentdatetm($date_line);
  ($sentdatetm,$sentdate) = &get_sentdatetm_rcpt($receiptdate) if(!$sentdatetm and $receiptdate);

  $subject = &prep_subject($subject_line,$ehandle) if($subject_line);

  $message = $buffer unless($message =~ /[A-Za-z0-9]/ and length($message) > 30 and ($subject_line or $dateline));

  $message =~ s/\r/\n/g;            #change \r to \n
  $message =~ s/^\n*//;             # strip leading blank lines

  return;
}

sub firstpass_header_save {  # Gets email in $buffer or $message, $ehandle, sentdate, subject, frommail
	#   globals to this script file: $buffer, $message, $sentdatetm, $senddate, $ehandle, $date_line, $subject_line, $from_line, $fromemail 
  my($inboxfilepath) = $_[0];
  $line_ctr = 1;
  my $end_hdr = "";
  my $blanklines = 0;
  my $buffer = "";
  my $msg_ctr = 0;
  my $line = "";

  open(INBOX, "<$inboxfilepath") or die "Could not open $inboxfilepath<br>\n";
  while (<INBOX>) 
  {
    $line = $_;
    chomp $line;
    &header_lines;
  }
  close(INBOX); 

  $line_cnt = 0;

  ($sentdatetm,$sentdate) = &get_sentdatetm($date_line);
  ($sentdatetm,$sentdate) = &get_sentdatetm_rcpt($receiptdate) if(!$sentdatetm and $receiptdate);

  $subject = &prep_subject($subject_line,$ehandle) if($subject_line);

  $message = $buffer unless($message =~ /[A-Za-z0-9]/ and length($message) > 30 and ($subject_line or $dateline));

  $message =~ s/\r/\n/g;            #change \r to \n
  $message =~ s/^\n*//;             # strip leading blank lines

  return;
}


sub header_lines 
{
	my $line = $_[0];
	my $userResults;
	$maybe_handle = "";
# print "em229 line $line<br>\n";
    $line = &line_fix($line);     #  eliminate non-ascii line endings
    chomp($line);

#    next if(&initial_skip($line));

	$buffer = "$buffer$line\n";                    # put entire email in $buffer for main processing
	
	if(!$line) {
		$blanklines = $blanklines + 1;
		$end_hdr = 'T' if($blanklines > 1 and $end_hdr !~ 'T');
	}
	else {
		$blanklines = 0;
	}
		
    if($end_hdr =~ /T/) {
	    $msg_ctr = $msg_ctr + 1;
	    $ehandle = $maybe_handle if(!$ehandle and $maybe_handle);
	    $ehandle = "unk" unless($ehandle);
	    if($msg_ctr == 1) {
	        ($userResults,$uHandle,$uStop) = &get_contributor($ehandle,$fromemail); #in contributor.pl
## print "169 uStop $uStop ..uStop_blankct $uStop_blankct uSkip $uSkip<br>\n";
		    if($line =~ /HANDLE:/i) {
		       ($rest,$ehandle) = split(/HANDLE:/,$line);
		       $ehandle =~ s/^\s+//s;
		    }
		    $ehandle = $uHandle unless($ehandle or !$uHandle);
	    }

	    next if(($uSkip and $line =~ /$uSkip/));
		
	    last if(($uStop and $line =~ /$uStop/) or ($uStop =~ /blanks=/ and $uStop_blankct <= $blanklines));
	
	    $message = "$message$line\n" unless($line =~ /HANDLE:/i);
	}
	else {
	                 # ($ehandle,$ext,$date_line,$from_line,$subject_line) 
	    &get_header_info($line)  unless($end_hdr =~ /T/);
	    if($line =~ /Forwarded Message/i or $line =~ /Subject: Fwd:/) {
		    $end_hdr = "";
	        $forward_found = 'T';		
	    }
	}		
    $line_ctr = $line_ctr + 1;
}


sub get_header_info {
	my $line = $_[0];
	
	if($line =~ /from/i and $line =~ /pushjournal/) {
		$ehandle = "push";
	}
	elsif($line =~ /from/i and $line =~ /populationmedia/) {
		$ehandle = "pmc";
	}
	elsif($line =~ /from/i and $line =~ /google\.com/) {
		$maybe_handle = "goog";
	}
	elsif($line =~ /from/i and $line =~ /npg\.org/) {
		$ehandle = "npg";
	}		
	elsif($line =~ /from/i and $line =~ /ippf\.org/) {
		$ehandle = "ippf";
	}
	elsif($line =~ /from/i and $line =~ /karen\.gaia\.pitts/ and $forward_found) {
		$ehandle = "link";
	}
	elsif($line =~ /from/i and $line =~ /karen\.gaia\.pitts/) {
		$ehandle = "kgp";
	}
	elsif($line =~ /from/i and $line =~ /grist\.org/) {
		$ehandle = "grist";
	}
	elsif($line =~ /from/i and $line =~ /patachek/) {
		$ehandle = "pat";
	}
	
	if($line =~ /WOA APP::/) {
		$ext = 'app';
	}	
	elsif($line =~ /From:/) {
	      $from_line = $line;
		  $fromemail = &get_fromemail($line);
	}
	elsif($line =~ /Date:/) {
	      $date_line = $line;
	}
	elsif($line =~ /Subject:/) {
	      $subject_line = $line;
#	      $ehandle = "push" if($line =~ /Daily News Stories/);
	}
#	print "em255 end get_header_info ..date_line $date_line ..from_line $from_line ..subject_line $subject_line<br>\n";
    return($ehandle,$ext,$date_line,$from_line,$subject_line);
}


sub links_separate {          ## Not only for multiple articles in one submittal, but parses fields like date, source, etc.
 ($ep_type,$handle,$pdfline,$sectsubs,$fbody,$receiptdate) = @_;

 $fbody = &line_fix($fullbody);
 $fbody = &apple_line_endings($fbody);
 $fbody  =~ s/^\n*//g;   # beginning of line   TODO: need to go line-by-line
 $fbody  =~ s/\n+$//g;   # end of line

 my $save_sectsubs = $sectsubs;

 &clear_doc_data; # Fills hash %D with initialize values
 &clear_doc_helper_variables;
# $addsectsubs = $save_sectsubs;

 $head = "";
 my $misc = "";
 my $date_found = "";
 my $regions = "";
 my $answer = "";
 my $linkck = "";
 my $prelink = "";
 my $first = 'Y';

 my @bodylines = split(/\n/,$fbody);

 foreach my $bline (@bodylines) {
   chomp $bline;
   if($bline =~ /\b(http.*)\b/) {
	   $prelink = $1;
	   &links_separate_finish($save_sectsubs) unless($first);
	   $first = "";
	   $link = $prelink;
    }
    elsif($bline =~ /\/\//) {
		($headline,$rest) = split(/\/\//,$bline,2);
		@varbits = split(/\/\//,$rest);
		foreach $varbit (@varbits) {
		   &extract_variables($varbit,"Y");	# in smartdata.pl
		}
	}
	else {
	    &extract_variables($bline,"");
    }
 }
&links_separate_finish($save_sectsubs);   # End of bodylines
}

sub links_separate_finish
{
 $D{sectsubs} = $_[0];
 my $docid = "";  # not assigned until &main_storeform in docitem.pl
 $link = "htt$link" if($link and $link !~ /http/);
 $D{link} = $link;

 $D{headline}    = $headline;
 $D{subheadline} = $subheadline;
 $miscinfo       = "$msgline_date$misc_info";
 $D{miscinfo}    = $miscinfo;
 $D{priority}    = $priority;
 $D{author}      = $author;
 $fullbody       = &finish_fullbody($fullbody);
 $D{fullbody}    = $fullbody;
#                  refine_date found in date.pl
 $pubdate        = &refine_date($msgline_anydate,$msgline_date,$msgline_link,$D{link},$msgline_source,$paragr_source,$uDateloc,$sentdate,$todaydate) 
     if($pubdate !~ /[0-9]/ or $pubdate < $DT{earliest_date});
 $D{pubdate}     = $pubdate;
 ($ource,$src_region) = &refine_source($msgline_source,$D{link}) if(!$source);
 ($source,$region) = &get_source_linkmatch($D{link})  if(!$source);
 $D{source} = $source;
 $D{region} = $region;
# $region = &refine_region($region,$src_region) if(!$region or $region eq 'Global');   # found in regions.pl

 $D{sysdate} = &calc_date('sys',0,'+');

 &main_storeform($docid);      # in docitem.pl - store the link and other data
 &clear_doc_data; # Fills hash %D with initialize values
 &clear_doc_vars;
 &clear_doc_helper_variables;
}

sub clear_doc_vars
{
 $link        = "";	
 $sectsubs    = "";
 $headline    = "";
 $subheadline = "";
 $miscinfo    = "";
 $priority    = "";
 $author      = "";
 $region      = "";
 $fullbody    = "";
 $pubdate     = "";
 $source      = "";
 $region      = "";
}

sub finish_fullbody
{
 my $fullbody = $_[0];
 $fullbody =~ s/MI $miscinfo//g;
 $qw_headline = qw($headline);
 $fullbody =~ s/$qw_headline//g;
 $fullbody =~ s/SH $subheadline//g;
 $fullbody =~ s/$author//g;
 $fullbody =~ s/SS $source//g;
 $fullbody =~ s/RR $region//g;
 $fullbody =~ s/\/\///g;
 $fullbody =~ s/^\n//;
 return($fullbody);
}

sub pass2_separate_email {          ## Not only for multiple articles in one submittal, but parses fields like date, source, etc.
 ($ep_type,$handle,$pdfline,$sectsubs,$emailbody,$receiptdate) = @_;
 ($userResults,$uHandle,$uStop) = &get_contributor($handle,""); #in contributor.pl
#CONTRIB_DATA is also a global set in contributors.pl - get_contributor
 ($userid,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat,$uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$uStart,$uStop,$uHeadkey,$uDtkey,$uStop_blankct,$uSep_blankct,$uStart_blankct,$stop_blankCRs,$sep_blankCRs,$start_blankCRs) 
   = split(/\^/,$CONTRIB_DATA,26);
 $MSGBODY = "";	
 $blanklines = 0;
 $stop_ct = 0;
 $sep_ct = 0;
 $skipoff_ct = 0;
 &set_default_variables;
 &clear_sepmail_variables;
 &clear_msgline_variables;
 $gEPtype = $ep_type; #E = email; P=Parse new
 $emailbody =~ s/\r\n/\n/g;                       # eliminate DOS line-endings
 $emailbody =~ s/\n\r/\n/g;
 $emailbody =~ s/\r/\n/g;
#    $emailbody =~ s/\r\r/\n\n/g;
 $emailbody  =~ s/^\n*//g;
 $emailbody  =~ s/\n+$//g;
 $emailbody =~ s/=20//g;

 $msg_on = '';
 $msg_off = '';
 $msg_on = 'Y' if( ($uStart =~ /%NA/  or !$uStart) and !$uStart_blankct);  # Used to be $uSkipoff and $uEnd
 $no_sep = "";

#                        #  uSkipon:  skip first lines until skipoff
 if($uSkipon =~ /%first/ 
	and ( ($emailbody =~ /$uStart/ and $uStart) or ($uStart_blankct and $emailbody =~ /$start_blankCRs/) )    ) {
   $skip_on = 'Y';
   $first_skipoff_found = '';
 }
 else {
   $first_skipoff_found = 'Y';
 }  

 $no_sep = 'Y' unless( ($emailbody =~ /$uSeparator/ and $uSeparator) or $uSep_blankct);
# print "em297 ..no_sep $no_sep ..uSeparator $uSeparator ..uSep_blankct $uSep_blankct<br>\n";

 print "<br>***INBOX $inboxfilename ..EPtype $gEPtype ..h-$ehandle subj-$subject  ..sent $sentdate ..from $fromemail no_sep $no_sep<br>\n" 
        if($gEPtype eq 'E');
 $emailbody = &line_fix($emailbody);
 $emailbody = &apple_line_endings($emailbody);

 @emsglines = split(/\n/,$emailbody);
 foreach $emsgline (@emsglines) {
    chomp $emsgline;
    next if(&initial_skip($emsgline));
	if($line_cnt2 eq 0 and !$emsgline) { # get rid of initial blanks
		next;
	}
	else {
	   $line_cnt2 = $line_cnt2 + 1;
	   $top_lines2 = "$top_lines2$emsgline\n";
	} 
	if($emsgline =~ /^Articles/ and $handle =~ /PMC/) {
		print "em309 Article found<br>\n";
	   $prev_skipon = 'Y';
	   next;
    } 
	if($emsgline =~ /^------/ and $ehandle =~ /PMC/ and $prev_skipon) {
	   $prev_skipon = '';
	   next;
    }
    &parse_email;   #processes $emsgline; separates the emails, among other things   
 } # end foreach
&close_it;   #write last op file under certain conditions (separation)
}



## 300  PARSE THE EMAIL BODY FOR SEPARATORS, ETC

sub parse_email   #parse line-by-line - variables already initialized in process_popnews_inbox
{ 
  # $emsgline is a global

### DO WE NEED? WE'VE ALREADY DONE THIS
  $msg_on = 'Y' if( ($emsgline =~ /$uStart/ and ($uStart or $uStart !~ /%NA/) )
                or ($uStart_blankct and $blanklines >= $uStart_blankct) );  # Used to be $uSkipoff and $uEnd
  $msg_off = 'Y' if( ($msg_on eq 'Y' and $uStop and $uStop !~ /%NA/ and $emsgline =~ /$uStop/)
                 or ($uStop_blankct and $blanklines >= $uStop_blankct) );


#print "327 p2 on $msg_on off $msg_off sep $uSeparator locsep $uLocSep start $uStart stop $uStop line $emsgline<br>\n";
#print "327 $emsgline<br>\n";
  if($msg_off and 
          $first_skipoff_found eq 'Y' and 
            ($top_of_msg ne 'Y' or       
            ($blanklines > 0 xor $emsgline =~ /[a-zA-Z0-9]/) ) ) {
	      &close_it;   #  write_it under certain conditions (separation)
	      last;
  }

  next if($msg_on ne 'Y');   ## next line
  last if($msg_off eq 'Y');  ## last line

  if(!$emsgline) { 
      $blanklines += 1;                     ## count blank lines at top & between
      $skip_it = 'Y' if($blank_topmsg =~ /Y/);  ## skip top blank lines
      $top_of_msg = '' if($blank_topmsg ne 'Y');
      $paragraph = "";
      $headline_save="";
	  $MSGBODY = "$MSGBODY$emsgline\n";
#		print "blank emsgline blanklines $blanklines skip_it $skip_it top_of_msg $top_of_msg <br>\n";
   }
   else {
      &parse_line;             
      $paragraph = "$paragraph\n$emsgline";
      $blank_topmsg = '';
      $blanklines = 0;
   }
   last if($empty_msg);
}
                      ## 220 PARSE A LINE
sub parse_line
{
 # $emsgline is a global
 $sep_found = '';
 $skip_it = '';
 $skip_on = '';
 
# $skip_on = 'Y' if($uLocSep =~ /first|pre/ and $separator_cnt eq 0);

 if($emsgline =~ /$uSkipon/ and $uSkipon ) {
       $skip_on = 'Y';
#	print "em271 $ehandle **** NOT SKIPON  $skip_on  prev_skipon $prev_skipon <br>\n";
       $skipon_found = 'Y';       
 }

if( ($emsgline =~ /$uStart/ and $uStart) 
	or ($uStart_blankct and $blanklines >= $uStart_blankct) ) {
	  $skip_it = 'Y';
	  $skip_on = '' if(!$prev_skipon);
	  $first_skipoff_found = 'Y';	
 }                                       
 $emsgline = &bad_stuff_convert($emsgline);

 if(!$no_sep and !$prev_skipon) {
	 if($uSeparator and $emsgline =~ /$uSeparator/) {	
	    if($uBlanks eq 0 or !$uBlanks or
	      (($uBlanks and $blanklines >= $uBlanks and  $uLocSep =~ /first|pre/) or $uLocSep =~ /last|post/) ){
	        &do_sep_found;
	    }
	    elsif($uSep_blankct and $blanklines >= $uSep_blankct  ) {
	        &do_sep_found;	
	    }
	}
 }

 if($sep_found eq 'Y') {
    if($uLocSep =~ /last|post/) {
	     &addline2msg_ifnotskip;
	     &write_email; 
    }
    elsif($uLocSep =~ /after1st/) {
	     $headline_save = "$paragraph\n$emsgline";
	      &write_email;
    }
    else {  # first|pre     ## pre separator is before the separation
	     &write_email;
		 &addline2msg_ifnotskip;
    }
  }
  else {
    &addline2msg_ifnotskip unless($sep_found eq 'Y' and $uLocSep =~ /first|pre/ and $separator_cnt eq 1);	
  }
  last if($empty_msg);  # this is the last line if an empty message is found

 $prev_skipon = $skipon_found;
 $skipon_found = '';
}

sub do_sep_found
{
  $sep_found = 'Y';
  $separator_cnt += 1;
  $skip_on = '' if($uLocSep =~ /first|pre/);
  $headline_save = "$paragraph\n$emsgline" if($uLocSep =~ /after1st/);	
}

sub addline2msg_ifnotskip {
  my $skip_it = "";
 ($skip_it, $emsgline) = &check_skip($emsgline);
  if($skip_it) {
#	print"em327 $ehandle ****SKIPPED msg $emsgline<br>\n";
    $skip_it = '';
  }
  else {
    $itemline_cnt += 1;
#	print " ln $emsgline<br>\n" if($line_cnt < 20); 	
	$line_cnt ++;
	$emsgline =~ s/^\s+//;
	$emsgline =~ s/^ +//;
	$MSGBODY = "$MSGBODY$emsgline\n";
 }
}

sub initial_skip {
 my $emsgline = $_[0];
 
 if(
    $emsgline =~ /message is in MIME format/i or
    $emsgline =~ /this message may not be legible/i or 
    $emsgline =~ /=_Part_/i or
    $emsgline =~ /view message in web browser/i or
    $emsgline =~ /_NextPart_/i or
    $emsgline =~ /charset=/i or
    $emsgline =~ /Content-Transfer-Encoding/i or
	$emsgline =~ /\Q_Part_\E/i or
	$emsgline =~ /\Q--Apple-Mail\E/i or  
	$emsgline =~ /\QContent-Type: text\E/i or 
	$emsgline =~ /\QContent-Transfer-Encoding:\E/i or
	$emsgline =~ /\QContent-Disposition:\E/i or
	$emsgline =~ /\Qoctet-stream\E/i or
	$emsgline =~ /\Q--===\E/ or
	$emsgline =~ /^\Q--bc\E/ or
	$emsgline =~ /Content-Type:\|aspNetEmail/) {
		 return('Y');
	}
 return("");
}

sub check_skip {
 my $emsgline = $_[0];
 my $skip_it = '';
 
 if(
    $emsgline =~ /message in MIME format/ or
    $emsgline =~ /_NextPart_/ or
    $emsgline =~ /charset=/ or
    $emsgline =~ /Content-Transfer-Encoding/ or
    $emsgline =~ /Image/ or
    $emsgline =~ /Reserved \>\>/ or
    $emsgline =~ /Go to top./ or
    $emsgline =~ /Reserved \>\>/ or
	$emsgline =~ /\Q_Part_\E/ or
	$emsgline =~ /\Q--Apple-Mail\E/ or  
	$emsgline =~ /\QContent-Type: text\E/ or 
	$emsgline =~ /\QContent-Transfer-Encoding:\E/ or
	$emsgline =~ /\QContent-Disposition:\E/ or
	$emsgline =~ /\Qoctet-stream\E/ or
	$emsgline =~ /^Subject:/ or
	$emsgline =~ /^From:/ or
	$emsgline =~ /^To:/ or
	#			$emsgline =~ /^Date:/   # date can be in push
	$emsgline =~ /^Copyright/ or
	$emsgline =~ /^Privacy:/ or
	$emsgline =~ /Forwarded Message/ or
	$emsgline =~ /Powered By LexisNexis/ or
	$emsgline =~ /^--[a-f0-9]{27}/ or
	$emsgline =~ /Content-Type:\|aspNetEmail/) {
		 $skip_it = 'Y';
	}
 
  elsif( $skip_on or
	 ($emsgline =~/$uSeparator/ and $uSeparator and $uLocSep =~ /post|pre/) or
     ($uSkip =~ /ALLCAPS/ and $emsgline !~ /[a-z]/ and $emsgline =~ /[A-Z]/) or
	 ($emsgline =~ /$uSkip/ and $uSkip and $uSkip !~ /%NA/ and $ehandle !~ /pmc/) or
	 ($emsgline =~ /^$uSkip/ and $uSkip and $uSkip !~ /%NA/ and $ehandle =~ /pmc/) ) {
		 $skip_it = 'Y';
	}
	
   elsif($emsgline and $ehandle =~ /pmc/ and $emsgline =~ /$uSkip/ and $emsgline !~ /^$uSkip/ and $uSkip and $uSkip !~ /%NA/) {
      ($emsgline,$rest) = split(/$uSkip/,$emsgline,2);  #looks for PMC's rs20 long URL and eliminates it.
      $emsgline = "$emsgline $rest";
   }
   return($skip_it, $emsgline);
}

sub prep_subject {
   my($subject,$ehandle) = @_;
   ($rest,$subject) = split(/:/,$subject,2);	
   $subject =~ s/ Fwd:// if($subject =~ /^ Fwd:/);
   ($rest,$subject) =~ split(/Fw:/,$subject,2) if($subject =~ /CCNR/ and $subject =~ /Fw:/);
   $subject =~ s/^\s+//;
   $subject =~ s/^ +//;
   $subject = &apple_convert($subject);
   $subject = "$ehandle:: $subject" if($ehandle =~ /pat/);
   return($subject); 	
}

sub get_fromemail {
   my($fromline) = $_[0];
   my($fromemail) = "";
   if($fromline) {
	  my($mailuser,$domainfrom)  = split(/\@/,$fromline,2);
      my($rest,$mailuser)        = split(/\</,$mailuser,2) if($mailuser =~ /\</);
      my($domainfrom,$rest2)     = split(/\>| /,$domainfrom,2);
      $fromemail = "$mailuser\@$domainfrom";
   }
   else {
	  $fromemail = "karen.gaia.pitts\@gmail.com";
   }
   return($fromemail);
}


#  WRITE INCOMING EMAIL TO suggested_emailed as a selection list on the web

sub close_it
{
	#              write the email if there is a separator
  if($MSGBODY and (($separator_cnt > 0 and $uLocSep =~ /first|pre/) or $separator_cnt eq 0) ){
      $separator_cnt = $separator_cnt + 1;
#    		print "good ..$MSGBODY<br><br><br>\n" if($line_cnt < 4); 	
        $line_cnt = $line_cnt + 1;
        &write_email;
  }
  elsif($empty_msg) {
	  $fullbody = "$top_lines\n\n$message";
	  $headline = $subject if($subject);
	  $pubdate = $sentdate if($sentdate);
	  print "*** WRITE_EMAIL -> $op_filename -$separator_cnt NO MSGBODY -Writing top lines + message<br>\n";
	  &write_doc_item($op_filename,$idx_insert_sth);   # in docitem.pl
      $empty_msg = "";
  }
  elsif(!$email_written) {
      &write_email;
  }
  $email_written = '';
}

sub write_email    #writes what is accumulated in $MSGBODY, a global variable
{
 if($gEPtype eq 'P' and $ehandle !~ /push/) {
	    $save_sectsubs = $sectsubs;
	    &parse_popnews($pdfline,$MSGBODY,$sectsubs);  #in smartdata.pl - modifies $MSGBODY, a global
	
	    $addsectsubs = $sectsubs;
        &main_storeform($docid);   #in docitem.pl
	    goto write_clear;  # if more than one article on form, we are not done
  }	
  my $op_filename = "$sentdatetm-$ehandle";	
  if($MSGBODY) {
	  $email_cnt = $email_cnt + 1;
#		  print "em471 $ehandle **** PREPARE WRITE_EMAIL skip_item $skip_item msg $MSGBODY<br>\n" if($ehandle =~ /push/);
	  $emailfile = "$mailpath/$op_filename-$separator_cnt.itm";

	  $MSGBODY = &parse_popnews($pdfline,$MSGBODY,$sectsubs);  # in smartdata.pl this is where we switch to $emessage
      if($skip_item =~ /Y/) { 
#	      unlink "$inboxfilepath"; 
		  print "**** SKIP WRITE_EMAIL -> $op_filename -$separator_cnt from inbox $inboxfilename<br>\n";
	  }
	  else {
		  my $l_docid = "$op_filename-$separator_cnt";
		  print "**** WRITE_EMAIL (standard) -> $l_docid<br>\n";
		  &write_doc_item($l_docid,$idx_insert_sth);   # in docitem.pl
		  $email_written = 'T';
	  }
  }
  else {
  $empty_msg = 'T';
  print "**** EMPTY FOUND -> $op_filename -$separator_cnt from bkp $inboxfilename<br>\n";
  }

WRITE_CLEAR:
  &clear_doc_data;   # in docitem.pl
  &clear_doc_variables; # in docitem.pl
  &clear_helper_variables;
  &clear_msgline_variables;

##                 next email
  $MSGBODY = "";
  $MSGBODY = "$headline_save\n"  if($uLocSep =~ /after1st/ and $headline_save and $headline_save !~ /Register./);
    
  $itemline_cnt = 0;
}


sub rs_url {
	my($rs,$line) = @_;  # rs holds the status of the http://r20 process
    my $keepline = $line;  # keep the line if no rs20 url found
    my $line2 = "";

	if($line =~ /\[http:\/\/r20/ and $line !~ /link to the following/) {
	    $rs = 'T';
	    if($line =~ /^\[http:\/\/r20/) {
	        ($keepline,$line2) = split(/\[http:/,$line);
	    }
	    else {
		    $keepline = "";
	    }
	    ($rs,$line2) = &rs_url_end($rs,$line2);  # see if there is an interruption of the url - ] or space
	    $keepline = "$keepline$line2";		
	}	    
    elsif($rs eq 'T') {
        ($rs,$keepline) = &rs_url_end($rs,$line);  # look for the end 
    }
## print "em440 ..ehandle $ehandle ..rs $rs  ..keep $keepline ..lineln $line";
	return($rs,$keepline);
}

sub rs_url_end {    # comes here if rs is 'T'
 my($rs,$line) = @_;

 if($line =~ /\]/) {
   ($rest,$line) = split(/\]/,$line);
   $rs = 'F';
 }
 elsif($line =~ / /) {
    ($rest,$line) = split(/ /,$line);
 }
 else {
    $line = "";
 }
 return($rs,$line);
}	


##                converts quotes, hyphens and other wayword perversions
sub bad_stuff_convert
{
 local($datafield) = $_[0];
# ($datafield,$rest) = split(/=/,$datafield,2) if($datafield =~ /=\s*$/);
# print "SPLIT = ***$datafield\n";
 $r = rindex($datafield,'=');
 $l = length($datafield);
 if($r > 0 and $l > 60 and ($l - $r) < 2) {
    $datafield = substr($datafield, 0, $r);
    $pre_equal_found = 'Y';	
 }

 $datafield =~ s/= $//;            #eliminate ending =
 $datafield =~ s/=$//;            #eliminate ending =
 $datafield =~ s/=20$//;           #more ending stuff
 $datafield =~ s/ = $/ /g;         #end of line

 $datafield =~ s/=3D/*/g;          # bullet?

 $datafield =~ s/=B7//g;           # tab?
 
 $datafield =~ s/^=3D([a-z])/$1/g;   ## next line starts with lower case - not a paragraph
 $datafield =~ s/^=0D=0A([a-z])/$1/g;
  
 $datafield =~ s/([a-z0-9] )$/$1/ig;

 ##                             # single quote, apostrophe
 $datafield =~ s/L/'/g;    #81
 $datafield =~ s/&rsquo;/'/g;
 $datafield =~ s/=91/'/g;  #91
 $datafield =~ s/=92/'/g;  #92 
 $datafield =~ s/Â´/'/;
 $datafield =~ s/â€˜/'/g;
 $datafield =~ s/=E2=80=99/'/g;
 $datafield =~ s/â€™/&#39;/g;
 $datafield =~ s/=E2=90=99/&#39;/g; # same as proceeding
 $datafield =~ s/’/'/g;      # single quote
 $datafield =~ s/=2018/"/g; #right quote
 $datafield =~ s/=2019/"/g; #left quote
 
 ##                    # double quotes    
 $datafield =~ s/``/"/g;         
 $datafield =~ s/=93/"/g; #93
 $datafield =~ s/=94/"/g; #94
 $datafield =~ s/E/"/g;   #81
 $datafield =~ s/''/"/;   #doublequote
 $datafield =~ s/”/"/;    #backquote
 $datafield =~ s/“/"/;    #frontquote
 $datafield =~ s/``/"/g;  #double back tick
 $datafield =~ s/â€/"/g;  #double quote 2
 $datafield =~ s/â€œ/"/g; #double quote 3
 $datafield =~ s/=E2=80=9D/"/;  #double quote 3 - same as preceeding
 $datafield =~ s/=E2=80=9C/"/;  #double quote 3 - same as preceeding
 $datafield =~ s/“A/"/g; #double quote 4
 $datafield =~ s/”/"/g; #end quote

 $datafield =~ s/&#40;/\(/g;  # left parens
 $datafield =~ s/&#41;/\)/g;  # right parens
 
 $datafield =~ s/&#91;/\[/g;  # left bracket
 $datafield =~ s/&#93;/\]/g;  # right bracket

 $datafield =~ s/=D0/-/g;    # 95    hyphen
 $datafield =~ s/=95/-/g;    # 95    hyphen
 $datafield =~ s/=96/-/g;    # 95    hyphen
 $datafield =~ s/=97/-/g;    # 95    hyphen
 $datafield =~ s/=3F/-/g;    # 95    hyphen
 $datafield =~ s/â€“/-/g;    #hyphen
 $datafield =~ s/–/-/g;      #hyphen
 $datafield =~ s/=E2=80/-/g;   # hyphen
 $datafield =~ s/=95/=2D/g;    #double hyphen

 $datafield =~ s/=A3/£/g;    # A3    pound sign

##                        special Latin characters
 $datafield =~ s/=E9/é/g;   
 
 $datafield =~ s/=A0/ /g;    #blank
 
 return($datafield);  	
}


sub get_sentdatetm {
	my($datafield) = $_[0];
	return if($datafield !~ /[A-Za-z0-9]/);
	my $rest = "";
	my $sentdd = "";
	my $sentmon = "";
	my $sentyyyy = "";
	my $senttime ="";
	my $rest1 = "";
	$datafield =~ s/[Dd]ate://;
	$datafield =~ s/^\s+//;  ## remove leading blanks
    $datafield =~ s/  / /g;  ## change double blanks to single blanks

    if($datafield =~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/) {
	         # Date: Mon, 4 Jul 2011  Date: 05 Jul 2011 
	    ($rest,$sentdd,$sentmon,$sentyyyy,$senttime,$rest1) = split(/ /,$datafield,6);
    }
    else {
        ($sentdd,$sentmon,$sentyyyy,$senttime,$rest1) = split(/ /,$datafield,5);
    }
    $senttime = $rest1 if($senttime =~ /[a-zA-Z]/);
    $senttime =~ s/://g;

    if($sentdd =~ /[a-zA-Z]/) {  #swap sentdd and sentmon
	   $rest1 = $sentmon;
	   $sentmon = $sentdd;
	   $sentdd = $rest1; 
    }

    $sentdd = '0' . $sentdd if($sentdd =~ /^[1-9]{1}$/); # pad if a single digit
    my $month_table = "01-Jan;02-Feb;03-Mar;04-Apr;05-May;06-Jun;07-Jul;08-Aug;09-Sep;10-Oct;11-Nov;12-Dec";
    my @months = split(/;/,$month_table);
    foreach $month (@months) {
		($sentmm,$mon) = split(/-/,$month);
	    if($sentmon =~ /$mon/) {
		  last;
	    }
	}
	
	$sentdatetm = "$sentyyyy-$sentmm-$sentdd-$senttime";
	$sentdatetm =~ s/,//;
	($sentdatetm,$rest1) = split(/ /,$sentdatetm);
		
	$sentdate = "$sentyyyy-$sentmm-$sentdd";
	$sentdate =~ s/,//;
	($sentdate,$rest1) = split(/ /,$sentdate);
	
    if(!$sentdatetm or $sentdatetm =~ /-12--/) {
	    $sentdatetm = &calc_date('sys',0,'+');  #in date.pl
    }  
    return($sentdatetm,$sentdate);
}

sub get_sentdatetm_rcpt {
	my ($receiptdate) = $_[0];	
	my ($sentyyyy,$sentmm,$sentdd,$senttime,$rest1) = split(/-/,$receiptdate,5);
	return ("$sentyyyy-$sentmm-$sentdd-$senttime", "$sentyyyy-$sentmm-$sentdd");
}

sub ck_dup_email
{
 my $opfilename = $_[0];   # if dup found for 1st, exit -  all others would be dupped as well
 if($dupck_stack =~ /$opfilename/) {
	print "<br>***DUP FILE FOUND: $opfilename SKIPPING THIS FILE $inboxfilename<br>\n\n";
#	my $dup = "$mailbkppath/$filedup.dup";
#	system 'touch $dup' or die;
	return('T');
 }
 else {
   $dupck_stack = "$dupck_stack$opfilename|";
   return("");
 }
}

sub ck_dup_email_old
{
 my $opfilename = $_[0];   # if dup found for 1st, exit -  all others would be dupped as well
 opendir(POPMAILDIR, "$mailpath");  # overpopulation.org/popnews_mail
 my(@popnewsfiles) = grep /^$opfilename.+\.email$/, readdir(POPMAILDIR);
 closedir(POPMAILDIR);

 foreach $filedup (@popnewsfiles) {
	##   sentyyyy-mm-dd-hhmmss-ehandle
	print "<br>***DUP FILE FOUND: $filedup SKIP THIS FILE<br>\n\n";
	my $dup = "$mailbkppath/$filedup.dup";
	system 'touch $dup' or die;
	return('T');
 }
}

sub set_default_variables {
   $std_skipon  = "text/html";
   $std_skipoff = "text/plain";
   $std_separator = "######";	
}

sub clear_sepmail_variables {
	undef(@emsglines);
	undef(@msglines);
	$MSGBODY = "";
	$msgline = "";
	$emsgline = "";
	$first_skipoff_found = '';
	$sep_found = '';
	$top_lines = "";
	$top_lines2 = "";
	$line_cnt = 0;
    $line_cnt2 = 0;
    $email_written = '';
    $empty_msg = "";
	$end_hdr_found = "";
	$msg_on = "";
    $msg_off = "";
	$contributor = "";
	$identifier = "";
	$done_handle = "";
	$keep = "";
	$todays_datetm = "";	
	$end_header = "";  # Y = end of header detected; = (first blank line)
	$emailpath = "";
	$bkpfilepath = "";
  $headline_save = "";
  $linecnt = 0;
  $msgline1 = "";
  $msgline2 = "";
  $msgline3 = "";
  $paragr_linecnt = 0;
  $paragr_cnt = 0;
  $paragraph  = "";
  $paragraph1 = "";
  $paragraph2 = "";
  $paragraph3 = "";
  $blanklines = 0;
  $separator_cnt = 0;
  $skip_on = '';
  $skip = "";
  $skip_it = '';
  $prev_skipon  = '';
  $skipon_found = '';
  $blank_topmsg = 'Y';
  $top_of_msg   = 'Y';
  $prev_line = "";
  $prevprev_line = ""; 
  $save_line = "";
  $save_prev_line = "";
  $save_prevprev_line = ""; 
  $prev_para    = "";
  $sep_ctr = 0;
  $start = "";
  $stop = "";
  $no_sep = "";
  $separator = "";
  $seploc = "";
  $sepctr = "";
  $itemline_cnt = 0;
  $rs = "";
  $msgline_link = "";
  $nextline_link = "";
  $eof = "";
}

sub clear_message_variables {
  $gEPtype = "";
  $MSGBODY = "";
  $emsgbody = "";
  $blanklines = "";
  $email_written = '';
  $forward_on = "";
  $buffer = "";
  $handle = "";
  $ehandle = "";
  $save_handle = "";
  $contributor = "";
  $identifier = "";
  $done_handle = "";
  $keep = "";
  $ext = 'email';
  $receiptdate = "";
  $date_line = "";
  $subject = "";
  $subject_line = "";
  $from_line = "";
  $fromemail = "";
  $sentdatetm = "";
  $sentdate = "";
  $todays_datetm = "";
  $op_ctr = 0;	
  $stop_hdr = "";
  $end_hdr = "";  # Y = end of header detected; = (first blank line)
  $end_header = "";  # Y = end of header detected; = (first blank line)
  $emailpath = "";
  $bkpfilepath = "";
  $msgtop = "";
  $separator_cnt = 0;
  $skip_on = '';
  $skip = "";
  $prev_skipon  = '';
  $skipon_found = '';
  $blank_topmsg = 'Y';
  $top_of_msg   = 'Y';
  $message = "";
}

sub clear_helper_variables {	
  $msgtop = "";
  $linecnt = 0;
  $head = "";
  $msgline1 = "";
  $msgline2 = "";
  $msgline3 = "";
  $msgline4 = "";
  $msgline_parens = "";
  $paragr_linecnt = 0;
  $paragr_cnt = 0;
  $paragraph  = "";
  $paragraph1 = "";
  $paragraph2 = "";
  $paragraph3 = "";
  $paragraph4 = "";
  $paragraph_parens = "";
  $blanklines = 0;
  $prev_line = "";
  $prevprev_line = ""; 
  $save_line = "";
  $save_prev_line = "";
  $save_prevprev_line = ""; 
  $prev_para       = "";
#  $itemline_cnt   = 0;
  $msgline_link    = "";
  $nextline_link   = "";
  $msgline_anydate = "";
  $msgline_date    = "";
  $msgline_source  = "";
  $msgline_anysrc  = "";
  $paragr_source   = "";
  $prev_headline   = "";
  $twolines        = "";
}

sub clear_msgline_variables {
  $holdmonth  = "";
  $chkline    = "";
  $pyear      = "";
  $line = "";
  $msglineN = "";
  $msglineN1 = "";
  $max_linecnt = 0;
}

1;
