#!/usr/bin/perl


## escape these meta characters:   .^*+?{}()[]\|  and / if using as a delimiter
##  * Match 0 or more times   + Match 1 or more times    ? Match 1 or 0 times

## July 1, 2011 - Splitting into getmail.pl and new version of sepmail.pl (renamed to email2docitem.pl); 
#                 Not doing Feb 22 below

## Feb 22, 2011 - Reduced functionality, moving most into parsemail.pl, due to large file processing resulting in NO results.
##                Now reading one line at a time. Hope this works on ippf

# 2011 Feb 16 - enlarged functionality: found date, subject, ehandle; did weird character conversion to ascii;
#              chopped off excess at top and bottom; added sepmail functionality
# 2010 July 22 - buffer too small; broke into lines while reading in

#*********************************************************************
# DOCUMENTATION -- The winding trail of Email Processing and Selection
#
#  1. article.pl?display_section%%%Suggested_emailedItem%%adminUserID
#      a. Goes to email2docitem.pl &separate_email_files
#          * Takes emails delivered to overpopulation.org/popnews_inbox by getmail.pl (straight copy to email)
#          * Copies to /popnews_bkp; deletes file from popnews_inbox
#          * Eliminates dups
#          * Separates if more than one article in an email (&parse_email)
#          * Puts email in docitem format (&parse_popnews) and writes to popnews_mail
#          * writes 'docid' (filename=sent date time + senderid) to index at autosubmit/sections/suggested_emailedItem.idx
#      b. Create_html and print selection list of emails (in article.pl)
#            Uses doclist (index) = suggested_emailedItem.idx to generate list.
#            <form post="...article.pl"
#            <input name="cmd" value="select_items" type="hidden">
#            <input name="sdocid0001" value="2011-06-29-746-push-1"> #document id = sent date time + senderid
#  2. article.pl - receives 'post' from 1.b, parses the list for selected items
#       a. &select_email - line 566
#       b. &process_popnews_email($selectdocid) and- in docitem.pl line 363
#            If selected:
#             * assigns a new docid
#             * reads in doc data from overpopulation.org/popnews_mail
#             * assigns to section 'suggested_suggestedItem' and writes docid to suggested_suggestedItem.idx
#             * writes docitem to autosubmit/items/$docid.itm
#            If not selected:  (in article.pl)
#              *unlink mailpath/selectitem file (from /popnews_mail)
#      **      *delete from suggested_suggestedItem.idx
#  3. article.pl prints <meta for article.pl?display_section%%%Suggested_suggestedItem%%
#        to print an select/update form list of all items on 'suggested' index.
#  4. article.pl - receives 'post' from #3, parses the list for selected & updated items
#  5. From there the article usually goes to the Headlines list, where the summarizer picks it; then to the summarized list;
#     then to the NewsDigest_NewsItem list (which is published as the front page of WOA)
#*******************************************************************************

sub separate_email_files {   
  $line_cnt = 0;      # Only for debugging
  $email_cnt = 0;     # Only for debugging
  $dupck_stack = "";
  &set_default_variables;
  &clear_message_variables;   # clears variables, makes them visable

print "<div style=\"font-size:70%; font-family:verdana\">\n";
#  &generate_popnews_email_top;  # web selection list top - in article.pl - do create_html instead

  opendir(INBOXDIR, "$inboxpath");  # overpopulation.org/popnews_inbox <- This is where getmail.pl puts it
  my(@popnewsfiles) = grep /^.+\.email$/, readdir(INBOXDIR);
  closedir(INBOXDIR);

##           FIRST PASS
  foreach $inboxfilename (@popnewsfiles) {
     &do_one_email('E',"$inboxfilename");
  } # end foreach
print "<\/div>\n";
}

