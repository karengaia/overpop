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
  &split_section_ctrlB($rSectsubid);
  $rPage   = $cPage;
  $rSubdir = $cSubdir;
  $rSectid = $cSectid;
  $rSubid  = $cSubid;
  $rDoclink = $cDocLink;
  $email_it = 'Y' if($cVisable eq 'E');

  if($cPage) {
     $htmlfile_it = 'Y';

     $lock_file = "$statuspath/$rPage.busy";
     &waitIfBusy($lock_file, 'lock');

     $outfile = "$prepagepath/$rPage.html";
     unlink $outfile if(-f $outfile);
  }

  $found_it  = 'N';
  $pgItemnbr = "";
  $pgitemcnt = "";
  $pgItemnbr = 1;
  $pgitemcnt = &padCount4($pgItemnbr);
		
  foreach $cSectsub (@CSARRAY) {
     ($SSid,$SSseq,$cSectsubid,$rest) = split(/\^/,$cSectsub);
     $cSectsubInfo = "$SSid^$SSseq^$cSectsubid^$rest";
     ($cSectid,$cSubid) = split(/_/,$cSectsubid);
     &clear_doc_data;  ### clear out any data that may be left from another time
     &clear_doc_variables;
     @DOCARRAY = "";
     undef %DOCARRAY;
     if($cmd =~ /display_subsection/)  {
         &generate_WOA_webpage if($rSubid eq $cSubid);
     }
     elsif($rSectid eq $cSectid)  {	
         &generate_WOA_webpage;
     }

	 if(($cSectid ne $rSectid and $found_it =~ /Y/)
     or ($cmd =~ /display_subsection/ and $cSubid ne $rSubid and $found_it =~ /Y/) ) {
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

## 00440 ###  GENERATE WOA WEBPAGE ###

sub generate_WOA_webpage
{	
   &split_section_ctrlB($cSectsubid);
##      will work even if no page
  $supress_nonsectsubs = 'Y' if($pg_num > 1);
  if(($cPage eq $rPage) and ($cSectid eq $rSectid)) {
	if($rSectsubid =~ /$cSectsubid/ or $supress_nonsectsubs !~ /Y/) {
       &do_subsection;
    }
  }
}

sub do_subsection
{
 $savetemplate = $aTemplate;
 $aTemplate = "";

 $save_printit = $print_it;
 if($cVisable eq 'E'){
    $email_it = 'Y'
 }
 else {
    $print_it = 'Y' if($rPage and $rSubid eq $cSubid and $cmd ne 'storeform');
    $print_it = 'Y' if($rPage eq "" and $rSectid eq $cSectid and $cmd ne 'storeform');
    $print_it = 'Y' if($cmd eq "display_section" and $rSectid eq $cSectid);
    $htmlfile_it  = 'N' if($pg_num > 1);
    $email_it = 'N' if($pg_num > 1);
 }
 $found_it = 'Y';

 if($pg_num eq 1 or $pg_num !~ /[0-9]/) {
     if($cHeader or $qHeader) {
           $aTemplate = $cHeader if($cHeader);
           $aTemplate = $qHeader if($qHeader);
           &process_template($print_it,$aTemplate);  #in template_ctrl.pl
           $aTemplate = "";
     }
     if($cmd eq 'print_select' and !$qHeader) {
         $aTemplate = "select_top";
         &process_template($print_it,$aTemplate) if($thisSectsub !~ /[$suggestedSS|CSWP|MAIDU]/);  #in template_ctrl.pl
         $aTemplate = "";
     }

     if( $cmd =~ /display_subsection/ or $cmd =~ /display_section/) {
	    if($qMobidesk =~ /mobi/ or $cMobidesk =~ /mobi/) {
		   $aTemplate = "WOAmobileTop";
	    }
	    elsif ($thisSectsub =~ /$suggestedSS/) {
	        $aTemplate  = "selectUpdt_Top";
	    }
     }
     if($cTitleTemplate) {
        $aTemplate = $cTitleTemplate;
     }
     else {
        $aTemplate = "stdSubtitle" if($cTitle and $rSectsubid !~ /NewsDigest_NewsItem/);
     }
 }
 else {
   if($qMobidesk =~ /mobi/ or $cMobidesk =~ /mobi/) {
	   $aTemplate = "WOAmobileTop";
   }
   elsif(!$aTemplate) {
       $aTemplate  = "smallWOATop";
   }
 }
 &process_template($print_it,$aTemplate) if($aTemplate);

 $aTemplate = $qTemplate;  #time to do detail
 if($cIdxSectsubid) {
    $doclistname = "$sectionpath$slash$cIdxSectsubid.idx";
    $dFilename = $cIdxSectsubid;
 }
 else {
	$doclistname = "$sectionpath$slash$cSectsubid.idx";
    $dFilename = $cSectsubid;
 }

 if(-f $doclistname) {
    $nodata = 'N';
    $nodata = 'Y' if(-z $doclistname);
 }
 else {
    $nodata = 'Y';
 }

#                          do template even if no items
 if($nodata eq 'Y' and $cTemplate) {
   &process_template($print_it,$aTemplate) if($cTemplate !~ /Item/); #in template_ctrl.pl
 }
 else {
    &process_doclist;
 }

 if($cmd =~ /print_select/ and $thisSectsub !~ /$suggestedSS/ and !$qFooter) {
     $aTemplate = 'select_end';
     &process_template($print_it,$aTemplate);  #in template_ctrl.pl
     $aTemplate = "";
 }

 if($cFooter =~ /[A-Za-z0-9]/ or $qFooter =~ /[A-Za-z0-9]/) {
     $aTemplate = $cFooter if($cFooter =~ /[A-Za-z0-9]/);
     $aTemplate = $qFooter if($qFooter =~ /[A-Za-z0-9]/);
     &process_template($print_it,$aTemplate);  #in template_ctrl.pl
     $aTemplate = "";
 }

 $aTemplate = $savetemplate;
 $print_it  = $save_printit;
}


sub process_doclist
{
 if($DB_doclist > 0 and $rSectsubid !~ /$emailedSS/ and $cAllOr1 =~ /all/) {
	&do_doclist_sql($dFilename);     # in sections.pl
   return;
 }
 $lock_file = "$dFilename.busy";
 &waitIfBusy($lock_file, 'lock');
 $expired = "";

 local($counts) = &get_start_stop_count($pg_num);  # in sections.pl
 ($start_count,$stop_count) = split(/:/,$counts,2);
 $prev_docid = "000000";

 if($rSectsubid =~ /$emailedSS/) {
    &process_popnews_list;
 }
 elsif($cAllOr1 =~ /1only/) {
    &process_1only_list;
 }
 else {
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
 $ckItemnbr = 1;
 open(INFILE, "$doclistname");
 while(<INFILE>) {
	   chomp;
	   $line = $_;
	   ($docid,$docloc) = split(/\^/,$line,3);
		&get_doc_data($docid,'N');
	    &do_one_doc if($docid ne $prev_docid and $ckItemcnt > $start_count);  ## skip dups
	    $prev_docid = $docid;
	    $ckItemnbr  = $ckItemnbr + 1;
	    $ckItemcnt  = &padCount6($ckItemnbr);
	    last if($ckItemcnt > $stop_count);
	    if($pgItemnbr ne "" or $pgItemnbr > 0) {
	        $pgItemnbr = $pgItemnbr + 1;
	        $pgitemcnt = &padCount4($pgItemnbr);
	    }
	    $totalItems = $totalItems + 1;
	    $ckItemnbr  = $ckItemnbr + 1;
 } #end file
 close(INFILE);
 $totalItems = $totalItems - 1;
 &set_item_count($totalItems,$doclistname); #in sections.pl
}


sub process_1only_list
{
 &push_items_to_sort;

 print "<!-- - - - subsection $qSectsub $ss_ctr - - - -->\n";

 local($ckItemnbr) = 1;
 local($ckItemcnt) = &padCount6($ckItemnbr);
 local($all_d) = 'N';

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

 if(-f "../../karenpittsMac.yes") {
    open(OUTSUB, ">$newsectionfile") or print "art H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$newsectionfile");
 }

 foreach $data (@sorted) {
    ($keyfield,$docid,$docloc) = split(/\^/,$data,3);

##    print "<!-- art877 pre do_one ..docid $docid ..ckItemcnt $ckItemcnt ..-->\n";
    if($ckItemnbr == 1){
        if($docloc =~ /d/) {
          &do_one_doc;   ## Display the first item -- sub found in docitem.pl
          $docloc = 'n';  ## change from do display to don't display
        }
        else { ## if first one is not a 'd', then set all to 'd'
            $all_d = 'Y';
        }
    }
    $docloc = 'd' if($all_d eq 'Y');

    print(OUTSUB "$docid^$docloc\n");

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
 $totalItems = $totalItems - 1;
 &set_item_count($totalItems,$doclistname); #in sections.pl

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
##
##         is in docitem.pl

    &do_one_doc if($docid ne $prev_docid and $ckItemcnt > $start_count and $docid =~ /[0-9]/);  ## skip dups

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


sub do_expired
{
## if($expired =~ /[A-Za-z0-9]/) {
if($expired =~ /goofy/) {
      @expired = split(/;/,$expired);
      foreach $docid (@expired) {
     	   &get_doc_data($docid,N);  ## in docitem.pl
   	   $delsectsubs = $sectsubs;
   	   $addsectsubs = $expiredSS;
   	   $sectsubs    = $expiredSS;
   	   &write_doc_item;  ## in docitem.pl
   	   &hook_into_system;
     }
 }
}



##  00310 RE-CREATE THE HTML PAGE IF IT HAS CHANGED

sub do_html_page
{
 local($savedocid) = $docid;

 @chgsectsubs = split(/;/,"$chgsectsubs");
 local($didsections) = "";

 foreach $rSectsub (@chgsectsubs) {
   if($rSectsub) {
     &split_rSectsub;
     $cSectsubid = $rSectsubid;
     &split_section_ctrlB($rSectsubid);
#                  if we didn't already do this section
      if($didsections !~ /$rSectid/ and $cPage =~ /[A-Za-z0-9]/)   {
        &create_html if($action !~ /move_webpage/);

        $pagenames = "$cPage;$pagenames" if($pagenames !~ /$cPage/ and $PAGEINFO{$cPage} =~ /ftpdefault/);
        $didsections = "$didsections;$rSectsubid";
      }
   }
 }
 $pagenames =~  s/^;+//;  #get rid of leading semi-colons
 $docid = $savedocid;
}


1;