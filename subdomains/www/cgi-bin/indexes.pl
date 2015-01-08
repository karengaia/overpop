#!/usr/bin/perl --

# January 2014
#        indexes.pl  : maintains flatfile indexes  and indexes table
#    To confuse matters, a list of document ids (docid) is called both an index or a section.
#    Only one index per section in the 'section' control file (sections.html or sectsubs table)

####

sub write_index_flatfile {
 my($rSectsubid,$docid,$docloc,$addchk,$delSS,$listsingle) = @_;
 $sectionfile    = "$sectionpath/$rSectsubid.idx";
 $newsectionfile = "$sectionpath/$rSectsubid.new";
 $bkpsectionfile = "$sectionpath/$rSectsubid.bkp";
 $lock_file      = "$statuspath/$rSectsubid.busy";
 &waitIfBusy($lock_file, 'lock');

 system "cp $sectionfile $bkpsectionfile" if(-f $sectionfile);

 unlink "$newsectionfile" if(-f $newsectionfile);
 system "touch $newsectionfile";

 $newIdx_written= 'N';
 $testct = 1;

 &split_section_ctrlB($rSectsubid); # in sectsubs.pl
 my $cOrder = $SS{order};

 if($SVRinfo{environment} == 'development') {
    open(OUTSUB, ">$newsectionfile") or print "idx30 dev - failed to open temp new section index file: $newsectionfile<br>\n";
 }
 else {
	open(OUTSUB, ">>$newsectionfile");
 }
 open(INSUB, "$sectionfile") or print "Could not open section index file: $sectionfile - idx201<br>\n";
 while(<INSUB>) {
    chomp;
    $index_written = 'N';
    my $testline  = $_;
   ($idocid,$idocloc,) = split(/\^/,$testline,2);
    $idocloc = 'M' if($idocloc !~ /[A-Z]/);

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

#### MOVEDP AGING TO DISPLAY.PL

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
    my $delete_ct = 0;
 print "Opening index file for $sectsubname<br>\n";
    open(INSUB2, "$sectionfile");
    open(OUTSUB2, ">>$newsectionfile");

    while(<INSUB2>) {
       chomp;
       ($sDocid,$sDocloc) = split(/\^/,$_,2);

       if($deletelist =~ /$sDocid/) {
	     print "Deleting $sDocid<br>\n";
	     $delete_ct = $delete_ct + 1;
       }
       else {
         print OUTSUB2 "$sDocid^$sDocloc\n";
       }
    } #endwhile

print "Total deleted: $delete_ct<br>\n";
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

 if($docid =~ /-/) {  # email docid - probably no longer used
    &write_index_straight($emailedSS,$docid);     # in indexes.pl
    &DB_update_sectsub_idx($idx_insert_sth,$sectsubfk,$docid,$stratus,$delsectsubs) if($DB_docitem > 0);    # in sections.pl
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
# print "idx258 $docid ..sectsubs $sectsubs ..addsectsubs $addsectsubs ..delsectsubs $delsectsubs ..chglocs $chglocs<br>\n";
 my $adddelsectsubs = "$addsectsubs;$delsectsubs;$chglocs";

 my @adddelsectsubs = split(/;/,$adddelsectsubs);

 foreach $rSectsub (@adddelsectsubs)  {
	 my $saveCsectsub = $cSectsubid;
   if($rSectsub) {
     my($sectsubname,$rSectid,$rSubid,$stratus) = &split_sectsub($rSectsub);
     &updt_subsection_index($idx_insert_sth,$sectsubname,$docid,$stratus,$addsectsubs,$delsectsubs,$listsingle); #not exporting
   }
 }

## go back to listSectsub
 $cSectsubid = $saveCsectsub;
 &split_section_ctrlB($cSectsubid);
}


##      Update docid index file (flatfile)- for each $rSectsubid

sub updt_subsection_index
{
 my($idx_insert_sth,$sectsubname,$docid,$stratus,$addsectsubs,$delsectsubs,$listsingle) = @_;

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

 $addchk =~ s/;$//;
 $delchk =~ s/;$//;

 $stratus = 'M' if($stratus !~ /[A-Z]/);
 &write_index_flatfile($sectsubname,$docid,$stratus,$addchk,$delsectsubs,$listsingle);

##     Delete the docid we wrote before
##         - just in case it didn't delete above
# &deleteFromIndex_2nd($docid,$sectsubname,'Y') if($delsectsubs =~ /$sectsubname/);

my @sectsubs = split(/;/,$D{sectsubs});
foreach $sectsub (@sectsubs) {
     my ($sectsubname,$docloc,$rest) = split(/`/, $sectsub,3);   # get rid of stratus A...M...Z
         # will either add to or delete from index
}
 my $n_docid = int($docid);
#                                             IS THIS RIGHT?
 &DB_update_sectsub_idx($idx_insert_sth,$sectsubname,$n_docid,$stratus,$delsectsubs,$listsingle) if($DB_docitems > 0);
undef %newIdx_written;
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

# I DON'T BELIEVE THIS WORKS - CHECK WHERE THIS IS COMING FROM
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

   &DB_update_idx_list($idx_insert_sth,$sectsubname,$delsectsubs,$DELETELIST) if($DB_docitems > 0);
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

sub split_dSectsub   ## SEE SPLIT_SECTSUB - REUSE
{
 ($dSectsubid,$dDocloc)
       = split(/`/, $dSectsub,3);
 ($dSectid,$dSubid) = split(/_/, $dSectsubid);

 $dDocloc = $default_docloc if($dDocloc !~ /[A-Z]/);
}

sub split_sectsub {
     my $sectsub = $_[0];
     my ($sectsubname,$docloc) = split(/`/,$sectsub,3);
     ($sectid,$subid) = split(/_/, $sectsubname);

     return ($sectsubname,$sectid,$subid,$docloc);
}

#### TODO: this does not seem to be used

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

sub total_items
{
 my $doclistname = $_[0];
 my $tot_items = 0;
 if($DB_docitems > 0) {
	my $sectsubid = &get_sectsubid($doclistname);
	my $result = $dbh->do("SELECT COUNT from indexes as i where i.sectsubid = $sectsubid");
 }
 return($result);

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

sub DB_do_doclist_sql {    # for display
  my $dSectsub = $_[0];
  my $counts = &get_start_stop_count($pg_num);  #in sections.pl
  ($start_count,$stop_count) = split(/:/,$counts,2);
  my $start_cnt = 0;
  my $num_articles = 0;
  my $orderby = "";
  my $lastpg2woadatetm = '99-99-99 99:99:99';

  $ckItemnbr = 1;
  $ckItemcnt = &padCount6($ckItemnbr);

  unless($DBH) {
    $DBH = &db_connect() or die "DB failed connect";
  }

  $start_cnt = int($start_count);
  $num_articles = $stop_count - $start_count;

  my $orderby = &get_orderby;

## Page 2 and so on:  WHERE d.woapubdatetm < last one on page 1 - ORDER by d.pubdate desc  LOOK AT GET_ORDERBY

  my $sql = "SELECT i.docid, d.woapubdatetm, i.stratus, d.pubdate FROM indexes as i, docitems as d, sectsubs as s WHERE i.sectsubid = s.sectsubid AND d.docid=i.docid AND s.sectsub = ? ORDER BY $orderby LIMIT ?, ?";
  my $doclist_sth = $DBH->prepare($sql) or die "DB doclist failed prepare";
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


sub DB_prepare_idx_count {
  my $sth = $DBH->prepare("SELECT COUNT(*) FROM indexes  WHERE docid = ? and sectsubname = ?") or die("Couldn't prepare statement: " . $sth->errstr);
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
     $sth = $DBH->prepare( 'INSERT IGNORE INTO indexes VALUES ( ?, ?, ?)' ) ;
 }
 else {
	 $sth = $DBH->prepare( 'INSERT INTO indexes VALUES ( ?, ?, ?) ON DUPLICATE KEY UPDATE stratus = ?' ) ;
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
    $DBH->do($query) or die "DB Delete $docid from $sectsubid failed<br>\n";
}


sub DB_delete_from_indexes_by_list  # NEEDS TO HAVE SQL FIXED
{
    my($sectsubid,$deletelist) = @_;
    my $query = "DELETE FROM indexes WHERE sectsubid = $sectsubid AND docid IN $deletelist";
    $DBH->do($query) or die "DB Delete $deletlist from $sectsubid failed<br>\n";
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
 my $sth_idxrows = $DBH->prepare( 'SELECT i.docid,i.sectsubid,i.stratus FROM indexes as i  WHERE i.sectsubid = ?' )
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
    open(OUTSUB, ">$expsectionfile") or print "sec901 H Mac - failed to open temp new section index file: $newsectionfile<br>\n";
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
	my ($sectsubid,$seq,$sectsub,$fromtoSSid,$fromtoSSname,$cSubdir,$cPage,$cCategory,$cVisable,$cPreview,$sortorder,$cPg2order,$cTemplate,$cTitleTemplate,$cTitle,$cAllOr1,$cMobidesk,$cDocLink,$cHeader,$cFooter,$cFTPinfo,$cPg1Items,$cPg2Items,$cPg2Header,$cMore,$cSubtitle,$cSubtitletemplate,$cMenuTitle,$cKeywordsmatch)
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
		 $pubdate = $sysdate   if($sortorder =~ /[AD]/);
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
		 $pubdate = $sysdate   if($sortorder =~ /[AD]/);
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


sub export_indexes  ## IS THIS USED?
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

1;
