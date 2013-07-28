#!/usr/bin/perl --

# January 2013
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
      &get_doc_data($docid,'N');
      $docid = $saveDocid;
  }

  $priority = '5' if($priority !~ /[1-7]/ or -f "$priority5path/$docid.pri5");
  $kDocloc  = 'M' if($kDocloc !~ /[A-Za-z0-9]/ and $cAllOr1 =~ /all/);
  $kDocloc  = 'd' if($kDocloc !~ /[A-Za-z0-9]/ and $cAllOr1 =~ /1only/);
# my $x = &lessthan_3monthsago($sysdate);  #in date.pl
  my $sysdatenum = $sysdate;
  $sysdatenum =~ s/-//g;
#  if($sysdatenum < $t3monthsago) {
#  my $t3monthsago = &get_3monthsago;
#  my $t6weeksago  = &get_6weeksago;
  my $tdaysago  = &get_somedaysago(42);  # 6 weeks
  if($sysdatenum < $tdaysago) {
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
     my $kPriority = (7 - $priority);
     $keyfield = "$kDocloc-$priority-$region-$topic";
  }
  elsif($sortorder =~ /[Pp]/) {
     &get_sort_pubdate;
     $keyfield = "$kDocloc-$kPubdate";
  }
  elsif($sortorder =~ /d/) {     # headlines priority
	 my $kPriority = 5;
     $kPriority = (7 - $priority) if($priority =~ /[0-9]/);
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
     my $kPriority = 7;
     $kPriority = (7 - $priority) if($priority >=0);
     &get_sort_sysdate;
     $keyfield = "$kDocloc-$kPriority-$kSysdate";
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

sub get_sort_woadateitme   ## still need to add woadatetime to index for summarized, suggested, news
{                          ## this is just for conversion of flat to DB (do we need?)
	$kSysdate = &conform_date($woadatetime,'n',$pubdate); # if no woadatetime, use $pubdate + hhmmss = 000000
    if($sortorder eq 'W') {
        $kSysdate = (30000000000000 - $kSysdate);
        $kSysdate = "0$kSysdate" if($kSysdate =~ /^9/);
    }
}

sub conform_date    # format yyyy-mm-dd
{
  my ($date,$format,$date2) = @_;

  ($yyyy,$mm,$dd) = split(/-/,$date,3);  ## need to add split on space and : if datetime

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
 my($rSectsubid,$docid,$docloc,$cOrder,$addchk,$delSS,$listsingle) = @_;
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

 if($SVRinfo{environment} == 'development') {
    open(OUTSUB, ">$newsectionfile") or print "sec428 H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$newsectionfile");
 }
 open(INSUB, "$sectionfile") or print "Could not open section index file: $sectionfile - sec432<br>\n";
 while(<INSUB>) {
    chomp;
    $index_written = 'N';
    my $testline  = $_;
    ($idocid,$idocloc,) = split(/\^/,$testline,2);
    $idocloc = $default_docloc if($idocloc !~ /[A-Z]/);

    if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N') {
       if($docloc lt $idocloc) {
          &put_docid($docid,$docloc);
       }
##                 This puts it on top of stratus unless sortorder = L (last)
       elsif($docloc eq $idocloc and $cOrder ne 'L') {
          &put_docid($docid,$docloc);
       }
       else {
          &put_idocid($rSectsubid,$idocid,$idocloc,$docid);
       }
    }

    &put_idocid($rSectsubid,$idocid,$idocloc,$docid) if($index_written eq 'N');

    $testct = $testct + 1;
 } #endwhile

 if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N') {
    &put_docid($docid,$docloc);
 }

 close(INSUB);
 close(OUTSUB);

 if(-f $newsectionfile) {
	unlink $sectionfile;
##    system "cp $newsectionfile $sectionfile" or print "idx233 - failed to copy new to section index file: $sectionfile<br>\n";
##   THE ABOVE IS A LIE! IT DOES NOT FAIL TO COPy
     system "cp $newsectionfile $sectionfile";
 }
 else {
	print "Section index file $newsectionfile failed to update; Error code sec472 I; processing stopped.  Please contact web admin. <br>\n";
    exit;
 }

