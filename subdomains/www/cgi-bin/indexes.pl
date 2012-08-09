#!/usr/bin/perl --

# February 2012
#        indexes.pl  : maintains flatfile indexes  and indexes table
#    To confuse matters, a list of document ids (docid) is called both an index or a section.
#    Only one index per section in the 'section' control file (sections.html or sectsubs table)

####   ADDING AND DELETING TO INDEX

##  SORT INDEX #####

sub pushdata_to_sortArray
{
 $sortorder = $cOrder;
 if($kDocid ne $docid) {
      $saveDocid = $docid;
      $docid = $kDocid;
      &get_doc_data;
      $docid = $saveDocid;
  }
  $kDocloc = 'M' if($kDocloc !~ /[A-Za-z0-9]/ and $cAllOr1 =~ /all/);
  $kDocloc = 'd' if($kDocloc !~ /[A-Za-z0-9]/ and $cAllOr1 =~ /1only/);
# my $x = &lessthan_3monthsago($sysdate);  #in date.pl
  my $sysdatenum = $sysdate;
  $sysdatenum =~ s/-//g;
  if($sysdatenum < $t3monthsago) {
     $priority = '0';
#print "ind21 priority $priority ..sysdatenum $sysdatenum lt t3monthsago $t3monthsago<br>\n";
   }
   else {
#print "ind22 priority $priority..sysdatenum $sysdatenum gt t3monthsago $t3monthsago<br>\n";
}
  if($sortorder eq 'R') {
     &get_sort_pubdate;
     $keyfield = "$kDocloc-$region-$kPubdate";
  }
  elsif($sortorder eq 'T') {
     $keyfield = "$kDocloc-$region-$topic";
  }
  elsif($sortorder eq 't') {
     $kPriority = (6 - $priority);
     $keyfield = "$kDocloc-$priority-$region-$topic";
  }
  elsif($sortorder =~ /[Pp]/) {
     &get_sort_pubdate;
     $keyfield = "$kDocloc-$kPubdate";
  }
  elsif($sortorder =~ /d/) {     # headlines priority
	 $kPriority = 6;
     $kPriority = (6 - $priority) if($priority >= 0);
     &get_sort_sysdate;
     &get_sort_pubdate;
     $keyfield = "$kPriority-$kSysdate-$kPubdate";
 }
  elsif($sortorder =~ /D/) {  # headlines_sustainability
     &get_sort_sysdate;
     &get_sort_pubdate;
     $keyfield = "$kSysdate-$kPubdate";
  }
  elsif($sortorder =~ /[A]/) {
     $kPriority = 6;
     $kPriority = (6 - $priority) if($priority >=0);
     &get_sort_sysdate;
     $keyfield = "$kDocloc-$kPriority-$kSysdate";
     unlink $kPriority;
  }
  elsif($sortorder eq 'H') {
     $keyfield = "$headline";
  }
  elsif($sortorder eq 'S') {
     $keyfield = "$kDocloc-$source";
  }

  elsif($sortorder eq 'r') {    #reverse physical order
     $kSeq = 9999 - $kSeq;
     $keyfield = "$kDocloc-$kSeq";
  }

##   F=first L=last - whichever it was stored in
  else {
     $keyfield = "$kDocloc-$kSeq";
  }

## print "<font face=arial size=1 color=silver>sec470 $kDocid $keyfield</font><br>\n";
  $pushdata = "$keyfield^$kDocid^$kDocloc";
  $pushdata =~ s/^\^+//;   ## trim leading carets
  $pushdata =~ s/\^$//;    ## trim trailing carets
  if(@unsorted) {
     push @unsorted, $pushdata;
  }
  else {
     @unsorted = ($pushdata);
  }
 unlink $keyfield;
 unlink $pushdata;
 unlink $kPubdate;
 unlink $kSysdate;
}

## 475

sub get_sort_pubdate
{
  $kPubdate = 0;
  $kPubdate = &conform_date($pubdate,'n',$sysdate);
#  $xPubdate = $kPubdate;
  if($sortorder =~ /[PDdRA]/) {
       $kPubdate = (30000000 - $kPubdate);
       $kPubdate = "0$kPubdate" if($kPubdate =~ /^9/);
  }
}

sub get_sort_sysdate
{
	$kSysdate = &conform_date($sysdate,'n');
    if($sortorder =~ /[PdDRA]/) {
        $kSysdate = (30000000 - $kSysdate);
        $kSysdate = "0$kSysdate" if($kSysdate =~ /^9/);
    }
}

sub conform_date    # format yyyy-mm-dd
{
  my ($date,$format,$date2) = @_;

  ($yyyy,$mm,$dd) = split(/-/,$date,3);

  if(($yyyy !~ /^[0-9]{4}$/ or $yyyy =~ /0000/) and $sysdate) {
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


sub write_index_flatfile {
 my($rSectsubid,$docid,$docloc,$cOrder) = @_;
 $sectionfile    = "$sectionpath/$rSectsubid.idx";
 $newsectionfile = "$sectionpath/$rSectsubid.new";
 $bkpsectionfile = "$sectionpath/$rSectsubid.bkp";

 $lock_file = "$statuspath/$rSectsubid.busy";
 &waitIfBusy($lock_file, 'lock');

 system "cp $sectionfile $bkpsectionfile" if(-f $sectionfile);

 unlink "$newsectionfile" if(-f $newsectionfile);
 system "touch $newsectionfile";

 $newIdx_written= 'N';

 $testct = 1;

## find info about the one we are inserting/deleting
## $dSectsubs = $sectsubs;
###   $docloc = &splitout_sectsub_info($rSectsubid,$dSectsubs);

 if($SVRinfo{environment} == 'development') {
#	system "touch $newsectionfile" or print "sec426 Mac - touch failed on temp new section index file: $newsectionfile<br>\n";
#	system "chmod 0777 $newsectionfile"  or print "sec427 Mac -chmod failed on temp new section index file: $newsectionfile<br>\n";
    open(OUTSUB, ">$newsectionfile") or print "sec428 H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$newsectionfile");
 }

 open(INSUB, "$sectionfile") or print "Could not open section index file: $sectionfile - sec432<br>\n";
 while(<INSUB>) {
    chomp;
    $index_written = 'N';
    local($testline) = $_;
    ($iDocid,$iDocloc,) = split(/\^/,$testline,2);
    $iDocloc = $default_docloc if($iDocloc !~ /[A-Z]/);

    if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N') {
       if($docloc lt $iDocloc) {
          &put_docid($docid,$docloc);
       }
##                 This puts it on top of stratus unless sortorder = L (last)
       elsif($docloc eq $iDocloc and $cOrder ne 'L') {
          &put_docid($docid,$docloc);
       }
       else {
          &put_idocid($idocid,$idocloc,$docid);
       }
    }

    &put_idocid($idocid,$idocloc,$docid) if($index_written eq 'N');

    $testct = $testct + 1;
 } #endwhile

 if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N') {
    &put_docid($docid,$docloc);
 }

 close(INSUB);
 close(OUTSUB);

 if(-f $newsectionfile) {
	unlink $sectionfile;
##    system "cp $newsectionfile $sectionfile" or print "sec469 - failed to copy new to section index file: $sectionfile<br>\n";
##   THE ABOVE IS A LIE! IT DOES NOT FAIL TO COPy
    system "cp $newsectionfile $sectionfile";
 }
 else {
	print "Section index file $newsectionfile failed to update; Error code sec472 I; processing stopped.  Please contact web admin. <br>\n";
    exit;
 }

 unlink $newsectionfile if(-f $newsectionfile);
 unlink $lock_file  if(-f $lock_file);
}


