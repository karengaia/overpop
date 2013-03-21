#!/usr/bin/perl --

# January 23

#        display.pl

## Sort (on ctrl rec)   default=F=first  L=last
##   P=pubdate(reverse)   p=pubdate   H=headline D=sysdate(reverse)  d=sysdate
##   T=region/topic   t=priority/region/topic  S=source  R=region/rev pubdate
##  First and Last are not sorted

sub init_display_variables
{
 $email_it     = 'N';
 $print_it     = 'N';
 $htmlfile_it  = 'N';
 $now_email    = 'N';
 $now_print    = 'N';
 $now_htmlfile = 'N';
 $nodata  = 'N';
 $kSeq = 9999;
}

sub create_html
{
  my ($rSectsubid,$aTemplate,$pg_num,$supress_nonsectsubs) = @_;
  $supress_nonsectsubs = 'Y' if($pg_num > 1);

  if($rSectsubid =~ /Volunteer_log/) {   ## <-- Does this work? Where is volunteer's id?
		$doclistname = "$sectionpath/$rSectsubid.idx";
		&process_doclist($rSectsubid,$doclistname);
		exit;
  }

  &split_section_ctrlB($rSectsubid);
  $rPage    = $cPage;
  $rSubdir  = $cSubdir;
  $rSectid  = $cSectid;
  $rSubid   = $cSubid;
  $rDoclink = $cDocLink;
  $email_it = 'Y' if($cVisable eq 'E');

  if($rPage and $rPage !~ /emailed|summarized|suggested/) {
     $htmlfile_it = 'Y';

     $lock_file = "$statuspath/$rPage.busy";
     &waitIfBusy($lock_file, 'lock');

     $outfile = "$prepagepath/$rPage.html";
     unlink $outfile if(-f $outfile);
  }

  $found_it  = "";
  $pgItemnbr = "";
  $pgitemcnt = "";
  $pgItemnbr = 1;
  $pgitemcnt = &padCount4($pgItemnbr);

  foreach $cSectsub (@CSARRAY) {
     ($SSid,$SSseq,$cSectsubid,$rest1,$rest2,$rest3,$cPage,$rest4) = split(/\^/,$cSectsub);
     ($cSectid,$cSubid) = split(/_/,$cSectsubid);
     &clear_doc_data;  ### clear out any data that may be left from another time
     &clear_doc_variables;
     @DOCARRAY = "";
     undef %DOCARRAY;
     if($rSectid eq $cSectid) {
        if( ($cmd =~ /display_section/ and $rPage eq $cPage) or
            ($cmd =~ /(display_subsection|print_select)/ and ($rSectsubid eq $cSectsubid or $supress_nonsectsubs !~ /Y/) ) )  { ##      will work even if no page
             $found_it = &do_subsection($cSectsubid,$print_it,$email_it,$htmlfile_it,$pg_num,$found_it);
	    }
	  }

	 if(($cSectid ne $rSectid and $found_it)
     or ($cmd =~ /display_subsection/ and $cSubid ne $rSubid and $found_it) ) {
        last;
     }
  }

  if($htmlfile_it eq "Y" and (-f "$statuspath/$rPage.busy")) {
##     system "cp $prepagepath/$rPage.html $publicdir/pre.$rPage.html" if (-f "$prepagepath/$rPage.html");
     unlink "$statuspath/$rPage.busy";
     $outfile eq "";
  }

  $htmlfile_it = 'N';
  $email_it    = 'N';
  $print_it    = 'N';
}


