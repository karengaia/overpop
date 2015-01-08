#!/usr/bin/perl --

# 2014 Sept. 19. display_list.pl

## TODO: make these part of the $L hash: $pg2max,$totalItems,$pg1max

# renamed from display.pl
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
 %DL = ();
 $INLINE = "";
 $L{start_count} = 0;
 $L{stop_count} = 0;
 $L{stop_count} = $cMaxItems if($cMaxItems =~ /[0-9]/);
}

sub init_paging_variables
{
 $ckItemcnt = 0;    ## ck for max
 $pgitemcnt = "";   ##page
 $ssItemcnt = "";   ##subsection
 $totalItems = 0;
 $pg_num = 1;
 $ckItemnbr = 0;
 $default_itemMax = 7;
 $default_order = 'p';
}


##  RE-CREATE THE HTML PAGE IF IT HAS CHANGED; From docitem.pl at end of       storeform

sub do_html_page
{
 my ($docid,$listSectsub,$aTemplate,$pg_num,$chgsectsubs) = @_;
 $L{pg_num} = $pg_num;
 my @chgsectsubs = split(/;/,$chgsectsubs);
 my $didsections = "";

 foreach my $rSectsub (@chgsectsubs) {
   if($rSectsub) {
     &split_rSectsub;
     $cSectsubid = $rSectsubid;
     &split_section_ctrlB($rSectsubid);
#                  if we didn't already do this section
     if($didsections !~ /$rSectid/ and $cPage and $action !~ /move_webpage/)   {
        &create_html($rSectsub,$aTemplate,$pg_num,'Y',$listSectsub);

        $pagenames = "$cPage;$pagenames" if($pagenames !~ /$cPage/ and $PAGEINFO{$cPage} =~ /ftpdefault/);
        $didsections = "$didsections;$rSectsubid";
     }
   }
 }
 $pagenames =~  s/^;+//;  #get rid of leading semi-colons
 $L{pagenames} = $pagenames;
}

sub create_html
{
  my ($rSectsubid,$aTemplate,$pg_num,$supress_nonsectsubs,$listSectsub) = @_;
  $supress_nonsectsubs = 'Y' if($pg_num > 1);

  if($rSectsubid =~ /Volunteer_log/) {   ## <-- Does this work? Where is volunteer's id?
		$doclistname = "$sectionpath/$rSectsubid.idx";
		&process_doclist($rSectsubid,$doclistname);
		return;
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
      if($DB_docitems < 1) {
     	$lock_file = "$statuspath/$rPage.busy";
     	&waitIfBusy($lock_file, 'lock');
     	$outfile = "$prepagepath/$rPage.html";
     	unlink $outfile if(-f $outfile);
     }
  }

  $found_it  = "";
  $pgItemnbr = "";
  $pgitemcnt = "";
  $pgItemnbr = 1;

  $pgitemcnt = &padCount4($pgItemnbr);

  foreach $cSectsub (@CSARRAY) {
     ($SSid,$SSseq,$cSectsubid,$rest1,$rest2,$rest3,$rest4,$cPage,$rest5) = split(/\^/,$cSectsub);
     ($cSectid,$cSubid) = split(/_/,$cSectsubid);
     &clear_doc_data;  ### clear out any data that may be left from another time
     &clear_doc_helper_variables;
     @DOCARRAY = "";
     undef %DOCARRAY;

     if($rSectid eq $cSectid) {
        if( ($cmd =~ /display_section/ and $rPage eq $cPage)
           or ($cmd =~ /(display_subsection|print_select)/ and ($rSectsubid eq $cSectsubid or $supress_nonsectsubs !~ /Y/) ) )  { ##      will work even if no page
       
           $found_it = &do_subsection($cSectsubid,$cFiltername,$print_it,$email_it,$htmlfile_it,$pg_num,$found_it);
        }
	  }
	  if(($cSectid ne $rSectid and $found_it)
     or ($cmd =~ /display_subsection/ and $cSubid ne $rSubid and $found_it) ) {
        last;
     }
  }

  if($DB_docitems < 1 and $htmlfile_it eq "Y" and (-f "$statuspath/$rPage.busy")) {
##     system "cp $prepagepath/$rPage.html $publicdir/pre.$rPage.html" if (-f "$prepagepath/$rPage.html");
     unlink "$statuspath/$rPage.busy";
     $outfile eq "";
  }

  $htmlfile_it = 'N';
  $email_it    = 'N';
  $print_it    = 'N';
}

