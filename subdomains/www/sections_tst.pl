#!/usr/bin/perl --

# April 12, 2010

#        sections.pl

## Processes sections - indexes and sectsub handling; 
##  as well as sections print and add to/update sections.

## Called by article.pl or docitem.pl

## 2010 Apr 12 - moved to radio buttons on selection section for: News, Headlines, 
##               Suggested (emailed, summarized, suggested); removed some HTML and text from script
## 2006 Mar 18 - write better delete; reorganized code in sections.pl
## 2006 Jan 25 - sort order for priority set stratus to A for 2006
## 2006 Jan07  - write item count to a .cnt file for page indexing
## 2005 Dec 4 - added item counts for paging


## 100 INITIALIZING SECTIONS INFORMATION

sub read_sectCtrl_to_array
{
  $CSidx = 0;
  open(SECTIONS, "$sectionctrl");
  while(<SECTIONS>)
  {
    chomp;
    $line = $_;    
    if(($line !~ /<PRE>/) and ($line !~ /<\/PRE>/)
      and ($line !~ 'sectid_subid') ) {
      ($name,$value) = split(/`/,$line,2);
      $CSINDEX{$name} = $value;
      $CSARRAY[$CSidx] = $line;
      &savePageinfo;     
      $CSidx = $CSidx + 1;
    }
  } 
  close(SECTIONS);
  
  undef $savepage;

##   special sections that we work with

 $newsdigestSS     = "NewsDigest_NewsItem";
 $publogSS         = "PublicLog_pubLogEntry";
 $deleteSS         = "delete_deleteItem";
 $expiredSS        = "expired_expiredItem";
 $newsdateSS       = "NewsDigest_date";
 $newsmthlySS      = "NewsMthly";
 $newsWeeklySS     = "NewsWeekly_WeeklyItem";
 $mthlyItemSS      = "NewsMthly_MthlyItem";
 $reviewSS         = "review_review";
 $recentSS         = "recent_recentItem";  ##obsolete
 $suggestedSS      = "Suggested_suggestedItem";
 $volunteerSS      = "Volunteer";
 $volunteerGrist   = "Volunteer_grist";
 $volunteerFP      = "Volunteer_womenFP";
 $emailedSS        = "Suggested_emailedItem";
 $emailedSub       = "emailedItem";
 $summarizedSS     = "Suggested_summarizedItem";
 $headlinesSectid  = "Headlines";
 $volunteerSectid  = "Volunteer";
 $headlnPrioritySS = "Headlines_priority";
 $newsdigestSectid = "NewsDigest";
 $newsScan2Sectid  = "NewsScan2";
 $archiveSectid    = "Archives";
 $needsSummSS      = "needsSumm_item";
 $testSS           = "Test_testItem";
 $worklistSS       = "worklist_item";
 $convertSS        = "convert_Item";
 
 $prt_countries = '';
 $DELETELIST = "";
}

#### 200 PRINTING FOR ARTICLE.PL

#########  for printing sections dropdowns from a template

## if template contains [CURRENT_SECTIONS]

sub get_current_sections
{
 if ($action ne 'new') {
      $first_time = 0;
      @dSectsubs = split(/;/, $dSectsubs);
      foreach $dSectsub (@dSectsubs) {
      	   &split_dSectsub;
      	   $cSectsubid = $dSectsubid;
           &split_section_ctrlB;
           $docloc = $dDocloc;
           $first_time = $first_time + 1; 
           if($first_time eq 1) {
             print MIDTEMPL "<font color=\"#666666\" size=1 face=verdana>If you do not have admin access<br> to a section, none of the above<br>will be available for that section.</font>\n"
                if($operator_access !~ /[AB]/);
  	       }
           &ck_visability;
     
           if($tVisable eq 'Y' and $tPreview eq 'Y') {
               &print_current_section(updt);         	
           }
           else { 
               &print_cant_change_section;                     
          }  
     }    
 } 
}

sub print_current_section
{
  local($add)  = $_[0]; 
  local($checked);
  local($name);
  
  if($add !~ /add/) {
     $name = "updsectsubs";
  }
  else {
     $name = "addsectsubs";  
  }

  if($dSectsubid =~ /Headlines|News|Suggested/) {
     local($mutX_sects) = "Headlines_sustainability|NewsDigest_NewsItem|NewsDigest_EventsBox|Suggested_emailedItem|Suggested_suggestedItem|Suggested_SummarizedItem|NA";
     local(@x_sects) = split(/|/,$mutX_sects);
          
     foreach $x_sect (@x_sects) {
       $checked = "";
       $checked = "checked" if($dSectsubid =~ /$x_sect/);
       print MIDTEMPL "<input type=\"radio\" name=\"$name\" value=\"$dSectsubid\" $checked >$dSectsubid<br>\n";
     }
  }  
  elsif($ipform eq "docUpdate")  {
     &prt_current_sections($name);
  }
}

sub prt_current_sections {
  local($name)  = $_[0];
  local($checked) = "";
  $checked = "checked=\"checked\"" if($name =~ /updsectsubs/); 
  print MIDTEMPL "<input type=\"checkbox\" name=\"$name\" ";
  print MIDTEMPL "value=\"$dSectsubid\" $checked>$dSectsubid<br>\n";

   print MIDTEMPL <<END; 
   <table><td><font size="1" face="verdana">\n
END
  
  if($name =~ /updsectsubs/) {
     print MIDTEMPL "<select name=\"docloc_$dSectsubid\">\n";
     $ck_docloc = $docloc;
  }
  else {
     print MIDTEMPL "<select name=\"docloc_add\">\n";
     $ck_docloc = $default_docloc;
  }

  &print_doc_order;

   print MIDTEMPL <<END; 
     </font></td><td>\n
     <font size="1" face="verdana">Item stratification <br>
      M=middle (normal)</font></td></table>\n 
              
    print MIDTEMPL "<font size=1 face=\"verdana\">Image specification:&nbsp;&nbsp;&nbsp;name:<br>\n";
END
    print MIDTEMPL "<input type=\"text\" name=\"imagefile_$dSectsubid\" value=\"\" size=23><br>\n";
    print MIDTEMPL "<input type=\"radio\" value=\"R\" name=\"imageloc_$dSectsubid\">right &nbsp;\n";
    print MIDTEMPL "<input type=\"radio\" value=\"L\" name=\"imageloc_$dSectsubid\">left &nbsp;\n";
    print MIDTEMPL "<input type=\"radio\" value=\"T\" name=\"imageloc_$dSectsubid\">top &nbsp;\n";
    print MIDTEMPL "<input type=\"radio\" value=\"B\" name=\"imageloc_$dSectsubid\">btm &nbsp;\n";
    print MIDTEMPL "</font>\n";
}

sub print_cant_change_section
{ 
  print MIDTEMPL "$dSectsubid<br>\n";
  print MIDTEMPL "<input type=\"hidden\" name=\"updsectsubs\" value=\"$dSectsubid\">\n";
  print MIDTEMPL "<input type=\"hidden\" name=\"docloc_$dSectsubid\" value=\"$docloc\">\n";
  print MIDTEMPL "<input type=\"hidden\" name=\"neardocid_$dSectsubid\" value=\"\">\n";
  print MIDTEMPL "<input type=\"hidden\" name=\"imagefile_$dSectsubid\" value=\"$dImagefile\">\n";
  print MIDTEMPL "<input type=\"hidden\" name=\"imageloc_$dSectsubid\" value=\"$dImageloc\">\n";
}


sub print_doc_order
{
 @doc_order_codes =
 ("A", "B", "C", "D", "E", "F", 
  "M",
  "U", "V", "W", "X", "Y", "Z");

  foreach $tdocloc(@doc_order_codes) {
     $selected = "";
     $selected = "selected=\"selected\"" if($tdocloc =~ /$ck_docloc/);
     print MIDTEMPL "<option value=\"$tdocloc\" $selected>$tdocloc</option>\n";
  }
  print MIDTEMPL "</select><br>\n";
}

#####


## if template contains [NEWS_SECTION]

sub get_news_section
{
 $dSectsubid = "$newsdigestSS";
 &print_current_section(add);
}


## if template contains [ADD_COUNTRIES]

sub get_country_sections
{
 &get_addl_sections(C,1);
}


## if template contains [ADD_NON_COUNTRIES]

sub get_nonCountry_sections
{
 &get_addl_sections(O,2);
}

## if template contains [WORKLIST_SECTIONS]

sub get_worklist_sections
{
 &get_addl_sections(W,3);
}


sub get_addl_sections
{
 local($catCode,$catnum)  = @_;

#####################################
  


  if($aTemplate =~ /docUpdate/) {
    print MIDTEMPL <<END;
     <br></font><font face="comic sans ms" size="1">\n
     (the following tools do not work with multiple <br>adds in this category. Add one <br>at a time
     if using other than default)</font>\n
     <p>
     <table><td><font size="1" face="verdana">2. Item stratification <br>
        &nbsp;&nbsp;&nbsp;M=middle (normal)</font></td>\n
        <td> <font size=1 face="verdana">
END     
   print MIDTEMPL "<select name=\"docloc_add$catnum\">\n";


   $ck_docloc = $default_docloc;
   &print_doc_order;
 
   print MIDTEMPL <<END;
     <br><font size=1 face=verdana>3. Image: &nbsp;&nbsp;filename:<br> 
    <input type="text" name="imagefile_add" value="" size="23"><br> 
    <input type="radio" value="R" name="imageloc_add">right &nbsp; 
    <input type="radio" value="L" name="imageloc_add">left &nbsp; 
    <input type="radio" value="T" name="imageloc_add">top &nbsp; 
    <input type="radio" value="B" name="imageloc_add">btm &nbsp; 
    </font>
    </td></table>
END
  } #end if($aTemplate =~ /docUpdate/)
} #end sub


sub ck_visability
{
## access = A - admin, has access to everything:
##             V-view all articles | C-update contributors | F-ftp | U-update all articles | 
##             F -'from' sectsubs dropdown | T -'to' sectsubs dropdown | E-look at email |   
##             X - utilities menu 
##          B      - V | U     | T | E 
##          C      - V | U     | T | 
##          D      - V | U-own | T | 
##     permissions limit :
##                 - V-no | U-yes or own | F-no | T-yes  
##    if (permissions) - from newsscan/archives (Read only) to permitted
  	   
## visable (sections file) - V = visable to public on sectsubs dropdown
##                           P = visable and to be put on public log
##                           E = email
##                           A = not visable except to admin A-D
##                           S = parts of section not visable except when user_visable = 'Y'
##                           T = Top of page; not visable to public in dropdown
##                           B = Bottom of page; not visable to public in dropdown
##                           H = visable to helpers ABCDP

## preview - Sectsubs dropdown - admin
##                           A = visable only for admin A-B or if permission for that section
##                           D - visable to/from for admin A-C or D w/permissions
##                           R - visable 'from' only for admin A-C or D w/permissions

           $tVisable = 'N';
           $tPreview = 'N';
           
           $tVisable = 'Y' if($cVisable =~ /[VP]/
                  or ($cVisable =~ /[STB]/ and $operator_access =~ /[ABCD]/ and $user_visable eq 'Y')
                  or ($cVisable eq 'A' and $operator_access =~ /[ABCD]/)
                  or ($cVisable eq 'H' and $operator_access =~ /[ABCDP]/) );
                  
           $tPreview = 'Y' if($cPreview =~ /A/ and ($operator_access =~ /[AB]/ or $op_permissions =~ /$cSectid/));
           $tPreview = 'Y' if(   ($cPreview =~ /[DR]/ and $operator_access =~ /[ABC]/)
                              or ($operator_access =~ /D/ and $op_permissions =~ /$cSectid/) );	
           $tPreview = 'Y' if($template =~ /selectUpdt|commonDropdowns|article_control/);
           
##print "200x vis-$tVisable prev-$tPreview $cSectsubid $cSectid .. $cVisable - $cPreview template $template<br>\n";
 
#      $tVisable = 'Y' if($cVisable =~ /[VP]/ 
#                      or ($cVisable =~ /A/ and $operator_access =~ /[ABCD]/)
#                      or ($cVisable =~ /[STB]/ and $operator_access =~ /[ABCD]/ and $user_visable eq 'Y') );
#      $tPreview = 'Y' if($cPreview eq 'A' and ($operator_access =~ /[AB]/ or $cSectid =~ /$op_permissions/));   		
}



####  400 ADDING AND DELETING TO INDEX

##      Update docid index file - one at a time

sub updt_subsection_index
{
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

 $addchk = "$addsectsubs;$chglocs"; 
 $delchk = "$delsectsubs;$chglocs";

##   Since we have been having problems deleting, we are doing this as a backup 
 if($delsectsubs =~ /$rSectsubid/) {
   &toDeleteList_open($rSectsubid,'Y');
   &toDeleteList_write($docid);
   &toDeleteList_close;
 }

##print "<font color=#666666 face=arial size=1>sec400a rSectsubid $rSectsubid docid $docid sectionfile $sectionfile</font><br>\n";
 
## find info about the one we are inserting/deleting
 $dSectsubs = $sectsubs;
 $docloc = &splitout_sectsub_info($rSectsubid);
 
 open(OUTSUB, ">>$newsectionfile");
 open(INSUB, "$sectionfile");
 while(<INSUB>) {
    chomp;
    $index_written = 'N';
    local($testline) = $_;
    ($iDocid,$iDocloc) = split(/\^/,$testline,2);
    $iDocloc = $default_docloc if($iDocloc !~ /[A-Z]/);     
                  	
    if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N') {
       if($docloc lt $iDocloc) {
          &put_docid;
       }
##                 This puts it on top of stratus unless sortorder = L (last)
       elsif($docloc eq $iDocloc and $cOrder ne 'L') { 
          &put_docid;       
       }
       else {
          &put_idocid;
       }
    }
    
    &put_idocid if($index_written eq 'N');
    
    $testct = $testct + 1;
 } #endwhile
 
 &put_docid if($addchk =~ /$rSectsubid/ and $newIdx_written eq 'N');

 close(INSUB);
 close(OUTSUB);
  
 system "cp $newsectionfile $sectionfile" if(-f $newsectionfile);
 unlink $newsectionfile if(-f $newsectionfile);
 unlink $lock_file  if(-f $lock_file);

##                     Delete the docid we wrote before  
##                     - just in case it didn't delete above
 &deleteFromIndex_2nd($rSectsubid,'Y') if($delsectsubs =~ /$rSectsubid/);     

 
 undef %iDocid;
 undef %iDocloc;
 undef %idx_written;
 undef %newIdx_written;
}


## 00410

sub put_docid
{
    print(OUTSUB "$docid^$docloc\n");

 $newIdx_written = 'Y';
}    


sub put_idocid
{
##print "420 k- $kDocid-$kDocloc  d- $docid-$dDocloc i-$iDocid-$iDocloc delsectsubs $delsectsubs ord- $cOrder r- $rSectsubid $sectsubs<br>\n";		
 if($delsectsubs =~ /$rSectsubid/ and $iDocid eq $docid)  
    { }
 else { 
    print(OUTSUB "$iDocid^$iDocloc\n");
 }
 
 $index_written = 'Y';
}


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

##     DELETE - Need more than one method ####
##                     Old way, keep
sub delete_from_index
{  
   $lock_file = "$statuspath/$rSectsubid.busy";
   &waitIfBusy($lock_file, 'lock');
   
   $delsectsubs    = $rSectsubid;
   $sectionfile    = "$sectionpath/$rSectsubid.idx";
   $newsectionfile = "$sectionpath/$rSectsubid.new";
   $bkpsectionfile = "$sectionpath/$rSectsubid.bkp";
   
   if(-f $sectionfile) {  
      system "cp $sectionfile $bkpsectionfile";
      unlink "$newsectionfile" if(-f $newsectionfile); 
      system "touch $newsectionfile";
      
      open(INSUB, "$sectionfile");
      open(OUTSUB, ">>$newsectionfile");
        
      while(<INSUB>) {
         chomp;
         local($sDocid,$sDocloc) = split(/\^/,$_,2);
##         $do_delete = $DELETEARRAY{$sDocid};      
##         if($do_delete eq 'Y') { 
	if($DELETELIST =~ /$sDocid/) {
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


sub deleteFromIndex_2nd   
{
 local($lSectsubid, $from_updt_subsec_idx)  = @_;
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
     &printDataErr_Continue("Sec400 missing list of deletions. Non-fatal error; continuing with processing. Notify admin. Thanks");
     return;
 }

 $DELETELIST = "";
 
 local($lDocid);
 while(<DEL2LIST>)
  {
    chomp;
    $lDocid = $_;      
    $DELETELIST = "$DELETELIST$lDocid^";    
  } 
 close(DEL2SECT);

 $sectionfile    = "$sectionpath/$lSectsubid.idx";
 $newsectionfile = "$sectionpath/$lSectsubid.new";
 $bkpsectionfile = "$sectionpath/$lSectsubid.bkp";
  
 if(-f $sectionfile) {  
    system "cp $sectionfile $bkpsectionfile";
    unlink "$newsectionfile";
    system "touch $newsectionfile";

    local($lDocid,$lDocloc);
        
    open(INSUB2, "$sectionfile");
    open(OUTSUB2, ">>$newsectionfile");
    
    while(<INSUB2>) {
       chomp;
       ($lDocid,$lDocloc) = split(/\^/,$_,2);  
      
       if($DELETELIST =~ /$lDocid/) { 
       }
       else {
         print OUTSUB2 "$lDocid^$lDocloc\n";
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
 



## 470 SORT INDEX #####

sub pushdata_to_sortArray
{
  if($kDocid ne $docid) {
      $saveDocid = $docid;
      $docid = $kDocid;
      &get_doc_data;
      $docid = $saveDocid;
  }
  
  $kDocloc = 'M' if($kDocloc !~ /[A-Za-z0-9]/);
  $kDocloc = 'A' if($sectsubs =~ /$headlinesSectid|$suggestedSS|$summarizedSS/ and $priority =~ /6/ and $sysdate =~ /2006/);
    
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
  elsif($sortorder =~ /[Dd]/) {
     &get_sort_sysdate;
     $keyfield = "$kDocloc-$kSysdate";
  }
  elsif($sortorder =~ /[A]/) {
     $kPriority = 6;
     $kPriority = (6 - $priority) if($priority =~ /0-6/);
     &get_sort_sysdate;
     $keyfield = "$kDocloc-$kPriority-$kSysdate";
     unlink $kPriority;
  }
  elsif($sortorder eq 'H') {
     $theless_headline = $headline;
     $theless_headline =~ s/^\s+//;
     $theless_headline =~ s/^The //;
     $theless_headline =~ s/^the //;
     $theless_headline =~ s/<i>//g;
     if($theless_headline =~ /\<font/) {
     	($rest, $theless_headline) = split(/>/,$theless_headline,2)
     }
     $theless_headline =~ s/^\s+//;
     $keyfield = "$kDocloc-$theless_headline";
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

 $pubmonth = '00' if( $pubmonth !~ /[1-9]/);
 $pubday   = '00' if( $pubday   !~ /[1-9]/);
 $kPubdate = "$pubyear$pubmonth$pubday";
 
## print "sec475 docid $docid sortorder $sortorder kPubdate $kPubdate<br>\n";
 if($pubyear =~ /^[0-9]{4}$/) {
     if($sortorder =~ /[PDRA]/) {    
        $kPubdate = (30000000 - $kPubdate);
        $kPubdate = "0$kPubdate" if($kPubdate =~ /^9/);
     }
 }
 else {    
     &get_sort_sysdate;
     $kPubdate = $kSysdate;
 }
}

sub get_sort_sysdate
{
     ($sysyear,$sysmonth,$sysday) = split(/-/,$sysdate,3);
     $sysmonth = '00' if( $sysmonth !~ /[1-9]/);
     if($sysmonth =~ /^[0-9]([0-9][0-9])/) {
     	$sysmonth = $1;
     }
     $sysday   = '00' if( $sysday   !~ /[1-9]/);
     if($sysday =~ /^([0-9][0-9])[0-9]/) {
     	$sysday = $1;
     }
     $sysyear  = '0000' if( $sysyear  !~ /^[1-2]/);
     $kSysdate = "$sysyear$sysmonth$sysday";
     if($sortorder =~ /[PDRA]/) {
        $kSysdate = (30000000 - $kSysdate);
        $kSysdate = "0$kSysdate" if($kSysdate =~ /^9/);
     }
}   




#### 00470  SECTIONS CONTROL FILE ###


sub clear_section_ctrl
{
 $default_itemMax = '100';
 $totalItems     = 0;
 $cIdxSectsubid  = "";
 $cWebsite       = "";
 $cSubdir        = "";
 $cPage          = "";
 $cVisable       = "";
 $cPreview       = "";
 $cOrder         = "";
 $cTemplate      = "";
 $cTitleTemplate = "";
 $cTitle         = "";
 $cSubtitle      = "";
 $cBlockquote    = "";
 $cRtCol         = "";
 $cLogo          = "";
 $cHeader        = "";
 $cFooter        = "";
 $cFTPinfo       = "";
 $cMaxItems      = "";
 $cPg1max        = "";
 $cFly           = "";
}

sub split_section_ctrlA
{
 $cSectsubInfo = "";
 ($cSectsubid,$cSectsubInfo) = split(/\`/, $cSectsub);
 &split_section_ctrlC;
}

sub split_section_ctrlB
{
 $cSectsubInfo = "";
 $cSectsubInfo = $CSINDEX{$cSectsubid}; 
 &split_section_ctrlC;
}


sub split_section_ctrlC
{
  &clear_section_ctrl;

##print "470a cSectsubid $cSectsubid cSectsubInfo $cSectsubInfo<br>\n";

##                                  May point to another section for index file 


  if($cSectsubInfo =~ /^>>/) {  
     ($cIdxSectsubid,$cSectsubInfo) = split(/\^/,$cSectsubInfo,2);
     $cIdxSectsubid =~ s/^>>+//g;  ## delete leading arrows
  }
  ($cSubdir,$cPage,$cVisable,$cPreview,$cOrder,$cTemplate,$cTitleTemplate,$cTitle,$cBlockquote,$cRtCol,$cLogo,$cHeader,$cFooter,$cFTPinfo,$cMaxItems,$cFly) 
        = split(/\^/,$cSectsubInfo);
 
##print "sec470c $cSectsubid docfile $cIdxSectsubid .. pg $cPage .. ord-$cOrder .. BRL $cBlockquote$cRtCol$cLogo .. hdr $cHeader .. ftr $cFooter .. ftp $cFTPinfo .. max $cMaxItems .. fly $cFly<br>\n";
## if($cSectsubid =~ /NewsDigest_NewsItem/);
#    May contain another website
  $cWebsite = "popaware";   # defaults
  $cSubdir  = "";
  ($cPage,$cWebsite,$cSubdir) = split(/;/,$cPage,3); 
  
  
  ($cTitle,$cTitle2nd,$cSubtitle) = split(/#/,$cTitle,3) if($cTitle =~ /#/);

  ($cSectid,$cSubid) = split(/_/,$cSectsubid);
  
  $cMaxItems = $default_itemMax if($cMaxItems !~ /[0-9]/);
  
  ($cMaxItems,$cPg1max,$rest) = split(/:/,$cMaxItems,3) if($cMaxItems =~ /:/);
  
  $cPg1max = $cMaxItems if($cPg1max !~ /[0-9]/);

### Order may be different on the first page from that of subsequent pages; esp. the news page  
  $cNextOrder = $cOrder;
  ($cOrder,$cNextOrder) = split(/;/,$cOrder) if($cOrder =~ /;/);
  
  $cOrder = $cNextOrder if($pg_num > 1);
    
## DON'T DO    $cMaxItems = &padCount4("$cMaxItems") if($cMaxItems =~ /[0-9]/);
##  $cPg1max = &padCount4("$cPg1max") if($cPg1max =~ /[0-9]/);
}



########### 480 INDEX CONTENTS OF A DIRECTORY ##############


sub index_suggested_email
{
  $emailpath = "$sectionpath/$emailedSS.idx";
       
  if(-f $emailpath) {
     unlink $emailpath;	
  }
  undef $emailpath;

  opendir(POPMAILDIR, "$sepmailpath");
 
  local(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
  closedir(POPMAILDIR);

  open(NEWSUB, ">$sectionpath/$emailedSS.idx");
  
  foreach $filename (@popnewsfiles) { 
     if(-f "$sepmailpath/$filename" and $filename !~ /debug/) {
          ($docid,$rest) = split(/\.email/,$filename);
          print NEWSUB "$docid\n";
    }      
  }  
  close(NEWSUB);
}


########  500 PAGING  ##########


##  DO PAGE ITEM COUNTS: start count and stop count

## query string:     1^100:10 i.e. pg_num^max:pg1max
## in sections.html : maxitems: 100:10   N:M = stop after 10 on the 1st page
##                   DO NOT PAD!!

##    pg 1: start_count = 0; stop_count = N
##    pg 2on start_count = N + (pg - 2)*M   2-11, 3-111, 4-211
##           stop_count = start_count + M
          
## Also need to calculate total number of pages


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
 elsif($cPg1max =~ /[0-9]/) {
   $pg1max = $cPg1max;
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
 local($doclistname,$itemMax,$tot_items) = @_;
 
 if($tot_items > 0 and tot_items =~ /0-9/) {
 }
 else {
    $tot_items = &total_items($doclistname);
 }
 if($tot_items !~ /[0-9]/ or $tot_items < 2
 or $itemMax !~ /[0-9]/ or $itemMax == 0) {
    $totalPages = 1;	
 }
 else {
   $tot_items = $tot_items - 1;

   ($totalPages) = ($tot_items / $itemMax) + 1;

   ($totalPages,$rest) = split(/\./,$totalPages,2);  
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
   }
   $tot_items = &strip0s_fromCount($tot_items);
   
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
sub print_pages_index
{
 local($pg_num,$sectsubid,$itemMax,$totalItems) = @_;
 local($pg);
 $doclistname = "$sectionpath$slash$sectsubid.idx";
 
 &set_start_stop_count_maxes;  ## we have to this twice - also before start-stop count
  
 $totalPages = &total_pages($doclistname,$itemMax,$totalItems);
  
 if($totalPages > 1) {
    print MIDTEMPL "<font size=1 face=verdana>Pg $pg_num of $totalPages ... &nbsp;&nbsp;\n";
    print MIDTEMPL "<a target=_top href=\"http://www.$cgiSite/cgi-bin/cgiwrap/popaware/article.pl?display_subsection%%%$sectsubid%%1\">1<\/a>.. \n";	
    for($pg=2;$pg<($totalPages);$pg++) {
       if($pg > ($pg_num - 10) and $pg < ($pg_num + 11)) {
          print MIDTEMPL "<a target=_top href=\"http://www.$cgiSite/cgi-bin/cgiwrap/popaware/article.pl?display_subsection%%%$sectsubid%%$pg\">$pg<\/a>  \n";
       }	
    }
    print MIDTEMPL "..<a target=_top href=\"http://www.$cgiSite/cgi-bin/cgiwrap/popaware/article.pl?display_subsection%%%$sectsubid%%$totalPages\">$totalPages<\/a>\n";
    print MIDTEMPL "</font>\n";
 }
}


##### 550 PAGE INFORMATION


sub savePageinfo
{
  $cSectsub = $line;
  &split_section_ctrlA;
               
  if($cPage =~ /[A-Za-z0-9]/) {
##   print "<br><font size=1 face=verdana>460 C $cSectsubid .. pg-$cPage ..V-$cVisable ..P-$cPreview ..O-$cOrder ..templ-$cTemplate ..titltemp-$cTitleTemplate ..Blk-$cBlockquote ..R-$cRtCol L-$cLogo ..H-$cHeader ..F-$cFooter ..FTP-$cFTPinfo</font>\n";
     if($PAGEINFO{$cPage}) {   
     }
     else{    # if a new page, save the FTP info
        $PAGEINFO{$cPage} = "$cFTPinfo";
     }
  }
}


#### 600 SECTSUBS processing (to be put in document item)



##  Need to add parms for both sectsubid and sectsubs; 
##   also for what field we want

sub splitout_sectsub_info
{
  local($lSectsubid) = $_[0];
  local($lDocloc) = "";

  @dSectsubs = split(/;/, $dSectsubs); 

  foreach $dSectsub (@dSectsubs) 
  {
    &split_dSectsub;

    if($lSectsubid =~ /$dSectsubid/) {
       $lDocloc   = $dDocloc;
       $dTemplate = 'straight' if($straight_html eq 'Y');
       last;
    }
  }
  return $lDocloc
}


sub split_rSectsub {
     ($rSectsubid,$rSubinfo) = split(/`/,$rSectsub,2) if($rSectsub);
     ($rSectid,$rSubid) = split(/_/, $rSectsubid) if($rSectsubid);
     
     if($rSubInfo =~ /^\>\>/) {   
        ($rIdxSectsubid,$rSubInfo) = split(/\^/,$rSubInfo,2);
        $rIdxSectsubid =~ s/^\>+//g;  ## delete leading arrows
     }
}


## need to feed this a parameter and return a specific field;
## also remove $saveDtemplate logic

sub split_dSectsub
{
## temporary fix - all subsects the same template
 local($saveDtemplate) = $dTemplate;
 ($dSectsubid,$dDocloc,$dNeardocid,$dTemplate,$dSrcstyle,$dHeadstyle,$dBodystyle,$dCmntstyle,$dFullstyle,$dImagefile,$dImageloc) 
       = split(/`/, $dSectsub,11);
    ($dSectid,$dSubid) = split(/_/, $dSectsubid);
    
 $dTemplate = $saveDtemplate;
 
 $dDocloc = $default_docloc if($dDocloc !~ /[A-Z]/);
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
    
    $iDocloc = &splitout_sectsub_info($rSectsubid) if($dSectsubs);
 }
 else {
    $errmsg = "<br>AUTOSUBMIT 552 - File not found $itempath/$docid.itm <br>\n";
    &printSysErrExit;
    $found_it = "N";
 }
}

#### 620 SECTSUBS

sub do_sectsubs
{
##print "<font size=1 face=\"comic sans ms\" color=\"#666666\">art270b ipform $ipform .. docaction $docaction .. sectsubs $sectsubs .. formSectsub $formSectsub..delsectsubs $delsectsubs .. addsectsubs $addsectsubs</font><br>\n";

  &add_addl_0123sections_subinfo(0,$addsectsubs0) if($addsectsubs0);
  &add_addl_0123sections_subinfo(1,$addsectsubs1) if($addsectsubs1);
  &add_addl_0123sections_subinfo(2,$addsectsubs2) if($addsectsubs2);
  &add_addl_0123sections_subinfo(3,$addsectsubs3) if($addsectsubs3);
  
  if($ipform eq "newArticle") {
     if($body =~ /[A-Za-z0-9]/) {
     	$addsectsubs = $summarizedSS;
     }
     else {
     	$addsectsubs = $suggestedSS;
     }     
  }
  elsif($docaction eq 'D') {
      $delsectsubs = $sectsubs;
      $sectsubs    = $deleteSS;
      $addsectsubs = $deleteSS;
  }
#                if volunteer chose to summarize a chase link item
  elsif($ipform eq "chaseLink" and $body =~ /[A-Za-z0-9]/) {
       $delsectsubs = $sectsubs;
       $delsectsubs = "$sectsubs;$volunteerFP;$volunteerGrist" if($sectsubs != /$volunteerSS/);
       $sectsubs    = $summarizedSS;
       $addsectsubs = $summarizedSS;
  }
  elsif($ipform eq "chaseLink" and $body !~ /[A-Za-z0-9]/) {
       $delsectsubs = "$volunteerFP;$volunteerGrist";
#       $delsectsubs =~  s/^;+//;  #get rid of leading semi-colons
       $sectsubs    = $suggestedSS;
       $addsectsubs = "";
  }
  else {
       &add_del_sectsubs;
  }
    
##print "<font size=1 face=\"comic sans ms\" color=\"#666666\">art270b ipform $ipform .. docaction $docaction .. sectsubs $sectsubs .. formSectsub $formSectsub ..delsectsubs $delsectsubs .. addsectsubs $addsectsubs</font><br>\n";
    	
  $expdate = "0000-00-00" if($expdate !~ /[0-9]/);
 
  if($expdate gt "0000-00-00" and $expdate lt $nowdate and $sectsubs !~ /$expiredSS/) {
   if($docaction eq 'N') {
     $errmsg = "This date has expired - $expdate. Please correct if you wish it to be published.";
     &printBadContinue;
   }
   $delsectsubs = $sectsubs;
   $addsectsubs = $expiredSS;
   $sectsubs    = $expiredSS;
  }
  else {
    &add_subinfo if($docaction ne 'D');
  }
 }
 
  
#### 640 SECTSUBS    simplified version used for selected items

sub add_del_selected_sectsubs
{	
 if(($addsectsubs and $deleteto ne 'Y') or ($delsectsubs =~ /[A-Za-z]/ and $addsectsubs !~ /[A-Za-z]/)) {
    if($sectsubs =~ /$first_addsectsub/ and $moveselected eq 'Y') {
    	$errmsg = "Item $docid already resides in the target section_subsection: $first_addsectsub</font>";
    	$add_error = 'Y';
    	&printBadContinue;
    }
    else {
      $docloc = 'M' if($itemstratus eq 'normal');
##      $docloc = 'A' if($addsectsubs =~ /$headlinesSectid|$suggestedSS|$summarizedSS/ and $priority =~ /6/);
      $sectsubs = "$sectsubs;$first_addsectsub`$docloc";
      $sectsubs =~  s/^;+//;
      
       $redosectsubs = "";

       @sectsubs = split(/;/,$sectsubs);
       foreach $sectsub (@sectsubs) {
          ($sectsubid,$subinfo) = split(/`/,$sectsub);
          if($delsectsubs =~ /$sectsubid/) {
          	 }
          else {
          	$redosectsubs .= ";$sectsub";
          }	
       }     
       $redosectsubs =~  s/^;+//;  #get rid of leading semi-colons
       $sectsubs = $redosectsubs; 
   } 
 }
 
 if($sectsubs !~ /[A-Za-z0-9]/) {
    $sectsubs    = $deleteSS;
    $addsectsubs = $deleteSS;
 }
} 


# 00660     Add to, subtract from existing sectsubs
##          For one-at-a-time item processing
sub add_del_sectsubs
{
 $modsectsubs  = "";
 $redosectsubs = "";
 
 &add_extra_sections;
 
 &delete_sectsubs;
 
 $redosectsubs .= ";$addsectsubs" if($addsectsubs);
 $redosectsubs =~  s/^;+//;  #get rid of leading semi-colons
  
 $sectsubs = $redosectsubs;
 

## 00670  Add sections not shown on document record.

 $addsectsubs .= ";$mthlyItemSS" if($addsectsubs =~ /$newsdigestSS/);
 $addsectsubs =~  s/^;+//;  #get rid of leading semi-colons
 $addsectsubs =~  s/;$//;   #ditto trailing semi-colons	
 
 if($sectsubs !~ /[A-Za-z0-9]/) {
    $sectsubs    = $deleteSS;
    $addsectsubs = $deleteSS;
 }
}

sub add_extra_sections
{
 if(($ipform eq 'suggest' or $docaction eq 'N') and
         $addsectsubs !~ /[A-Za-z0-9]/ and $sectsubs !~ /[A-Za-z0-9]/) {
            $addsectsubs = "$suggestedSS";
 }
 elsif($body =~ /[A-Za-z0-9]/) {
      if($advance eq 'Y' and $secstubs !~ /$newsdigestSS/) {
          $addsectsubs .= ";$newsdigestSS";
      }
      elsif($ipform eq 'summarize' and $secstubs !~ /$newsdigestSS|$summarizedSS/) {
          $addsectsubs .= ";$summarizedSS";
      }
      
      $addsectsubs =~  s/^;+//;
 }

 if($thisSectsub !~ /$suggestedSS/ and $thisSectsub =~ /[a-zA-Z0-9]/) {   ## sectsubs have already been set for Suggested)
    @ckaddsectsubs = split(/;/,$addsectsubs);
    $addsectsubs = "";
    foreach $ckSectsub (@ckaddsectsubs) {
       if($sectsubs =~ /$ckSectsub/ and $ckSectsub =~ /[A-Za-z0-9]/) {
       	 $errmsg = "Cannot add an item twice to the same section_subsection";
       	 &printBadContinue;
       }
       else {
       	 $addsectsubs = "$addsectsubs;$ckSectsub";
       	 $addsectsubs =~  s/^;+//;  #get rid of leading semi-colons
       }
    }
 }
}

##00675

sub delete_sectsubs
{
##          current sectsubs

 @sectsubs = split(/;/,$sectsubs);
 
 $oldArchiveSS     = "ArchivesJan-Apr2002";

 foreach $sectsub (@sectsubs) {

   last if($sectsub !~ /[A-Za-z0-9]/);

   ($sectsubid, $subinfo) = split(/`/, $sectsub);
   ($sectid,$subid) = split(/_/, $sectsubid);
   
   &chk_for_delete;

   if($delete_it eq 'Y') {
        $delsectsubs .= ";$sectsubid";
   }	
   else { 		
        $redosectsubs .= ";$sectsub";  # if not deleted, redo it
        $modsectsubs  .= ";$sectsubid" if($docaction eq 'C');
   }   
 } # end foreach
 
 $delsectsubs  =~  s/^;+//;  #get rid of leading semi-colons
 $redosectsubs =~  s/^;+//; 
 $modsectsubs  =~  s/^;+//; 
 
 undef $delete_it;
 undef $oldArchiveSS;
}

# 677            Delete if delsected from current sections dropdown,
#                or headlines being moved to newsDigest

sub chk_for_delete
{
   $delete_it = 'N';
   
   if(   ($cmd eq "storeform" and $updsectsubs !~ /$sectsubid/)   
   
      or ($sectsubid =~ /$oldArchiveSS/)
      
      or ($sectsubid =~ /$newsdigestSectid/ 
        and $sectsubs =~ /$archiveSectid|$newsScan2Sectid/)
                
      or ($sectid eq $headlinesSectid 
        and $addsectsubs =~ /$summarizedSS|$newsdigestSectid/)
        
      or ($sectsubid =~ /$suggestedSS|$volunteerSS/  
        and $addsectsubs =~ /$summarizedSS|$headlinesSectid|$newsdigestSectid/)
        
      or ($sectsubid =~ /$volunteerSS/  
        and $ipform =~ /chaseLink/ and $pgitemcnt eq '9998' and $fullbody =~ /[A-Za-z0-9]/)
        
      or ($sectsubid =~ /$summarizedSS|$headlinesSectid/  
        and $addsectsubs =~ /$newsdigestSectid/)
                   
      or ($sectsubid =~ /$newsScan2Sectid/  
        and $addsectsubs =~ /$archiveSectid/) )
    {
        $delete_it = 'Y'
    }	
}


sub add_addl_0123sections_subinfo
{
 local($ct0123,$addsectsubs0123) = @_;
 local($first_addsectsub,$rest) = split(/;/,$addsectsubs0123,2);
## print"sect677 ct $ct .. addsectsubs0123 $addsectsubs0123 .. first_addsectsub $first_addsectsub<br>\n";
 local(@asectsubs) = split(/;/,$addsectsubs0123);
 foreach $dSectsub (@asectsubs) {
   &split_dSectsub;
   if($FORM{"docloc_add$ct"} and $first_addsectsub =~ /$dSectsubid/) {
        $dDocloc = $FORM{"docloc_add$ct"};
   }
   else {
     $dDocloc = $default_docloc;
   }
 $addsectsubs .= ";$dSectsubid`$dDocloc";
## $addsectsubs .= ";$dSectsubid`$dDocloc`$dNeardocid`$dTemplate`$dSrcstyle`$dHeadstyle`$dBodystyle`$dCmntstyle`$dFullstyle`$dImagefile`$dImageloc";
## $addsectsubs =~  s/`+$//;   #get rid of trailing ticks
 $addsectsubs =~  s/^;+//;  #get rid of leading semi-colons
 }
}

    
## 00680  Add the docloc, template, and styles to sectsub
##       Doesn't do $addsectsubs0123, which are done above




## 00685  ### Add on TEMPORARY sectsubs 

sub add_temporary_sectsubs {

#                    date for news page and Pop news monthly
 
   $addsectsubs .= ";$newsDateSS" 
      if($addsectsubs =~ /$newsdigestSS/ and $addsectsubs !~ /$newsDateSS/);
   
   $addsectsubs =~  s/^;+//;   #get rid of leading semi-colons
   $delsectsubs =~  s/^;+//;   
   
   if($docaction eq 'N' and $addsectsubs) {
   #                    public log
       @addsectsubs = split(/;/,$addsectsubs);
       foreach $addsectsubid (@addsectsubs) {
         $cSectsubid = $addsectsubid;
         &split_section_ctrlB;
         if($cVisable eq 'P') {
             $addsectsubs .= ";$publogSS";
             last;
         } 
       } #end foreach
    } # end outer if
    
    $addsectsubs =~  s/^;+//;   #get rid of leading semi-colons
}


sub add_subinfo
{   
 $redosectsubs = "";
 $chglocs      = "";
  
 @sectsubs = split(/;/,$sectsubs);

 $fDocloc = "";
 foreach $dSectsub (@sectsubs) {
     &split_dSectsub;
    $fDocloc = $FORM{"docloc_$dSectsubid$pgitemcnt"}; 
    $fDocloc = 'M' if($fDocloc !~ /[A-Z]/);
    
    if($fDocloc and $dDocloc ne $fDocloc) {
        $dDocloc = $fDocloc;
##         if change in docloc, del and add back in with new docloc
        $chglocs .= ";$dSectsubid";    
    }
    elsif($FORM{docloc_add} and $first_addsectsub =~ /$dSectsubid/) {
        $dDocloc = $FORM{"docloc_add"};
    }
##    $redosectsubs .= ";$dSectsubid`$dDocloc`$dNeardocid`$dTemplate`$dSrcstyle`$dHeadstyle`$dBodystyle`$dCmntstyle`$dFullstyle`$dImagefile`$dImageloc";
##    $redosectsubs =~  s/`+$//;   #get rid of trailing ticks
    $redosectsubs .= ";$dSectsubid`$dDocloc";
    $redosectsubs =~  s/^;+//;  #get rid of leading semi-colons

    $chglocs =~  s/^;+//;   #get rid of leading semi-colons
 }

 $sectsubs = $redosectsubs;
}


sub change_sectsubs_for_updt_selected
{
  if($priority  =~ /D/
##            if chaseLink selected and = docid9998, we skipped it above  
##            if chaseLink selected and != 9998, delete it 
   or ($ipform =~ /chaseLink/ and $selitem =~ /Y/ and $pgitemcnt !~ /9998/) ) {
     $delsectsubs = $sectsubs;
     $sectsubs    = $deleteSS;
     $addsectsubs = $deleteSS;
  }
  elsif($cmd =~ /updateCvrtItems/ or $ipform =~ /chaseLink/) {
     $delsectsubs = $convertSS;
     $addsectsubs = $fSectsubs;
     $sectsubs    = "$fSectsubs`$dDocloc";
  }
  else {
     $addsectsubs = "";
     $delsectsubs = "";

     @fSectsubs = split(/;/,$fSectsubs);
     foreach $fSectsub (@fSectsubs) {
        $addsectsubs = "$addsectsubs;$fSectsub" if($sectsubs !~ /$fSectsub/);
     }
     
     @sectsubs = split(/;/,$sectsubs);
     foreach $sectsub (@sectsubs) {
     	$delsectsubs = "$delsectsubs;$sectsub" if($fSectsubs !~ /$sectsub/);
     }     	
     $addsectsubs =~  s/^;+//;
     $delsectsubs =~  s/^;+//;
    
     $sectsubs = $fSectsubs;
     &add_extra_sections;   
     $redosectsubs = ""; 
     &delete_sectsubs;
     $sectsubs = $redosectsubs;
     &add_subinfo;
  }		
}


## 0800 ADD TO INDEX

sub hook_into_system
{
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

 @adddelsectsubs = split(/;/,"$addsectsubs;$delsectsubs;$chglocs");
 
 $saveCsectsub = $cSectsubid;
 
## print "art285a docid $docid cSectsubid $cSectsubid ... add $addsectsubs ..del $delsectsubs ..chg $chglocs <br>\n";
 foreach $rSectsub (@adddelsectsubs)  {
   if($rSectsub) {
     &split_rSectsub;
     $cSectsubid = $rSectsubid;
     &split_section_ctrlB;
     &updt_subsection_index;
   } 
 }

## go back to thisSectsub 
 $cSectsubid = $saveCsectsub;
 &split_section_ctrlB;
}


### 900 UTILTIES

sub clean_index
{
   if($thisSectsub =~ /$emailedSS/) {
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


1;