## 00410

sub put_docid
{
	($docid,$docloc) = @_;
    print(OUTSUB "$docid^$docloc\n");

 $newIdx_written = 'Y';
}


sub put_idocid
{
  ($idocid,$idocloc,$docloc) = @_;
##print "420 k- $kDocid-$kDocloc  d- $docid-$dDocloc i-$iDocid-$iDocloc delsectsubs $delsectsubs ord- $cOrder r- $rSectsubid $sectsubs<br>\n";
 if($delsectsubs =~ /$rSectsubid/ and $iDocid eq $docid)
    { }
 else {
    print(OUTSUB "$iDocid^$iDocloc\n");
 }

 $index_written = 'Y';
}

sub write_index_straight
{
  my($sectsubname,$docid) = @_;
  $indexpath = "$sectionpath/$sectsubname.idx";

  open(EMAILIDX, ">>$indexpath");
  print EMAILIDX "$docid\n";
  close(EMAILIDX);
}


######## PAGING  ##########


##  DO PAGE ITEM COUNTS: start count and stop count

## query string:     1^100:10 i.e. pg_num^max:pg1max
## in sections.html : maxitems: 100:10   N:M = stop after 10 on the 1st page
##                   DO NOT PAD!!

##    pg 1: start_count = 0; stop_count = N
##    pg 2on start_count = N + (pg - 2)*M   2-11, 3-111, 4-211
##           stop_count = start_count + M

## Also need to calculate total number of pages

sub init_paging_variables
{
 $ckItemcnt = 0;    ## ck for max
 $pgitemcnt = "";   ##page
 $ssItemcnt = "";   ##subsection
 $totalItems = 0;
 $pg_num = 1;
 $start_count = '000001';
 $ckItemnbr = 1;
 $ckItemcnt = &padCount6($ckItemnbr);
 $default_itemMax = 7;
 $default_order = 'p';	
}

sub set_start_stop_count_maxes
{
 if($qItemMax =~ /[0-9]/) {
   $itemMax = $qItemMax;
 }
 elsif($cMaxItems =~ /[0-9]/) {
   $itemMax = $cMaxItems;
 }
 else {
   $itemMax = $default_itemMax;
 }

 if($qPg1max =~ /[0-9]/) {
   $pg1max = $qPg1max;
 }
 elsif($cPg1Items =~ /[0-9]/) {
   $pg1max = $cPg1Items;
 }
 else {
   $pg1max = $itemMax;
 }
}


sub get_start_stop_count
{
 local($pg_num) = $_[0];

 $start_count = 0;
 $stop_count = 0;

 &set_start_stop_count_maxes;

 if($pg_num eq 1) {
    $start_count = 0;
    $stop_count = $pg1max;
 }
 else {
    $start_count = $pg1max + (($pg_num - 2) * $itemMax);  #  pg2-11, pg3-111, pg4-211
    $stop_count = $start_count + $itemMax;
 }

## print "sec500b start_count $start_count ..stop_count $stop_count .. itemMax $itemMax ..pg1max $pg1max<br>\n";

 $start_count = &padCount6($start_count);
 $stop_count  = &padCount6($stop_count);

## print "sec500 pg_num $pg_num .. itemMax $itemMax .. start_count $start_count .. stop_count $stop_count<br>\n";
 return("$start_count:$stop_count")
}

sub total_pages
{
 local($doclistname,$itemMax,$tot_items,$pg1max) = @_;
 if($itemMax !~ /[0-9]/ or $itemMax == 0) {
	$itemMax = $default_itemMax;
}

 if($tot_items > 0 and tot_items =~ /0-9/) {
 }
 else {
    $tot_items = &total_items($doclistname);
 }

 if($tot_items !~ /[0-9]/ or $tot_items < 2 or $tot_items <= $pg1max ) {
    $totalPages = 1;
 }
 else {  # more than one page

#   ($totalPages) = ($tot_items / $itemMax) + 1;

   $remaining_items = $tot_items - $pg1max;

   $totalPages = ($remaining_items / $itemMax) + 2; # add page 1 and fraction back in

   ($totalPages,$rest) = (/\./,$totalPages,2);
 }
 return $totalPages;
}


sub total_items
{
 local($doclistname) = $_[0];
 local($tot_items) = 0;

  if(-f "debugit.yes") {
     $cntfilename = "testitem.txt"
  }
  else {
     ($cntfilename,$rest) = split(/\.idx/,$doclistname);
     $cntfilename = "$cntfilename.cnt";
  }

  if(-f  $cntfilename) {
    open(CNTFILE,"$cntfilename");
    while(<CNTFILE>) {
      chomp;
      $tot_items = $_;
    }
    close(CNTFILE);
    $tot_items = &strip0s_fromCount($tot_items);
  }
  else {
	 ($doclistname,$rest) = split(/\.idx/,$cntfilename,2);
	 $tot_items = 1;
	 &set_item_count(2,$doclistname);
  }
##   print "sec500a cntfilename $cntfilename tot_items $tot_items<br>\n";
   return $tot_items;
}


sub set_item_count
{
 local($ckItemnbr,$doclistname) = @_;
 local($cntfilename) = "";
 if(-f "debugit.yes") {
    $cntfilename = "testitem.txt";
 }
 else {
   ($cntfilename,$rest) = split(/\.idx/,$doclistname,2);
   $cntfilename = "$cntfilename.cnt";
   if(-f $cntfilename) {}
   else {
     system "touch $cntfilename";
   }
 }
 $ckItemnbr = $ckItemnbr - 1;
 local($ckItemcnt) = &padCount6($ckItemnbr);

 open(CNTFILE,">$cntfilename");
 print(CNTFILE "$ckItemcnt\n");
 close(CNTFILE);
}

### set default top of page and bottom - but use both sectsub and subsect titles
### called from article.pl