sub do_subsection {
 my ($rSectsubid,$print_it,$email_it,$htmlfile_it,$pg_num,$found_it) = @_;
 $listSectsub = $rSectsubid;

 &split_section_ctrlB($rSectsubid);
 $pg2Max = $qItemMax;
 $pg2Max = $cPg2Items unless($itemMax);
 $pg1max  = $qPg1max;
 $pg1max  = $cPg1Items unless($qPg1max);

 $savetemplate = $aTemplate;
 $aTemplate = "";
 $save_printit = $print_it;
 if($cVisable eq 'E'){
    $email_it = 'Y'
 }
 else {
    $print_it    = 'Y' if($rPage and $rSubid eq $cSubid and $cmd ne 'storeform');
    $print_it    = 'Y' if($rPage eq "" and $rSectid eq $cSectid and $cmd ne 'storeform');
    $print_it    = 'Y' if($cmd eq "display_section" and $rSectid eq $cSectid);
    $htmlfile_it = 'N' if($pg_num > 1);
    $email_it    = 'N' if($pg_num > 1);
 }

##  First do the top

 if(!$found_it and ($pg_num eq 1 or $pg_num !~ /[0-9]/) ) { 
     if($cHeader or $qHeader) {
           $aTemplate = $cHeader if($cHeader);
           $aTemplate = $qHeader if($qHeader);
           &process_template($aTemplate,'Y',$email_it,$htmlfile_it);  #in template_ctrl.pl
           $aTemplate = "";
     }
     if($cmd eq 'print_select' and !$qHeader) {
         $aTemplate = "select_top";
         &process_template($aTemplate,'Y',$email_it,$htmlfile_it) unless($listSectsub =~ /[$suggestedSS|CSWP|MAIDU]/ or $owner);  #in template_ctrl.pl
         $aTemplate = "";
     }

     if( $cmd =~ /display_subsection/ or $cmd =~ /display_section/) {
	    if($qMobidesk =~ /mobi/ or $cMobidesk =~ /mobi/) {
		   $aTemplate = "WOAmobileTop";
	    }
	    elsif ($listSectsub =~ /$suggestedSS/) {
	        $aTemplate  = "selectUpdt_Top";
	    }
     }
 }
 else {
    if($qMobidesk =~ /mobi/ or $cMobidesk =~ /mobi/) {
	   $aTemplate = "WOAmobileTop";
    }
#    elsif(!$aTemplate) {
#       $aTemplate  = "smallWOATop";
#    }
    &process_template($aTemplate,'Y',$email_it,$htmlfile_it) if($aTemplate);
    $aTemplate = "";
 }
 $found_it = 'Y';

 if($cTitleTemplate) {
    $aTemplate = $cTitleTemplate;
 }
 else {
    $aTemplate = "stdSubtitle" if($cTitle and $rSectsubid !~ /NewsDigest_NewsItem/);
 }

 &process_template($aTemplate,'Y',$email_it,$htmlfile_it) if($aTemplate);
 $aTemplate = "";

 if($cIdxSectsubid) {
    $doclistname = "$sectionpath$slash$cIdxSectsubid.idx";
    $dFilename = $cIdxSectsubid;
 }
 else {
	$doclistname = "$sectionpath$slash$cSectsubid.idx";
    $dFilename = $cSectsubid;
 }

 if($rSectsubid =~ /$emailedSS/) {
    $nodata = 'N';	
 }
 elsif(-f $doclistname) {
    $nodata = 'N';
    $nodata = 'Y' if(-z $doclistname);
 }
 else {
    $nodata = 'Y';
 }

#                          do template even if no items
 $aTemplate = $qTemplate;  #time to do detail
 $aTemplate = $cTemplate unless($aTemplate);

 if($nodata eq 'Y' and $cTemplate) {
    &process_template($aTemplate,'Y',$email_it,$htmlfile_it) if($cTemplate !~ /Item/); #in template_ctrl.pl
 }
 else {
    &process_doclist($rSectsubid,$doclistname);
 }

 if($cmd =~ /print_select/ and $listSectsub !~ /$suggestedSS/ and !$qFooter) {
    $aTemplate = 'select_end0';
     &process_template($aTemplate,'Y',$email_it,$htmlfile_it);  #in template_ctrl.pl
     $aTemplate = "";
 }
 if($cFooter or $qFooter) {
     $aTemplate = $cFooter if($cFooter);
     $aTemplate = $qFooter if($qFooter);
     &process_template($aTemplate,'Y',$email_it,$htmlfile_it);  # $print_it = Y in template_ctrl.pl
     $aTemplate = "";
 }

 $aTemplate = $savetemplate;
 $print_it  = $save_printit;
 return($found_it);
}


sub process_doclist
{
 my ($rSectsubid,$doclistname) = @_;
 $expired = "";
 my $counts = &get_start_stop_count($pg_num);  # in sectsubs.pl
 ($start_count,$stop_count) = split(/:/,$counts,2);
 $prev_docid = "000000";

 if($DB_doclist > 0 and $rSectsubid !~ /$emailedSS/ and $cAllOr1 =~ /all/) {
	&do_doclist_sql($dFilename);     # in sectsubs.pl
   return;
 }

 if($rSectsubid =~ /$emailedSS/) {	
    &process_popnews_list;
 }
 elsif($cAllOr1 =~ /1only/) {
    &process_1only_list;
 }
 else {
	$lock_file = "$dFilename.busy";
	&waitIfBusy($lock_file, 'lock');
 
    &push_items_to_sort;
    &sort_and_out;     
    $docid = "";
    undef @unsorted;
    undef @sorted;
    undef %pushdata;
    undef %keyfield;
 }
 unlink "$lock_file";
}