sub do_one_email {    #comes here from article.pl for cmd= emailsimulate
 my($ep_type,$inboxfile) = @_;
 $inboxfilename = $inboxfile;
 $inboxfilepath = "$inboxpath/$inboxfile";
 $mailbkpfilepath = "$mailbkppath/$inboxfile";
 if(-f "$inboxfilepath" and $inboxfile =~ /\.email/) {
	 system "cp $inboxfilepath $mailbkpfilepath";  #back it up
	 &clear_message_variables;
	 &clear_msgline_variables;
	
	 ($receiptdate,$rest) = split(/\./,$filename);	
	 if($$ep_type =~ /P/) {   #simulate email
		  my $op_filename = "$receiptdate";  # assign a new file name
	      $ehandle = "";
	      $ext     ="";
	      $subject = "";
	      $sentdatetm = substr($receiptdate,0,10);
	      $message = $fullbody;
		              # $ep_type,$hand,$pdfline,$ss,$full
          &separate_email($ep_type,"","","",$fullbody);		
	 }
	 else {
		  ($ehandle,$ext,$subject,$sentdatetm,$sentdate,$message) = &read_do_1stpass($inboxfilepath);

		  my $op_filename = "$sentdatetm-$ehandle";  # assign a new file name
	
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
		      print "<br>**** INBOX $inboxfilename WRITE_EMAIL -> $op_filename  BYPASSING parse<br>\n";
		      &write_doc_item($op_filename);
		  }
	      else {  # FINALLY, a normal email
		              # $ep_type,$hand,$pdfline,$ss,$full
	         &separate_email($ep_type,"","","",$message);
	      }
	} #end elsif ep_type
	unlink $inboxfilepath;  # in any case, delete the input file (inbox)
 } # end outer if
 else {
		print "Error: File not found @ $inboxfilepath<br>\n";
 }
}


sub read_do_1stpass {  # Gets email in $buffer, ehandle, sentdate, subject, frommail
  my($inboxfilepath) = $_[0];
  $line_ctr = 1;
  open(INBOX, "<$inboxfilepath");
  while (<INBOX>) 
  {
	$line = $_; 
	$line = &line_end_fix($line);     #  eliminate non-ascii line endings
    chomp($line);
#    next if(&initial_skip($line));
    $line =~ s/^=A0 //;                # annoying unicode

#	print "sep72 line $line<br>\n";
	$buffer = "$buffer$line\n";                    # put entire email in $buffer for main processing
	
	if(!$line and !$stop_hdr) {
	   $stop_hdr = 'T';    # End of header info
	   $end_hdr = 'T' if(!$end_hdr);
    }
	if($end_hdr and $line =~ /Forwarded Message/i) {
	   $stop_hdr = '';    # End of forward info
	   $forward_found = 'T';
    }
#	if($end_hdr and $line =~ /Content-Type: text\/plain/i) {
#	   $stop_hdr = '';    # End of extra header stuff
#    }

 	if($stop_hdr) {
	}
	else {
		my($ehandle,$ext,$date_line,$from_line,$subject_line) = &get_header_info($line);
    }
    $line_ctr = $line_ctr + 1;
  }
  close(INBOX);
  $line_cnt = 0;

  my($sentdatetm,$sentdate) = &get_sentdatetm($date_line);

  ($sentdatetm,$sentdate) = &get_sentdatetm_rcpt($receiptdate) if(!$sentdatetm and $receiptdate);

  my $subject = &prep_subject($subject_line,$ehandle) if($subject_line);

  $buffer =~ s/\r/\n/g;            #change \r to \n

  my($rest,$message) = split(/\n\n/,$buffer,2);  # eliminate header section

  my($first_para,$msg_rest)  = split(/\n\n/,$message,2); # eliminate 2nd header section

  if($first_para =~ /Content-type/i) {
	 $message = $msg_rest;
  }

  $message =~ s/^\n*//;  # strip leading blank lines

  $fromemail = &get_fromemail($from_line) if($from_line);

  my($line1,$rest) = split(/\n/,$message,2);
  
  if($line1 =~ /HANDLE:/i) {
     ($rest,$ehandle) = split(/HANDLE:/,$line1);
     $ehandle =~ s/^\s+//s;
     $blanklines = 1; 
     ($line1,$message) = split(/\n/,$message,2);   # Looks like $line 1 not used anywhere else
  }

##                                
  &check_contributor($ehandle,$fromemail);   ## in contributor.pl - puts $uemail, $uhandle, and contributor data into global $CONTRIB_DATA for later reference

  $message = $buffer if(!$subject_line and !$dateline);
  return($ehandle,$ext,$subject,$sentdatetm,$sentdate,$message);
}