sub print_pages_index
{
 local($pg_num,$sectsubid,$itemMax,$totalItems,$pg1max,$end_section) = @_;
 local($pg);
 $doclistname = "$sectionpath$slash$sectsubid.idx";
 &set_start_stop_count_maxes;  ## we have to this twice - also before start-stop count

 $totalPages = &total_pages($doclistname,$itemMax,$totalItems,$pg1max);

 if(($cMobidesk =~ /mobi/ or $qMobidesk =~ /mobi/) and $end_section eq 'Y') {
	$pg = $pg_num + 1;
##article.pl?0-cmd%1-atemplate%2-docid%3-thisSectsub%4-doclist/sectsubid%5-userid/pgnum%6-pgcnt%7-header%8-footer%9-order%10-mobidesk	
    print MIDTEMPL "<a target=_blank href=\"http://$scriptpath/article.pl?display_subsection%%NewsDigest_newsmobile%NewsDigest_newsmobile%%$pg%5%%%%mobi\">Next<\/a>\n";	
 }
 elsif($totalPages > 1) {
	if($end_section eq 'Y') {
      print MIDTEMPL " End of this page in <b>";
      &do_title;  # in article.pl
      print MIDTEMPL "</b> section, ";
	}
    print MIDTEMPL "pg $pg_num ... Go to page <a target=\"_blank\" href=\"http://$cgiSite/prepage/viewsection.php?$sectsubid%%$pg_num\">1<\/a>.. \n";

   for($pg=2;$pg<($totalPages);$pg++) {
      if($pg > ($pg_num - 10) and $pg < ($pg_num + 11)) {
         print MIDTEMPL "<a target=\"_blank\" href=\"http://$cgiSite/prepage/viewsection.php?$sectsubid%%$pg\">$pg<\/a>\n";
      }
   }
   $totalPages = $totalPages -1 if($totalPages > 19);
   print MIDTEMPL ".. <a target=\"_blank\" href=\"http://$cgiSite/prepage/viewsection.php?$sectsubid%%$totalPages\">$totalPages<\/a>\n";
}
}

######  END PAGING ##########

## 420

sub mass_add2index
{
 if($ckItemnbr == 1 or $totalItems == 1) {
     $lock_file = "$statuspath/$rSectid.busy";
     &waitIfBusy($lock_file, 'lock');

     $sectionfile    = "$sectionpath/$rSectsubid.idx";
     $newsectionfile = "$sectionpath/$rSectsubid.new";
     $bkpsectionfile = "$sectionpath/$rSectsubid.bkp";

     system "cp $sectionfile $bkpsectionfile" if(-f $sectionfile);

     unlink "$newsectionfile" if(-f $newsectionfile);
     system "touch $newsectionfile";
     open(MASSIDX, ">>$newsectionfile");
 }

 print(MASSIDX "$kDocid^$kDocloc\n");
}


sub end_mass_add2index
{
 close(MASSIDX);

 if($cOrder eq 'L') {
   system "cat $newsectionfile >>$sectionfile";
 }
 else {
   system "cat $sectionfile >>$newsectionfile";
   unlink $sectionfile;
   system "cp $newsectionfile $sectionfile";
   unlink $newsectionfile;
 }
 unlink "$lock_file";
}


## flatfile delete

sub delete_from_index
{
   my ($rSectsubname,$docid) = @_;
   $lock_file = "$statuspath/$rSectsubname.busy";
   &waitIfBusy($lock_file, 'lock');

   $delsectsubs    = $rSectsubname;
   $sectionfile    = "$sectionpath/$rSectsubname.idx";
   $newsectionfile = "$sectionpath/$rSectsubname.new";
   $bkpsectionfile = "$sectionpath/$rSectsubname.bkp";

   if(-f $sectionfile) {
      system "cp $sectionfile $bkpsectionfile";
      unlink "$newsectionfile" if(-f $newsectionfile);
      system "touch $newsectionfile";

      open(INSUB, "$sectionfile") or die;
      open(OUTSUB, ">>$newsectionfile") or die;

      while(<INSUB>) {
         chomp;
         local($sDocid,$sDocloc) = split(/\^/,$_,2);
	     if($docid =~ /$sDocid/) {
         }
         else {
             print OUTSUB "$sDocid^$sDocloc\n";
         }
      } #endwhile

      close(OUTSUB);
      close(INSUB);
      system "cp $newsectionfile $sectionfile" if(-f $newsectionfile);
      unlink "$newsectionfile" if(-f $newsectionfile);

      unlink $lock_file  if(-f $lock_file);
   }
}


sub delete_from_index_by_list
{
 my ($sectsubname, $deletelist)  = @_;
 $sectionfile    = "$sectionpath/$sectsubname.idx";
 $newsectionfile = "$sectionpath/$sectsubname.new";
 $bkpsectionfile = "$sectionpath/$sectsubname.bkp";

 if(-f $sectionfile) {
    system "cp $sectionfile $bkpsectionfile";
    unlink "$newsectionfile";
    my $sDocid = "";
    my $sDocloc = "";
    open(INSUB2, "$sectionfile");
    open(OUTSUB2, ">>$newsectionfile");

    while(<INSUB2>) {
       chomp;
       ($sDocid,$sDocloc) = split(/\^/,$_,2);

       if($deletelist =~ /$sDocid/) {
       }
       else {
         print OUTSUB2 "$sDocid^$sDocloc\n";
       }
    } #endwhile

    close(OUTSUB2);
    close(INSUB2);
    system "cp $newsectionfile $sectionfile" if(-f $newsectionfile);
    unlink $newsectionfile;

    unlink $lock_file  if(-f $lock_file);

    unlink $delsectionfile;
   }
   else {
      &printDataErr_Continue("Ind600 Delete failed: Can't find index for $sectionname: $sectionfile. Non-fatal error; continuing with processing. Notify admin. Thanks");
   }
}


################

##  ADD TO INDEX
##                 Updates the appropriate index flatfiles and the indexes table on the DB
sub hook_into_system
{
  my($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic) = @_;  #fields needed for sorting
 $pubdate = &conform_date($pubdate,'n',$sysdate);
  $sysdate = &conform_date($sysdate,'n');

 if($sectsubs !~ /$deleteSS|$expiredSS/ and $cmd !~ /selectItems|updateCvrtItems/) {
   &add_temporary_sectsubs;
 }

 if($addsectsubs =~ /$deleteSS|$expiredSS/) {
   system "touch $deletepath/$docid.del" if($docid ne "");
 }

 ##   if delete is deleted and another section added
 if($delsectsubs =~ /$deleteSS|$expiredSS/ and $addsectsubs =~ /[A-Za-z0-9]/) {
   unlink "$deletepath/$docid.del";
 }

 ##      update subsection indexes by docid;

 my $lifo_sth = &DB_prepare_lifonum unless ($DB_indexes < 1); #Prepare for execute in &updt_subsection_index
 my $maxsth   = &DB_prepare_getnew_lifo unless ($DB_indexes < 1);

 my @adddelsectsubs = split(/;/,"$addsectsubs;$delsectsubs;$chglocs");
 my $saveCsectsub = $cSectsubid;

 foreach $rSectsub (@adddelsectsubs)  {
   if($rSectsub) {
     my($sectsubname,$rSectid,$rSubid,$stratus,$lifonum) = &split_sectsub($rSectsub);
     &split_section_ctrlB($sectsubname);
     &updt_subsection_index($lifo_sth,$maxsth,$sectsubname,$cSSid,$cOrder,$pubdate,$sysdate,$headline,$region,$topic,$stratus,$lifonum);
   }
 }

## go back to thisSectsub
 $cSectsubid = $saveCsectsub;
 &split_section_ctrlB($cSectsubid);
}