sub process_popnews_list
{
  $totalItems = 1;
  $ckItemnbr  = 1;
  opendir(MAILDIR, "$mailpath");  # overpopulation.org/popnews_inbox <- This is emailed2docitem.pl puts it
  my(@mailfiles) = grep /^.+\.(itm|email)$/, readdir(MAILDIR);
  closedir(MAILDIR);
#           FIRST PASS

  my $filename = "";
  foreach $filename (@mailfiles) {
     $filepath = "$mailpath/$filename";
     ($fdocid,$rest) = split(/\.itm/,$filename) if($filename =~ /itm$/);
     ($fdocid,$rest) = split(/\.email/,$filename) if($filename =~ /email$/);

     &do_one_mail($filepath,$fdocid,$ckItemnbr);  

     $ckItemcnt  = &padCount6($ckItemnbr);
     if($pgItemnbr ne "" or $pgItemnbr > 0) {
         $pgItemnbr = $pgItemnbr + 1;
         $pgitemcnt = &padCount4($pgItemnbr);
     }
     $totalItems = $totalItems + 1;
     $ckItemnbr  = $ckItemnbr + 1;
     last if($ckItemcnt > $stop_count);
  } # end foreach 

#  $totalItems = $totalItems - 1 unless($totalItems < 1);
#  &set_item_count($totalItems,$doclistname); #in indexes.pl
}

sub do_one_mail
{
 my ($filepath,$fdocid,$ckItemnbr) = @_;
 &clear_doc_data;     #in docitem.pl

 $docid = $fdocid;

 if(-f $filepath) {
   open(MAILFILE, "$filepath") or die"Could not open mail file @ $filepath";
 }
 else {
	print "File does not exist $filepath<br>\n";
 }

 while(<MAILFILE>)
 {
     chomp;
     $line = $_;
    if($line !~ /\^/) {
       $DATA{$name} = "$DATA{$name}\n$line";
     }
     else {
       ($name, $value) = split(/\^/,$line);
       $DATA{$name} = $value;
     }
      $printout .= "$line<br>\n" if($printit =~ /Y/); # printit not the same as $print_it passed in as arg
 }
 close(MAILFILE);

 ($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
    = &extract_docitem_variables;     # in docitem.pl

    $select_item = &do_we_select_item;   # in docitem.pl
   if($select_item) {
		 &print_one_doc($aTemplate,'Y','N','N',$ckItemnbr);  ## skip dups do_one_doc in docitem.pl
    }
}


sub process_1only_list
{
 &push_items_to_sort;

 print "<!-- - - - subsection $qSectsub $ss_ctr - - - -->\n";

 my $ckItemnbr = 1;
 my $ckItemcnt = &padCount6($ckItemnbr);
 my $all_d = 'N';

 @sorted = sort(@unsorted);

 ($rSectsubid,$rest) = split(/\./,$doclistname,2);
 $sectionfile    = "$sectionpath/$rSectsubid.idx";
 $newsectionfile = "$sectionpath/$rSectsubid.new";
 $bkpsectionfile = "$sectionpath/$rSectsubid.bkp";

 $lock_file = "$statuspath/$rSectsubid.busy";
 &waitIfBusy($lock_file, 'lock');

 system "cp $sectionfile $bkpsectionfile" if(-f $sectionfile);

 unlink "$newsectionfile" if(-f $newsectionfile);
 system "touch $newsectionfile" or die;

 if($SVRinfo{'environment'} == 'development') {
    open(OUTSUB, ">$newsectionfile") or print "art H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$newsectionfile");
 }

 foreach $data (@sorted) {
    ($keyfield,$docid,$docloc) = split(/\^/,$data,3);

##    print "<!-- art877 pre do_one ..docid $docid ..ckItemcnt $ckItemcnt ..-->\n";
    if($ckItemnbr == 1) {
        if($docloc =~ /d/) {
          &do_one_doc($index_insert_sth);   ## Display the first item -- sub found in docitem.pl
          $docloc = 'n';  ## change from do display to don't display
        }
        else { ## if first one is not a 'd', then set all to 'd'
            $all_d = 'Y';
        }
    }
    $docloc = 'd' if($all_d eq 'Y');

    print OUTSUB "$docid^$docloc\n";

	  if($docid ne $prev_docid ) {
	       $ckItemnbr = $ckItemnbr+1;
	       $ckItemcnt = &padCount6($ckItemnbr);
	  }

    $prev_docid = $docid;
 }
 close(OUTSUB);

 if(-f $newsectionfile) {
	  unlink $sectionfile;
##    system "cp $newsectionfile $sectionfile" or print "art877 - failed to copy new to section index file: $sectionfile<br>\n";
##   THE ABOVE IS A LIE! IT DOES NOT FAIL TO COPY
    system "cp $newsectionfile $sectionfile";
 }
 else {
	  print "Section index file $newsectionfile failed to update; Error code art882; processing stopped.  Please contact web admin. <br>\n";
    exit;
 }

 unlink $newsectionfile if(-f $newsectionfile);
 unlink $lock_file  if(-f $lock_file);

 $docid = "";
 undef @unsorted;
 undef @sorted;
}

