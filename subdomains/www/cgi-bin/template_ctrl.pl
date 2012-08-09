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
  my($template,$print_it,$email_it,$htmlfile_it) = @_;
  &put_data_to_array;     # in docitem.pl
  if($print_it eq 'Y') {
     $nowPEH = 'P';
     $now_print = 'Y';
     &template_merge_print($template); 
     $now_print = 'N';
  }
  if($email_it eq 'Y') {
     $nowPEH = 'E';
     $now_email = 'Y';
     &template_merge_print($template);
     $now_email = 'N';
  }
  if($htmlfile_it eq 'Y') {
     $nowPEH = 'H';
     $now_htmlfile = 'Y';
     &template_merge_print($template);
     $now_htmlfile = 'N';
  }
}


##  00050 ### MERGE THE TEMPLATE WITH THE DATA

sub template_merge_print
{
my $aTemplate = $_[0];
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
$midfile = "$templatepath$slash$templfile.mid";

open(MIDTEMPL, ">$midfile") or print "temp72 cannot open midfile $midfile<br>\n";
   foreach $template (@templates) {	
      &do_template($template);
}
close(MIDTEMPL);

 open(OUTFILE, ">>$outfile") if($outfile);
 $javascript = 'N';
 $template_path1 = "$templatepath/$templfile.mid";
 $template_path2 = "$templatepath/$templfile\.mid";

 if (-f "$template_path2") {
  open(MIDTEMP2, "$templatepath/$templfile.mid");
  }
 else {
	die "ERROR: reason: template_merge $templatepath/$templfile\.mid not found .. could not open<br>\n";
 }

 local($img_ctr = 0);
 while(<MIDTEMP2>)
 {
     chomp;
     $line = $_;

# Javascripts bracket used for indexes CONFLICTS
##      with brackets used for data substitution
     $javascript = 'Y' if($line =~ /\<[sS][cC][rR][iI][pP][tT]/ or $line =~ /\[JS_ON\]/);
     $javascript = 'N' if($line =~ /\<\/[sS][cC][rR][iI][pP][tT]/ or $line =~ /\[JS_OFF\]/);

     if($line =~ /docfullbody/) {
     	$docfullbody = $DOCARRAY{fullbody};
        $docfullbody =~ s/\"/&quote\;/g;
        $DOCARRAY{fullbody} = $docfullbody;
     }

     $line =~ s/\[(\S+)\]/$DOCARRAY{$1}/g  if($javascript =~ /N/);
     
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
        print OUTFILE "$line\n" if($outfile and $now_htmlfile =~ /Y/);
        print"$line\n" if($now_print eq 'Y');
     }

##     last if($line =~ /<\/html>/);  It was dying before storeform could finish doing idx
 }

 close(MIDTEMP2);

 close(OUTFILE) if ($outfile);

unlink "$templatepath/$templfile.mid";

 @templates = "";

 ## die if($line =~ /\/html>/);
}

## 080

sub do_template
{
 my $template = $_[0];
 $default_class = "";

 unless($template) {
	%template = $cTemplate;
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

 $templatefile = "$templatepath/$template\.htm";

unless(-f "$templatefile") {
    $errmsg = "tem170 template= $template not found. ..templatepath $templatepath ..c $cTemplate ..d $dTemplate ..a $aTemplate ..cSectsubid $cSectsubid<br>\n";
    &printSysErrExit($errmsg);
 }

 unless($template =~ /select_top|select_end/ and $cmd ne 'print_select') {
   $javascript = 'N';
   open(TEMPLATE, "$templatefile") or die "art1081 cannot open template $templatefile";
   while(<TEMPLATE>)  {
     chomp;
     $line = $_;
##        Process IN-LINE TEMPLATE
     if($line =~ /TEMPLATE=/ or $line =~ /OWNERTEMPLATE=/) {
        ($rest, $intemplate) = split(/=/,$line);
         ($intemplate,$rest) = split(/]/,$intemplate);

         if($owner and $line =~ /OWNERTEMPLATE/) {
	         my $lc_owner = lc($owner);
	         $intemplate = $lc_owner . $intemplate;
	     }

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
     else {
          &process_imbedded_commands;
          last if($stop eq 'Y');
     }
   }     ## end while
   close(TEMPLATE);
 }
## print "art1216 docid $docid end of do_template<br>\n"; 
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
##print "90A javascr-$javascript linecmd-$linecmd $line<br>\n" if($line =~ /onClick/);
   	if($linecmd =~ /[a-z]/ and $linecmd !~ /=/) {  #data plugins are lowercase or mixed case
#print "90B javascr-$javascript linecmd-$linecmd $line<br>\n";
   	   print MIDTEMPL "$line\n";
   	}
   	else {
##print "90C javascr-$javascript linecmd-$linecmd $line<br>\n" if($line =~ /onClick/);
           ($beginline,$endline) = split(/\[$linecmd\]/,$line,2);
           $linecmd = "[$linecmd]";
           print MIDTEMPL $beginline if($beginline =~ /[A-Za-z0-9]/);
##   print "<font size=1 face=verdana color=#CCCCCC>bb-$beginline c-$linecmd e-$endline</font><br>\n";
      	   &do_imbedded_commands;
   	}
   }
   else {
    	print MIDTEMPL "$line\n";
   }
}


