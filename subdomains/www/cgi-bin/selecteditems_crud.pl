#!/usr/bin/perl --

# 2013 Feb 19

#   selecteditems_crud.pl

##### TAKES SELECTED ITEMS FROM A LIST AND PROCESS ; Entry from article.pl ##########

sub updt_select_list_items    # for emailed articles,  we do select_email instead
{              # called by article.pl
 my($listSectsub,$ipform) = @_;
 $DELETELIST = "";
 $selected_found = 'N';
 $index_insert_sth = &DB_prepare_idx_insert(""); #in indexes table; prepare only once
 my $startTime = time;

 if($ipform !~ /chaseLink/) {
    print "<h3>The following is a list of the items you have selected. ...sel15</h3><br><br><br>\n";
 }
 $docid9998 = $FORM{docid9998};   # $ipform =~ /chaseLink/
 $pgItemnbr = 1;
 $pgitemcnt = &padCount4($pgItemnbr);

 &get_select_form_values;  # in docitem.pl
# $selitem = 'Y' if($listSectsub =~ /Suggested_suggestedItem/ and $priority =~ /[D1-7]/);

 until($selitem =~ /Z/ or $pgItemnbr > 100) {
	
    if($selitem !~ /[YN]/ and $docid !~ /[0-9]/ and !$priority) #there may not be any item 0001
       {}
    elsif($ipform =~ /chaseLink/ and   ## skip if volunteer filled out the form and it has same docid
       $docid eq $docid9998 and
       ($FORM{headline9998} or $FORM{fullbody9998} or $FORM{body9998}) )
       {}
    elsif($selitem =~ /Y/) {
        $form_priority = $priority;   ## save for when we get doc and override	
        $selected_found = 'Y';
        &do_updt_selected($listSectsub);  #in docitem.pl
    }

    if($pgItemnbr ne "" and $pgItemnbr > 0) {
       $pgItemnbr = $pgItemnbr + 1;
       $pgitemcnt = &padCount4($pgItemnbr);
       &get_select_form_values;   # in docitem.pl
#       $selitem = 'Y' if($listSectsub =~ /Suggested_suggestedItem/ and $priority =~ /[D1-7]/);
    }

    exit if(&tooMuchLooping($startTime,120,'art430')); #stop if > 1 minute

 } #until

 if($ipform =~ /chaseLink/ and $selitem =~ /Z/) {
    $pgitemcnt = "9998";
    $listSectsub = "";
    &get_select_form_values;   # in docitem.pl
    goto &storeform;  ## in docitem.pl -- the last item has no item ct and is as if it were alone and not in the list
 }

 &deleteFromIndex_deletelist($listSectsub, $from_updt_subsec_idx); #in indexes.pl - uses $DELETED LIST

print "</font><p><br><br><font face=verdana size=3><b><a href=\"http://$scriptpath/article.pl?display_subsection%%%$listSectsub%%%10\">Back to $listSectsub List</a><br></b></font>\n";

 undef $FORM{thisSectsub};
 undef $FORM{addsectsubs};
}

###### AFTER ITEMS ARE SELECTED FROM A LIST - COMES HERE TO PROCESS ##########

sub do_selected_items
{
 $DELETELIST = "";
 &prelim_select_items;   ## get action-selected, sort order

 $pgItemnbr = 1;
 $pgitemcnt = &padCount4($pgItemnbr);

 $selitem = $FORM{"selitem$pgitemcnt"};
 $docid   = $FORM{"sdocid$pgitemcnt"};

 my $startTime = time;

 until($selitem eq 'Z') {
    if($selitem =~ /Y/
       or ($startselect =~ /Y/ and $selected_found =~ /Y/) ) {
      $selected_found = 'Y';
      &do_selected;
    }
    if($pgItemnbr ne "" and $pgItemnbr > 0) {
       $pgItemnbr = $pgItemnbr + 1;
       $pgitemcnt = &padCount4($pgItemnbr);
    }
    $selitem = $FORM{"selitem$pgitemcnt"};
    goto endselitem if($selitem =~ /Z/);
    $docid   = $FORM{"sdocid$pgitemcnt"};
    exit if(&tooMuchLooping($startTime,120,'sel101')); #stop if > 1 minute
 } #until
endselitem:

 if($selected_found eq 'N' and ($moveselected eq 'Y' or $delselected eq 'Y')) {
   &printUserMsg("No item was selected; Hit back button and select an item.");
 }

 if($moveselected eq 'Y') {
    $indexpath = "$sectionpath/$addsectsubs.idx";
##    added docids are already in the array
##     now fill with others already in index
##    &fill_unsorted_array if(-f "$indexpath");
##    &sort_and_write;
##    &sort_subsection if($cOrder !~ /[FL]/);

    &end_mass_add2index;
 }

 if($DELETELIST) {
   if($deleteto eq 'Y') {
       $rSectsubid = $listSectsub = $FORM{'addsectsubs'};
       &delete_from_index_by_list($rSectsubid,$DELETELIST);  #in indexes.pl
       &DB_delete_from_indexes_by_list ($rSectsubid,$DELETELIST) unless($DB_indexes < 1);
   }

   if($delselected eq 'Y') {
       $rSectsubid = $listSectsub = $FORM{'thisSectsub'};
       &delete_from_index_by_list($rSectsubid,$DELETELIST);   # in indexes.pl
       &DB_delete_from_indexes_by_list ($rSectsubid,$DELETELIST) unless($DB_indexes < 1);
   }
 }

 undef $delselected;
 undef %DELETEARRAY;
 undef $unsorted;
 undef $actionselected;
 undef $delselected;
 undef $moveselected;
 undef $deleteto;
 undef $set_skiphandle;

 undef $FORM{actionselected};
 undef $FORM{thisSectsub};
 undef $FORM{addsectsubs};
}

