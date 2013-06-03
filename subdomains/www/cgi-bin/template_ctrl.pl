#!/usr/bin/perl --

# April 21, 2012
#        template_ctrl.pl


# Processes templates found in article.pl
# Merges  autosubmit doc data with a template and prints it.
# Will look for imbedded TEMPLATE first and do temporary pre-processing,
#   before subsequent merge of data and template.

## templates can come from 1. section ctrl info
##                         2. sectsub - overrides section ctrl
##                         3. parameters


sub process_template
{
 my($template,$print_it,$email_it,$htmlfile_it,$ctr) = @_;
 $printmode = 'M';
 $DOCARRAY{'cPage'}       = $cPage;
 $DOCARRAY{'cTitle'}      = $cTitle;
 $DOCARRAY{'cTitle2nd'}   = $cTitle2nd;
 $DOCARRAY{'cSubtitle'}   = $cSubtitle;
 $DOCARRAY{'cSubid'}      = $cSubid; 
 $DOCARRAY{'rSectsubid'}  = $rSectsubid;
 $DOCARRAY{'thisSectsub'} = $listSectsub;
 $DOCARRAY{'cSectsubid'}  = $cSectsubid;

  if($print_it eq 'Y') {
     $nowPEH = 'P';
     $now_print = 'Y';
     &template_merge_print($template,$ctr); 
     $now_print = 'N';
  }
  if($email_it eq 'Y') {
     $nowPEH = 'E';
     $now_email = 'Y';
     &template_merge_print($template,$ctr);
     $now_email = 'N';
  }
  if($htmlfile_it eq 'Y') {
     $nowPEH = 'H';
     $now_htmlfile = 'Y';
     $now_print = 'Y' if($print_it eq 'Y')
     &template_merge_print($template,$ctr);
     $now_htmlfile = 'N';
     $now_print = 'N';
  }
}

sub process_inside_template
{
 my ($template,$docid) = @_;
 $printmode = 'I'; # Inside op goes to a file with the docid as a name.
 my $beginline = "";
 my $endline = "";
 $now_htmlfile = 'Y';
 $now_print eq 'N';
 $insidefile = "$templateMidpath$slash$docid.mid";
#	print "tmp60 @@ FOUND inside_template docid $docid ,,aTemplate $aTemplate ..docary_headline $DOCARRAY{'headline'} ...insidefile $insidefile<br>\n";
 
 $INSIDE = "INSIDE-$docid-$ctr";
 open($INSIDE, ">$insidefile") or die "tem58 cannot open outfile $outfile<br>\n";
 $templatefilepath = "$templatepath$slash$template.htm";
 open(TPLINSIDE, $templatefilepath) or die "tmp55 cannot open template $templatefilepath<br>\n";	

 while(<TPLINSIDE>)  {
     chomp;
     $line = $_;
# print "tmp68 template ln $line INSIDE $INSIDE<br>\n";
    if($line =~ /\[([A-Za-z0-9_]+)\]/ or $line =~ /\[([A-Za-z0-9_]+.*)\]/ ) {
		   	$linecmd = $1;
		   	if($linecmd =~ /[a-z]/ and $linecmd !~ /=/) {  #data plugins are lowercase or mixed case
			    $line =~ s/\[(\S+)\]/$DOCARRAY{$1}/g;      #substitute data plugins from DOCARRAY
		   	    print $INSIDE "$line\n";
		   	}
			else {
	           ($beginline,$endline) = split(/\[$linecmd\]/,$line,2);
	           $linecmd = "[$linecmd]";
	           print $INSIDE $beginline if($beginline =~ /[A-Za-z0-9]/);
	      	   &do_imbedded_commands($linecmd,"I");
	           print $INSIDE "$endline\n" if($endline =~ /[A-Za-z0-9]/);
		   	}
	 }
     else {
    	print $INSIDE "$line\n";
     }
     last if($stop eq 'Y');
 }     ## end while
   close(TPLINSIDE);
   close($INSIDE);
   $ctr = $ctr+1;
}
  

##  00050 ### MERGE THE TEMPLATE WITH THE DATA

sub template_merge_print
{
 my ($aTemplate,$ctr) = @_;
#  Template named at start of program (aTemplate) overrides all others
#   - except aTemplate is overridden for 'generate_WOA_html' (list of docs) routine.
#   ..cTemplate is from section control
#   .. straightHTML is determined from the doc
 $tTemplate = $cTemplate if($cTemplate);
 $tTemplate = $dTemplate if($dTemplate and $cSectsubid !~ /$convertSS/);
 $tTemplate = $aTemplate if($aTemplate);

 if($tTemplate eq 'default') {
     $tTemplate = $cTemplate;
 }

 ($template,$rest) = split(/;/,$tTemplate,2);
 $templfile = "$template$nowPEH";

 if($tTemplate =~ /;/) {
    @templates = split(/;/,$tTemplate);
 }
 else {
    @templates = $tTemplate;
 }
 $midfile = "$templateMidpath$slash$templfile-$ctr.mid";
 $MIDTEMPL = "MIDTEMPL$ctr";
 open($MIDTEMPL, ">$midfile") or die "tem80 cannot open midfile $midfile<br>\n";
   foreach $template (@templates) {	
      &do_template($template,$ctr);
}
close($MIDTEMPL);
 
 $OUTFILE = "FILEOUT-$ctr";
 open($OUTFILE, ">>$outfile") if($outfile);
 $javascript = 'N';
 $template_path1 = "$templateMidpath/$templfile-$ctr.mid";
 $template_path2 = "$templateMidpath/$templfile-$ctr.mid";   ## ?????
 $ctr=$ctr+1;

 if (-f "$template_path2") {
	$MIDTEMP2 = "MIDTEMP2-$ctr";
    open($MIDTEMP2, "$template_path2") or die("cant open");
#    open($MIDTEMP2, "$templateMidpath/$templfile-$ctr.mid") or die("cant open");
  }
 else {
    &printUserMsgExit ("ERROR: reason: template_merge $templateMidpath/$templfile-$ctr\.mid not found .. could not open<br>\n");
 }

#return;
 my $img_ctr = 0;
 while(<$MIDTEMP2>)
 {
     chomp;
     $line = $_;

# Javascripts bracket used for indexes CONFLICTS
##      with brackets used for data substitution
     $javascript = 'Y' if($line =~ /\<[sS][cC][rR][iI][pP][tT]/ or $line =~ /\[JS_ON\]/);
     $javascript = 'N' if($line =~ /\<\/[sS][cC][rR][iI][pP][tT]/ or $line =~ /\[JS_OFF\]/);

     if($line =~ /docfullbody/) {
     	$docfullbody = $DOCARRAY{'fullbody'};
        $docfullbody =~ s/\"/&quote\;/g;
        $DOCARRAY{'fullbody'} = $docfullbody;
     }
     $line =~ s/\[(\S+)\]/$DOCARRAY{$1}/g  if($javascript =~ /N/);

#	print "tem119 after regexp  $DOCARRAY{'docid'} line $line<br>\n";     
     if($cMobidesk =~ /mobi/ or $qMobidesk =~ /mobi/) { # if mobile version
         $line =~ s/<!--.*-->// ;                        # get rid of comments
         if($line =~ /<img/) {
            $line =~ s/src=".*"/src=""/ if($img_ctr > 1); # get rid of image if not the logo
            $img_ctr = $img_ctr + 1;
         }
         else {
	        $line =~ s/src=".*"/src=""/;  #get rid of iframe URL 
         }
     }
 ##                     in case we want to email it.
     $email_msg = "$email_msg$line\n" if($now_email =~ /Y/);

     if($line !~ /\[JS_ON\]/) {
        print $OUTFILE "$line\n" if($outfile and $now_htmlfile =~ /Y/);
        print"$line\n" if($now_print eq 'Y');
     }
 }
 close($MIDTEMP2);
#return;
 close($OUTFILE) if ($outfile);
	
 unlink "$template_path2";
 @templates = "";
}