sub push_items_to_sort
{
 $qOrder = $SSARRAY{'qOrder'};
 if($qOrder =~ /[A-Za-z0-9]/) {
   $sortorder = $qOrder;
 }
 else {
   $sortorder = $cOrder;
 }

 $access = $operator_access;

 $totalItems = 1;
 $ckItemnbr = 1;

 open(INFILE, "$doclistname");
 while(<INFILE>) {
    chomp;
    $line = $_;
    ($docid,$docloc) = split(/\^/,$line,3);
    if($docid =~ /[0-9]/) {   ## prepare for sort
       $kDocid  = $docid;
       $kDocloc = $docloc;
       $kSeq    = &calc_idxSeqNbr($totalItems);
       &get_doc_data($docid,N);    # in docitem.pl
       &pushdata_to_sortArray; ## in indexes.pl
       $totalItems = $totalItems + 1;
       $ckItemnbr  = $ckItemnbr + 1;
    }
 } #end file
 close(INFILE);
 $totalItems = $totalItems - 1 unless($totalItems < 1);
 &set_item_count($totalItems,$doclistname);       #in indexes.pl
#       Only do count file if an item has been changed, added, deleted; not just on display
# $time4countfile = "$autosubdir/status/time4count.txt";
# if(-f $time4countfile) {
#    &set_item_count($totalItems,$doclistname) if(-f $time4countfile); #in indexes.pl
#    unlink $time4countfile;
# }
 unlink "$lock_file";
}


sub sort_and_out
{
## sort the data we pushed to the array
$ss_ctr = $ss_ctr + 1;
print "<!-- - - - subsection $qSectsub $ss_ctr - - - -->\n";

### $stop_count = $cMaxItems if($cMaxItems =~ /[0-9]/);
 $ckItemnbr = 1;
 $ckItemcnt = &padCount6($ckItemnbr);

 @sorted = sort(@unsorted);

 foreach $data (@sorted) {
     ($keyfield,$docid,$docloc) = split(/\^/,$data,3);

   my $save_docid = $docid;
#          ## do_one_doc is in docitem.pl
    &do_one_doc($index_insert_sth) if($docid ne $prev_docid and $ckItemcnt > $start_count and $docid =~ /[0-9]/);  ## skip dups
    $docid = $save_docid;
     if($skip_item !~ /Y/ or $select_item eq 'Y') {
	    if($docid ne $prev_docid ) {
	       $ckItemnbr = $ckItemnbr+1;
	       $ckItemcnt = &padCount6($ckItemnbr);
		   if($pgItemnbr ne "" or $pgItemnbr > 0) {
				$pgItemnbr = $pgItemnbr + 1;
				$pgitemcnt = &padCount4($pgItemnbr);
		   }
	    }
	 }
     $prev_docid = $docid;
     last if($ckItemcnt > $stop_count);
  }
}



##  00310 RE-CREATE THE HTML PAGE IF IT HAS CHANGED

sub do_html_page
{
 my($savedocid) = $docid;

 @chgsectsubs = split(/;/,"$chgsectsubs");
 local($didsections) = "";

 foreach $rSectsub (@chgsectsubs) {
   if($rSectsub) {
     &split_rSectsub;
     $cSectsubid = $rSectsubid;
     &split_section_ctrlB($rSectsubid);
#                  if we didn't already do this section
      if($didsections !~ /$rSectid/ and $cPage =~ /[A-Za-z0-9]/)   {
        &create_html($rSectsub,$aTemplate,$pg_num) if($action !~ /move_webpage/);

        $pagenames = "$cPage;$pagenames" if($pagenames !~ /$cPage/ and $PAGEINFO{$cPage} =~ /ftpdefault/);
        $didsections = "$didsections;$rSectsubid";
      }
   }
 }
 $pagenames =~  s/^;+//;  #get rid of leading semi-colons
 $docid = $savedocid;
}


1;