##      Update docid index file - for each $rSectsubid

sub updt_subsection_index
{
 my ($lifo_sth,$maxsth,$rSectsubid,$SSid,$cOrder,$pubdate,$sysdate,$headline,$region,$topic,$stratus,$lifonum) = @_;
	##   Since we have been having problems deleting, we are doing this as a backup
 if($delsectsubs =~ /$rSectsubid/) {
    &toDeleteList_open($rSectsubid,'Y');
    &toDeleteList_write($docid);
    &toDeleteList_close;
 }
	
 $addchk = "$addsectsubs;$chglocs";
 $delchk = "$delsectsubs;$chglocs";

 ($rSectsubid,$rest) = split(/`/,$rSectsubid,2) if ($rSectsubid =~ /`/); #fix a bug from somewhere

 $stratus = $default_docloc if($stratus !~ /[A-Z]/);

 &write_index_flatfile($rSectsubid,$docid,$stratus,$cOrder); # in indexes.pl

##                     Delete the docid we wrote before
##                     - just in case it didn't delete above
 &deleteFromIndex_2nd($docid,$rSectsubid,'Y') if($delsectsubs =~ /$rSectsubid/);

 undef %iDocid;
 undef %iDocloc;
 undef %idx_written;
 undef %newIdx_written;

 if($delsectsubs =~ /$rSectsubid/) {
    &DB_delete_from_indexes ($SSid,$docid) unless($DB_indexes < 1);
	#	   return(); put a return here once we get rid of flatfile indexes
 }
 else {
#	 @sectsubs = split(/\^/,$sectsubs);
#	 foreach $sectsub (@sectsubs) {   ## get stratus
#		my($xsectsub,$stratus) = split(/`/,$sectsub);
#		last if($rSectsubid =~ /$sectsub/);
#	 }
#
	    # skip volunteer log for now - add it later; put userid in sortchar, nowdate in pubdate
	 &DB_add_to_indexes ($lifo_sth,$maxsth,$SSid,$docid,$stratus,$pubdate,$sysdate,$region,$headlines,$topic,$stratus,$lifonum)
		  unless($DB_indexes < 1 or $rSectsubid =~ /Volunteer/ or !$rSectsubid);   
	#     If docid/sectsubid combo already in index, it will update instead of insert
 }
}

sub toDeleteList_open
{
   local($lSectsubid, $from_updt_subsec_idx)  = @_;
   if($from_updt_subsec_idx =~ /[Yy]/) {
   }     ## Don't lock if in the middle of &updt_subsection_index - already locked
   else {
     $lock_file = "$statuspath/$lSectsubid.del.busy";
     &waitIfBusy($lock_file, 'lock');
   }

   local($delsectionfile) = "$sectionpath/$lSectsubid.del";

   if(-f $delsectionfile) {
   }
   else {
      system "touch $delsectionfile";
   }
   open(DELLIST, ">>$delsectionfile");
}

sub toDeleteList_write
{
 local($ldocid)  = $_[0];
 print DELLIST "$ldocid\n";
}


sub toDeleteList_close
{
 close(DELLIST);
 unlink $lock_file  if(-f $lock_file);
}

## not sure this ever worked - lDocid is a local - where does docid to be deleted come in????
sub deleteFromIndex_2nd
{
 local($ldocid,$lSectsubid, $from_updt_subsec_idx)  = @_;
 local($delsectionfile) = "$sectionpath/$lSectsubid.del";

 if(-f $delsectionfile) {
     if($from_updt_subsec_idx =~ /[Yy]/) {
     }     ## Don't lock if in the middle of &updt_subsection_index - already locked
     else {
        $lock_file = "$statuspath/$lSectsubid.busy";
        &waitIfBusy($lock_file, 'lock');
     }

     open(DEL2LIST, "$delsectionfile");
 }
 else {
     &printDataErr_Continue("Sec645 missing list of deletions. Non-fatal error; continuing with processing. Notify admin. Thanks");
     return;
 }

 $DELETELIST = "";

 local($xDocid);
 while(<DEL2LIST>)
  {
    chomp;
    $xDocid = $_;
    $DELETELIST = "$DELETELIST$xDocid^";
  }
 close(DEL2SECT);

 $sectionfile    = "$sectionpath/$lSectsubid.idx";
 $newsectionfile = "$sectionpath/$lSectsubid.new";
 $bkpsectionfile = "$sectionpath/$lSectsubid.bkp";

 if(-f $sectionfile) {
    system "cp $sectionfile $bkpsectionfile";
    unlink "$newsectionfile";

    local($sDocid,$sDocloc);

    open(INSUB2, "$sectionfile");
    open(OUTSUB2, ">>$newsectionfile");

    while(<INSUB2>) {
       chomp;
       ($sDocid,$sDocloc) = split(/\^/,$_,2);

       if($DELETELIST =~ /$sDocid/) {
       }
       else {
         print OUTSUB2 "$sDocid^$sDocloc\n";
       }
    } #endwhile

    close(OUTSUB2);
    close(INSUB2);
    system "cp $newsectionfile $sectionfile" if(-f $newsectionfile);
    unlink $newsectionfile;

    unlink $lock_file  if(-f $lock_file);

    unlink $delsectionfile;
   }
   else {
      &printDataErr_Continue("Sec430 Can't find index for $rSectsubid: $sectionfile. Non-fatal error; continuing with processing. Notify admin. Thanks");
   }
}

#### INFO ON AN INDEX ROW processing

sub splitout_sectsub_info
{
  my($sectsubname,$sectsubs) = @_;

  my @sectsubs = split(/;/, $sectsubs);
  foreach $sectsub (@sectsubs)
  {
###    &split_dSectsub;
    if($sectsub =~ /$sectsubname/) {
	    my($xsectsubname,$xsectname,$xsubname,$docloc,$xlifonum) = &split_sectsub($sectsub);
	    $docloc = 'M' if($docloc !~ /[A-Z]/);
#       $dTemplate = 'straight' if($straight_html eq 'Y');   ## DO WE NEED?
        return($docloc);
    }
  }
  return('M');
}

sub split_rSectsub {
     ($rSectsubid,$rSubinfo) = split(/`/,$rSectsub,2) if($rSectsub);
     ($rSectid,$rSubid) = split(/_/, $rSectsubid) if($rSectsubid);

     if($rSubInfo =~ /^\>\>/) {
        ($rIdxSectsubid,$rSubInfo) = split(/\^/,$rSubInfo,2);
        $rIdxSectsubid =~ s/^\>+//g;  ## delete leading arrows
     }
}

## need to feed this a parameter and return an array field;
## also remove $saveDtemplate logic

sub split_dSectsub   ## SEE SPLIT_SECTSUB - REUSE
{
## temporary fix - all subsects the same template  DO WE EVEN NEED TEMPLATE?????
# local($saveDtemplate) = $dTemplate;
 ($dSectsubid,$dDocloc,$dLifonum)
       = split(/`/, $dSectsub,3);
 ($dSectid,$dSubid) = split(/_/, $dSectsubid);

# $dTemplate = $saveDtemplate;
 $dDocloc = $default_docloc if($dDocloc !~ /[A-Z]/);
}