# unlink $newsectionfile if(-f $newsectionfile);
 unlink $lock_file  if(-f $lock_file);
}


## 00410

sub put_docid
{
 my($docid,$docloc) = @_;
 print(OUTSUB "$docid^$docloc\n");

 $newIdx_written = 'Y';
}


sub put_idocid
{
  my($rSectsubid,$idocid,$idocloc,$docloc) = @_;
 if($delsectsubs =~ /$rSectsubid/ and $idocid eq $docid)
    { }
 else {	
    print(OUTSUB "$idocid^$idocloc\n");
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
 $ckItemcnt = &padCount6($ckItemnbr);  # in db_ctrl_tables.pl
 $default_itemMax = 7;
 $default_order = 'p';	
}

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
}


sub get_start_stop_count
{
 my $pg_num = $_[0];

 $start_count = 0;
 $stop_count = 0;

 &set_start_stop_count_maxes;

 if($pg_num eq 1) {
    $start_count = 0;
    $stop_count = $pg1max;
 }
 else {
    $start_count = $pg1max + (($pg_num - 2) * $pg2max);  #  pg2-11, pg3-111, pg4-211
    $stop_count = $start_count + $pg2max;
 }

## print "sec500b start_count $start_count ..stop_count $stop_count .. pg2Max $pg2max ..pg1max $pg1max<br>\n";

 $start_count = &padCount6($start_count);
 $stop_count  = &padCount6($stop_count);

## print "sec500 pg_num $pg_num .. pg2Max $pg2max .. start_count $start_count .. stop_count $stop_count<br>\n";
 return("$start_count:$stop_count")
}