sub do_imbedded_commands
{
   if($linecmd =~ /\[ADVANCE\]/ and ($access =~ /[ABCD]/ or $op_userid =~ /P0004|P0083|P0008/) ) {
          print MIDTEMPL "<br><br><input type=\"checkbox\" name=\"advance\" ";
          print MIDTEMPL " value=\"Y\"><b>Advance this item</b> to\n";
          if($action eq 'new') {
          	print MIDTEMPL "NEEDS SUMMARY list <font size=1 face=\"comic sans ms\">(From where you can add a summarization)</font>\n";
          }
          else {
          	print MIDTEMPL "preliminary <b>NEWS DIGEST</b> page - ready for publication\n";
          }
          print MIDTEMPL "<font size=1 face=\"comic sans ms\"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\n";
          print MIDTEMPL "(Use only when admin review needs to be bypassed)</font><p>\n";
   }

   elsif($linecmd =~ /\[LAST_FTPDATE\]/) {
   	if(-f $lastFTPfile) {
           @datetime = stat($lastFTPfile);
           local($lastFTPdate) = &datetime_prep('yyyy-mm-dd',@datetime);
           print MIDTEMPL "$lastFTPdate";
        }
   }

   elsif($linecmd =~ /\[CGISITE\]/) {
       print MIDTEMPL "$cgiSite";
   }

   elsif($linecmd =~ /\[CGIPATH\]/) {
       print MIDTEMPL "$cgiPath";
   }

   elsif($linecmd =~ /\[SCRIPTPATH\]/) {
       print MIDTEMPL "$scriptpath";
   }

   elsif($linecmd =~ /\[PUBLICURL\]/) {
       print MIDTEMPL "$publicUrl";
   }

   elsif($linecmd =~ /\[PAGES_INDEX\]/) {  # 'N' = not end of subsection
       &print_pages_index($pg_num,$cSectsubid,$itemMax,$totalItems,$pg1max,'N') if($ckItemcnt >= $totalItems);
   }

   elsif($linecmd =~ /\[END_OF_PAGES_INDEX\]/) {  # 'Y' = end of subsection
       &print_pages_index($pg_num,$cSectsubid,$itemMax,$totalItems,$pg1max,'Y'); ## in sections.pl
   }

   elsif($linecmd =~ /\[DIV_CLASS\]/) {
		print MIDTEMPL "<div $dBoxStyle</div>" if($dBoxStyle);
   }

   elsif($linecmd =~ /\[END_DIV_CLASS\]/) { 
		print MIDTEMPL "</div>" if($dBoxStyle);
   }

   elsif($linecmd =~ /\[FILEDIR\]/) {
       &print_qkchg_filesdirs;
   }

   elsif($linecmd =~ /\[DBTABLES\]/) {
	print MIDTEMPL "DBTABLES calls list_functions<br>\n";
      &list_functions;
   }

   elsif($linecmd =~ /\[RTCOL_TOP\]/ and $cRtCol eq 'R') {
       print MIDTEMPL "<TABLE align=right width=35% cellspacing=5>";
   }

   elsif($linecmd =~ /\[FLYIMG=/) {
       ($rest,$imgname) = split(/\[FLYIMG=/,$line);
       ($imgname,$rest)  = split(/]/,$imgname);

       if($fly =~ /fly/ or $cFly =~ /fly/) {
          print MIDTEMPL "\"$publicUrl/$imgname\"";
       }
       else {
       	  print MIDTEMPL "\"/$imgname\"";
       }
   }

   elsif($linecmd =~ /\[BEGIN_TR\]/) {
       print MIDTEMPL "<tr><td>";
   }

   elsif($linecmd =~ /\[END_TR\]/) {
       print MIDTEMPL "<\/td>";
   }

   elsif($linecmd =~ /\[RTCOL_END\]/) {
       print MIDTEMPL "<\/td><\/table>";
   }

   elsif($linecmd =~ /\[BOXCLASS\]/) {
		print MIDTEMPL " class=\"$dStyleClass\" " if($dStyleClass);
   }

   elsif($linecmd =~ /\[2ND_CLASS\]/) {
		print MIDTEMPL " $dBoxStyle" if($dBoxStyle);
   }

   elsif($linecmd =~ /\[HITCOUNT\]/) {
       &get_hitcount;
       print MIDTEMPL "$hitCount";
   }

   elsif($linecmd =~ /\[USER\]/) {
   	&get_userinfo;   # in contributor.pl
   }

   elsif($linecmd =~ /\[SUBTITLE\]/) {
         print MIDTEMPL "<br><br><br><center><font face=arial size=5><b>$cSubtitle</b><\/font><\/center>"
         if($cSubtitle);
   }

   elsif($linecmd =~ /\[CTITLE\]/) {
     if($cTitle =~ /[A-Za-z0-9]/) {
	    print MIDTEMPL "\"$cTitle\"";
	 }
	 else {
		print MIDTEMPL "this ";
	 }
   }

   elsif($linecmd =~ /\[TODAY\]/) {
         $month = @months[$nowmm-1];
       print MIDTEMPL "$month $nowdd, $nowyyyy";
   }

   elsif($linecmd =~ /\[BLOCKQUOTE\]/) {
       print MIDTEMPL "<BLOCKQUOTE>\n" if($cBlockquote eq 'B');
   }

   elsif($linecmd =~ /\[MODDELNEW\]/) {
         &do_modelnew;
   }

   elsif($linecmd =~ /\[SYSDATE\]/) {
         print MIDTEMPL "$nowyyyy-$nowmm-$nowdd-$nowhh-$nowmn-$nowss";
   }

   elsif($linecmd =~ /\[PRIORITY\]/) {
         &get_priority;
   }

   elsif($linecmd =~ /\[PUBDAY\]/) {
	      ($pubyear,$pubmonth,$pubday) = split(/-/,$pubdate,3);
          print MIDTEMPL "$pubday" if($pubday ne '00');
          print MIDTEMPL "  " if($pubday eq '00');
   }

   elsif($linecmd =~ /\[PUBMONTHS\]/) {
	    ($pubyear,$pubmonth,$pubday) = split(/-/,$pubdate,3); # needed for this and Day, year subroutines
          &get_pubmonths;
   }

   elsif($linecmd =~ /\[PUBYEARS\]/) {
         &get_pubyears;
   }

   elsif($linecmd =~ /\[EXPDAY\]/) {
          print MIDTEMPL "$expday" if($expday ne '00');
          print MIDTEMPL "  " if($expday eq '00');
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
         print MIDTEMPL "$source";
      }
  }

  elsif($linecmd =~ /\[DATE_SOURCE\]/) {
      &print_srcdate;  # in date.pl
      if($source =~ /\(select one\)/) {
      	$source = "";
      }
      else {
        print MIDTEMPL "$source";
      }
  }

  elsif($linecmd =~ /\[HEADLINE\]/) {
      print MIDTEMPL "\r\r" if($now_email eq 'Y');
      print MIDTEMPL "<p>" if($now_print eq 'Y');
# changed meaning of $regionhead - now: Y = 'override' region in headline
      if($headline !~ /$region/ and $region !~ /Global/ and $regionhead = 'N') {
          print MIDTEMPL "$region: $headline";
      }
      else {
          print MIDTEMPL "$headline";
      }
      print MIDTEMPL "\r" if($now_email eq 'Y');
      print MIDTEMPL "<br>" if($now_print eq 'Y');
  }

## 0100

   elsif($linecmd =~ /\[SOURCES\]/) {
         $sourcefound = &get_sources('F',$source);  #print source = 'F: form'
   }

   elsif($linecmd =~ /\[OTHERSOURCE\]/) {
      if( ($docid =~ /[0-9]/) and ($sourcefound =~ /N/) ) {
         print MIDTEMPL $source;
      }
   }

   elsif($linecmd =~ /\[REGIONS\]/) {
	    &get_regions('F',$region);  # print_region= F=form, in regions.pl 
   }

   elsif($linecmd =~ /\[LIKELYREGIONS\]/ and $region =~ /;/) {
      	print MIDTEMPL "<select size=2 multiple name=\"region$pgitemcnt\">\n";
        &print_likely_regions;              # in controlfile.pl
        print MIDTEMPL "<\/select><br>\n";
   }

   elsif($linecmd =~  /\[REGION\]/) {
       print MIDTEMPL "$region" if($region !~ /;/);
   }

   elsif($linecmd =~ /\[REGIONHEAD\]/) {
        print MIDTEMPL " checked " if($regionhead eq 'Y');
   }

   elsif($linecmd =~ /\[SSTARTSWTHE\]/) {
        print MIDTEMPL " checked " if($sstarts_with_the eq 'T');
   }

   elsif($linecmd =~ /\[RSTARTSWTHE\]/) {
        print MIDTEMPL " checked " if($rstarts_with_the eq 'T');
   }

   elsif($linecmd =~ /\[ALINK\]/) {
         &do_link if($link =~ /[A-Za-z0-9]/  or $selfLink =~ /Y/);
   }

   elsif($linecmd =~ /\[A_NAME\]/) {
	     if($rDocLink =~ /doclink/) {
		     print MIDTEMPL "<a name=$docid><\/a>\n";
	     }
	     else {
		     print MIDTEMPL "<!-- doc $docid  - - ?display%login%$docid%-->";
	     }
   }

   elsif($linecmd =~ /\[END_ALINK\]/) {
          print MIDTEMPL "</a>" if($link =~ /[A-Za-z0-9]/  or $selfLink =~ /Y/);
   }

   elsif($linecmd =~ /\[HLINK\]/) {
   	 $link = "http://$link" if($link !~ /http:\/\//);
         $link = "\"$link\"";
         print MIDTEMPL "$link";
   }

   elsif($linecmd =~ /\[LINK\]/) {
         print MIDTEMPL "$link\r"   if($link =~ /[0-9A-Za-z]/ and $now_email eq 'Y');
         print MIDTEMPL "$link<br>" if($link =~ /[0-9A-Za-z]/ and $now_print eq 'Y');
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
         print MIDTEMPL " checked" if($straightHTML eq 'Y');
   }

   elsif($linecmd =~ /\[PERIOD_RADIOS\]/) {
         &print_period_radios;
   }

   elsif($linecmd =~ /\[HEADLINE_PERIOD\]/ and $headline =~ /[A-Za-z]/) {
      if($regionhead eq 'Y' and $headline !~ /$region/
         and $region =~ /[A-Za-z0-9]/) {
        print MIDTEMPL "$region: $headline";
      }
      else {
        print MIDTEMPL "$headline";
      }
   }

   elsif($linecmd =~ /\[SUBHEADLINE\]/ and $subheadline) {
       print MIDTEMPL "<h5>$subheadline</h5>";
   }

   elsif($linecmd =~ /\[BODY\]/) {
        $body = &do_body_comment($body);
        print MIDTEMPL "$body";
   }

   elsif($linecmd =~ /\[COMMENT\]/ and $comment =~ /[A-Za-z0-9]/) {
         $comment = &do_body_comment($comment);
         print MIDTEMPL "<div class=\"comment\">$comment</div>\n";
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
         print MIDTEMPL " checked" if($freeview eq 'Y');
   }

   elsif($linecmd =~ /\[SELFLINK_CHECK\]/) {
         print MIDTEMPL " checked" if($selfLink eq 'Y');
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
        print MIDTEMPL " checked " if($needsSum eq 'Y');
   }

   elsif($linecmd =~ /\[CKENDTABLE\]/) {
        print MIDTEMPL " checked " if($endtable eq 'Y');
   }

   elsif($linecmd =~ /\[REDARROW\]/) {
	    &do_redarrow if($rDoclink =~ /doclink/);
   }

   elsif($linecmd =~ /\[DOCLINK\]/) {
	  print MIDTEMPL "<a href=\"http://$scriptpath/article.pl?display%login%$docid%$qSectsub\">$docid</a>";
   }
#   elsif($linecmd =~ /\[CSWPDOCLINK\]/) {   # can get rid of this one
#	  print MIDTEMPL "<a href=\"http://$scriptpath/article.pl?display%cswplogin%$docid%$sectsubs\">$docid</a>";
#   }

   elsif($linecmd =~ /\[OWNERDOCLINK\]/) {
	  my $o_logintemplate = $OWNER{ologintemplate};
	  print MIDTEMPL "<a href=\"http://$scriptpath/article.pl?display%$o_logintemplate%$docid%$qSectsub\">$docid</a>";
   }
   elsif($linecmd =~ /\[OWNERCHANGEADD\]/) {
	  if(!$docid) {
		print MIDTEMPL "<strong class=\"red\"><big>A. <\/big><\/strong><strong style=\"font-family:geneva;font-size:1.0em;\">Add new webpage item<\/strong>";
		print MIDTEMPL "<input name=\"action\" type=\"hidden\" value=\"new\" >";
	  }
	  else {
	     print MIDTEMPL "<input name=\"action\" type=\"radio\" value=\"mod\" checked=\"checked\"><strong class=\"red\"><big>A. <\/big><\/strong><strong style=\"font-family:geneva;font-size:1.0em;\"> CHANGE item below or";
		 print MIDTEMPL "<input name=\"action\" type=\"radio\" value=\"new\" onclick=\"clearItem();\"> Clear item and ADD a new one<\/strong> ";
      }
   }

   elsif($linecmd =~ /\[OWNER_CSS\]/) {
	  if($owner) {
	     my $owner_csspath = $OWNER{'ocsspath'};
	     print MIDTEMPL "$owner_csspath";
      }
   }

   elsif($linecmd =~ /\[REFRESH_URL\]/) {
#	  print "<meta http-equiv=\"refresh\" content=\"0;url=http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%$aTemplate%$thisSectsub%$owner$user\"<br>\n";
      ($userid,$rest) = split(/;/,$userid);
      my $oupdatetemplate  = $OWNER{'oupdatetemplate'};
      $ownersectsub = $OWNER{'odefaultSS'} unless($ownersectsub);
	  print MIDTEMPL "http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%$oupdatetemplate%$ownersectsub%$owner%$userid%$ownerSubs";
   }

   elsif($linecmd =~ /\[PRIORITY_STAR\]/) {
       print MIDTEMPL "<img src=\"\/star.gif\" alt=\"high priority\" border=0 height=11 width=11 valign=bottom>"
         if($priority =~ /6/);
   }

   elsif($linecmd =~ /\[OOPS\]/) {
       if($sectsubs =~ /$newsdigestSS/ and $qSectsub =~ /$headlinesSectid/) {
	       print MIDTEMPL "&nbsp; ..Oops! This article has already been summarized. Will fix this soon (I hope)...&nbsp;"
       }
   }

   elsif($linecmd =~ /\[SUMMARIZE_IT\]/) {
        print MIDTEMPL "<input type=\"radio\" name=\"action\" ";
        print MIDTEMPL " value=\"summarize\"> Summarize it. <br>\n";
   }

   elsif($linecmd =~ /\[COMMENT\]/) {
       if($comment eq "") {}
       else {
          print MIDTEMPL "<div class=\"comment\">$comment</div>\n";
        }
   }

   elsif($linecmd =~ /\[ENDTABLE\]/ and $endtable =~ /Y/) {
      print MIDTEMPL "<\/td><\/table>";
      print MIDTEMPL "<\/div>";
      print MIDTEMPL "<\/ul>";
      print MIDTEMPL "<\/blockquote>";
      print MIDTEMPL "<\/center>";
   }

   elsif($linecmd =~ /\[ACRONYMS\]/) {
	require 'misc_dbtables.pl';
      &prt_acronym_list;       #in misc_dbtables.pl;
   }

   elsif($linecmd =~ /\[THISSECTION\]/) {
       if( ($action ne 'new') and ($thisSectsub ne "") ) {
          print MIDTEMPL "<p>This section: $thisSectsub<p>\n" ;
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
         &get_summarizer_name;  ## found in contributor.pl
   }

   elsif($linecmd =~ /\[OPERATOR_NAME\]/) {
         &get_operator_name;  ## found in contributor.pl
   }

   elsif($linecmd =~ /\[SUGGESTOR_NAME\]/) {
         &get_suggestor_name;  ## found in contributor.pl
   }

   elsif($linecmd =~ /\[STD_ITEM_TOP\]/) {
	print MIDTEMPL "<a name=\"$docid\"></a>\n";
	 	if($savecmd =~ /print_select/ or $sectsubs =~ /Suggested_emailedItem/) {
          print MIDTEMPL "<input type=\"checkbox\" name=\"selitem$pgitemcnt\" value=\"Y\">\n";
          print MIDTEMPL "<input type=\"hidden\" name=\"sdocid$pgitemcnt\" value=\"$docid\">\n";
        }
   }

   elsif($linecmd =~ /\[END_SELECT\]/and $cmd eq 'print_select') {
##   print "art120 END_SELECT pgItemnbr $pgItemnbr<br>\n";
         if($pgItemnbr ne "" and $pgItemnbr > 0) {
            $pgItemnbr = $pgItemnbr + 1;
            $pgitemcnt = &padCount4($pgItemnbr);
         }
         print MIDTEMPL "<input type=\"hidden\" name=\"selitem$pgitemcnt\" value=\"Z\">\n";
   }

   elsif($linecmd =~ /\[FLOATSTYLE\]/) {
	     print MIDTEMPL " style=\"float:right;\"" if($savecmd = 'print_select');
   }

   elsif($linecmd =~ /\[EMAILED\]/) {
      if($cSubid eq $emailedSub) {
          print MIDTEMPL "<input type=\"hidden\" name=\"emailed$pgitemcnt\" value=\"Y\">\n";
      }
      else {
          print MIDTEMPL "<input type=\"hidden\" name=\"emailed$pgitemcnt\" value=\"N\">\n";
      }
   }

   elsif($linecmd =~ /\[JUSTSECTSUBIDS\]/) {
     @sectsubs = split(/;/,$sectsubs);
     foreach $sectsub (@sectsubs) {
        ($sectsubid,$rest) = split(/`/,$sectsub,2);
        if($thisSectsub =~ /$convertSS/) {
            print MIDTEMPL "$sectsubid;";
        }
        else {
            print MIDTEMPL "<a target=_top href=\"http://$scriptpath/article.pl?display_section%%%$sectsubid%\">$sectsubid<\/a>;"
        }
     }
   }

   elsif($linecmd =~ /\[GETURLQUERY=(.*)\]/) {
        my $urlquery = $1;
print MIDTEMPL "tem815 urlquery $urlquery<br>\n";
        $ENV{QUERY_STRING} = $urlquery;
#     $scriptpath determined in common.pl
        goto comeagain   # in article.pl
   }

   elsif($linecmd =~ /\[MOVEWEBPAGE\]/ and $access =~ /[ABCD]/) {
       print MIDTEMPL "<a href=\"http://$scriptpath/moveutil.pl?move%$pagenames";
       print MIDTEMPL "\">&nbsp;Move $pagenames to public web page</a><br>\n";
   }

   elsif($linecmd =~ /\[MOVEWEBPAGE2MINS\]/) {
       print MIDTEMPL "<meta http-equiv=\"refresh\" content=\"15;url=http://$scriptpath/moveutil.pl?move%$pagenames\">"
         if($pagenames =~ /[A-Za-z0-9]/);
   }

   elsif($linecmd =~ /\[MAKEPUBLIC]\]/) {
	   print MIDTEMPL "<br>$qPrtmove 4-$info[4] 6-$info[6]  7-$info[7] 8-$info[8]<a href=\"http://$scriptpath/moveutil.pl?move%$cPage\"><b>Move $cPage to public page</b></a><br>\n"; 
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
              print MIDTEMPL $preframe ."http://$scriptpath/moveutil.pl?move%$pagename" . $postframe;
          }
          elsif($sectsubid =~ /$newsdigestSS|WOAcommon|NewsDigest/) { #news digest has both newsItem and index
	          if($sectsubid =~ /$newsdigestSS/) {
		          print MIDTEMPL "<br><b>NewsIndex</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsindex%$newsIndexSS" . $postframe;
                  sleep 15;
                  print MIDTEMPL "<br><b>NewsHeadlines</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsheadlines%$newsHeadlinesSS" . $postframe;	
		          sleep 10;
		      }
	          print MIDTEMPL $preframe . "http://$cgiSite/prepage/savePagePart.php?$pagename%$sectsubid" . $postframe;
          }
          elsif($sectsubid =~ /HowToHelp_alerts/) {
			     print MIDTEMPL "<br><b>NewsAlerts</b><br><iframe src =\"http://$cgiSite/prepage/savePagePart.php?newsalerts%$newsAlertsSS" . $postframe;	
			     sleep 10;
			     print MIDTEMPL $preframe . "http://$cgiSite/php/savesection.php?$pagename%$sectsubid" . $postframe;	
          }
          else {            # all sections (page 2) 
              print MIDTEMPL $preframe . "http://$cgiSite/php/savesection.php?$pagename%$sectsubid" . $postframe;	
          }
          sleep 15;
          $sectsub_ctr = $sectsub_ctr + 1;
       } # end foreach
       if($sectsubs =~ /$newsdigestSS/) {
	          print MIDTEMPL "<br><br><a target=\"_blank\" href =\"http://$cgiSite/php/saveindex.php?\">Save NewsDigest to index.html</a><br><br>\n";
	   } 
   }

   elsif($linecmd =~ /\[ONSUBMIT\]/ and -f $futzingON) {
##     print MIDTEMPL "onsubmit=\"buildResultDocument\(\)\"";
   }

   else {
       print MIDTEMPL "$linecmd" if($linecmd =~ /[A-Za-z0-9]/);
   }

   print MIDTEMPL "$endline\n";
}

## 0130

 sub get_pubmonths
{
 for($mm=0;$mm<12;$mm++) {
   $mo  = $mm + 1;
   $mo  = "0$mo" if($mo < 10);
   print MIDTEMPL "<option id=\"mm$mo\" value=$mo";
   print MIDTEMPL " selected" if($mo eq $pubmonth);
   print MIDTEMPL ">$months[$mm]</option>\n";
 }

 print MIDTEMPL "<option value=\"_\"";
 print MIDTEMPL " selected" if($pubmonth eq "00");
 print MIDTEMPL ">_</option>\n";
}

sub get_expmonths
{
 for($mm=0;$mm<12;$mm++) {
   $mo  = $mm + 1;
   $mo  = "0$mo" if($mo < 10);
   print MIDTEMPL "<option value=$mo";
   print MIDTEMPL " selected" if($mo eq $expmonth);
   print MIDTEMPL ">$months[$mm]</option>\n";
 }

 print MIDTEMPL "<option value=\"_\"";
 print MIDTEMPL " selected" if($expmonth eq "00" or $expyear eq "0000");
 print MIDTEMPL ">_</option>\n";
}

sub get_pubyears
{
 $yearsago = '1990';
 $nextyr   = $nowyyyy + 2;
 print MIDTEMPL "<option value=\"no date\"";
 print MIDTEMPL " selected" if($pubyear eq '0000');
 print MIDTEMPL ">no date</option>\n";
 for($yr=$yearsago;$yr<$nextyr;$yr++) {
    print MIDTEMPL "<option id=\"yyyy$yr\" value=\"$yr\"";
    print MIDTEMPL " selected" if($yr eq $pubyear);
    print MIDTEMPL ">$yr</option>\n";
 } # END for
}

sub get_expyears
{
 $yearsago = $nowyyyy - 10;
 $nextyr   = $nowyyyy + 2;
 print MIDTEMPL "<option value=\"no date\"";
 print MIDTEMPL " selected" if($expyear eq '0000');
 print MIDTEMPL ">no date</option>\n";
 for($yr=$yearsago;$yr<$nextyr;$yr++) {
    print MIDTEMPL "<option value=$yr";
    print MIDTEMPL " selected" if($yr eq $expyear);
    print MIDTEMPL ">$yr</option>\n";
 } # END for
}

##137

sub get_priority
{
 print MIDTEMPL  "<font size=1 face=verdana><select name=\"priority\">\n";
 for($i=0;$i<7;$i++) {
   print MIDTEMPL "<option value=\"$i\"";
   print MIDTEMPL " selected" if($priority eq $i);
   print MIDTEMPL ">$i</option>\n";
 }
 print MIDTEMPL "<\/select></font>\n";
}

##138

sub get_borderbkgrnd
{
 @borderBGs = (
 "NA^normal",
 "BDR^000000^1.grey border",
 "BDR^AFOFOO^2.red border",
 "BDR^CCCCFF^3.teale border",
 "BDR^FFFFFF^4.invisible border",
 "BGc^D9D9F3^5.sky blue background",
 "BGc^CCCCFF^6.blue background",
 "BGc^FFD303^7.gold background",
 "BGc^E5E7E8^8.lt blue background",
 "BGc^FF3399^9.bright pink background",
 "BGc^FF6000^10.orange sherbert background",
 "BGc^FFF0F0^11.baby pink background",
 "BGi^colors/NewTan.gif^12.golden tan background",
 "BGi^colors/MedVioletRed.gif^13.strong violet red background",
 "BGi^colors/Thistle.gif^14.strong thistle background",
 "BGi^colors/MedTurq.gif^15.strong med. turquoise background",
 "BGi^colors/PaleGreen.gif^16.lime green background",
 "BGi^ccolors/DarkOrchid.gif^17.royal purple  background",
 "BGi^colors/Thistle.gif^18.strong thistle background"
 );

 print MIDTEMPL  "<select size=2 name=\"borderBG\">\n";
 foreach $bbg (@borderBGs) {
   ($value,$descr) = split(/\^/,$bbg,2);
   print MIDTEMPL "<option value=\"$value\"";
   print MIDTEMPL " selected" if($borderBG eq $value);
   print MIDTEMPL ">$descr</option>\n";
 }
 print MIDTEMPL "<\/select><br>\n";
}



sub do_link
{
  $target = " target=\"_blank\" ";
  $target = " " if($cMobidesk =~ /mobi/);
  if($selfLink =~ /Y/) {
	   local($prt) = "<a$target"."href=\"$scriptpath/article.pl?display%fullArticle%$docid\">";
      print MIDTEMP $prt;
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
           local($prt) = "<a$target"."href=\"$link\">";
           print MIDTEMPL $prt;
      }
      elsif( ($link =~ /\.htm/) or ($link =~ /\.html/) or ($link[0] eq '#') ) {
           print MIDTEMPL "<a href=\"$link\">";
      }
      else {
           $link = "http:\/\/$link" if($link !~ /^http\/\//);
           print MIDTEMPL "<a$target href=\"$link\">";
      }
      $link = $save;
  }
}

sub do_redarrow
{
 my $link = "";
   $sectsubs =~ s/`+$//;  #get rid of trailing tic marks
 if($owner) {
#	http://overpop/cgi-bin/article.pl?display%ownerlogin%026391%CSWP_Calendar%%xxxx%%%%%%CSWP
    my $ownerlogin = $OWNER{ologintemplate};
    my $ownersubs  = $OWNER{ownersubs};
    $link = "<a class=\"tinyimg\" href=\"http://$scriptpath/article.pl?display%$ownerlogin%$docid%$sectsubs%%$userid%%%%%%$owner%$ownersubs\">";
 }
 else {
    $link = "<a class=\"tinyimg\" href=\"http://$scriptpath/article.pl?display%login%$docid%$sectsubs%%$userid\">";
 }
 my $imgtag = "<img src=\"";
 my $redarrow = "/redArrow.gif\" height=\"7\" width=\"7\" border=\"0\" alt=\"doclink\"></a>";
 my $invisibledot = "/invisibledot.gif\" height=\"4\" width=\"4\" border=\"0\" alt=\"doclink\"></a>";
 my $greybutton = "/plain_grey_button.gif\" height=\"4\" width=\"4\" border=\"0\" alt=\"doclink\"></a>";

  if($nodata eq 'Y' or $cVisable =~ /[STB]/) {  ## non-article pieces
   	   print MIDTEMPL "$link$imgtag$invisibledot";
   }
  elsif($cSectid =~ /[Hh]eadlines/) {
       print MIDTEMPL "$link$imgtag$redarrow";
   }
  else {
       print MIDTEMPL "$link$imgtag$greybutton";
   }
}

## 150

sub print_period_radios
{
  @punctARRAY = (".-period", ",-comma", "&nbsp;-space", "<br>-line break");
  foreach $punct (@punctARRAY) {
   ($punct,$punctname) = split(/-/,$punct);
   print MIDTEMPL "<input name=\"period\" type=\"radio\" ";
   if( ($period eq $punct) or ($period eq "" and $punctname eq "period") ) {
      print MIDTEMPL " checked";
   }
   print MIDTEMPL " value=\"$punct\"> $punctname";
  } # END for
}

sub do_title
{
  if($cTitle =~ /[A-Za-z0-9]/) {
    print MIDTEMPL "\"$cTitle\"";
  }
  else {
	print MIDTEMPL "this ";
  }
}

##0155

sub do_5lines
{
  @lines = split(/\n/,$fullbody);
  local($linecnt) = 0;
  foreach $line (@lines) {
    chomp;
    if($line =~ /[A-Za-z0-9]/) {
       $linecnt = $linecnt + 1;
       if($linecnt < 7) {
          print MIDTEMPL "$line<br>\n";
       }
    }
  }
}

sub do_body_comment
{
  $bodycom = $_[0];
##print "tem1102 now_email $now_email body $body\n";
  if($now_email eq 'Y') {
     $bodycom     =~ s/\r/" "/g;
     $bodycom     =~ s/\n/" "/g;
     $bodycom     =~ s/<i>/""/g;
     $bodycom     =~ s/<\/i>/""/g;
  }
  else {
	 $bodycom =~ s/ {1-9}\n/\n/g;  # get rid of trailing spaces
	 my @bodylines = split(/\n/,$bodycom);
	 my $url = "";
	 my $acronym = "";
	 my $word = "";
	 my $title = "";
	 $bodycom = "";
	foreach $bodycomline (@bodylines) {
	    if($bodycomline =~ /#http/ or $bodycomline =~ /#[A-Z]/ or $bodycomline =~ /#mp3#http/) { #link or acronym
		   my @words = split(/ /,$bodycomline);
		   $bodycomline = "";
		   foreach $word (@words) {
		       if($word =~ /^#(http:\/\/.*)/ or $word =~ /##(http:\/\/.*)/ or $word =~ /#mp3#(http:\/\/.*)/) {
				   $url = $1;
				   if($word =~ /##http:/) {   #   2 ##s = clickable url
					  $word = "<small><a target=\"blank\" href=\"$url\">$url<\/a><\/small>";
				   }
                   elsif($template eq "newsalertItem") {
				        $word = "Click left arrow ";
                   }
				   elsif($word =~ /#mp3#http:/) {   #   2 ##s = clickable url
					    $word .= "<object width=\"300\" height=\"42\"> <param name=\"src\" value=\"$url\">";
$word = <<ENDWORD;
<param name="autoplay" value="false">
<param name="controller" value="true">
<param name="bgcolor" value="#FFFFFF">
<embed 
ENDWORD
                         $word .= "src=\"$url\" autostart=\"false\" loop=\"false\" width=\"300\" height=\"42\" controller=\"true\" bgcolor=\"#FFFFFF\"><\/embed><\/object>";	
				   }
                   else {	
				        $word = "<a target=\"blank\" href=\"$url\">Click here<\/a>";
                   }	      
		       }
		       elsif($word =~ /^#([A-Za-z0-9\-]{2,30})/) {  
			      $acronym = $1;
			      $title = &get_title($acronym);  # in misc_dbtables.pl
                  if($title) {
			          $word = "<acronym title=\"$title\">$acronym<\/acronym>";
                  }
                  else {
	                  $word = $acronym;
                  }
		       }
		       $bodycomline = "$bodycomline$word ";
		   }
		   $bodycomline =~ s/^ +//;  #trim leading spaces
		   $bodycomline =~ s/ +$//;  #trim leading spaces
	    }
	    $bodycom = "$bodycom$bodycomline\n";
	 }
	 $bodycom =~ s/^\n+//;  #trim leading line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns	
	 $bodycom =~ s/\r$//;  #trim trailing line returns
	 $bodycom =~ s/\r$//;  #trim trailing line returns
	 $bodycom =~ s/\r$//;  #trim trailing line returns
     if($template =~ /straight|link/
	     or $bodycom =~ /<font|<center|<blockquote|<div|<table|<li|<dl|<dt|<dd/) {
	   $bodycom = &xhtmlify($docid,$template,$bodycom);  ## in docitem.pl
	 }
	 elsif ($bodycom =~ /\n\n/) {
	      $bodycom =~ s/\n\n/<\/p><p>\n/g;
	 }
	 else {
	      $bodycom =~ s/\n/<br>\n/g;
	}
  }
  $bodycom =~ s/\r/<br>/g;
  $bodycom =~ s/<\/p><p>$//g;   ## delete last paragraph
  $bodycom =~ s/<\/p><p>\n/<\/p>\n\n<p>/g;
  $bodycom =~ s/<br.{0-2}>//gi;   ## all line breaks
  $bodycom =~ s/<BR \/>//g;
  $bodycom = &apple_convert($bodycom);  # takes care of encoding
  $bodycom =~ s/ & / &#38; /g; ## ampersand to html code
  $bodycom =~ s/=27/&39#;/g;   ## single quote to html code
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  return($bodycom);
}


sub do_points
{
##print "art155 now_email $now_email body $body\n";
    local($save) = $points;

	$points =~ s/ {1-9}\n/\n/g;  # get rid of trailing spaces
	if ($points =~ /\n\n/) {
	    $points =~ s/\n\n/<\/p><p>\n/g;
	}
	else {
	    $points =~ s/\n/<br>\n/g;
	}
	$points =~ s/\r/<br>/g;
	$points =~ s/<\/p><p>$//g;   ## delete last paragraph
	$points =~ s/<\/p><p>\n/<\/p>\n\n<p>/g;
	$points =~ s/<br.{0-2}>$//gi;   ## delete last line break
	$points =~ s/<BR \/>//g;
	$points = &apple_convert($points);  # takes care of encoding
	$points =~ s/ & / &#38; /g; ## ampersand to html code
	$points =~ s/=27/&39#;/g;   ## single quote to html code

	print MIDTEMPL "$points";
	$points = $save;
}

sub do_handle
{
  if($sumAcctnum ne "" and $skiphandle ne 'Y') {
     ($userdata,$access) = &read_contributors(N,N,_,_,$sumAcctnum,98989); # args=print?, html file?, handle, email, acct#
     print MIDTEMPL "<span class=\"smallfont\"> $handle </span>"
            if($userdata eq "GOOD" and $handle =~ /[A-Za-z0-9]/);
  }
}

sub skip_handle
{
 ($userdata,$access) = &read_contributors(N,N,$handle,_,);     ## args=print?, html file?, handle, email, acct#

 if($handle ne "" and $userdata eq "GOOD") {
    print MIDTEMPL "<input type=\"checkbox\" name=\"skiphandle\" value=\"Y\"";
    print MIDTEMPL " checked" if($action eq "new" and $access =~ /[ABC]/);
    print MIDTEMPL " checked" if($skiphandle eq 'Y');
    print MIDTEMPL <<END;
>&nbsp;Hide initials (handle)</font>
END
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
  print MIDTEMPL "$fullbody";
  $fullbody = $save;
}


## 0160

sub check_url
{
  if( ($link eq "") and ($userdata eq 'BAD') ) {
     print MIDTEMPL "<b><font color=purple size=4 face=arial>";
     print MIDTEMPL "There is no link to the full article.\n";
     print MIDTEMPL "Please wait until your account <br>number \n";
     print MIDTEMPL "is assigned to view this article \n";
     print MIDTEMPL "from our archives.</b></font><br></td></table>\n";
     $stop = 'Y';
  }
  else {
     if($link ne "") {
        print MIDTEMPL "Let me know ($adminEmail) if link does not work.<br>\n";
     }
  }
}

sub do_modelnew
{
 if($action eq "new") {
       print MIDTEMPL "<input type=\"hidden\" name=\"action\" value=\"new\">";
 }
 elsif($operator_access =~ /[AB]/) {
       print MIDTEMPL <<END;
         <input type="radio" name="action" value="update" checked>
           Update &nbsp;
         <input type="radio" name="action" value="clone">
           Clone &nbsp;
        <input type="radio" name="action" value="deleteitem">
           Delete
END
 }
}


##00210

sub print_select_template
{
 local($ckTemplate);
 local(@lTemplates) =
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

 local(@lBoxStyles) =
 ("default^default",
  "greyred^grey/red",
  "orangeblue^orange/blue",
  "redblue^red/blue",
  "blackwhite^black/white",
  "blackblue^black/blue",
  "right^right",
  "center^center");

 print MIDTEMPL "<select name=\"dTemplate\">\n" if($aTemplate !~ /cvrtUpdtItem/);
 if($dTemplate =~ /[A-Za-z0-9]/) {
 	$ckTemplate = $dTemplate}
 else {
 	$ckTemplate = 'default';
 }
 foreach $lTemplate (@lTemplates) {
     ($lTemplate,$descr) = split(/\^/,$lTemplate);
     print MIDTEMPL "<option value=\"$lTemplate\" ";
     print MIDTEMPL "selected " if($ckTemplate =~ /$lTemplate/);
     print MIDTEMPL ">$descr</option>\n";
 }
 print MIDTEMPL "</select>\n";

 print MIDTEMPL "&nbsp;&nbsp;<select name=\"dBoxStyle\">\n";
 if($dBoxStyle =~ /[A-Za-z0-9]/) {
 	$ckBoxStyle = $dBoxStyle}
 else {
 	$ckBoxStyle = 'default';
 }
 foreach $lBoxStyle (@lBoxStyles) {
     ($lBoxStyle,$descr) = split(/\^/,$lBoxStyle);
     print MIDTEMPL "<option value=\"$lBoxStyle\" ";
     print MIDTEMPL "selected " if($ckBoxStyle =~ /$lBoxStyle/);
     print MIDTEMPL ">$descr</option>\n";
  }

  print MIDTEMPL "</select>\n";
}


sub print_select_all_templates
{
 print MIDTEMPL "<select name=\"dTemplate\">\n" if($aTemplate !~ /cvrtUpdtItem/);

 local($ckTemplate);
 local $ext = "htm";
 local $listname="$sectionpath\\templatesdir.idx";

 &list_files_in_directory($templatepath,$ext,$listname); ## in sections.pl

 local(@lTemplates);

 print MIDTEMPL "<option value=\"default>default template</option>\n";

 open(TEMPLATELST, "$listname");
     while(<TEMPLATELST>) {
        chomp;
        $lTemplate = $_;
        print MIDTEMPL "<option value=\"$lTemplate\" ";
        print MIDTEMPL ">$descr</option>\n";
     } #endwhile
 close(TEMPLATELST);
 print MIDTEMPL "</select>\n";
}

##00215

sub print_select_format_NOT_USED
{
 print MIDTEMPL "<select name=\"wFormat\" size=2 multiple>\n" if($aTemplate !~ /cvrtUpdtItem/);
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
     print MIDTEMPL "<option value=\"$aFormat\" ";
     if($aFormat =~ /[A-Za-z0-9]/) {}
     else {
     	$aFormat = 'default';
     }
     print MIDTEMPL "selected " if($wFormat =~ /$aFormat/);
     print MIDTEMPL ">$descr</option>\n";
  }
  print MIDTEMPL "</select><br>\n";
}

## 0220


### MOVED TO SECTIONS.PL


sub get_sortorder
{
 print MIDTEMPL "<select size=1 name=\"sortorder\">\n";
 @sort_order_codes = (
  "N;keep order as is",
  "U;use subsection default",
  "P;reverse publish date",
  "p;publish date",
  "A;priority 6=highest",
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
     print MIDTEMPL "<option value=\"$tcode\" $selected>$tdescr</option>\n";
  }
  print MIDTEMPL "</select>\n";
}


1;