## get action-selected, sort order
sub prelim_select_items
{
 $actionselected = 'N';
 $add_error      = 'N';
 $delselected    = 'N';
 $moveselected   = 'N';
 $deleteto       = 'N';
 $set_skiphandle = 'N';
 $addsectsubs    = "";
 $delflag        = 'N';

 $actionselected = $FORM{actionselected} if($FORM{actionselected});
 $fix_selected   = 'Y' if($actionselected) =~ /fix/;
 $delselected    = 'Y' if($actionselected) =~ /delsource|move/;
 $moveselected   = 'Y' if($actionselected) =~ /move|copy/;
 $deleteto       = 'Y' if($actionselected) =~ /deltarget/;
 $delflag        = 'Y' if($deleteto eq 'Y' or $delselected eq 'Y');
 $set_skiphandle = $FORM{sethandle};
 $addsectsubs    = $FORM{addsectsubs};

 $addsectsubs = "" if($actionselected) =~ /delsource/;

 if($addsectsubs =~ /;/) {
    ($first_addsectsub,$rest) = split(/;/,$addsectsubs,2);
 }
 else {
    $first_addsectsub = $addsectsubs;
 }

 $thisSectsub = $FORM{thisSectsub};
 $listSectsub = $thisSectsub;
 $rSectsubid  = $FORM{thisSectsub} if($moveselected eq 'Y' or $set_skiphandle eq 'Y');
 $fOrder      = $FORM{sortorder};
 $itemstratus = $FORM{itemstratus};
 $startselect = $FORM{startselect};

 $delsectsubs = $FORM{addsectsubs} if($deleteto eq 'Y');
 $delsectsubs = $FORM{thisSectsub} if($delselected eq 'Y');

 $cSectsubid = $FORM{thisSectsub};
 &split_section_ctrlB($cSectsubid);

 $ipform = $FORM{ipform};
 if(($actionselected =~ /delsource|move|copy|deltarget/
    and ($addsectsubs or $delselected or $set_skiphandle eq 'Y'))
    or $actionselected =~ /fix/  )
   {}
 else {
   $errmsg = "Nothing doable selected";
   &printInvalidExit;
 }

 if($addsectsubs =~ /$FORM{thisSectsub}/ and $delselected ne 'Y') {
   $errmsg = "Source and target cannot be the same section_subsection Hit you back button to correct";
   &printInvalidExit;
 }

 $selected_found = 'N';
 $newseqct       = 0;
 $count          = 0;
 print $GLVARS{'std_headtop'} . "<title>$owner action on selected items $thisSectsub<\/title>\n";
 print $GLVARS{'std_meta'};

 $aTemplate = $OWNER{'oupdatetemplate'}; 
 my $ownerformcss = $OWNER{'ocsspath'};
 print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/$ownerformcss.css\" media=\"Screen\" />\n" 
   if($owner);
 print "</head><body>\n";
 print "<h3>The following is a list of the items you have selected. ...sel214<h3>\n";
 print "<p>&nbsp;They have been added to $addsectsubs. Sortorder is $sortorder and default is $dOrder</p>\n"
     if($addsectsubs =~ /[A-Za-z0-9]/ and $deleteto ne 'Y');
 print "<p>&nbsp;They have been deleted from $listSectsub</p>\n"
     if($delselected eq 'Y');
 print "<p>&nbsp;They have been deleted from the target sectsub $delsectsubs</p>\n"
     if($deleteto eq 'Y');
 print "<p>&nbsp;They have had skiphandle set to 'Y'</p>\n"
     if($set_skiphandle eq 'Y');

##  get order of destination section

 if($first_addsectsub =~ /[A-Za-z0-9]/ and $deleteto ne 'Y') {
    &split_section_ctrlB($first_addsectsub);
 }

}