sub get_header_info {
	my $line = $_[0];
	my($ehandle,$ext,$date_line, $from_line,$subject_line);
	
	if($line =~ /from/i and $line =~ /pushjournal/) {
		$ehandle = "push";
	}
	elsif($line =~ /from/i and $line =~ /populationmedia/) {
		$ehandle = "pmc";
	}
	elsif($line =~ /from/i and $line =~ /google\.com/) {
		$ehandle = "goog";
	}
	elsif($line =~ /from/i and $line =~ /npg\.org/) {
		$ehandle = "npg";
	}		
	elsif($line =~ /from/i and $line =~ /ippf\.org/) {
		$ehandle = "ippf";
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
	elsif($line =~ /^[fF]rom:/) {
	      $from_line = $line;
	}
	elsif($line =~ /^[dD]ate:/) {
	      $date_line = $line;
	}
	elsif($line =~ /^[Ss]ubject:/) {
	      $subject_line = $line;
	}
	return($ehandle,$ext,$from_line,$date_line,$subject_line);
}

sub separate_email {          ## Not only for multiple articles in one submittal, but parses fields like date, source, etc.
 my($ep_type,$hand,$pdfline,$ss,$full) = @_;
 $sectsubs = $ss;
 $handle = $hand;
 $fullbody = $full;

  #set these as globals until we can find a more graceful way to use them; CONTRIB_DATA is also a global set in contributors.pl - check_contributor

  ($c_uid_fk,$uemail,$uhandle,$uBlanks,$uSeparator,$uLocSep,$uSkipon,$uSkipoff,$uSkip,$uEmpty,$uDateloc,$uDateformat, 
	   $uHeadlineloc,$uSourceloc,$uSingleLineFeeds,$uEnd,$created_on,$uStart,$uStop,$uHeadkey,$uDtkey) = split(/^/,$CONTRIB_DATA,21);
	
 if($ep_type =~ /P/) {
	 &set_default_variables;
	 &clear_message_variables;
	 &clear_msgline_variables;
	 $handle = $hand;
	 $gEPtype = $ep_type; #E = email; P=Parse new
	 $fullbody =~ s/\r\n/\n/g;                       # eliminate DOS line-endings
	 $fullbody =~ s/\n\r/\n/g;
	 $fullbody =~ s/\r/\n/g;
	 $fullbody =~ s/\r\r/\n\n/g;
	 $fullbody  =~ s/^\n+//g;
	 $fullbody  =~ s/\n+$//g;
	 $message = $fullbody;
	 $ehandle  = $handle;
 }
 $message =~ s/=20//g;

 $msg_on = '';
 $msg_off = '';
 $msg_on = 'Y' if($uStart =~ /%NA/  or !$uStart);  # Used to be $uSkipoff and $uEnd
 $no_sep = "";

##     Cannot use caret ^ in contributor file because ^ separates variables.  

 if($message =~ /\n\n\n/ and $uSeparator =~ /\n\n\n/) {
    $message =~ s/\n\n\n/#####\n/g;
    $uSeparator = "#####";
 }

#                        #  uSkipon:  skip first lines until skipoff
 if($uSkipon =~ /%first/ and $message =~ /$uSkipoff/ and $uSkipoff) {
   $skip_on = 'Y';
   $first_skipoff_found = '';
print "em280 $ehandle *****  SKIP ON <br>\n";
   }
 else {
   $first_skipoff_found = 'Y';
 }  

 $no_sep = 'Y' unless($message =~ /$uSeparator/ and $uSeparator);
 $uSeparator = "\^$uSeparator" if($ehandle =~ /npg|grist|kgp|push/ or $uSeparator =~ /#####/); 

print "<br>***INBOX $inboxfilename ..gEPtype $gEPtype ..h-$ehandle subj-$subject  ..sent $sentdate ..from $fromemail<br>\n" 
        if($gEPtype eq 'E');

 @emsglines = split(/\n/,$message);
 foreach $emsgline (@emsglines) {
    chomp $emsgline;

    next if(&initial_skip($emsgline));    
	if($line_cnt2 eq 0 and !$emsgline) { # get rid of initial blanks
		next;
	}
	else {
	   $line_cnt2 = $line_cnt2 + 1;
	   $top_lines2 = "$top_lines2$emsgline\n";
#	   print"em226 2ND TOPLINES $ehandle $line_cnt2 **$emsgline<br>\n" if($line_cnt2 < 8);
	} 
    &parse_email;   #separates the emails, among other things   
 } # end foreach

 &close_it;   #write last op file under certain conditions (separation)
}



## 300  PARSE THE EMAIL BODY FOR SEPARATORS, ETC

sub parse_email   #parse line-by-line - variables already initialized in separate_email_files
{ 
  $msg_on = 'Y' if($emsgline =~ /$uStart/ and ($uStart or $uStart !~ /%NA/) );  # Used to be $uSkipoff and $uEnd
  $msg_off = 'Y' if($msg_on eq 'Y' and $uStop and $uStop !~ /%NA/ and $emsgline =~ /$uStop/);

    if($msg_off and 
          $first_skipoff_found eq 'Y' and ($top_of_msg ne 'Y' or       
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
	  $msgbody = "$msgbody$emsgline\n";
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
 $sep_found = '';
 $skip_it = '';
 $skip_on = '';
 
# $skip_on = 'Y' if($uLocSep =~ /first|pre/ and $separator_cnt eq 0);

 if($emsgline =~ /$uSkipon/ and $uSkipon ) {
       $skip_on = 'Y';
#	print "em271 $ehandle **** NOT SKIPON  $skip_on  prev_skipon $prev_skipon <br>\n";
       $skipon_found = 'Y';
 }

 if($emsgline =~ /$uSkipoff/ and $uSkipoff ) {
       $skip_it = 'Y';
       $skip_on = '' if(!$prev_skipon);
#	print "em271 $ehandle **** NOT SKIPON  $skip_on  prev_skipon $prev_skipon <br>\n";
        $first_skipoff_found = 'Y';
}                                        
#	print "em330 ..skip_on $skip_on separator_cnt $separator_cnt uSkipon $uSkipon uSkipoff $uSkipoff prev_skipon $prev_skipon ln- $emsgline<br>\n" if($inboxfilename =~ /2011-07-06-094953/);

 $emsgline = &bad_stuff_convert($emsgline);

# print "em334 ..no_sep $no_sep ..uSeparator $uSeparator ..prev_skipon $prev_skipon ..uBlanks $uBlanks blanklines $blanklines uLocSep $uLocSep<br>**$emsgline<br>\n";

 if(!$no_sep and $emsgline =~ /$uSeparator/ and $uSeparator and !$prev_skipon) {	
##          How many blanks before the separator?
    if($uBlanks eq 0 or !$uBlanks or
      (($uBlanks and $blanklines >= $uBlanks and  $uLocSep =~ /first|pre/) or $uLocSep =~ /last|post/) ){
        $sep_found = 'Y';
        $separator_cnt += 1;
        $skip_on = '' if($uLocSep =~ /first|pre/);
        $headline_save = "$paragraph\n$emsgline" if($uLocSep =~ /after1st/);
    }
 }
#print "em391 ep_type $ep_type ..inboxfilename $inboxfilename inboxfilepath $inboxfilepath<br>\n";

 if($sep_found eq 'Y') {
    if($uLocSep =~ /last|post/) {
	     &write_email;
		 &addline2msg_ifnotskip;  
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

sub addline2msg_ifnotskip {
  ($skip_it, $emsgline) = &check_skip($emsgline);
# print "em375 addline skip $skip_it - $emsgline<br>\n" if($inboxfilename =~ /2011-07-06-094953/);
  if($skip_it) {
#	print"em327 $ehandle ****SKIPPED msg $emsgline<br>\n";
    $skip_it = '';
  }
  else {
    $itemline_cnt += 1;
#		print " ..$emsgline<br>\n" if($line_cnt < 30); 	$line_cnt ++;
	$emsgline =~ s/^\s+//;
	$emsgline =~ s/^ +//;
	$msgbody = "$msgbody$emsgline\n";
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
	$emsgline =~ /^--bcaec/ or
	$emsgline =~ /Content-Type:\|aspNetEmail/) {
		 $skip_it = 'Y';
	}
 
  elsif( $skip_on or
	 ($emsgline =~/$uSeparator/ and $uSeparator and $uLocSep =~ /post|pre/) or
     ($uSkip =~ /ALLCAPS/ and $emsgline !~ /[a-z]/ and $emsgline =~ /[A-Z]/) or
	 ($emsgline =~ /$uSkip/ and $uSkip and $uSkip !~ /%NA/) ) {
		 $skip_it = 'Y';
	}
	
  elsif($emsgline and $ehandle =~ /pmc/) {
      ($rs,$emsgline) = &rs_url($rs,$emsgline);  #looks for PMC's rs20 long URL and eliminates it.
      $skip_it = 'Y' if(!$emsgline);
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


##400 WRITE INCOMING EMAIL TO suggested_emailed as a selection list on the web

sub close_it
{
	#              write the email if there is a separator
  if($msgbody and (($separator_cnt > 0 and $uLocSep =~ /first|pre/) or $separator_cnt eq 0) ){
      $separator_cnt = $separator_cnt + 1;
#    		print "good ..$msgbody<br><br><br>\n" if($line_cnt < 4); 	
        $line_cnt = $line_cnt + 1;
        &write_email;
  }
  elsif($empty_msg) {
	  $fullbody = "$top_lines\n\n$message";
	  $headline = $subject if($subject);
	  $pubdate = $sentdate if($sentdate);
	  print "*** WRITE_EMAIL -> $op_filename -$separator_cnt NO MSGBODY -Writing top lines + message<br>\n";
	  &write_doc_item($op_filename);   # in docitem.pl
      $empty_msg = "";
  }
  elsif(!$email_written) {
      &write_email;
  }
  else {
	  $fullbody = "$top_lines\n\n$message";
	  $headline = $subject if($subject);
	  $pubdate = $sentdate if($subject);
	  print "*** WRITE NO_WRITE EMAIL -> $op_filename -$separator_cnt -Writing top lines + message<br>\n";
	  &write_doc_item($op_filename);   # in docitem.pl
      $empty_msg = "";
  }
  $email_written = '';
}

sub write_email 
{
 if($gEPtype eq 'P') {
	    $save_sectsubs = $sectsubs;
	    $msgbody = &parse_popnews($pdfline,$msgbody,$sectsubs);  #in smartdata.pl
	
	    $addsectsubs = $sectsubs;
        &main_storeform;   #in docitem.pl
	    return();
	
#       $docid = &get_docCount;   # in docitem.pl
#        $sysdate = &calc_date('sys',0,'+');
#		&write_doc_item($docid);   # in docitem.pl
#		$sectsubs = $save_sectsubs;
#		return();
	}
# else comes here
	my $op_filename = "$sentdatetm-$ehandle";	
	if($msgbody =~ /[A-Za-z0-9]/) {
	   $email_cnt = $email_cnt + 1;
#		  print "em471 $ehandle **** PREPARE WRITE_EMAIL skip_item $skip_item msg $msgbody<br>\n" if($ehandle =~ /push/);
	     $emailfile = "$mailpath/$op_filename-$separator_cnt.itm";
	
	     $msgbody = &parse_popnews($pdfline,$msgbody,$sectsubs);  # in smartdata.pl this is where we switch to $emessage

	   if($skip_item =~ /Y/) { 
#	      unlink "$inboxfilepath"; 
		  print "**** SKIP WRITE_EMAIL -> $op_filename -$separator_cnt from inbox $inboxfilename<br>\n";
	   }
	   else {
		  my $l_docid = "$op_filename-$separator_cnt";
		 print "**** WRITE_EMAIL -> $op_filename -$separator_cnt<br>\n";
		  &write_doc_item($l_docid);   # in docitem.pl
		  $email_written = 'T';
	   }
   }
   else {
	  $empty_msg = 'T';
	  print "**** EMPTY FOUND -> $op_filename -$separator_cnt from bkp $inboxfilename<br>\n";
   }
   &clear_doc_data;   # in docitem.pl
   &clear_doc_variables; # in docitem.pl
   &clear_helper_variables;
   &clear_msgline_variables;

##                 next email
  $msgbody = "";
  $msgbody = "$headline_save\n"  if($uLocSep =~ /after1st/);
     
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

sub line_end_fix 
{
 local($datafield) = $_[0];
 $datafield =~ s/\n\r/\n/g;
 $datafield =~ s/\r\n/\n/g;
 $datafield =~ s/\r//g;
 $datafield =~ s/=20$//g;
 $datafield =~ s/=20//g;
 $datafield =~ s/=3D=30=41//g;  #hidden line break ??
 return($datafield);
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

sub clear_message_variables {
	undef(@emsglines);
	undef(@msglines);
	$gEPtype = "";
	$msgbody = "";
	$emsgbody = "";
	$msgline = "";
	$emsgline = "";
	$top_lines = "";
	$top_lines2 = "";
	$line_cnt = 0;
    $line_cnt2 = 0;
    $email_written = '';
    $empty_msg = "";
	$end_hdr_found = "";
	$forward_on = "";
	$msg_on = "";
    $msg_off = "";
	$buffer = "";
	$handle = "";
	$ehandle = "";
	$save_handle = "";
	$contributor = "";
	$identifier = "";
	$done_handle = "";
	$keep = "";
	$ext = 'email';
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
	@msglines = ();
	@emsglines = ();
	$msgtop = "";
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
  $blankcount = 0;
  $blanklines = 0;
  $separator_cnt = 0;
  $skip_on = '';
  $skip = "";
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
  $message = "";
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
  $headline_save = "";
  $eof = "";
}

sub clear_helper_variables {
#	$msg_on = "";
#    $msg_off = "";
#	$identifier = "";
#	$done_handle = "";	
	$msgtop = "";
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
  $blankcount = 0;
  $blanklines = 0;
#  $skip_on = '';
#  $skip = "";
#  $prev_skipon  = '';
#  $skipon_found = '';
#  $blank_topmsg = 'Y';
#  $top_of_msg   = 'Y';
  $prev_line = "";
  $prevprev_line = ""; 
  $save_line = "";
  $save_prev_line = "";
  $save_prevprev_line = ""; 
  $prev_para    = "";
#  $itemline_cnt = 0;
  $msgline_link = "";
  $nextline_link = "";
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