sub do_subsection {
 my ($rSectsubid,$rFiltername,$print_it,$email_it,$htmlfile_it,$pg_num,$found_it) = @_;

 &split_section_ctrlB($rSectsubid);

 return("") if($SS{'tofrom'} eq 'T' and $DB_docitems > 0);
 return("") if($SS{'tofrom'} eq 'N' and $DB_docitems < 1);

 $listSectsub = $rSectsubid;
 $pg2Max = $qItemMax;
 $pg2Max = $cPg2Items unless($itemMax);
 $pg1max  = $qPg1max;
 $pg1max  = $cPg1Items unless($qPg1max);
 $L{pg2max} = $pg2max;
 $L{pg1max} = $pg1max;

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

## First find out if there is any data

 if($SS{'fromtoSSname'} and $SS{'tofrom'} ne 'T') {
	 my $fromSSname = $SS{'fromtoSSname'};
##                            If $DB_docitems > 0 means we have converted docitems, indexes and sectsubs
	 if($fromSSname =~ /Headlines_sustainability/ and $DB_docitems > 0) {
##          Do this until we can manually change from to Headlines_headlines
		 $fromSSname = "Headlines_headlines" # only instance of a from SS where name is being changed
	 }
     $doclistname = "$sectionpath$slash$fromSSname.idx";
     $dFilename = $fromSSname;
 }
 else {
	 $doclistname = "$sectionpath$slash$rSectsubid.idx";
     $dFilename = $rSectsubid;
 }

 if(-f $doclistname) {
    $nodata = 'N';
    $nodata = 'Y' if(-z $doclistname);
 }
 else {
    $nodata = 'Y';
 }

return ($found_it) if($nodata eq 'Y');

##  2nd do the top

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


#                          do template even if no items

 $aTemplate = $qTemplate;  #time to do detail
 $aTemplate = $SS{'template'} unless($aTemplate);
# $aTemplate = $cTemplate unless($aTemplate);

 if($nodata eq 'Y' and $aTemplate) {
    &process_template($aTemplate,'Y',$email_it,$htmlfile_it) if($cTemplate !~ /Item/); #in template_ctrl.pl
 }
 elsif ($nodata ne 'Y') {	
    &process_doclist($rSectsubid,$rFiltername,$doclistname);
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
 my ($rSectsubid,$rFiltername,$doclistname) = @_;

 if($DB_doclist > 0 and $rSectsubid !~ /$emailedSS/ and $cAllOr1 =~ /all/) {
#	 if($rFiltername and &filter_)
	 &DB_doclist_print($rSectsubid,$pg_num);     # in docitem.pl
     return;
 }

 $expired = "";
 ($L{startcount},$L{stopcount}) = &get_start_stop_count($pg_num); #results go in $L{start_count} and $L{stop_count}

 if($rSectsubid =~ /$emailedSS/) {
    &process_popnews_list;
 }
 elsif($cAllOr1 =~ /1only/) {
    &process_1only_list;
 }

 else {
	$lock_file = "$statuspath/$dFilename.busy";
	&waitIfBusy($lock_file, 'lock');

	my $ref_unsorted =  &push_items_to_sort($rSectsubid,$doclistname);

 	&sort_and_out($ref_unsorted);

	$docid = ""; $A{$docid} = "";

	unlink "$lock_file";
 }
}

sub process_popnews_list
{
  $totalItems = 1;
  $ckItemnbr  = 1;
  opendir(MAILDIR, "$mailpath");  # overpopulation.org/popnews_inbox <- This is where emailed2docitem.pl puts it
  my(@mailfiles) = grep /^.+\.(itm|email)$/, readdir(MAILDIR);
  closedir(MAILDIR);
#           FIRST PASS

  my $filename = "";
  foreach $filename (@mailfiles) {
     $filepath = "$mailpath/$filename";
     my($fdocid,$rest) = split(/\.itm/,$filename) if($filename =~ /itm$/);
     ($fdocid,$rest) = split(/\.email/,$filename) if($filename =~ /email$/);

     &do_one_mail($filepath,$fdocid,$ckItemnbr);
     $ckItemcnt  = &padCount6($ckItemnbr);
     if($pgItemnbr ne "" or $pgItemnbr > 0) {
         $pgItemnbr = $pgItemnbr + 1;
         $pgitemcnt = &padCount4($pgItemnbr);
     }
     $totalItems = $totalItems + 1;
     $ckItemnbr  = $ckItemnbr + 1;
     last if($ckItemcnt > $L{stop_count});
  } # end foreach
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

 &massage_docitem_variables;     # in docitem.pl ; Data goes in $D hash

    my $select_item = &do_we_select_item($D{docid});   # in docitem.pl
   if($select_item) { # skip dups
		 &print_one_doc($D{docid},$aTemplate,'Y','N','N',$ckItemnbr);  # in docitem.pl
    }
}


sub process_1only_list
{
#TODO: If DB > 0, do DB thing

 &push_items_to_sort($rSectsubid,$doclistname);

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
    my($keyfield,$docid,$stratus) = split(/\^/,$data,3);

##    print "<!-- art877 pre do_one ..docid $docid ..ckItemcnt $ckItemcnt ..-->\n";
    if($ckItemnbr == 1) {
        if($stratus =~ /d/) {
          &prt_one_doc($docid,$aTemplate,'Y','N','N',$ckItemnbr);   ## Display the first item -- sub found in docitem.pl
          $stratus = 'n';  ## change from do display to don't display
        }
        else { ## if first one is not a 'd', then set all to 'd'
            $all_d = 'Y';
        }
    }
    $stratus = 'd' if($all_d eq 'Y');

    print OUTSUB "$docid^$stratus\n";

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
 my($rSectsubid,$doclistname) = @_;
 my $sortorder = $cOrder;

 if($L{qlistorder} =~ /[A-Za-z0-9]/) {  # listorder specified by query string in article.pl
   $sortorder = $L{qlistorder};
 }

 my $tdaysago  = &get_somedaysago(42);  # 6 weeks
# $access = $operator_access;

 $totalItems = 1;
 $ckItemnbr = 1;
 my $prev_docid = "";
 my @unsorted = ();

 my $fromSSname = &DB_get_fromSSname($rSectsubid); # in sectsubs.pl
# my $srcsectsub = $SS{$rSectsubid}{srcsectsub};

 open(INFILE, "$doclistname") or die("Couldn't open doclist $doclistname");
 while(<INFILE>) {
    chomp;
    my $line = $_;
    my($docid,$stratus) = split(/\^/,$line,3);
    if($docid =~ /[0-9]/ and $docid ne $prev_docid) {   ## prepare for sort
       &get_doc_data($docid,N);    # in docitem.pl
#               DON'T LIST IT UNLESS the docitem sectsubs shows the list sectsub or the from sectsub #  and $tofrom ne 'T'
       if(!$rSectsubid or ($rSectsubid and ($D{sectsubs} =~ /$rSectsubid/)) or ($fromSSname and $tofrom ne 'T' and $D{sectsubs} =~ /$fromSSname/) ) {  # process only if the list sectsub is one of the docitem sectsubs
#             print "<small><small><small><small style=\"color:grey\">````` $docid</small></small></small></small><br>\n";
           if($rSectsubid and $rSectsubid =~ /Headlines_priority/ and $D{priority} != 7) {}
	       else {
		       $seq = &calc_idxSeqNbr($totalItems,$sortorder);
		       &pushdata_to_sortArray($docid,$stratus,$ckItemnbr,$sortorder,$tdaysago,\@unsorted);
		       $totalItems = $totalItems + 1;
		       $ckItemnbr  = $ckItemnbr + 1;
		       last if($total_items > 30);    ##### TEMPORARY FIX
		       $prev_docid = $docid;
		  }
       }
    }
 } #end file
 close(INFILE);
 $totalItems = $totalItems - 1 unless($totalItems < 1);

#       Only do count file if an item has been changed, added, deleted; not just on display
 if(-f $time4countfile) {
    &set_item_count($totalItems,$doclistname) if(-f $time4countfile); #in indexes.pl
    unlink $time4countfile;
 }
 unlink "$lock_file";
 return(\@unsorted);
}


sub sort_and_out  #flatfile version - after the sort
{
 my $ref_unsorted = $_[0];
## sort the data we pushed to the array

 $ss_ctr = $ss_ctr + 1;
 print "<!-- - - - subsection $qSectsub $ss_ctr - - - -->\n";

 $L{stop_count} = $cMaxItems if($cMaxItems =~ /[0-9]/);

 $ckItemnbr = 0;
 $ckItemcnt = &padCount6($ckItemnbr);
 my $prev_docid = "000000";
 my @sorted = {};
    @sorted = sort(@{$ref_unsorted});

 my $data = "";
 foreach $data (@sorted) {
     my($keyfield,$docid,$stratus) = split(/\^/,$data,3);
#	 print "dis527 docid $docid ..ckItemcnt $ckItemcnt ..stop_count $L{stop_count}<br>\n";
     $ckItemnbr = &display_doc($docid,$stratus,$prev_docid,$ckItemnbr);
	 last if($ckItemcnt > $L{stop_count});
#	print "dis530 after last<br>\n";
	 $prev_docid = $docid;
 }
}

sub display_doc
{
  my($docid,$stratus,$prev_doc,$ckItemnbr) = @_;
#         print "<small><small><small style=\"color:grey\">.... $docid ..prev_docid $prev_docid ..L-start_count $L{start_count}</small></small></small>\n";
  if($docid ne $prev_docid and $ckItemcnt >= $L{start_count} and $docid =~ /[0-9]/) {
	  my($skip_item,$select_item) = &do_each_doc($docid,$stratus,$ckItemnbr); #in docitem.pl
#          print "<small><small><small style=\"color:grey\">.... skip_item $skip_item ..select_item $select_item .. $docid</small></small></small>\n";
	  if($skip_item !~ /Y/ or $select_item == 'Y')
		{
	        $ckItemnbr = $ckItemnbr + 1;
	        $ckItemcnt = &padCount6($ckItemnbr);
		    if($pgItemnbr ne "" or $pgItemnbr > 0) { # $pgItemnbr and $pgitemcnt are globals
				$pgItemnbr = $pgItemnbr + 1;
				$pgitemcnt = &padCount4($pgItemnbr);
		    }
	 }
   }
   return($ckItemnbr);
}


sub DB_doclist_print {  #database version
  my($dSectsub,$pagenum) = @_;

 $L{stop_count} = $cMaxItems if($cMaxItems =~ /[0-9]/);
 $ckItemnbr = 0;
 $ckItemcnt = "";

  my ($n_startcnt,$num_articles,$orderby,$lastpg2woadatetm)
       =  &DB_prep_counts_order($dSectsub,$pagenum);  # in display.pl

  &clear_doc_data;   #  ready for next row = in docitem.pl
  my $col_sql = &build_sql('select');

  my $sql = "SELECT $col_sql,i.stratus FROM indexes as i, docitems as d, sectsubs as s WHERE i.sectsubid = s.sectsubid AND d.docid=i.docid AND s.sectsub = ? AND deleted = 'N' AND d.woadatetem > ? ORDER BY ? LIMIT ?, ?";

  my $sth = $DBH->prepare($sql) or die "DB doclist failed prepare";

  $sth->execute($dSectsub,$lastpg2woadatetm,$orderby,$n_startcnt,$num_articles) or die "DB doclist failed execute";
  %D = $query->fetchhash;

  my %row;
  $sth->bind_columns( \( @row{ @{$sth->{NAME_lc} } } ));
  while ($sth->fetch) {
      %D = %$row;   # %D is a global hash where docitem column data is stored.

	  $ckItemnbr = &display_doc($D{docid},$D{stratus},"",$ckItemnbr);
	  last if($ckItemcnt > $L{stop_count});
  }

	#  my %d;
	#  while( my $d = $sth->fetchrow_hashref) {
	#	  if ($sth->rows == 0) {
	#	  }
	#	  else {
	#		  %D = %$d;  %D is a global
	#		  &display_one_doc;
	#	  }
	#   }
}


sub pushdata_to_sortArray
{
 my($docid,$stratus,$itemnbr,$sortorder,$tdaysago,$ref_unsorted) = @_;
# if($kDocid ne $docid) {
#      $saveDocid = $docid;
#      $docid = $kDocid;
  &get_doc_data($docid,'N');
#  $docid = $saveDocid;
#  }

  if(!$D{sectsubs}) {
#	print "$docid Sectsubs empty .. sysdt $D{sysdate} return .. dl568<br>\n";
	return;
}
  my $kSysdate;
  my $kPubdate;
  my $kPriority;
  my $keyfield;

  my $seq = &calc_idxSeqNbr($itemnbr,$sortorder);

  $stratus  = 'M' if(!$stratus and $cAllOr1 =~ /all/);
  $stratus  = 'd' if(!$stratus and $cAllOr1 =~ /1only/);
  $stratus = 'M' if(!$stratus);

  if($D{sysdate} < $tdaysago and $rSectsubid =~ /Headlines/) {
     $D{priority} = '4';
  }

  if($sortorder eq 'R') {
     $kPubdate = &get_sort_pubdate($D{pubdate},$sortorder);
     $keyfield = "$stratus-$D{region}-$kPubdate";
  }
  elsif($sortorder eq 'T') {
     $keyfield = "$stratus-$D{region}-$topic";
  }
  elsif($sortorder eq 't') {
     $kPriority = (8 - $D{priority});
     $keyfield = "$stratus-$kPriority-$D{region}-$D{topic}";
  }
  elsif($sortorder =~ /[Pp]/) {
     $kPubdate = &get_sort_pubdate($D{pubdate},$sortorder);
     $keyfield = "$stratus-$kPubdate";
  }
  elsif($sortorder =~ /d/) {     # headlines priority
#     $kPriority = (8 - $D{priority}) if($D{priority} =~ /[0-9]/);
      $kPriority = $D{priority} if($D{priority} =~ /[0-9]/);
     $kSysdate = &get_sort_sysdate($D{sysdate},$sortorder);
     $kPubdate = &get_sort_pubdate($D{pubdate},$sortorder);
     $keyfield = "$kPriority-$kSysdate-$kPubdate";
 }
  elsif($sortorder =~ /D/) {  # headlines_sustainability
     $kSysdate = &get_sort_sysdate($D{sysdate},$sortorder);
     $kPubdate   = &get_sort_pubdate($pubdate,$sortorder);
     $keyfield   = "$kSysdate-$kPubdate";
  }
  elsif($sortorder =~ /[A]/) {
     $kPriority = 7;
     $kPriority = (7 - $D{priority}) if($D{priority} >=0 and $D{priority} ne 'D');
     $kSysdate = &get_sort_sysdate($D{sysdate},$sortorder);
     $keyfield = "$stratus-$kPriority-$kSysdate";
  }
  elsif($sortorder eq 'H') {
     $keyfield = "$D{headline}";
  }
  elsif($sortorder eq 'S') {
     $keyfield = "$stratus-$S{source}";
  }

  elsif($sortorder eq 'r') {    #reverse physical order
     my $seq = 9999 - $seq;
     $keyfield = "$stratus-$seq";
  }

##   F=first L=last - whichever it was stored in
  else {
     $keyfield = "$stratus-$seq";
  }

## print "<font face=arial size=1 color=silver>sec470 $kDocid $keyfield</font><br>\n";
  my $pushdata = "$keyfield^$docid^$stratus";
  $pushdata =~ s/^\^+//;   ## trim leading carets
  $pushdata =~ s/\^$//;    ## trim trailing carets

#  print "dl641 push docid $docid ..pushdata $pushdata<br>\n";
 if( @{$ref_unsorted} ) {
    push @{$ref_unsorted}, $pushdata;
 }
 else {
    @{$ref_unsorted} = ($pushdata);
 }

#  if(@unsorted) {
#     push @unsorted, $pushdata;
#  }
#  else {
#     @unsorted = ($pushdata);
#  }
}

sub calc_idxSeqNbr
{
 my($itemnbr,$sortorder) = @_;
 my $count = 999999;
 $count = $itemnbr          if $sortorder eq 'F';
 $count = 999999 - $itemnbr if $sortorder eq 'L';
 $count = &padCount6($count);
 return $count;
}

sub get_sort_pubdate
{
  my ($puddate,$sortorder) = $_[0];
  my $pubdate = &conform_date($pubdate,'n',$D{sysdate});
#  $xPubdate = $kPubdate;
#  if($sortorder =~ /[PDdRA]/) {
	   $pubdate =~ s/-//g;
       $pubdate = (30000000 - $pubdate);
       $pubdate = "0$pubdate" if($pubdate =~ /^9/);
#  }
  return($pubdate);
}

sub get_sort_sysdate
{
   my ($sysdate,$sortorder) = $_[0];
   my $sysdate = &conform_date($sysdate,'n');
#   if($sortorder =~ /[PdDRA]/) {
	   $sysdate =~ s/-//g;
       $sysdate = (30000000 - $sysdate);
       $sysdate = "0$sysdate" if($sysdate =~ /^9/);
#   }
    return($sysdate);
}

sub get_sort_woadatetime   ## still need to add woadatetime to index for summarized, suggested, news
{                          ## this is just for conversion of flat to DB (do we need?)
	$kSysdate = &conform_date($D{woadatetime},'n',$D{pubdate}); # if no woadatetime, use $pubdate + hhmmss = 000000
    if($sortorder eq 'W') {
        $kSysdate = (30000000000000 - $kSysdate);
        $kSysdate = "0$kSysdate" if($kSysdate =~ /^9/);
    }
}

sub conform_date    # format yyyy-mm-dd
{
  my ($date,$format,$date2) = @_;

  if($date eq $epoch_time or $date eq $epoch_date or $date eq $null_time) {
      return($date2);
  }

  ($yyyy,$mm,$dd) = split(/-/,$date,3);  ## need to add split on space and : if datetime

  if(($yyyy !~ /^[0-9]{4}$/ or $yyyy =~ /0000/) and $D{sysdate}) {
	 $date = $date2;
     ($yyyy,$mm,$dd) = split(/-/,$date,3);
  }

  if($yyyy !~ /^[0-9]{4}$/ or $yyyy =~ /0000/) {
      return ("0000-00-00") if($format =~ /f/);
      return ("00000000") if($format !~ /f/);   # use this format on indexes
  }

  if( $mm =~ /00([0-9])/) {
	     $mm = "0$1" ;
  }
  $mm = "00" if($mm !~ /[0-1][0-9]/ and length($mm) != 2);

  if($dd =~ /[0-3]{1}[0-9]{1}/) {
  }
  elsif($dd =~  / [1-9]/) {
     $dd =~ s/ ([1-9])/0$1/;  # replace days leading blank with leading zero
  }
  elsif($dd =~ /[1-9]{1}/) {
     $dd   =~ s/([1-9]{1})/0$1/;  # pad with 0 any day with just one character
  }
  else {
     $dd = "00";
  }

  if($format =~ /f/) {
	return("$yyyy-$mm-$dd");
  }
  else {
    return("$yyyy$mm$dd");  # use this format on indexes
  }
}


######## PAGING  ##########

## query string:     1^100:10 i.e. pg_num^max:pg1max
## in sections.html : maxitems: 100:10   N:M = stop after 10 on the 1st page
##                   DO NOT PAD!!

##    pg 1: start_count = 0; stop_count = N
##    pg 2on start_count = N + (pg - 2)*M   2-11, 3-111, 4-211
##           stop_count = start_count + M

sub set_start_stop_count_maxes
{
 if($qItemMax =~ /[0-9]/) {
   $pg2max = $qItemMax;
 }
 elsif($cMaxItems =~ /[0-9]/) {
   $pg2max = $cMaxItems;
 }
 else {
   $pg2max = $default_itemMax;
 }

 if($qPg1max =~ /[0-9]/) {
   $pg1max = $qPg1max;
 }
 elsif($cPg1Items =~ /[0-9]/) {
   $pg1max = $cPg1Items;
 }
 else {
   $pg1max = $pg2max;
 }
 $L{pg1max} = $pg1max;
 $L{pg2max} = $pg2max;
}


sub get_start_stop_count
{
 my $pg_num = $_[0];

 my $start_count = 0;
 my $stop_count = 0;

 &set_start_stop_count_maxes;

 if($pg_num eq 1) {
    $start_count = 0;
    $stop_count = $pg1max;
 }
 else {  # 40 + (1-2) * 40
    $start_count = $pg1max + (($pg_num - 2) * $pg2max);  #  pg2-11, pg3-111, pg4-211
    $stop_count = $start_count + $pg2max;
 }

 $start_count = &padCount6($start_count);
 $stop_count  = &padCount6($stop_count);

 return($start_count,$stop_count);
}

sub DB_prep_counts_order   {
  my ($dSectsub,$pagenum) = @_;

  ($L{startcount},$L{stopcount}) = &get_start_stop_count($pagenum); # results go in $L{start_count} and $L{stop_count}
  my $orderby = &get_orderby;
  my $lastpg2woadatetm = $epoch_time;
  $lastpg2woadatetm = &DB_get_lastpg2_woadatetm if($orderby =~ /[LrW]/);  # in docitem.pl
  my $num_articles = $L{stop_count} - $L{start_count};

  return(int($start_count),$num_articles,$orderby,$lastpg2woadatetm);
}

sub total_pages
{
 my($doclistname,$pg2max,$tot_items,$pg1max) = @_;;
 if($pg2max !~ /[0-9]/ or $pg2max == 0) {
	$pg2max = $default_itemMax;
}

 unless($tot_items > 0 and tot_items =~ /0-9/) {
    $tot_items = &total_items($doclistname) + 1;
 }

 if($tot_items !~ /[0-9]/ or $tot_items < 2 or $tot_items <= $pg1max ) {
    $totalPages = 1;
 }
 else {  # more than one page

   $remaining_items = $tot_items - $pg1max;

   $totalPages = ($remaining_items / $pg2max) + 2; # add page 1 and fraction back in

   $totalPages = int($totalPages);
#   ($totalPages,$rest) = (/\./,$totalPages,2);
 }
 $L{totalitems} = $tot_items;
 $L{totalpages} = $totalPages;
 return($tot_items,$totalPages);
}

### set default top of page and bottom - but use both sectsub and subsect titles
### called from template.pl

sub print_pages_index
{
 my($pg_num,$sectsubid,$pg2max,$totalItems,$pg1max,$end_section) = @_;
 my $pg;
 $doclistname = "$sectionpath/$sectsubid.idx";
 &set_start_stop_count_maxes;  ## we have to this twice - also before start-stop count

 ($totalItems,$totalPages) = &total_pages($doclistname,$pg2max,$totalItems,$pg1max);

 if(($cMobidesk =~ /mobi/ or $qMobidesk =~ /mobi/) and $end_section eq 'Y') {
	$pg = $pg_num + 1;
##article.pl?0-cmd%1-atemplate%2-docid%3-listSectsub%4-doclist/sectsubid%5-userid/pgnum%6-pgcnt%7-header%8-footer%9-order%10-mobidesk
    print MIDTEMPL "<a target=_blank href=\"http://$scriptpath/article.pl?display_subsection%%NewsDigest_newsmobile%NewsDigest_newsmobile%%$pg%5%%%%mobi\">Next<\/a>\n";
 }
 elsif($totalPages > 1) {
	if($end_section eq 'Y') {
      print MIDTEMPL " End of this page in <b>";
      &do_title;  # in article.pl
      print MIDTEMPL "</b> section, ";
	}
    print MIDTEMPL "pg $pg_num ... Go to page ";
#    print MIDTEMPL "pg $pg_num ... Go to page <a target=\"_blank\" href=\"http://$publicUrl/prepage/viewsection.php?$sectsubid%%$pg_num\">1<\/a>.. \n";

     for($pg=1;$pg<($totalPages+1);$pg++) {
       if($pg > ($pg_num - 10) and $pg < ($pg_num + 11) and $pg != $pg_num) {
          print MIDTEMPL "<a target=\"_blank\" href=\"http://$publicUrl/prepage/viewsubsection.php?$sectsubid%%$pg\">$pg<\/a> ";
       }
     }
     if($totalPages > $pg) {
       $totalPages = $totalPages -1;
       print MIDTEMPL ".. <a target=\"_blank\" href=\"http://$publicUrl/prepage/viewsection.php?$sectsubid%%$totalPages\">$totalPages<\/a>\n";
     }
  }
}


1;