sub do_selected
{
  &get_doc_data($docid,N);  #in docitem.pl

  &get_more_select_form_values if($ipform =~ /[Uu]pdate|[Uu]pdt/);  ## overrides prior doc values

  &add_new_source if($addsource eq 'Y' and $source);  #in source.pl

  $add_error = 'N';
  &add_del_selected_sectsubs if($addsectsubs =~ /[A-Za-z0-9]/ or $delsectsubs =~ /[A-Za-z0-9]/);

  $skiphandle = 'Y' if($set_skiphandle eq 'Y');

  if($fix_selected =~ /Y/) {
##  	 $body = "";
##  	 $region = "";
##       $pubdate = "0000-00-00";
##       $source  = "";
##     $sectsubs = "Impacts_pollution`M";


##     if($sumAcctnum !~ /P0083/) {
##     	$sumAcctnum = 'P0372';
##     }
##     print "37 $docid sumAcctnum $sumAcctnum<br>\n";

##       $chkline = $fullbody;
##       &basic_date_parse;
  }
  my $deletedmsg = "";
  $deletedmsg = 'Yes' if($delflag eq 'Y');
  print "&nbsp;<small>$docid </small>$headline :: deleted?-$deletedmsg<br>\n";
  $DELETELIST = $DELETELIST . "^$docid";
  &write_doc_item($docid);

 if($moveselected eq 'Y' and $add_error eq 'N') {
        $kDocloc = &splitout_sectsub_info($rSectsubid)  if($itemstratus eq 'maintain');
    #     first push 'moved' items
        $kDocid  = $docid;

        &mass_add2index;

        undef $FORM{"selitem$pgitemcnt"};
        undef $FORM{"sdocid$pgitemcnt"};
  }
  
  &clear_doc_variables;
}


sub select_email    #comes here from article.pl
{        #         CAPTURE EMAILED SUGGESTED ARTICLES 
 $rSectsubname = $rSectsubid = $emailedSS;  # Trying to rename sectsubid to sectsubname
 &split_section_ctrlB($rSectsubname);   # in sectsubs.pl - returns 	$id,$seq,$cSectsubid,$fromsectsubid,$cIdxSectsubid,$cSubdir,$cPage,$cCategory,$cVisable,$cPreview,$cOrder,$cPg2order,$cTemplate,$cTitleTemplate,$cTitle,$cAllOr1,$cMobidesk,$cDocLink,$cHeader,$cFooter,$cFTPinfo,$cPg1Items,$cPg2Items,$cPg2Header,$cMore,$cSubtitle,$cSubtitletemplate,$cMenuTitle,$cKeywordsmatch
 $SSid = $cSSid;    # primary key for section on DB
 my $lMaxItems = $cMaxItems + 1;

#	print "doc289 not found - $mailpath/2013-02-19-347-link-1.itm<br>\n" unless(-f "$mailpath/2013-02-19-347-link-1.itm");
#	print "doc290 found - $mailpath/2013-02-19-347-link-1.itm<br>\n" if(-f "$mailpath/2013-02-19-347-link-1.itm");
	
 $pgItemnbr = 1;
 $pgitemcnt = &padCount4($pgItemnbr);
 my $startTime = time;
 $index_insert_sth = &DB_prepare_idx_insert("") if($DB_indexes > 0); #in indexes table; prepare only once

 $selected = $FORM{"selitem$pgitemcnt"};

 print "<div style=\"font-size:70%; font-family:verdana\"><br><b>The following items have been selected</b> ... ... ...  ... sel297<br><br>\n";

 while($selected !~ /Z/ and $pgitemcnt < $lMaxItems) {
### note: this docid is the email docid, not the regular docid
    $selectdocid    = $FORM{"sdocid$pgitemcnt"};
    $selected       = $FORM{"selitem$pgitemcnt"};
    $selectlink     = $FORM{"link$pgitemcnt"};
    $selectpriority = $FORM{"priority$pgitemcnt"};
    last unless($selectdocid);         # go until there blank docied

    if($selected =~ /Y/) {     ## process_popnews_email is in docitem.pl
         &process_popnews_email($selectdocid,$selectlink,$selectpriority,$index_insert_sth)
            unless($selectpriority =~ /D/); 
         print "$selectdocid --- deleted<br>\n" if($selectpriority =~ /D/);
#print "sel310 unlinking $mailpath/$selectdocid.itm<br>\n";
         unlink "$mailpath/$selectdocid.itm";
    }

    if($pgItemnbr ne "" and $pgItemnbr > 0) {
       $pgItemnbr = $pgItemnbr + 1;
       $pgitemcnt = &padCount4($pgItemnbr);
    }

    exit if(&tooMuchLooping($startTime,120,'sel318')); #stop if > 1 minute

 } #while
print "</div>\n";
 undef $selectdocid;
 undef $selected;
##  now display the new Section again
}

1;