## 080

sub do_template
{
 my($template,$ctr) = @_;
 $printmode = 'M';

 $default_class = "";

 unless($template) {
	$template = $cTemplate;
 }

 if($cStyleclass =~ /[A-Za-z0-9]/) {
	$default_class = $cStyleclass;
 }
 elsif($template =~ /quote/) {
	$default_class = 'redquote';
 }
 elsif($template =~ /[iI]tem$/ or $template =~ /sidebar/) {
	$default_class = $template;  # class name is the same as the template
 }
 $default_2nd_class = "";

 $template =~ s/\s+//g;    ## remove spaces
# print "tmp220 ..template $template<br>\n";

 $templatefile = "$templatepath/$template\.htm";

unless(-f "$templatefile") {
    $errmsg = "tem170 template= $template not found. ..templatepath $templatepath ..c $cTemplate ..d $dTemplate ..a $aTemplate ..cSectsubid $cSectsubid<br>\n";
    &printSysErrExit($errmsg);
 }

# unless($template =~ /select_top|select_end|select_end0/ and $cmd ne 'print_select') {
   $javascript = 'N';
   open(TEMPLATE, "$templatefile") or die "art1081 cannot open template $templatefile";
   while(<TEMPLATE>)  {
     chomp;
     $line = $_;

#        Process IN-LINE TEMPLATE
     if($line =~ /TEMPLATE=/) {
        ($rest, $intemplate) = split(/=/,$line);
         ($intemplate,$rest) = split(/]/,$intemplate);

         if($intemplate =~ /contactWOA/) {
             &do_intemplate if($cmd ne 'print_select');
         }
         elsif($intemplate =~ /logo/) {
             &do_intemplate if($cLogo eq 'L');
         }
         elsif($intemplate =~ /saveSummaryJS/) {
##             &do_intemplate if(-f $futzingON);
         }
         else {
             &do_intemplate;
         }
     }
     elsif($line =~ /OWNER_REVIEW_TEMPLATE/) {	 #later we will get sectsubs
             $intemplate = "ownerEventItem";     # and get the template from that sectsubs
             &do_intemplate; 
     }
     else {
          &process_imbedded_commands;
          last if($stop eq 'Y');
     }
   }     ## end while
   close(TEMPLATE);
# }
}


## 081

sub do_intemplate
{
 ($intemplate, $rest) = split(/\]/, $intemplate);

 if($intemplate =~ /select_top|select_end/ and $cmd ne 'print_select') {
 }
 else {
    if(-f "$templatepath/$intemplate.htm") {
      open(INTEMPL, "$templatepath/$intemplate.htm");
      while(<INTEMPL>) {
          chomp;
          $line = $_;
##              Javascripts bracket used for indexes CONFLICTS
##              with brackets used for data substitution
          $javascript = 'Y' if($line =~ /\<[sS][cC][rR][iI][pP][tT]/ or $line =~ /\[JS_ON\]/);
          $javascript = 'N' if($line =~ /\<\/script/ or $line =~ /\[JS_OFF\]/);
##print "82 javascr-$javascript $line<br>\n" if($line =~ /onClick/);
          &process_imbedded_commands;
          last if($stop eq 'Y');
      }
      close(INTEMPL);
    }
    else {
      $errmsg = "85 No intemplate $intemplate in $template found";
      &printSysErrExit($errmsg);
    }
 }
 $intemplate = "";
}


##### 090     PROCESS IMBEDDED COMMANDS

sub process_imbedded_commands
{
	             # cmd must be all caps & only one per line
##print "90 javascr-$javascript $line<br>\n" if($line =~ /onClick/);
   if($javascript =~ /N/ and ($line =~ /\[([A-Z0-9_]+)\]/ or $line =~ /\[([A-Z0-9_]+.*)\]/ ) ) {
   	$linecmd = $1;
   	if($linecmd =~ /[a-z]/ and $linecmd !~ /=/) {  #data plugins are lowercase or mixed case
   	   &print_output($printmode,"$line\n");
   	}
   	else {
           ($beginline,$endline) = split(/\[$linecmd\]/,$line,2);
           $linecmd = "[$linecmd]";
           &print_output($printmode, $beginline) if($beginline =~ /[A-Za-z0-9]/);
##   print "<font size=1 face=verdana color=#CCCCCC>bb-$beginline c-$linecmd e-$endline</font><br>\n";
      	   &do_imbedded_commands($linecmd,"M");
   	}
   }
   else {
    	&print_output($printmode, "$line\n");
   }
}

sub print_output {
	my ($printmode,$output) = @_;  #not the same output as in outputfile
	
# print "tmp327 printmode $printmode now_print $now_print ..now_htmlfile $now_htmlfile template $template op $output<br>\n";
	if($printmode =~ /M/) {
		print $MIDTEMPL "$output";
	}
	elsif($printmode =~ /I/) {
		print $INSIDE "$output";	
	}
	elsif($printmode =~ /O/) {
		print $OUTFILE "$output";
#        print"$output" if($now_print =~ /Y/);	
	}
	elsif($printmode =~ /P/) {
		print "$output";		
	}
}