sub split_sectsub {
	my $sectsub = $_[0];
     my ($sectsubname,$docloc,$lifonum) = split(/`/,$sectsub,3);
     ($sectid,$subid) = split(/_/, $sectsubname);
#print MIDTEMPL "sectsub $sectsub sectsubname $sectsubname docloc $docloc lifonum $lifonum<br>\n";
     return ($sectsubname,$sectid,$subid,$docloc,$lifonum);
}

sub docarray_sect_order
{
 if(-f "$itempath/$iDocid.itm") {
    open(DATA, "$itempath/$iDocid.itm");
#                  one line per field
    while(<DATA>)
    {  chomp;
       $line = $_;
       if($line =~ /sectsubs/) {
         ($name, $dSectsubs) = split(/\^/,$line);
         last;
       }
    }
    close(DATA);

    $iDocloc = &splitout_sectsub_info($rSectsubid,$dSectsubs) if($dSectsubs);
 }
 else {
    $errmsg = "<br>AUTOSUBMIT 552 - File not found $itempath/$docid.itm <br>\n";
    &printSysErrExit;
    $found_it = "N";
 }
}

#######


###  UTILTIES

sub clean_index
{
   my $thisSectsub = $_[0];
   $filepath = "$sectionpath/$thisSectsub.idx";
   print "sec1937 filepath $filepath<br>\n";
   if($thisSectsub =~ /$emailedSS/ and -f "$filepath") {
      open(INFILE, "$sectionpath/$thisSectsub.idx");
      while(<INFILE>) {
          chomp;
          ($docid,$docloc) = split(/\^/,$_,2);
          if($docid ne "" ) {
              system "cp $sepmailpath/$docid.email $mailbkppath/$docid.email" if(-f "$sepmailpath/$docid.email");
              unlink "$sepmailpath/$docid.email"
          }
      }
      close(INFILE);
   }

   unlink "$sectionpath/$thisSectsub.idx";
   print "<font size=3 face=verdana>Clean index is complete</font><p>\n";
}


sub clean_popnews_bkup
{
  opendir(POPMAILDIR, "$mailbkppath");

  local(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
  closedir(POPMAILDIR);

  foreach $filename (@popnewsfiles) {
     if(-f "$mailbkppath/$filename" and $filename =~ /email/) {
        unlink "$sepmailpath/$filename";
    }
  }
  print "<font size=3 face=verdana>Empty Popnews Mail Backup folder is complete</font><p>\n";
}


## DATABASE SQL ALTERNATIVE TO FLAT FILE INDEX

sub do_doclist_sql {    ## for the import
  my $dSectsub = $_[0];
  local ($counts) = &get_start_stop_count($pg_num);  #in sections.pl
  ($start_count,$stop_count) = split(/:/,$counts,2);
  my $start_cnt = 0;
  my $num_articles = 0;
  my $orderby = "";
  my $lastpg2lifo = 9999999;
  my $wherelifo_clause = "";

  $ckItemnbr = 1;
  $ckItemcnt = &padCount6($ckItemnbr);

  $dbh = &db_connect() or die "DB failed connect";

  $start_cnt = int($start_count);
  $num_articles = $stop_count - $start_count;

  if($qOrder =~ /[A-Za-z0-9]/) {
    $sortorder = $qOrder;
  }
  else {
    $sortorder = $cOrder;
  }

# R = region  T = topic  t = region/topic  P = reverse pubdate
# p = pubdate  d = docloc/sysdate  D = sysdate only A = priority/sysdate
# H = headline  S = source  # r = reverse physical order
# F = lifo  # L = fifo

  if ($sortorder == 'F') {  #last in, first out
	 if($pg_num < 3) {
		$orderby =  "i.stratus, i.lifonum DESC ";
	 }
	 else {
	   $lastpg2lifo = &DB_getlastpg2_lifo($dSectsub);
	   $orderby = "i.stratus, i.pubdate DESC";
	 }
  }
  elsif($sortorder == 'P') { #reverse publish date
	 $orderby = "i.stratus, i.pubdate DESC";
  }
  elsif($sortorder == 'A') { # priority / sysdate(in pubdate) (headlines)
	 $orderby = "i.stratus, i.pubdate DESC";
  }
  elsif($sortorder == 'R') { #region
	 $orderby = "i.stratus, i.sortchar, i.pubdate DESC";
  }
  elsif($sortorder =~ /[HT]/) { #headline
	 $orderby = "i.stratus, i.sortchar, i.pubdate DESC";
  }
  elsif($sortorder == 'd') { #docloc, sysdate (in pubdate)
	 $orderby = "i.stratus, i.pubdate DESC";
  }
  elsif($sortorder == 'D') { #docloc, sysdate (in pubdate)
	 $orderby = "i.pubdate DESC";
  }
  elsif($sortorder =~ /[rL]/) {    #reverse physical order
	 $orderby = "i.stratus, i.lifo DESC";
  }
  elsif($sortorder eq 'L') {    #reverse physical order
	 $orderby = "i.stratus, i.lifo DESC";
  }
  else {
	 $orderby = "i.stratus, i.pubdate DESC";
  }

  my $sql = "SELECT i.docid, i.lifonum, i.stratus, i.pubdate, i.sortchar FROM indexes as i, sectsubs as s WHERE i.sectsubid = s.sectsubid AND s.sectsub = ? AND i.lifonum < ? ORDER BY $orderby LIMIT ?, ?";		
  my $doclist_sth = $dbh->prepare($sql) or die "DB doclist failed prepare";
  $doclist_sth->execute($dSectsub,$lastpg2lifo,$start_cnt,$num_articles) or die "DB doclist failed execute";

  if ($doclist_sth->rows == 0) {
  }
  else {
	 $number = $doclist_sth->rows;
      while (my @row = $doclist_sth->fetchrow_array()) { # print data retrieved
	     $docid = $row[0];

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
      } ## end while
    } ## end else
	$doclist_sth->finish() or die "DB failed finish";
}


sub DB_getlastpg2_lifo {
    my($sectsub) = $_[0];
    my $pg1pg2Limit = 0;
    $pg1pg2Limit = ($cPg1Items + $cPg2Items -1);
	my $lastpg2lifo = 0;
	my $lifonum_sth = $dbh->prepare("SELECT i.lifonum FROM indexes AS i, sectsubs AS s WHERE i.sectsubid = s.sectsubid AND s.sectsub = ? ORDER BY i.lifonum DESC LIMIT ? , 1");

	if($lifonum_sth) {
	    $lifonum_sth->execute($sectsub,$pg1pg2Limit) or die "Couldn't execute statement: ".$lifonum_sth->errstr;
	    $lastpg2lifo = $lifonum_sth->fetchrow_array();
		$lifonum_sth->finish();
	}
	else {
	   print" Couldn't prepare DB_getlastpg2_lifo query<br>\n";
	}
	return ($lastpg2lifo);
}

sub if_exists_DBindex
{
   my($SSid,$docid) = @_;

  my $idxexists_sql = "SELECT COUNT(*) FROM indexes  WHERE docid = ? and sectsubname = ?";
  my $idxexists_sth = $dbh->prepare($idxexists_sql) or die("Couldn't prepare statement: " . $idxexists_sth->errstr);	
  $idxexists_sth->execute($docid,$SSid);
  my @row = $idxexists_sth->fetchrow_array();
  $idxexists_sth->finish;

  return(1) if($row);
  return(0);
}

sub DB_add_to_indexes    # updates if sectsubid/docid combo already there
{ 
	 my($lifo_sth,$maxsth,$SSid,$docid,$stratus,$pubdate,$sysdate,$region,$headline,$topic,$stratus,$fLifonum) = @_;
	if($SSid < 1 or $docid !~ /[0-9]/) {
		print "sec2044 Invalid sectsubid $SSid or docid $docid , continuing<br>\n";
		return;
	}
	
	 $pubdate = $sysdate   if($sortorder =~ /[ADd]/);
	 my $sortchar = "";
     $sortchar = $topic    if($sortorder =~ /T/);
     $sortchar = $headline if($sortorder =~ /H/);
     $sortchar = $region   if($sortorder =~ /R/);

# find lifonum for sectsubid and docid
     $lifo_sth->execute($SSid,$docid) or die("Couldn't execute lifo_sth @ 2103'");  #prepared before coming to updt_subsection_index
     my $lifonum = 0;
     my @row = $lifo_sth->fetchrow_array();
     $lifo_sth->finish;
     if($row[0]) {
	    $lifonum = @row[0];     #SSid is a unique id for sectsub living on indexes and sectsubs tables
     }

     if($lifonum > 0) {
		  my $update_sql = "UPDATE indexes SET stratus = '" . $stratus . "', lifonum = $lifonum, pubdate = '" .  $pubdate . "', sortchar = '" . $sortchar . "' WHERE docid = '" . $docid . "' and sectsubid = " . $SSid;
#		print "sec2113 updating $docid in $SSid ... SQL: $update_sql<br>\n";
		  $dbh->do($update_sql) or die "DB Update $docid to $SSid failed<br>\n";
     }
     else {
             #                         SELECT MAX(lifonum) from indexes WHERE sectsubid = ?
	    $lifonum = &DB_getnew_lifo($maxsth,$SSid);

#		print "sec2060 Adding $docid to $sectsubid, strat $stratus lifo $lifonum   pub $pubdate sortchar $headline<br>\n";

	    $insert_sql = "INSERT IGNORE INTO indexes VALUES ($SSid, '" . $docid . "', '" . $stratus . "', $lifonum, '" . $pubdate . "', '" . $sortchar . "')";
	    $dbh->do($insert_sql)
	           or die "DB Insert  failed<br>\n";
    }
}

sub DB_get_lifo_stratus {
  my($sectsubname,$docid) = @_;
  $dbh = &db_connect() or die("DB failed connect") unless $dbh;
  my $lifo_sql = "SELECT i.stratus, i.lifonum FROM indexes as i, sectsubs as s WHERE i.sectsubid = s.sectsubid and s.sectsub = ? and i.docid = ?";
  my $lifo_sth = $dbh->prepare($lifo_sql) or die("Couldn't prepare statement: ".$lifo_sth->errstr);	
  $lifo_sth->execute($sectsubid,$docid);
  my $lifonum = 0;
  my @row = $lifo_sth->fetchrow_array();
  $lifo_sth->finish;
  if($row[0]) {
     $stratus = @row[0];
     $lifonum = @row[1];     
  }
  return($stratus,$lifonum);
}

sub DB_prepare_lifonum {
	$dbh = &db_connect() or die("DB failed connect") unless $dbh;
	my $count_sql = "SELECT lifonum FROM indexes WHERE sectsubid = ? and docid = ?";
    $count_sth = $dbh->prepare($count_sql) or die("Couldn't prepare statement: ".$count_sth->errstr);
	return($count_sth);    
}

sub DB_prepare_getnew_lifo {
	$dbh = &db_connect() or die("DB failed connect") unless $dbh;
	my $maxsql = "SELECT lifonum from indexes WHERE sectsubid = ? ORDER BY lifonum DESC";
	my $maxsth = $dbh->prepare($maxsql) or die("Couldn't prepare statement: ".$sthmax->errstr);
	return($maxsth);
}

## [Tue Jan 03 10:41:55 2012] [error] [client 127.0.0.1] failed in fetchrow for maxlifo at sections.pl line 2166., referer: http://overpop/cgi-bin/article.pl?display_section%%%Suggested_suggestedItem%%%10
## There is another way to get the max - see regions table in controlfiles.

sub DB_getnew_lifo {
 my($maxsth,$SSid) = @_;
 my $maxlifo = 0;
 if($maxsth) {
	$maxsth->execute($SSid) or die("Couldn't execute statement: ".$maxsth->errstr);	
	while (my @row = $maxsth->fetchrow_array() or die("failed in fetchrow for maxlifo SSid $SSid - See comment in index\.pl")) {
        $maxlifo = $row[0];   #We just want the top row with the highest lifonum
	    if($maxlifo and $maxlifo =~ /^(\d+\.?\d*|\.\d+)$/) { # match valid number
			$maxlifo = $maxlifo + 10;
		}
		else {
		     print "sec2174 Failed in DB_getnew_lifo for ...SSid $SSid - see comment above @2161<br>\n";
	    }
		last;
	}
 }
 else {
   print "Couldn't prepare maxlifo query; continuing<br>\n";
 }
$maxsth->finish();
return($maxlifo);
}


sub DB_delete_from_indexes
{
    my($sectsubid,$docid) = @_;	
    my $query = "DELETE FROM indexes WHERE sectsubid = $sectsubid AND docid = $docid";
    $dbh->do($query) or die "DB Delete $docid from $sectsubid failed<br>\n";
}

sub DB_delete_from_indexes_by_list  # NEEDS TO HAVE SQL FIXED
{
    my($sectsubid,$deletelist) = @_;	
    my $query = "DELETE FROM indexes WHERE sectsubid = $sectsubid AND docid IN $deletelist";
    $dbh->do($query) or die "DB Delete $deletlist from $sectsubid failed<br>\n";
}

sub DB_add_docid_to_index
{ 
 my($sectsubname,$docid) = @_;
 $SSid = &get_SSid($sectsubname);
 $insert_sql = "INSERT IGNORE INTO indexes VALUES ($SSid, '" . $docid . "', '', 0, '', '')";
 $dbh->do($insert_sql) or die "DB Insert failed<br>\n";
}

sub create_indexes
{   ## Easier to do this on Telavant interface
	$dbh = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS indexes");

$sql = <<ENDINDEXES;
	CREATE TABLE indexes (
		sectsubid smallint unsigned not null,
		docid char(6) not null, 
		stratus char(1)  not null default 'M',
		lifonum integer unsigned not null default 0,
		pubdate varchar(8) default "",
		sortchar varchar(40) default "",
		PRIMARY KEY (sectsubid,docid))
ENDINDEXES

$sth2 = $dbh->prepare($sql);
$sth2->execute();
$sth2->finish();
}

## First time import

sub import_indexes
{
# Reads index files in , assigns a lifonum, them reads them in reverse order so that
# the right duplicate gets deleted; then inserts into the database
require('sections.pl');
print "<b>Import indexes</b><br><br>\n";
  $dbh = &db_connect() if(!$dbh);
		
#  $dbh->do("TRUNCATE TABLE indexes");
		
  my $sectionspath = "$controlpath/sections.html";

  open(SECTIONS, "$sectionspath") or die("Can't open sections");
  while(<SECTIONS>)
  {
    chomp;
    my $line = $_;
    next if($line =~ "#sectsubid^seq^");
	my ($sectsubid,$seq,$sectsub,$fromsectsubid,$cIdxSectsubid,$cSubdir,$cPage,$cCategory,$cVisable,$cPreview,$sortorder,$cPg2order,$cTemplate,$cTitleTemplate,$cTitle,$cAllOr1,$cMobidesk,$cDocLink,$cHeader,$cFooter,$cFTPinfo,$cPg1Items,$cPg2Items,$cPg2Header,$cMore,$cSubtitle,$cSubtitletemplate,$cMenuTitle,$cKeywordsmatch)
	      = split(/\^/,$line);
	
	$indexpath    = "$sectionpath/$sectsub.idx";
	
	if(-f $indexpath) {}
	else {
		next;  # next section if this one has no file
	}
#	print "indexpath $indexpath <br>\n";	
	my $ctr = 0;
	my %LIFOINDEX = ();
	my %DOCIDHASH = ();	
	
    open(INDEX, "$indexpath") or die("Can't open index $sectsub");
    while(<INDEX>)	{
	    chomp;
	    my $idx_line = $_;
	    ($docid,$rest)=  split(/\^/,$idx_line,2);
	    $ctr = $ctr + 1;
	    my $lifonum = $ctr * 10;
#		    print "$sectsub docid $docid ctr $ctr lifonum $lifonum<br>\n";
	    $LIFOINDEX{$lifonum} = $idx_line;  #store in a hash by lifonum
	}
	close(INDEX);

#  $ctr is now at its maximum
print "$sectsub max ctr $ctr<br>\n";

##   &indexes_import_flatfile_SAVE;

    my $new_cnt = 0;
    while($ctr > 0) {
		my $lifonum = $ctr * 10;
		my $docline = $LIFOINDEX{$lifonum};
	#		print"$sectsub lifonum $lifonum docline $docline<br>\n" if($ctr < 10);
		my ($docid,$stratus,$rest) = split(/\^/, $docline,3);
		$stratus = 'M' if($stratus !~ /[A-Z]/);
		$new_cnt = $new_cnt + 1;
		my $newlifonum = $new_cnt * 10;
		
        my ($priority,$pubdate,$sysdate,$pubyear,$topic,$region,$headline) 
          = &get_doc_data_for_DB($docid);
         my $sortchar = "";
		 $pubdate = $sysdate   if($sortorder =~ /[ADd]/);
		 $pubdate = &conform_date($pubdate,'n',$sysdate);  # in sections.pl
		 
         unless ($sysdate eq '00000000' or !$sysdate) {
	       $sortchar = $topic    if($sortorder =~ /T/);
	       $sortchar = $headline if($sortorder =~ /H/);
	       $sortchar = $region   if($sortorder =~ /R/);
			
     	   my $sth = $dbh->prepare( 'INSERT INTO indexes VALUES ( ?, ?, ?, ?, ?, ? ) ON DUPLICATE KEY UPDATE stratus = ?' );
 	       $sth->execute($sectsubid, $docid, $stratus, $newlifonum, $pubdate, $sortchar, $stratus);
         }								
	     $ctr = $ctr - 1;
    } #end 2nd pass - while
  }  # end sections
}

sub import_exported_indexes
{
# Reads exported files in , then inserts into the database

  print "<b>Import indexes</b><br><br>\n";
  $dbh = &db_connect() if(!$dbh);
		
  $dbh->do("TRUNCATE TABLE indexes");
  my $sth = $dbh->prepare( 'INSERT INTO indexes VALUES ( ?, ?, ?, ?, ?, ? ) ON DUPLICATE KEY UPDATE stratus = ?' );
  require('sections.pl');
  $getSSid_sth = &get_sectsubid ('prepare');

  my $indexpath = "$autosubdir/sections/$sectsub.idx";
  my $expindxpath = "$autosubdir/sectionsexp/$sectsub.idx";
  my $oldindxpath = "$autosubdir/sectionsexp/$sectsub.old";

  opendir(EXPFILES, "$expindxpath");
  my (@indexfiles) = grep /^.+\.idx$/, readdir(EXPFILES);
  closedir(EXPFILES);

  foreach $idxfile (@indexfiles) {
	  my($sectsub,$ext) = split(/\./,$idxfile);
	
      my $sectsubid = &get_sectsubid ($getSSid_sth,$sectsub);
	
      open(IDXFILE,"$indxfile") or die("Can't open index $sectsub");
      while(<IDXFILE>)	{
	     chomp;
	     my $idx_line = $_;
	     ($docid,$stratus,$lifonum)=  split(/\^/,$idx_line,2);

         my ($priority,$pubdate,$sysdate,$pubyear,$topic,$region,$headline) 
           = &get_doc_data_for_DB($docid);
         my $sortchar = "";
		 $pubdate = $sysdate   if($sortorder =~ /[ADd]/);
		 $pubdate = &conform_date($pubdate,'n',$sysdate);  # in sections.pl
		 
         unless ($sysdate eq '00000000' or !$sysdate) {
		     $sortchar = $topic    if($sortorder =~ /T/);
		     $sortchar = $headline if($sortorder =~ /H/);
		     $sortchar = $region   if($sortorder =~ /R/);
 	         $sth->execute($sectsubid, $docid, $stratus, $newlifonum, $pubdate, $sortchar, $stratus);
         }	# end unless							
	  } #end while
	  close(IDXFILE);
    } #end foreach
}

sub restore_flatfile_indexes
{
  print "<b>Restore flatfile indexes - will first do &export_indexes to autosubmit/sectionsexp/sectsubid.idx</b><br><br>\n";

  &export_indexes;

  opendir(EXPFILES, "$expindxpath");
  my (@indexfiles) = grep /^.+\.idx$/, readdir(EXPFILES);
  closedir(EXPFILES);

  foreach $idxfile (@indexfiles) {
	  my($sectsub,$ext) = split(/\./,$idxfile);
	  my $indexpath = "$autosubdir/sections/$sectsub.idx";
	  my $expindexpath = "$autosubdir/sectionsexp/$sectsub.idx";
	  my $indexoldpath = "$autosubdir/sectionsexp/$sectsub.old";
	  unlink $oldindexpath if(-f $indexoldpath);
	  sleep(3);
	  system "cp $indexpath $indexoldpath" or die("Couldn't copy current idx to old - $sectsubid");
	  sleep(3);
	  unlink $indexpath  if(-f $indexpath);
	  sleep(3);
	  system "cp $expindexpath $indxpath" or die("Couldn't copy exp idx to new idx - $sectsubid");
	  sleep(3);
  }
}

sub export_indexes
{
 ###  WE SHOULD CHANGE THIS TO EXPORT TO THE BACKUP AREA SINCE THE CURRENT SECTIONS IDX ARE WORKING.

  $dbh = &db_connect() if(!$dbh);
  my $sql =	"SELECT * from indexes WHERE sectsubid = ? ORDER BY $lifonum DESC";
  print "Exporting indexes to autosubmit/sections/$sectsub.idx and saving old in sectionsexp/$sectsub.idx<br>\n";
  print "sql = $sql<br>\n";

  $sth_exportIDX = $dbh->prepare($sql);
  if(!$sth_exportIDX) {
	 print "Errror in indexes export at Prepare command, sec341 " . $sth_exportSS->errstr . "<br>\n";
	 exit;	
  }

  my $sections = "$controlpath/sections.html";   # Use sections file as control

  open(SECTIONS, "$sections") or die("Can't open sections");  # sections.html controls the sectsubs
  while(<SECTIONS>) {
	    chomp;
	    $line = $_;
	    next if($line =~ /#secsubid^seq^d/);  #skip 1st line
		my ($sectsubid,$seq,$sectsub,$rest) = split(/\^/,$line,4);
	
		my $indexpath = "$autosubdir/sections/$sectsub.idx";
		my $expindxpath = "$autosubdir/sectionsexp/$sectsub.idx";
		my $oldindxpath = "$autosubdir/sectionsexp/$sectsub.old";
		
	    $sth_exportIDX->execute($sectsubid);
		if ($sth_exportIDX->rows == 0) {
		    print "Unexpected error in sectsubs export at rows command, sec139 " . $sth_exportSS->errstr . "<br>\n";
		    exit();
		}
		
		unlink $expindxpath if(-f $expindxpath);
		open(EXPINDEX, ">>$expindexpath"); 
	    while (my @row = $sth_exportIDX->fetchrow_array()) { # print data retrieved
		     my ($sectsubid,$docid,$stratus,$lifonum,$pubdate,$skipimage,$regionid,$sortchar) = @row;
	         my $line = "$sectsubid,$docid,$stratus,$lifonum,$pubdate,$skipimage,$regionid,$sortchar\n";	
	         print EXPINDEX "$line";
	         print "$line<br\n";
	    }
		close(EXPINDEX);
		unlink $oldindexpath if(-f $indexoldpath);
		system "cp $indexpath $indexoldpath";
		unlink $indexpath  if(-f $indexpath);
		system "cp $expindexpath $indxpath";	
  }
  $sth_exportIDX->finish() or die "DB indexes export failed finish";
  close(SECTIONS);
  print "<br><b>Export indexes completed</b><br>\n";
}

sub load_indexes {

     my $sections = ("$autosubdir/$sections.html");
	 my $stmt = <<LOADIDX;
	     LOAD LOCAL DATA INFILE ? INTO TABLE indexes 
		         FIELDS TERMINATED BY "^" 
		         LINES TERMINATED BY "\r\n"
LOADIDX
	
	 open(INFILE, "$sections");
	 while(<INFILE>) {
	    chomp;
	    $line = $_;
	    ($sectsub_pkid,$seq,$sectsub,$rest) = split(/\^/,$line,4);
	    my @bind = ("$autosubdir/sections/$sectsub.imp");
	    $sth2 = $dbh->prepare($stmt);
	    $sth2->execute(@bind);
	    $sth2->finish();
	}
}


sub insert_indexes_old {
	
  $dbh = &db_connect() if(!$dbh);
		
  $dbh->do("TRUNCATE TABLE indexes");
	
  my $sth = $dbh->prepare_cache( 'INSERT INTO indexes VALUES ( ?, ?, ?, ?, ? )' );

  my $sectionspath = "$controlpath/sections.html";
  print "sectionspath $sectionspath <br>\n";
  open(SECTIONS, "$sectionspath") or die("Can't open sections");
  while(<SECTIONS>)
  {
	    chomp;
	    $line = $_;
	    next if($line =~ "#sectsubid^seq^");
		my ($sectsubid,$seq,$sectsub,$rest) = split(/\^/,$line,4);

		my $indexpath    = "$sectionpath/$sectsub.imp";
		if(-f $indexpath) {}
		else {
			next;  # next section if this one has no file
		}	
	    open(INDEX, "$indexpath") or die("Can't open index $sectsub");
	    while(<INDEX>)	{
		    chomp;
		    my $idx_line = $_;
		    my ($sectsubid,$docid,$stratus,$lifonum,$skipimage) =  split(/\^/,$idx_line,3);
			$sth->execute($sectsubid,$docid,$stratus,$lifonum,$skipimage);	

		}
	}	
}

sub indexes_import_flatfile_SAVE 
{
	$index_import_path = "$sectionpath/$sectsub.imp";
    $new_cnt = 0;

	open(INDEX_IMPORT, ">>$index_import_path") or die("Can't open index_import $sectsub");
	while($ctr > 0) {
#		print "ctr $ctr<br>\n";
		$lifonum = $ctr * 10;
		$docline = $LIFOINDEX{$lifonum};
#		print"$sectsub lifonum $lifonum docline $docline<br>\n" if($ctr < 10);
		($docid,$stratus,$rest) = split(/\^/, $docline,3);
## later get rid of docidhash and new_cnt ---> will do count in export.		
		$docidhash = $DOCIDHASH{$docid};  #keep this for $new_cnt
        if($docidhash eq 'T') {   #skip duplicates
#           print "$docid duplicate<br>\n";
           }
        else {  
	        $DOCIDHASH{$docid} = "T";
# OLD		    print INDEX_IMPORT "$sectsubid^$docid^$stratus^$lifonum^$skipimage\n";
#		    print "$sectsubid^$docid^$stratus^$lifonum^$skipimage<br>\n" if($ctr < 10);
 	        $sth->execute($sectsubid,$docid,$stratus,$lifonum,$sortfield,$skipimage);
		    $new_cnt = $new_cnt + 1;
	    }
	    $ctr = $ctr - 1;	
	} # end index
	close(INDEX_IMPORT);

	$countpath    = "$sectionpath/$sectsub.newcnt";
	unlink $countpath if(-f  $countpath);
	open(NEW_CNT, ">>$countpath");
	print NEW_CNT "$new_cnt";
	close(NEW_CNT);
}

1;