sub total_pages
{
 my($doclistname,$pg2max,$tot_items,$pg1max) = @_;;
 if($pg2max !~ /[0-9]/ or $pg2max == 0) {
	$pg2max = $default_itemMax;
}

 if($tot_items > 0 and tot_items =~ /0-9/) {
 }
 else {
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
 return $totalPages;
}


sub total_items
{
 my $doclistname = $_[0];
 my $tot_items = 0;
 my $cntfilename = "";
 my $cntfilepath = "";
 $doclistname =~ s/\.cnt//g if($doclistname =~ /\.cnt/);
 $doclistname =~ s/\.idx//g if($doclistname =~ /\.idx/);

 if(-f "debugit.yes") {
     $cntfilename = "testitem.txt"
  }
  else {
     $cntfilename = "$doclistname.cnt" if($doclistname !~ /\.cnt$/);
  }
  if($cntfilename !~ /$sectionpath/) {
      $cntfilepath = "$sectionpath/$cntfilename";
  }
  else {
      $cntfilepath = "$cntfilename";
  }

  if(-f  $cntfilepath) {
	 my $found = "";
     open(CNTFILE,"$cntfilepath");
     while(<CNTFILE>) {
       chomp;
       $tot_items = $_;
       $found = 'Y';
     }
     close(CNTFILE);
     if($found) {
        $tot_items = &strip0s_fromCount($tot_items);
     }
     else {
	    $tot_items = 0;
     }
  }
  else {
	 &set_item_count(1,$doclistname);
  }
  $tot_items = 0 unless($tot_items);
  $tot_items = 0 if($tot_items < 0);
  return $tot_items;
}


sub set_item_count  #comes here from display; count is calculated on display during sort
{
 my ($ckItemnbr,$doclistname) = @_;

 $doclistname =~ s/$sectionpath\///;
 $doclistname =~ s/\.idx//g;

 if(-f "debugit.yes") {
    $doclistname = "testitem.txt";
 }

 my $cntfilepath = "$sectionpath/$doclistname.cnt";

 system "touch $cntfilepath" unless (-f $cntfilepath);

# my $ckItemcnt = &padCount6($ckItemnbr);

 open(CNTFILE,">$cntfilepath");
 print(CNTFILE "$ckItemnbr\n");
 close(CNTFILE);
}


### set default top of page and bottom - but use both sectsub and subsect titles
### called from article.pl

sub print_pages_index
{
 my($pg_num,$sectsubid,$pg2max,$totalItems,$pg1max,$end_section) = @_;
 my $pg;
 $doclistname = "$sectionpath/$sectsubid.idx";
 &set_start_stop_count_maxes;  ## we have to this twice - also before start-stop count

 $totalPages = &total_pages($doclistname,$pg2max,$totalItems,$pg1max);

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

sub hook_into_system
{
 my($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$listsingle) = @_;  #fields needed for sorting
# $pubdate = &conform_date($pubdate,'n',$sysdate);
# $sysdate = &conform_date($sysdate,'n');

 if($docid =~ /-/) {
    &write_index_straight($emailedSS,$docid);     # in indexes.pl
    &DB_update_sectsub_idx($idx_insert_sth,$sectsubfk,$docid,$stratus,$delsectsubs) unless($DB_docitem < 1);    # in sections.pl
    return("");
 }

 if($sectsubs !~ /$deleteSS|$expiredSS/ and $cmd !~ /selectItems|updateCvrtItems/) {
   &add_temporary_sectsubs;
 }

 ##   if delete is deleted and another section added
 if($delsectsubs =~ /$deleteSS|$expiredSS/ and $addsectsubs =~ /[A-Za-z0-9]/) {
   unlink "$deletepath/$docid.del";
 }

 ##      update subsection indexes by docid;

 my @adddelsectsubs = split(/;/,"$addsectsubs;$delsectsubs;$chglocs");
 my $saveCsectsub = $cSectsubid;

 foreach $rSectsub (@adddelsectsubs)  {
   if($rSectsub) {
     my($sectsubname,$rSectid,$rSubid,$stratus) = &split_sectsub($rSectsub);
     &updt_subsection_index($idx_insert_sth,$sectsubname,$cSSid,$docid,$stratus,$addsectsubs,$delsectsubs,$listsingle); #not exporting
   }
 }

## go back to listSectsub
 $cSectsubid = $saveCsectsub;
 &split_section_ctrlB($cSectsubid);
}


##      Update docid index file (flatfile)- for each $rSectsubid

sub updt_subsection_index
{
 my($idx_insert_sth,$sectsubname,$SSid,$docid,$stratus,$addsectsubs,$delsectsubs,$listsingle) = @_;	
	
 ($sectsubname,$rest) = split(/`/,$sectsubname,2) if ($sectsubname =~ /`/); #fix a bug from somewhere

##   Since we have been having problems deleting, we are doing this as a backup
 if($delsectsubs =~ /$sectsubname/ and $listsingle =~ /list/) {
    $DELETELIST = "$DELETELIST$docid^";
#    &toDeleteList_open($sectsubname,'Y');
#    &toDeleteList_write($docid);
#    &toDeleteList_close;
 }
	
 $addchk = "$addsectsubs;$chglocs";
 $delchk = "$delsectsubs;$chglocs";

## &split_section_ctrlB($sectsubname);  # to get $cOrder - in sectsub.pl  ### DON'T NEED ######
 $stratus = $default_docloc if($stratus !~ /[A-Z]/);

 &write_index_flatfile($sectsubname,$docid,$stratus,$cOrder,$addchk,$delsectsubs,$listsingle);

##                     Delete the docid we wrote before
##                     - just in case it didn't delete above
# &deleteFromIndex_2nd($docid,$sectsubname,'Y') if($delsectsubs =~ /$sectsubname/);

 my $n_docid = int($docid);
 &DB_update_sectsub_idx($idx_insert_sth,$sectsubname,$n_docid,$delsectsubs,$listsingle) if($DB_docitems eq 1);
 undef %iDocid;
 undef %iDocloc;
 undef %idx_written;
 undef %newIdx_written;
}

sub toDeleteList_open
{
   my($sectsubname, $from_updt_subsec_idx)  = @_;

print "idx708 open ..sectsubname $sectsubname WE SHOULD NOT BE COMING HERE!<br>\n";
  if($from_updt_subsec_idx =~ /[Yy]/) {
   }     ## Don't lock if in the middle of &updt_subsection_index - already locked
   else {
     $lock_file = "$statuspath/$sectsubname.del.busy";
     &waitIfBusy($lock_file, 'lock');
   }

   my $delsectionfile = "$sectionpath/$sectsubname.del";

   if(-f $delsectionfile) {
   }
   else {
      system "touch $delsectionfile";
   }
   open(DELLIST, ">>$delsectionfile");
}

sub toDeleteList_write
{
 my $docid  = $_[0];
 print DELLIST "$docid\n";
}


sub toDeleteList_close
{
 close(DELLIST);
 unlink $lock_file  if(-f $lock_file);
}

## not sure this ever worked - lDocid is a local - where does docid to be deleted come in????

sub deleteFromIndex_2nd    ## Doesn't work for emailed list - Just delete file from directory only
{
 my($ldocid,$sectsubname, $from_updt_subsec_idx)  = @_;

 unless($DELETELIST) {
    if (-f $delsectionfile) {
		 my($delsectionfile) = "$sectionpath/$sectsubname.del";
	
	     if($from_updt_subsec_idx =~ /[Yy]/) {
	     }     ## Don't lock if in the middle of &updt_subsection_index - already locked
	     else {
	        $lock_file = "$statuspath/$sectsubname.busy";
	        &waitIfBusy($lock_file, 'lock');
	     }
	     open(DEL2LIST, "$delsectionfile");
 
		 my $xDocid;
		 while(<DEL2LIST>)
		  {
		    chomp;
		    $xDocid = $_;
		    $DELETELIST = "$DELETELIST$xDocid^";
		  }
		 close(DEL2SECT);
	 }
	 else {
#	     &printDataErr_Continue("Idx773 missing list of deletions. Non-fatal error; continuing with processing. Notify admin. Thanks");
	 }
 }

 $sectionfile    = "$sectionpath/$sectsubname.idx";
 $newsectionfile = "$sectionpath/$sectsubname.new";
 $bkpsectionfile = "$sectionpath/$sectsubname.bkp";

 if(-f $sectionfile) {
    system "cp $sectionfile $bkpsectionfile";
    unlink "$newsectionfile";

    my($sDocid,$sDocloc);

    open(INSUB2, "$sectionfile") or die("Cant open sectionfile $sectionfile");
    open(OUTSUB2, ">>$newsectionfile") or die("Cant open newsectionfile $newsectionfile");
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

sub deleteFromIndex_deletelist
{
 my($sectsubname, $from_updt_subsec_idx)  = @_;

 unless($DELETELIST) {
    if (-f $delsectionfile) {
		 my($delsectionfile) = "$sectionpath/$sectsubname.del";
	
	     if($from_updt_subsec_idx =~ /[Yy]/) {
	     }     ## Don't lock if in the middle of &updt_subsection_index - already locked
	     else {
	        $lock_file = "$statuspath/$sectsubname.busy";
	        &waitIfBusy($lock_file, 'lock');
	     }
	     open(DEL2LIST, "$delsectionfile");
 
		 my $xDocid;
		 while(<DEL2LIST>)
		  {
		    chomp;
		    $xDocid = $_;
		    $DELETELIST = "$DELETELIST$xDocid^";
		  }
		 close(DEL2SECT);
	 }
	 else {
#	     &printDataErr_Continue("Idx773 missing list of deletions. Non-fatal error; continuing with processing. Notify admin. Thanks");
	     return;
	 }
	
	 &DB_delete_from_idx_list if($DB_indexes > 0);
 }

 $sectionfile    = "$sectionpath/$sectsubname.idx";
 $newsectionfile = "$sectionpath/$sectsubname.new";
 $bkpsectionfile = "$sectionpath/$sectsubname.bkp";

 if(-f $sectionfile) {
    system "cp $sectionfile $bkpsectionfile";
    unlink "$newsectionfile";

    my($sDocid,$sDocloc);

   open(INSUB2, "$sectionfile") or die("Cant open sectionfile $sectionfile");
   open(OUTSUB2, ">>$newsectionfile") or die("Cant open newsectionfile $newsectionfile");
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

   &DB_update_idx_list($idx_insert_sth,$sectsubname,$delsectsubs,$DELETELIST) if($DB_docitems eq 1);
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
	    my($xsectsubname,$xsectname,$xsubname,$stratus) = &split_sectsub($sectsub);
	    $stratus = 'M' if($stratus !~ /[A-Z]/);
#       $dTemplate = 'straight' if($straight_html eq 'Y');   ## DO WE NEED?
        return($stratus);
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
     my ($sectsubname,$docloc) = split(/`/,$sectsub,3);
     ($sectid,$subid) = split(/_/, $sectsubname);
#print MIDTEMPL "sectsub $sectsub sectsubname $sectsubname docloc $docloc<br>\n";
     return ($sectsubname,$sectid,$subid,$docloc);
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
   my $listSectsub = $_[0];
   $filepath = "$sectionpath/$listSectsub.idx";
   if($listSectsub =~ /$emailedSS/ and -f "$filepath") {
      open(INFILE, "$sectionpath/$listSectsub.idx");
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

   unlink "$sectionpath/$listSectsub.idx";
   print "<font size=3 face=verdana>Clean index is complete - $listSectsub</font><p>\n";
}


sub clean_popnews_bkup
{
  opendir(POPMAILDIR, "$mailbkppath");

  my(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
  closedir(POPMAILDIR);

  foreach $filename (@popnewsfiles) {
     if(-f "$mailbkppath/$filename" and $filename =~ /email/) {
        unlink "$sepmailpath/$filename";
    }
  }
  print "<font size=3 face=verdana>Empty Popnews Mail Backup folder is complete</font><p>\n";
}


####  Database stuff #########

sub DB_delete_from_idx_list   ## TODO: modify this to delete from a list
{                         # comes here from docitem.pl and indexes.pl
 my($idx_insert_sth,$sectsubname,$stratus,$delsectsubs,$DELETELIST) = @_;
 my $sectsubfk = 0;
 if($DB_sectsubs eq 1) {
    $sectsubfk = &DB_get_sectsubid($sectsubname);  #in sectsubs.pl
 }
 else {
    $sectsubfk = &get_sectsubid($sectsubname);	#flatfile
 }

 if($sectsubfk < 1 or !$sectsubfk) {
	print "sec933 Bad sectsub ..name $sectsubname<br>\n";
	&write_index_flatfile('import_Badsectsub',$docid,'','P','import_Badsectsub','','single');  #log - in index.pl
	return(1);
 }

 if($delsectsubs =~ /$sectsubname/) {
    &DB_delete_from_indexes($sectsubfk,$docid);
 }
 else {
    &DB_add_to_indexes($idx_insert_sth,$sectsubfk,$docid,$stratus);
 }
}



sub DB_update_sectsub_idx
{                         # comes here from docitem.pl and indexes.pl
 my($idx_insert_sth,$sectsubname,$docid,$stratus,$delsectsubs,$listsingle) = @_;
 my $sectsubfk = 0;
 if($DB_sectsubs eq 1) {
    $sectsubfk = &DB_get_sectsubid($sectsubname);  #in sectsubs.pl
 }
 else {
    $sectsubfk = &get_sectsubid($sectsubname);	#flatfile
 }

 if($sectsubfk < 1 or !$sectsubfk) {
	print "sec933 Bad sectsub ..name $sectsubname<br>\n";
	&write_index_flatfile('import_Badsectsub',$docid,'','P','import_Badsectsub','');  #log - in index.pl
	return(1);
 }

 if($delsectsubs =~ /$sectsubname/) {
    &DB_delete_from_indexes($sectsubfk,$docid) if($listsingle =~ /single/);  #lists are handle all deletes at once in DB_delete_from_idx_list
 }
 else {
    &DB_add_to_indexes($idx_insert_sth,$sectsubfk,$docid,$stratus);
 }
}

## DATABASE SQL ALTERNATIVE TO FLAT FILE INDEX

sub do_doclist_sql {    # for display
  my $dSectsub = $_[0];
  my $counts = &get_start_stop_count($pg_num);  #in sections.pl
  ($start_count,$stop_count) = split(/:/,$counts,2);
  my $start_cnt = 0;
  my $num_articles = 0;
  my $orderby = "";
  my $lastpg2woadatetm = '99-99-99 99:99:99';

  $ckItemnbr = 1;
  $ckItemcnt = &padCount6($ckItemnbr);

  unless($dbh) {
    $dbh = &db_connect() or die "DB failed connect";
  }

  $start_cnt = int($start_count);
  $num_articles = $stop_count - $start_count;

  my $orderby = &get_orderby;

## Page 2 and so on:  WHERE d.woapubdatetm < last one on page 1 - ORDER by d.pubdate desc  LOOK AT GET_ORDERBY

  my $sql = "SELECT i.docid, d.woapubdatetm, i.stratus, d.pubdate FROM indexes as i, docitems as d, sectsubs as s WHERE i.sectsubid = s.sectsubid AND d.docid=i.docid AND s.sectsub = ? ORDER BY $orderby LIMIT ?, ?";		
  my $doclist_sth = $dbh->prepare($sql) or die "DB doclist failed prepare";
  $doclist_sth->execute($dSectsub,$lastpg2woadatetm,$start_cnt,$num_articles) or die "DB doclist failed execute";

  if ($doclist_sth->rows == 0) {
  }
  else {
	 $number = $doclist_sth->rows;
      while (my @row = $doclist_sth->fetchrow_array()) { # print data retrieved
	     $docid = $row[0];

	      &do_one_doc($index_insert_sth) if($docid ne $prev_docid and $ckItemcnt > $start_count and $docid =~ /[0-9]/);  ## skip dups
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

sub get_orderby {
  my $orderby = '';

  if($qOrder =~ /[A-Za-z0-9]/) {
    $sortorder = $qOrder;
  }
  else {
    $sortorder = $cOrder;
  }

# R = region  T = topic  t = region/topic  P = reverse pubdate
# p = pubdate  d = docloc/sysdate  D = sysdate only A = priority/sysdate
# H = headline  S = source  # r = reverse physical order
# F = fifo  # L = lifo

  if ($sortorder == 'F') {  #last in, first out - NewsDigest_newsItem for example
	 if($pg_num < 3) {
		$orderby =  "i.stratus, d.woapubdatetm DESC ";
	 }
	 else {
	   $lastpg2woadatetm = &DB_getlastpg2_woadatetm($dSectsub);
	   $orderby = "i.stratus, d.pubdate DESC";
	 }
  }
  elsif($sortorder == 'P') { #reverse publish date
	 $orderby = "i.stratus, d.pubdate DESC";
  }
  elsif($sortorder == 'A') { # priority / sysdate(in pubdate) (headlines)
	 $orderby = "i.stratus, d.pubdate DESC";
  }
  elsif($sortorder == 'R') { #region
	 $orderby = "i.stratus, d.region, d.pubdate DESC";
  }
  elsif($sortorder =~ /[HT]/) { #headline
	 $orderby = "i.stratus, d.headline, d.pubdate DESC";
  }
  elsif($sortorder == 'd') { #docloc, sysdate (in pubdate)
	 $orderby = "i.stratus, d.pubdate DESC";
  }
  elsif($sortorder == 'D') { #docloc, sysdate (in pubdate)
	 $orderby = "i.pubdate DESC";
  }
  elsif($sortorder =~ /[LrW]/) {    #reverse physical order
	 $orderby = "i.stratus, d.woapubdatetm ASC";
  }
  else {
	 $orderby = "i.stratus, d.pubdate DESC";
  }
  return($orderby);
}


sub DB_getlastpg2_woadatetm {
    my($sectsub) = $_[0];
    my $pg1pg2Limit = 0;
    $pg1pg2Limit = ($cPg1Items + $cPg2Items -1);
	my $lastpg2woadatetm = 0;
	my $woadatetm_sth = $dbh->prepare("SELECT d.woadatetm FROM docitems AS d, indexes AS i, sectsubs AS s WHERE i.sectsubid = s.sectsubid AND d.docitem = s.doctiem AND s.sectsub = ? ORDER BY d.woadatetm DESC LIMIT ? , 1");

	if($woadatetm_sth) {
	    $woadatetm_sth->execute($sectsub,$pg1pg2Limit) or die "Couldn't execute statement: ".$woadatetm_sth->errstr;
	    $lastpg2woadatetm = $woadatetm_sth->fetchrow_array();
		$woadatetm_sth->finish();
	}
	else {
	   print" Couldn't prepare DB_getlastpg2_woadatetm query<br>\n";
	}
	return ($lastpg2woadatetm);
}

sub DB_prepare_idx_count {
  my $sth = $dbh->prepare("SELECT COUNT(*) FROM indexes  WHERE docid = ? and sectsubname = ?") or die("Couldn't prepare statement: " . $sth->errstr);		
  return $sth;
}

sub DBindex_exists
{
  my($SSid,$docid,$sth) = @_;
  $sth->execute($docid,$SSid);
  my @row = $sth->fetchrow_array();
  $sth->finish;
  return($row);
}

sub DB_prepare_idx_insert {
 my $mode = $_[0];
 my $sth;
 if($mode = 'import') {
     $sth = $dbh->prepare( 'INSERT IGNORE INTO indexes VALUES ( ?, ?, ?)' ) ; 
 }
 else {
	 $sth = $dbh->prepare( 'INSERT INTO indexes VALUES ( ?, ?, ?) ON DUPLICATE KEY UPDATE stratus = ?' ) ; 
 }
 return($sth);
}

sub DB_add_to_indexes
{ 
 my($sth,$SSid,$docid,$stratus) = @_;

 if($SSid < 1 or $docid !~ /[0-9]/) {
	print "idx2044 Invalid sectsubid $SSid or docid $docid , continuing<br>\n";
	return;
 }
 
 $sth->execute($SSid,$docid,$stratus);
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

sub create_indexes_table {
	#                        DO THIS MANUALLY ON THE DB SERVER
$INDEXES_SQL  = <<ENDINDEXES
  CREATE TABLE indexes (
  sectsubid      smallint unsigned not null, 
  docid          smallint unsigned not null,
  stratus        char(1)  default 'M',
  UNIQUE idx_ss_doc (sectsubid,docid) );
ENDINDEXES
}


sub export_indexes_XXX   ####### do this with each docitem!!!!!
{  #run this after all docitems are exported
 my $sth_idxrows = $dbh->prepare( 'SELECT i.docid,i.sectsubid,i.stratus FROM indexes as i  WHERE i.sectsubid = ?' ) 
    or die("Couldn't prepare statement: " . $sth_idxrows_sth->errstr);

 foreach $cSectsub (@CSARRAY) {
     ($SSid,$SSseq,$sectsubname) = split(/\^/,$cSectsub);
     &export_write_sectsub_index($sectsubname,$sth_idxrows);
 }
}


sub export_write_sectsub_index
{
 my($sectsubname,$sth_idxrows) = @_;

 $expsectionfile = "$expsectionpath/$sectsubname.idx";

 $lock_file = "$statuspath/$sectsubname.busy";
 &waitIfBusy($lock_file, 'lock');

 if($SVRinfo{'environment'} == 'development') {
    open(OUTSUB, ">$expsectionfile") or print "sec428 H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$expsectionfile");
 }
 $sth_idxrows->execute($sectsubname);
 while (my @row = $sth_idxrows->fetchrow_array()) { # print data retrieved
	 my ($docid,$sectsubid,$stratus) = @row;	
	
    $stratus = $default_docloc unless($stratus);
     print OUTSUB "$docid^$stratus\n";
 } 
 $sth_idxrows->finish;
 close(OUTSUB);
}

1;