sub do_imbedded_commands
{
   my ($linecmd,$printmode) = @_;   #  M=midtemplate  P=Print

   if($linecmd =~ /\[ADVANCE\]/ and ($access =~ /[ABCD]/ or $op_userid =~ /P0004|P0083|P0008/) ) {
          &print_output($printmode,"<br><br><input type=\"checkbox\" name=\"advance\" ");
          &print_output($printmode," value=\"Y\"><b>Advance this item</b> to\n");
          if($action eq 'new') {
          	&print_output($printmode,"NEEDS SUMMARY list <font size=1 face=\"comic sans ms\">(From where you can add a summarization)</font>\n");
          }
          else {
          	&print_output($printmode,"preliminary <b>NEWS DIGEST</b> page - ready for publication\n");
          }
          &print_output($printmode,"<font size=1 face=\"comic sans ms\"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n");
          &print_output($printmode, "(Use only when admin review needs to be bypassed)</font><p>\n");
   }

   elsif($linecmd =~ /\[LAST_FTPDATE\]/) {
   	if(-f $lastFTPfile) {
           @datetime = stat($lastFTPfile);
           my $lastFTPdate = &datetime_prep('yyyy-mm-dd',@datetime);
           &print_output($printmode, "$lastFTPdate");
        }
   }

   elsif($linecmd =~ /\[CGISITE\]/) {
       &print_output($printmode, "$cgiSite");
   }

   elsif($linecmd =~ /\[CGIPATH\]/) {
       &print_output($printmode, "$cgiPath");
   }

   elsif($linecmd =~ /\[SCRIPTPATH\]/) {
       &print_output($printmode, "$scriptpath");
   }

   elsif($linecmd =~ /\[PUBLICURL\]/) {
       &print_output($printmode, "$publicUrl");
   }

   elsif($linecmd =~ /\[PAGES_INDEX\]/) {  # 'N' = not end of subsection
       &print_pages_index($pg_num,$cSectsubid,$itemMax,$totalItems,$pg1max,'N') if($ckItemcnt >= $totalItems);
   }

   elsif($linecmd =~ /\[END_OF_PAGES_INDEX\]/) {  # 'Y' = end of subsection
       &print_pages_index($pg_num,$cSectsubid,$itemMax,$totalItems,$pg1max,'Y'); ## in sections.pl
   }

   elsif($linecmd =~ /\[OPAX\]/) {
		&print_output($printmode, "$operator_userid");
   }

   elsif($linecmd =~ /\[DIV_CLASS\]/) {
		&print_output($printmode, "<div $dBoxStyle</div>") if($dBoxStyle);
   }

   elsif($linecmd =~ /\[END_DIV_CLASS\]/) { 
		&print_output($printmode,  "</div>") if($dBoxStyle);
   }

   elsif($linecmd =~ /\[FILEDIR\]/) {
       &print_qkchg_filesdirs;
   }

   elsif($linecmd =~ /\[DBTABLES\]/) {
      &list_functions;  #in dbtables_ctrl.pl
   }

   elsif($linecmd =~ /\[RTCOL_TOP\]/ and $cRtCol eq 'R') {
       &print_output($printmode, "<TABLE align=right width=35% cellspacing=5>");
   }

   elsif($linecmd =~ /\[FLYIMG=\]/) {
       ($rest,$imgname) = split(/\[FLYIMG=\]/,$line);
       ($imgname,$rest)  = split(/]/,$imgname);

       if($fly =~ /fly/ or $cFly =~ /fly/) {
          &print_output($printmode, "\"$publicUrl/$imgname\"");
       }
       else {
       	  &print_output($printmode, "\"/$imgname\"");
       }
   }

   elsif($linecmd =~ /\[FILE=\]/) {     #  DOESN'T WORK FOR ARTICLES INSIDE A BODY
       ($rest,$filename) = split(/\[FILE=\]/,$line);
       ($filename,$rest)  = split(/]/,$filename);
       $line = "";
       $now_print = 'Y';
      $filepath = "$templateMidpath$slash$filename.mid";  # $filename = $docid
       open(INSIDEARTICLE, ">$filepath") or die "tem55 cannot open midfile $midfile<br>\n";	
	   while(<INSIDEARTICLE>) {
	        chomp;
	        my $inline = $_;
	        &print_output('M', $inline);
	      }
	    close(INSIDEARTICLE);
   }

   elsif($linecmd =~ /\[BEGIN_TR\]/) {
       &print_output($printmode, "<tr><td>");
   }

   elsif($linecmd =~ /\[END_TR\]/) {
       &print_output($printmode, "<\/td>");
   }

   elsif($linecmd =~ /\[RTCOL_END\]/) {
       &print_output($printmode, "<\/td><\/table>");
   }

   elsif($linecmd =~ /\[BOXCLASS\]/) {
		&print_output($printmode, " class=\"$dStyleClass\" ") if($dStyleClass);
   }

   elsif($linecmd =~ /\[2ND_CLASS\]/) {
		&print_output($printmode, " $dBoxStyle") if($dBoxStyle);
   }

   elsif($linecmd =~ /\[HITCOUNT\]/) {
       &get_hitcount;
       &print_output($printmode, "$hitCount");
   }

   elsif($linecmd =~ /\[USER\]/) {
	   &get_summarizer_name($sumAcctnum);   # in editor.pl
   }

    elsif($linecmd =~ /\[CMD_APP\]/) {
    &print_output($printmode, 'start_acctapp') unless($uid > 0);
    &print_output($printmode, 'update_acct')   if($uid > 0);
    }

   elsif($linecmd =~ /\[HIDEDIV\]/) {
       &print_output($printmode, " class=\"hide\" ") unless($operator_access =~ /[ABCD]/ );
   }

   elsif($linecmd =~ /\[APPROVED_CHECKYES\]/) {
       &print_output($printmode, " checked ") if($uapproved == 1);
   }

   elsif($linecmd =~ /\[APPROVED_CHECKNO\]/) {
       &print_output($printmode, " checked ") unless($uapproved == 1);
   }

   elsif($linecmd =~ /\[CHECKED=*.\]/) {
      my ($rest, $value) = split(/=/,$linecmd);
      ($value,$rest)  = split(/\]/,$value);
      &print_output($printmode, " checked ") if($upayrole) =~ /$value/;
   }

   elsif($linecmd =~ /\[APPLY_CHANGE\]/) {
       &print_output($printmode, "CHANGE") if($uid > 0);
       &print_output($printmode, "APPLY")  unless($uid > 0);
   }

   elsif($linecmd =~ /\[SUBTITLE\]/) {
       &print_output($printmode, "<br><br><br><center><font face=arial size=5><b>$cSubtitle</b><\/font><\/center>")
            if($cSubtitle);
   }

   elsif($linecmd =~ /\[CTITLE\]/) {
     if($cTitle =~ /[A-Za-z0-9]/) {
	    &print_output($printmode, "\"$cTitle\"");
	 }
	 else {
		&print_output($printmode, "this ");
	 }
   }

   elsif($linecmd =~ /\[TODAY\]/ or $linecmd eq 'TODAY') {
       $month = @months[$nowmm-1];
       &print_output('P', "$month $nowdd, $nowyyyy") if($printmode eq 'P');       
       &print_output($printmode, "$month $nowdd, $nowyyyy") if($printmode =~ /[TM]/);
   }

   elsif($linecmd =~ /\[BLOCKQUOTE\]/) {
       &print_output($printmode, "<BLOCKQUOTE>\n") if($cBlockquote eq 'B');
   }

   elsif($linecmd =~ /\[MODDELNEW\]/) {
         &do_modelnew;
   }

   elsif($linecmd =~ /\[SYSDATE\]/) {
         &print_output($printmode, "$nowyyyy-$nowmm-$nowdd-$nowhh-$nowmn-$nowss");
   }

   elsif($linecmd =~ /\[PRIORITY\]/) {
         &get_priorities($priority);
   }

   elsif($linecmd =~ /\[PUBDAY\]/) {
	      ($pubyear,$pubmonth,$pubday) = split(/-/,$pubdate,3);
          &print_output($printmode, "$pubday") if($pubday ne '00');
          &print_output($printmode, " ") if($pubday eq '00');
   }

   elsif($linecmd =~ /\[PUBMONTHS\]/) {
	    ($pubyear,$pubmonth,$pubday) = split(/-/,$pubdate,3); # needed for this and Day, year subroutines
          &get_pubmonths;
   }

   elsif($linecmd =~ /\[PUBYEARS\]/) {
         &get_pubyears;
   }

   elsif($linecmd =~ /\[EXPDAY\]/) {
          &print_output($printmode, "$expday") if($expday ne '00');
          &print_output($printmode,  " ") if($expday eq '00');
   }

   elsif($linecmd =~ /\[EXPMONTHS\]/) {
          &get_expmonths;
   }

   elsif($linecmd =~ /\[EXPYEARS\]/) {
         &get_expyears;
   }

   elsif($linecmd =~ /\[SRCDATE\]/) {
      &print_srcdate;  # in date.pl
   }

   elsif($linecmd =~ /\[SOURCE\]/) {
      if($source =~ /\(select one\)/
            or $source !~ /[A-Za-z0-9]/) {
      	 $source = "";
      }
      else {
	     if($sstarts_with_the =~ /T/) {
		     $source = "The $source";
	     }
         &print_output($printmode, "$source");
      }
  }

  elsif($linecmd =~ /\[AUTHOR\]/) {
     if($author and !$skipauthor) {
	    &print_output($printmode, "&nbsp;&nbsp;By: $author");
     }
  }

  elsif($linecmd =~ /\[DATE_SOURCE\]/) {
      &print_srcdate;  # in date.pl
      if($source =~ /\(select one\)/) {
      	$source = "";
      }
      else {
        &print_output($printmode, "$source");
      }
  }

  elsif($linecmd =~ /\[HEADLINE\]/) {
      &print_output($printmode, "\r\r") if($now_email eq 'Y');
      &print_output($printmode, "<p>") if($now_print eq 'Y');
# changed meaning of $regionhead - now: Y = 'override' region in headline
      if($headline !~ /$region/ and $region !~ /Global/ and $regionhead = 'N') {
          &print_output($printmode, "$region: $headline");
      }
      else {
          &print_output($printmode, "$headline");
      }
      &print_output($printmode, "\r") if($now_email eq 'Y');
      &print_output($printmode, "<br>") if($now_print eq 'Y');
  }

## 0100

   elsif($linecmd =~ /\[SOURCES\]/) {
         $sourcefound = &get_sources('F',$source);  #print source = 'F: form'
   }

   elsif($linecmd =~ /\[OTHERSOURCE\]/) {
      if( ($docid =~ /[0-9]/) and ($sourcefound =~ /N/) ) {
         &print_output($printmode, $source);
      }
   }

   elsif($linecmd =~ /\[REGIONS\]/) {
	    &get_regions('F',$region);  # print_region= F=form, in regions.pl 
   }

   elsif($linecmd =~ /\[LIKELYREGIONS\]/ and $region =~ /;/) {
      	&print_output($printmode, "<select size=2 multiple name=\"region$pgitemcnt\">\n");
        &print_likely_regions;              # in controlfile.pl
        &print_output($printmode, "<\/select><br>\n");
   }

   elsif($linecmd =~  /\[REGION\]/) {
       &print_output($printmode, "$region") if($region !~ /;/);
   }

   elsif($linecmd =~ /\[REGIONHEAD\]/) {
        &print_output($printmode, " checked ") if($regionhead eq 'Y');
   }

   elsif($linecmd =~ /\[SSTARTSWTHE\]/) {
        &print_output($printmode, " checked ") if($sstarts_with_the eq 'T');
   }

   elsif($linecmd =~ /\[RSTARTSWTHE\]/) {
        &print_output($printmode, " checked ") if($rstarts_with_the eq 'T');
   }

   elsif($linecmd =~ /\[ALINK\]/) {
         &do_link if($link =~ /[A-Za-z0-9]/  or $selfLink =~ /Y/);
   }

   elsif($linecmd =~ /\[LINK\]/) {
         &print_output($printmode, "$link");
   }

   elsif($linecmd =~ /\[A_NAME\]/) {
	     if($rDocLink =~ /doclink/) {
		     &print_output($printmode, "<a name=$docid><\/a>\n");
	     }
	     else {
		     &print_output($printmode, "<!-- doc $docid  - - ?display%login%$docid%-->");
	     }
   }

   elsif($linecmd =~ /\[END_ALINK\]/) {
          &print_output($printmode, "</a>") if($link =~ /[A-Za-z0-9]/  or $selfLink =~ /Y/);
   }

   elsif($linecmd =~ /\[HLINK\]/) {
   	 $link = "http://$link" if($link !~ /http:\/\//);
         $link = "\"$link\"";
         &print_output($printmode, "$link");
   }

   elsif($linecmd =~ /\[LINK\]/) {
         &print_output($printmode, "$link\r")   if($link =~ /[0-9A-Za-z]/ and $now_email eq 'Y');
         &print_output($printmode, "$link<br>") if($link =~ /[0-9A-Za-z]/ and $now_print eq 'Y');
   }

   elsif($linecmd =~ /\[SELECT_TEMPLATE\]/) {
         &print_select_template;
   }

   elsif($linecmd =~ /\[SELECT_ALL_TEMPLATES\]/) {
         &print_select_all_templates;
   }

   elsif($linecmd =~ /\[SELECT_FORMAT\]/) {
         &print_select_format;
   }

   elsif($linecmd =~ /\[STRAIGHT_CHECK\]/) {
         &print_output($printmode, " checked") if($straightHTML eq 'Y');
   }

   elsif($linecmd =~ /\[PERIOD_RADIOS\]/) {
         &print_period_radios;
   }

   elsif($linecmd =~ /\[NEEDSUM_RADIOS\]/) {
         &print_needsum_radio_buttons;
   }

   elsif($linecmd =~ /\[HEADLINE_PERIOD\]/ and $headline =~ /[A-Za-z]/) {
      if($regionhead eq 'Y' and $headline !~ /$region/
         and $region =~ /[A-Za-z0-9]/ and $region !~ /Global/) {
        &print_output($printmode, "$region: $headline");
      }
      else {
        &print_output($printmode, "$headline");
      }
   }

   elsif($linecmd =~ /\[SUBHEADLINE\]/ and $subheadline) {
       &print_output($printmode, "<h5>$subheadline</h5>");
   }

   elsif($linecmd =~ /\[BODY\]/) {
		 $body = &do_body_comment('body',$body);    #in docitem.pl
	     &print_output($printmode, "$body");
   }

   elsif($linecmd =~ /\[COMMENT\]/ and $comment =~ /[A-Za-z0-9]/) {
         $comment = &do_body_comment('com',$comment);
         &print_output($printmode, "<div class=\"comment\">$comment</div>\n");
   }

   elsif($linecmd =~ /\[COMMENT\]/) {
       if($comment eq "") {}
       else {
          &print_output($printmode, "<div class=\"comment\">$comment</div>\n");
        }
   }

   elsif($linecmd =~ /\[POINTS\]/) {
         &do_points;
   }

   elsif($linecmd =~ /\[FULLBODY\]/) {
         &do_fullbody;
   }

   elsif($linecmd =~ /\[1ST5_LINES\]/) {
         &do_5lines;
   }

   elsif($linecmd =~ /\[FREEVIEW_CHECK\]/) {
         &print_output($printmode, " checked") if($freeview eq 'Y');
   }

   elsif($linecmd =~ /\[SELFLINK_CHECK\]/) {
         &print_output($printmode, " checked") if($selfLink eq 'Y');
   }

   elsif($linecmd =~ /\[HANDLE\]/) {
         &do_handle if($skiphandle ne 'Y' and $cMobidesk !~ /mobi/);
   }

   elsif($linecmd =~ /\[SKIP_HANDLE\]/) {
         &skip_handle;
   }

   elsif($linecmd =~ /\[CHK_URL\]/) {
         &check_url;
   }

   elsif($linecmd =~ /\[KEYWORDS\]/) {
         &print_keyword_dropdown;
   }

   elsif($linecmd =~ /\[STYLES\]/) {
         &get_styles;
   }

## 0110

   elsif($linecmd =~ /\[NEEDSSUM\]/) {
        &print_output($printmode, " checked ") if($needsSum eq 'Y');
   }

   elsif($linecmd =~ /\[CKENDTABLE\]/) {
        &print_output($printmode, " checked ") if($endtable eq 'Y');
   }

   elsif($linecmd =~ /\[REDARROW\]/) {
	    &do_redarrow('') if($rDoclink =~ /doclink/);
   }

   elsif($linecmd =~ /\[REDAROWHEAD\]/) {
    &do_redarrow('head') if($rDoclink =~ /doclink/);
   }

   elsif($linecmd =~ /\[EXTRACT\]/) {
	    if($body !~ /[A-Za-z0-9]/ and $needsum eq 1) {
		    &print_output($printmode, "&nbsp;<i>(Needs Summarization)</i>");		
	    }
	    if($needsum =~ /[67]/) {
		    &print_output($printmode, "&nbsp;<i>(Extract)</i>");
	    }
	    elsif($needsum =~ /[45]/) {
		    &print_output($printmode, "&nbsp;<i>(Key points)</i>");
	    }
	    elsif($needsum =~ /[89]/) {
		    &print_output($printmode, "&nbsp;<i>(Summary)</i>");
	    }
   }

   elsif($linecmd =~ /\[DOCLINK\]/) {
	  &print_output($printmode, "<a href=\"http://$scriptpath/article.pl?display%login%$docid%$qSectsub\">$docid</a>");
   }

   elsif($linecmd =~ /\[OWNERDOCLINK\]/) {
	  my $o_logintemplate = $OWNER{ologintemplate};
	  &print_output($printmode, "<a href=\"http://$scriptpath/article.pl?display%$o_logintemplate%$docid%$qSectsub\">$docid</a>");
   }
   elsif($linecmd =~ /\[OWNERCHANGEADD\]/) {
	  if(!$docid) {
		&print_output($printmode, "<strong class=\"red\"><big>A-1. <\/big><\/strong><strong style=\"font-family:geneva;font-size:1.0em;\">Add new webpage item<\/strong>");
		&print_output($printmode, "<input name=\"action\" type=\"hidden\" value=\"new\" >");
	  }
	  else {
	     &print_output($printmode, "<input name=\"action\" type=\"radio\" value=\"mod\" checked=\"checked\"><strong class=\"red\"><big>A-1.<\/big><\/strong><strong style=\"font-family:geneva;font-size:1.0em;\"> CHANGE item below &nbsp;  &nbsp; or</strong>&nbsp;&nbsp;");
		 &print_output($printmode, "<input name=\"action\" type=\"radio\" value=\"new\" onclick=\"clearItem();\"><strong class=\"red\"><big>A-2. <\/big><\/strong><strong>ADD a new item<\/strong> ");
      }
   }

   elsif($linecmd =~ /\[OWNER_CSS\]/) {
	  if($owner) {
	     my $csspath = $OWNER{'ocsspath'};
	     &print_output($printmode, "$csspath");
      }
   }

   elsif($linecmd =~ /\[OWNER_SAVEPAGE\]/) {
	  my $ownerwebdir = "$owner" . "_webpage";
	     &print_output($printmode, "http://$publicUrl/php/savepage.php?$ownerwebdir/index.php%$ownerwebdir/index.html");
   }

   elsif($linecmd =~ /\[REFRESH_URL\]/) {
      ($userid,$rest) = split(/;/,$userid);
      my $oupdatetemplate  = $OWNER{'oupdatetemplate'};
      $ownersectsub = $OWNER{'odefaultSS'} unless($ownersectsub);
	  &print_output($printmode, "http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%$oupdatetemplate%$ownersectsub%$owner%$userid%$ownerSubs");
   }

   elsif($linecmd =~ /\[PRIORITY_STAR\]/) {
       &print_output($printmode, "<img src=\"\/star.jpg\" alt=\"high priority\" border=0 height=11 width=11 valign=bottom>")
         if($priority =~ /6/);
       &print_output($printmode, "<img src=\"\/stars_two.jpg\" alt=\"highest priority\" border=0 height=11 width=22 valign=bottom>")
         if($priority =~ /7/);
   }

   elsif($linecmd =~ /\[OOPS\]/) {
       if($sectsubs =~ /$newsdigestSS/ and $qSectsub =~ /$headlinesSectid/) {
	       &print_output($printmode, "&nbsp; ..Oops! This article has already been summarized. Will fix this soon (I hope)...&nbsp;");
       }
   }

   elsif($linecmd =~ /\[SUMMARIZE_IT\]/) {
        &print_output($printmode, "<input type=\"radio\" name=\"action\" ");
        &print_output($printmode, " value=\"summarize\"> Summarize it. <br>\n");
   }

   elsif($linecmd =~ /\[ENDTABLE\]/ and $endtable =~ /Y/) {
      &print_output($printmode, "<\/td><\/table>");
      &print_output($printmode, "<\/div>");
      &print_output($printmode, "<\/ul>");
      &print_output($printmode,  "<\/blockquote>");
      &print_output($printmode, "<\/center>");
   }

   elsif($linecmd =~ /\[ACRONYMS\]/) {
	require 'dbtables_ctrl.pl';
      &prt_acronym_list;       #in dbtables_ctrl.pl;
   }

   elsif($linecmd =~ /\[THISSECTION\]/) {
       if( ($action ne 'new') and ($listSectsub ne "") ) {
          &print_output($printmode, "<p>This section: $listSectsub<p>\n");
       }
   }

   elsif($linecmd =~ /\[CURRENT_SECTIONS\]/) {
         &get_current_sections;     # in sectsubs.pl
   }

   elsif($linecmd =~ /\[NEWS_ONLY_SECTIONS\]/) {
         &get_news_only_sections;     # in sectsubs.pl
   }
   elsif($linecmd =~ /\[OWNER_SECTIONS\]/) {  # CSWP and Maidu
         &get_owner_sections($ownerSections);   # in sectsubs.pl	
   }

   elsif($linecmd =~ /\[POINTS_SECTIONS\]/) {
         &get_points_sections;     # in sectsubs.pl
   }

   elsif($linecmd =~ /\[NEWS_SECTION\]/) {
         &get_news_section if($sectsubs =~ /$summarizedSS/);  # in sectsubs.pl
   }
   elsif($linecmd =~ /\[ADD_SECTIONS\]/) {
         &get_addl_sections(_,_,'');  # in sectsubs.pl
   }
   elsif($linecmd =~ /\[ADD_SECTIONS_INFO\]/) {
         &get_addl_sections(_,_,'I'); # in sectsubs.pl
   }
   elsif($linecmd =~ /\[SELECT_MOVE_SECTIONS\]/) {
         &prt_move_mauve_pages;   # in sectsubs.pl
   }
   elsif($linecmd =~ /\[PHP_DO_PAGES\]/) {
         &php_do_pages;  # in sectsubs.pl
   }
   elsif($linecmd =~ /\[ADD_NON_COUNTRIES\]/) {
         &get_addl_sections(O,2,''); # in sectsubs.pl
   }

   elsif($linecmd =~ /\[ADD_COUNTRIES\]/) {
         &get_addl_sections(C,1,'');  # in sectsubs.pl
   }

      elsif($linecmd =~ /\[OTHER_SECTIONS\]/) { # Admin
         &get_addl_sections(A,3,'');  # in sectsubs.pl
   }

   elsif($linecmd =~ /\[SORTORDER\]/) {
         &get_sortorder;
   }

   elsif($linecmd =~ /\[SUMMARIZER_NAME\]/) {
         &print_user_name($sumAcctnum,'Summarizer');  ## found in editor.pl
   }

   elsif($linecmd =~ /\[OPERATOR_NAME\]/) {
         &print_user_name($op_userid,'Current User');  ## found in editor.pl
   }

   elsif($linecmd =~ /\[SUGGESTOR_NAME\]/) {
         &print_user_name($suggestAcctnum,'Suggestor');  ## found in editor.pl
   }

   elsif($linecmd =~ /\[STD_ITEM_TOP\]/) {
	    &print_output($printmode, "<a name=\"$docid\"></a>\n");
	 	if($cmd =~ /print_select/ or  $savecmd =~ /print_select/ or $sectsubs =~ /Suggested_emailedItem/) {
          &print_output($printmode, "<input type=\"checkbox\" id=\"selitem$pgitemcnt\" name=\"selitem$pgitemcnt\" value=\"Y\">\n");
          &print_output($printmode, "<input type=\"hidden\" name=\"sdocid$pgitemcnt\" value=\"$docid\">\n");
        }
   }
   elsif($linecmd =~ /\[SEL_ITEM_TOP\]/) {
	  &print_output($printmode, "<input type=\"checkbox\" id=\"selitem$pgitemcnt\" name=\"selitem$pgitemcnt\" value=\"Y\">\n");
      &print_output($printmode, "<input type=\"hidden\" name=\"sdocid$pgitemcnt\" value=\"$docid\">\n");
   }

   elsif($linecmd =~ /\[END_SELECT\]/and $cmd eq 'print_select') {
##   print "art120 END_SELECT pgItemnbr $pgItemnbr<br>\n";
         if($pgItemnbr ne "" and $pgItemnbr > 0) {
            $pgItemnbr = $pgItemnbr + 1;
            $pgitemcnt = &padCount4($pgItemnbr);
         }
         &print_output($printmode, "<input type=\"hidden\" name=\"selitem$pgitemcnt\" value=\"Z\">\n");
   }

   elsif($linecmd =~ /\[FLOATSTYLE\]/) {
	     &print_output($printmode, " style=\"float:right;\"") if($savecmd = 'print_select');
   }

   elsif($linecmd =~ /\[EMAILED\]/) {
      if($cSubid eq $emailedSub) {
         &print_output($printmode, "<input type=\"hidden\" name=\"emailed$pgitemcnt\" value=\"Y\">\n");
      }
      else {
          &print_output($printmode, "<input type=\"hidden\" name=\"emailed$pgitemcnt\" value=\"N\">\n");
      }
   }
   elsif($linecmd =~ /\[THISSECTSUB\]/) {
	  &get_section_ctrl($thisSectsub);   #in sectsubs.pl
      if($thisSectsub and !$cIdxSectsubid) {
          &print_output($printmode, "$thisSectsub");
      }
      elsif($cIdxSectsubid) {
          &print_output($printmode, "$cIdxSectsubid");
      }
   }

   elsif($linecmd =~ /\[JUSTSECTSUBIDS\]/) {
     @sectsubs = split(/;/,$sectsubs);
     foreach $sectsub (@sectsubs) {
        ($sectsubid,$rest) = split(/`/,$sectsub,2);
        if($listSectsub =~ /$convertSS/) {
            &print_output($printmode, "$sectsubid;");
        }
        else {
            &print_output($printmode, "<a target=_top href=\"http://$scriptpath/article.pl?display_section%%%$sectsubid%\">$sectsubid<\/a>");
        }
     }
   }

   elsif($linecmd =~ /\[GETURLQUERY=(.*)\]/) {
        my $urlquery = $1;
        $ENV{QUERY_STRING} = $urlquery;
#     $scriptpath determined in common.pl
        goto comeagain   # in article.pl
   }

   elsif($linecmd =~ /\[MOVEWEBPAGE\]/ and $access =~ /[ABCD]/) {
       &print_output($printmode, "<a href=\"http://$scriptpath/moveutil.pl?move%$pagenames");
       &print_output($printmode, "\">&nbsp;Move $pagenames to public web page</a><br>\n");
   }

   elsif($linecmd =~ /\[MOVEWEBPAGE2MINS\]/) {
       &print_output($printmode, "<meta http-equiv=\"refresh\" content=\"15;url=http://$scriptpath/moveutil.pl?move%$pagenames\">")
         if($pagenames =~ /[A-Za-z0-9]/);
   }

   elsif($linecmd =~ /\[MAKEPUBLIC]\]/) {
	   &print_output($printmode, "<br>$qPrtmove 4-$info[4] 6-$info[6]  7-$info[7] 8-$info[8]<a href=\"http://$scriptpath/moveutil.pl?move%$cPage\"><b>Move $cPage to public page</b></a><br>\n"); 
   }

   elsif($linecmd =~ /\[GOOGLESEARCH\]/) {
#		     print $MIDTEMPL "src=\"https://www.google.com/search?q=Victory+in+Womens+rights\""; 
       my $search = "";
       my $hdsrc = $headline . ' ' . $source;
       ($hdsrc,$rest) = split(/\(/,$hdsrc); #remove parens at end of source
       ($hdsrc,$rest) = split(/&#40;/,$hdsrc);
	   my @hdsrcwords = split(/ /,$hdsrc);
	   foreach my $hdsrcword (@hdsrcwords) {
		  $search = "$search+$hdsrcword";
	    }
		$search =~  s/^\+//;
	    &print_output($printmode, "https://www.google.com/search?q=$search"); 
   }

   elsif($linecmd =~ /\[FLINK\]/) {
	    if($ehandle =~ /link/i and $link =~ /http/) {
           &print_output($printmode, "$link");
        }
        else {
	       &print_output($printmode, "#");
	    }
   }

   elsif($linecmd =~ /\[SHOWSECTSINFRAMES\]/) {
	   $postframe = "\" width=\"100%\" height=\"400\"> </iframe><br><br>\n";
	   @sectsubs = split(/;/,$sectsubs);
	   $sectsub_ctr = 0;
       foreach $sectsub (@sectsubs) {
          ($sectsubid,$rest) = split(/`/,$sectsub,2);
##          local(@pagenames) = split(/;/,$pagenames);
##          if(@pagenames[$sectsub_ctr]) {	      
##              $pagename = $pagenames[$sectsub_ctr];
	      $preframe = "<br><b>$sectsubid</b><br><iframe src =\"";
	
	      $pagename = &getpagename($sectsubid);   ## in sections.pl
	      if($sectsubid =~ /$mobileSS/) { # mobile does not go through php 
		      my $op = $preframe ."http://$scriptpath/moveutil.pl?move%$pagename" . $postframe;
              &print_output($printmode, $op);
          }
          elsif($sectsubid =~ /$newsdigestSS|WOAcommon|NewsDigest/) { #news digest has both newsItem and index
	          if($sectsubid =~ /$newsdigestSS/) {
		          my $op = "<br><b>NewsIndex</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsindex%$newsIndexSS" . $postframe;
		          &print_output($printmode, $op);
                  sleep 15;
                  $op = "<br><b>NewsHeadlines</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsheadlines%$newsHeadlinesSS" . $postframe;
                  &print_output($printmode, $op);	
		          sleep 10;
		      }
		      my $op = $preframe . "http://$cgiSite/prepage/savePagePart.php?$pagename%$sectsubid" . $postframe;
	          &print_output($printmode, $op);
          }
          elsif($sectsubid =~ /HowToHelp_alerts/) {
	             my $op = "<br><b>NewsAlerts</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsalerts%$newsAlertsSS" . $postframe;	
                 &print_output($printmode, $op);			     
                 sleep 10;
                 $op = "$preframe . http://$cgiSite/php/savesection.php?$pagename%$sectsubid" . $postframe;
			     &print_output($printmode, $op); 	
          }
          else {            # all sections (page 2) 
	          my $op = $preframe . "http://$cgiSite/php/savesection.php?$pagename%$sectsubid" . $postframe;
              &print_output($printmode, $op); 	
          }
          sleep 15;
          $sectsub_ctr = $sectsub_ctr + 1;
       } # end foreach
       if($sectsubs =~ /$newsdigestSS/) {
	          &print_output($printmode, "<br><br><a target=\"_blank\" href =\"http://$cgiSite/php/saveindex.php?\">Save NewsDigest to index.html</a><br><br>\n");
	   } 
   }

   elsif($linecmd =~ /\[ONSUBMIT\]/ and -f $futzingON) {
##     print $MIDTEMPL "onsubmit=\"buildResultDocument\(\)\"";
   }

   else {
       &print_output($printmode, "$linecmd") if($linecmd =~ /[A-Za-z0-9]/);
   }

   &print_output($printmode, "$endline\n");
}

## 0130

 sub get_pubmonths
{
 my $mo = 0;
 for($mm=0;$mm<12;$mm++) {
   $mo  = $mm + 1;
   $mo  = "0$mo" if($mo < 10);
   &print_output($printmode, "<option id=\"mm$mo\" value=$mo");
   &print_output($printmode, " selected") if($mo eq $pubmonth);
   &print_output($printmode, ">$months[$mm]</option>\n");
 }

 &print_output($printmode, "<option value=\"_\"");
 &print_output($printmode, " selected") if($pubmonth eq "00");
 &print_output($printmode, ">_</option>\n");
}

sub get_expmonths
{
 for($mm=0;$mm<12;$mm++) {
   $mo  = $mm + 1;
   $mo  = "0$mo" if($mo < 10);
   &print_output($printmode, "<option value=$mo");
   &print_output($printmode, " selected") if($mo eq $expmonth);
   &print_output($printmode, ">$months[$mm]</option>\n");
 }

 &print_output($printmode, "<option value=\"_\"");
 &print_output($printmode, " selected") if($expmonth eq "00" or $expyear eq "0000");
 &print_output($printmode, ">_</option>\n");
}

sub get_pubyears
{
 $yearsago = '1990';
 $nextyr   = $nowyyyy + 2;
 &print_output($printmode, "<option value=\"no date\"");
 &print_output($printmode, " selected") if($pubyear eq '0000');
 &print_output($printmode, ">no date</option>\n");
 for($yr=$nextyr;$yr>$yearsago;$yr--) {
    &print_output($printmode, "<option id=\"yyyy$yr\" value=\"$yr\"");
    &print_output($printmode, " selected") if($yr eq $pubyear);
    &print_output($printmode, ">$yr</option>\n");
 } # END for
}

sub get_expyears
{
 $yearsago = $nowyyyy - 10;
 $nextyr   = $nowyyyy + 2;
 &print_output($printmode, "<option value=\"no date\"");
 &print_output($printmode, " selected") if($expyear eq '0000');
 &print_output($printmode, ">no date</option>\n");
 for($yr=$yearsago;$yr<$nextyr;$yr++) {
    &print_output($printmode, "<option value=$yr");
    &print_output($printmode, " selected") if($yr eq $expyear);
    &print_output($printmode, ">$yr</option>\n");

    print $MIDTEMPL "<option value=\"$i\"";
    print $MIDTEMPL " selected" if($priority eq $i);
    print $MIDTEMPL ">$i</option>\n";
 } # END for
}

##137

sub get_priorities
{
   my $priority = $_[0];
   $priority = 5 unless($priority =~ /[1-7]/);
   &print_output($printmode, "<option value=\"D\">D</option>\n");
   for($i=7;$i>3;$i--) {
     &print_output($printmode, "<option value=\"$i\"");
     &print_output($printmode, " selected") if($priority eq $i);
     &print_output($printmode, ">$i</option>\n");
   }
}

sub do_link
{
  $target = " target=\"_blank\" ";
  $target = " " if($cMobidesk =~ /mobi/);
  if($selfLink =~ /Y/) {
	  my $prt = "<a$target"."href=\"$scriptpath/article.pl?display%fullArticle%$docid\">";
      &print_output($printmode, $prt);
   }
  else {
      $link =~ s/^\s+//;                         # eliminate leading white spaces
      $save = $link;
      if(   $link =~ /(www|www2)\./
         or $link =~ /http:\//
         or $link =~ /https:\//
         or $link =~ /\.(com|org|net|uk)/
    ##                    two or more dots
         or $link =~ /\.{2,}/ ) {
           $link =~ "http:\/\/$link"
               if($link !~ /^http:\/\// and $link !~ /^https:\/\//);
           my $prt = "<a$target"."href=\"$link\">";
           &print_output($printmode, $prt);
      }
      elsif( ($link =~ /\.htm/) or ($link =~ /\.html/) or ($link[0] eq '#') ) {
           &print_output($printmode, "<a href=\"$link\">");
      }
      else {
           $link = "http:\/\/$link" if($link !~ /^http\/\//);
           &print_output($printmode, "<a$target href=\"$link\">");
      }
      $link = $save;
  }
}

sub do_redarrow
{
 my $head = $_[0];
 my $link = "";
 $sectsubs =~ s/`+$//;  #get rid of trailing tic marks

 my $imgtag = "<img src=\"";
 my $redarrow;

 $redarrow = "/redArrow.gif\" height=\"7\" width=\"7\" border=\"0\" alt=\"doclink\">" if($cSectid =~ /[Hh]eadlines/);
 $redarrow = "/redArrow.gif\" height=\"10\" width=\"10\" border=\"0\" alt=\"doclink\">" unless($cSectid =~ /[Hh]eadlines/);
 my $invisibledot = "/invisibledot.gif\" height=\"4\" width=\"4\" border=\"0\" alt=\"doclink\">";
 my $greybutton = "/plain_grey_button.gif\" height=\"4\" width=\"4\" border=\"0\" alt=\"doclink\">";

 if($owner) {
#	http://overpop/cgi-bin/article.pl?display%ownerlogin%026391%CSWP_Calendar%%xxxx%%%%%%CSWP
    my $ownerlogin = $OWNER{'ologintemplate'};
    my $ownersubs  = $OWNER{'ownersubs'};
    $link = "<a class=\"tinyimg\" target=\"_blank\" href=\"http://$scriptpath/article.pl?display%$ownerlogin%$docid%$sectsubs%%$userid%%%%%%$owner%$ownersubs\">";
    &print_output($printmode, "$link$imgtag$greybutton</a>");
 }
 elsif($cSectid =~ /Headlines/) {
	$link = "<a class=\"tooltip2\" target=\"_blank\" href=\"http://$scriptpath/article.pl?display%login%$docid%$sectsubs%%$userid%%%%%%$owner%$ownersubs\">";
#        $bodytemp = substr($fullbody,0,500);    
	    &print_output($printmode, "$link$imgtag$redarrow");
	}
 else {
    $link = "<a class=\"tinyimg\" href=\"http://$scriptpath/article.pl?display%login%$docid%$sectsubs%%$userid\">";

	if($nodata eq 'Y' or $cVisable =~ /[STB]/) {  ## non-article pieces
	   	 &print_output($printmode, "$link$imgtag$invisibledot</a>");
	}

	elsif($head =~ /head/ and $needsum =~ /[1345]/) {
	     &print_output($printmode, "$link$imgtag$redarrow</a>");
	}
	elsif($head !~ /head/) {
	      &print_output($printmode, "$link$imgtag$greybutton</a>");
	}
 }
}


sub print_period_radios
{
  @punctARRAY = (".-period", ",-comma", "&nbsp;-space", "<br>-line break");
  foreach $punct (@punctARRAY) {
   ($punct,$punctname) = split(/-/,$punct);
   &print_output($printmode, "<input name=\"period\" type=\"radio\" ");
   if( ($period eq $punct) or ($period eq "" and $punctname eq "period") ) {
      &print_output($printmode, " checked");
   }
   &print_output($printmode, " value=\"$punct\"> $punctname");
  } # END for
}


sub print_needsum_radio_buttons
{
  my $needsum_radios = "1;needSum|2;more|3;both|4;key|5;keyArw|6;extrct|7;exmor|8;sum;checked|9;summor|0;clr";
  my $op = <<ENDNEEDSUM;
<cite style="font-family:arial,freesans,sans-serif;font-size:9x;">
ENDNEEDSUM

  &print_output($printmode, $op);
	
  my @nsradios = split(/\|/,$needsum_radios);
  my $checked = "";
  my $checkFound = "N";
  my($nscode,$nsdescr);
  foreach $nsradio (@nsradios) {
	  ($nscode,$nsdescr,$nschecked) = split(/\;/,$nsradio,3);
      if($needsum and $nscode == $needsum) {	
	     $checked = "checked";
	  }
	  elsif(!$needsum) {
	     $checked = $nschecked if(!$checkFound);
	  }
	  $checked = "checked=\"checked\"" if($checked);
	  &print_output($printmode, "<input type=\"radio\" name=\"needsum\" value=\"$nscode\" $checked><cite>$nsdescr</cite>");
      if($checked) {
	     $checkFound = 'Y';
      }
	  $checked = '';
  }
}


sub do_title
{
  if($cTitle =~ /[A-Za-z0-9]/) {
    &print_output($printmode, "\"$cTitle\"");
  }
  else {
	&print_output($printmode, "this ");
  }
}


sub do_5lines
{
  @lines = split(/\n/,$fullbody);
  local($linecnt) = 0;
  foreach $line (@lines) {
    chomp;
    if($line =~ /[A-Za-z0-9]/) {
       $linecnt = $linecnt + 1;
       if($linecnt < 7) {
          &print_output($printmode, "$line<br>\n");
       }
    }
  }
}


sub do_points
{
    my $save = $points;

	$points =~ s/ {1-9}\n/\n/g;  # get rid of trailing spaces
#	if ($points =~ /\n\n/) {
#	    $points =~ s/\n\n/<\/p><p>\n/g;
#	}
#	else {
#	    $points =~ s/\n/<br>\n/g;
#	}
	$points =~ s/\r/<br>/g;
	$points =~ s/<\/p><p>$//g;   ## delete last paragraph
	$points =~ s/<\/p><p>\n/<\/p>\n\n<p>/g;
	$points =~ s/<br.{0-2}>$//gi;   ## delete last line break
	$points =~ s/<BR \/>//g;
	$points = &apple_convert($points);  # takes care of encoding
	$points =~ s/ & / &#38; /g; ## ampersand to html code
	$points =~ s/=27/&39#;/g;   ## single quote to html code

	&print_output($printmode, "$points");
	$points = $save;
}

sub do_handle
{
  if($sumAcctnum ne "" and $skiphandle ne 'Y') {
	 ($userdata,$access) = &read_contributors('N','N',$sumAcctnum,'_',98989); # args=print?, html file?, handle, email, acct#
     &print_output($printmode, "<span class=\"smallfont\"> $handle </span>")
            if($userdata eq "GOOD" and $handle =~ /[A-Za-z0-9]/);
  }
}

sub skip_handle
{
 ($userdata,$access) = &read_contributors('N','N',$userid,$handle,"",);     ## args=print?, html file?, handle, email, acct#

 if($uhandle ne "" and $userdata eq "GOOD") {
    &print_output($printmode, "<input type=\"checkbox\" name=\"skiphandle\" value=\"Y\"");
    &print_output($printmode, " checked") if($action eq "new" and $access =~ /[ABC]/);
    &print_output($printmode, " checked") if($skiphandle eq 'Y');
    my $op = <<END;
>&nbsp;Hide initials (handle)</font>
END
    &print_output($printmode, $op);
 }
}

##  157
sub do_fullbody
{
  $save = $fullbody;

  if($template =~ /summarize/) {
     $fullbody =~ s/\r/<br>/g;
     $fullbody =~ s/\n/<br>/g;
  }
  elsif($cmd eq "processlogin" and $action ne 'view') {
#     $fullbody =~ s/\n/\r/g;
  }
  elsif($now_print eq 'Y' and $template !~ /docUpdate/) {
     $fullbody =~ s/\r/<br>/g;
     $fullbody =~ s/\n/<br>/g;
  }
  elsif($now_email eq 'Y') {
     $fullbody =~ s/\r/ /g;
  }
  &print_output($printmode, "$fullbody");
  $fullbody = $save;
}


## 0160

sub check_url
{
  if( ($link eq "") and ($userdata eq 'BAD') ) {
     &print_output($printmode, "<b><font color=purple size=4 face=arial>");
     &print_output($printmode, "There is no link to the full article.\n");
     &print_output($printmode, "Please wait until your account <br>number \n");
     &print_output($printmode, "is assigned to view this article \n");
     &print_output($printmode, "from our archives.</b></font><br></td></table>\n");
     $stop = 'Y';
  }
  else {
     if($link ne "") {
        &print_output($printmode, "Let me know ($adminEmail) if link does not work.<br>\n");
     }
  }
}

sub do_modelnew
{
 if($action eq "new") {
       &print_output($printmode, "<input type=\"hidden\" name=\"action\" value=\"new\">");
 }
 elsif($operator_access =~ /[AB]/) {
       my $op = <<END;
         <input type="radio" name="action" value="update" checked>
           Update &nbsp;
         <input type="radio" name="action" value="clone">
           Clone &nbsp;
        <input type="radio" name="action" value="deleteitem">
           Delete
END
       &print_output($printmode, $op);
 }
}


##00210

sub print_select_template
{
 my $ckTemplate;
 my @lTemplates =
 ("default^default",
  "newsitem^news item",
  "introItem^introduction",
  "introHeadItem^intro w/header",
  "opinionItem^opinion",
  "quoteItem^quote",
  "factoidItem^factoid",
  "paragraphItem^paragraphs",
  "poetry^prose/poetry",
  "index^section index",
  "index_nofloat^indx in sidebar",
  "indexright^index left of sidebar",
  "imageright^image 400px right",
  "imageleft^image 400px left",
  "sidebar^left or right sidebar",
  "bodyonly^body only",
  "tableonly^table only",
  "tablegrid^table grid",
  "straight^straight html");

 my @lBoxStyles =
 ("default^default",
  "greyred^grey/red",
  "orangeblue^orange/blue",
  "redblue^red/blue",
  "blackwhite^black/white",
  "blackblue^black/blue",
  "right^right",
  "center^center");

 &print_output($printmode, "<select name=\"dTemplate\">\n") if($aTemplate !~ /cvrtUpdtItem/);
 if($dTemplate =~ /[A-Za-z0-9]/) {
 	$ckTemplate = $dTemplate}
 else {
 	$ckTemplate = 'default';
 }
 foreach $lTemplate (@lTemplates) {
     ($lTemplate,$descr) = split(/\^/,$lTemplate);
     &print_output($printmode, "<option value=\"$lTemplate\" ");
     &print_output($printmode, "selected ") if($ckTemplate =~ /$lTemplate/);
     &print_output($printmode, ">$descr</option>\n");
 }
 &print_output($printmode, "</select>\n");

 &print_output($printmode, "&nbsp;&nbsp;<select name=\"dBoxStyle\">\n");
 if($dBoxStyle =~ /[A-Za-z0-9]/) {
 	$ckBoxStyle = $dBoxStyle}
 else {
 	$ckBoxStyle = 'default';
 }
 foreach $lBoxStyle (@lBoxStyles) {
     ($lBoxStyle,$descr) = split(/\^/,$lBoxStyle);
     &print_output($printmode, "<option value=\"$lBoxStyle\" ");
     &print_output($printmode, "selected ") if($ckBoxStyle =~ /$lBoxStyle/);
     &print_output($printmode, ">$descr</option>\n");
  }

  &print_output($printmode, "</select>\n");
}


sub print_select_all_templates
{
 &print_output($printmode, "<select name=\"dTemplate\">\n") if($aTemplate !~ /cvrtUpdtItem/);

 my $ckTemplate;
 my $ext = "htm";
 my $listname="$sectionpath\\templatesdir.idx";

 &list_files_in_directory($templatepath,$ext,$listname); ## in sections.pl

 my @lTemplates;

 &print_output($printmode, "<option value=\"default>default template</option>\n");

 open(TEMPLATELST, "$listname");
     while(<TEMPLATELST>) {
        chomp;
        $lTemplate = $_;
        &print_output($printmode, "<option value=\"$lTemplate\" ");
        &print_output($printmode, ">$descr</option>\n");
     } #endwhile
 close(TEMPLATELST);
 &print_output($printmode, "</select>\n");
}

##00215

sub print_select_format_NOT_USED
{
 &print_output($printmode, "<select name=\"wFormat\" size=2 multiple>\n") if($aTemplate !~ /cvrtUpdtItem/);
 @formats =
 ("NA^none",
  "div^align right",
  "BQ^left indent",
  "CTRout^center whole object",
  "BDRGrey^border (grey)",
  "BDRRed^border (red)",
  "BDRBlue^border (blue)",
  "BDRindent^indent left/right",
  "BGltGrey^lt grey background",
  "BGBlueGrey^lt blue/grey background",
  "BGPaleGreen^pale green background",
  "BGPink^pale pink background",
  "BGtan^tan background",
  "CTRin^center inside",
  "UL^start bulleted list",
  "OL^start numbered list",
  "LI^bulleted item"
  );

  foreach $aFormat (@formats) {
     ($aFormat,$descr) = split(/\^/,$aFormat);
     &print_output($printmode, "<option value=\"$aFormat\" ");
     if($aFormat =~ /[A-Za-z0-9]/) {}
     else {
     	$aFormat = 'default';
     }
     &print_output($printmode, "selected ") if($wFormat =~ /$aFormat/);
     &print_output($printmode, ">$descr</option>\n");
  }
  &print_output($printmode, "</select><br>\n");
}

## 0220


### MOVED TO SECTIONS.PL


sub get_sortorder
{
 &print_output($printmode, "<select size=1 name=\"sortorder\">\n");
 @sort_order_codes = (
  "N;keep order as is",
  "U;use subsection default",
  "P;reverse publish date",
  "p;publish date",
  "A;priority 7=highest",
  "D;reverse system date",
  "d;system date",
  "H;headline",
  "R;region",
  "T;region/topic",
  "t;priority/region/topic",
  "S;source of publication"
  );

  foreach $pair(@sort_order_codes) {
     ($tcode,$tdescr) = split(/;/,$pair,2);
     $selected = "";
     $selected = "selected" if($tcode =~ /$cOrder/ or $tcode =~ 'N' and $cOrder =~ /[FL]/);
     &print_output($printmode, "<option value=\"$tcode\" $selected>$tdescr</option>\n");
  }
  &print_output($printmode, "</select>\n");
}


1;