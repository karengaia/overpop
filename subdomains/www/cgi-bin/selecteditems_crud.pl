#!/usr/bin/perl --

# 2012 April 22 

#        selecteditems_crud.pl - moved from article.pl to display.pl to here

##### 00430 SELECT ITEMS FROM A LIST AND PROCESS ##########

sub updt_select_list_items
{              # called by article.pl
 my($thisSectsub,$ipform) = @_;
 $selected_found = 'N';
 if($ipform !~ /chaseLink/) {
    print "<h3>The following is a list of the items you have selected.</h3><br><br><br>\n";
 }
 $docid9998 = $FORM{docid9998};   # $ipform =~ /chaseLink/
 $pgItemnbr = 1;
 $pgitemcnt = &padCount4($pgItemnbr);

 &get_select_form_values;  # in docitem.pl
 $selitem = 'Y' if($thisSectsub =~ /Suggested_suggestedItem/ and $priority =~ /[D1-6]/);

 local($startTime) = time;

 until($selitem =~ /Z/) {
#### while($pgitemcnt ne '9998') {   ## dummy search - it will never reach 9998

    if($selitem !~ /[YN]/ and $docid !~ /[0-9]/ and !$priority) #there may not be any item 0001
       {}
    elsif($ipform =~ /chaseLink/ and   ## skip if volunteer filled out the form and it has same docid
       $docid eq $docid9998 and
       ($FORM{headline9998} or $FORM{fullbody9998} or $FORM{body9998}) )
       {}
    elsif($priority =~ /[1-6D]/
       or ($ipform =~ /chaseLink/ and $selitem !~ /N/ and $docid !~ /$docid9998/)  ) {
        $form_priority = $priority;   ## save for when we get doc and override
        if($selitem =~ /Y/) {
            $selected_found = 'Y';
            &do_updt_selected;  #in docitem.pl

			# Lets add this $mailfile to a list and unlink after all are processed or at start of next cycle.
			#      unlink $mailfile if($thisSectsub =~ /Suggested_emailedItem/); 
		} 
    }

    if($pgItemnbr ne "" and $pgItemnbr > 0) {
       $pgItemnbr = $pgItemnbr + 1;
       $pgitemcnt = &padCount4($pgItemnbr);
       &get_select_form_values;   # in docitem.pl
       $selitem = 'Y' if($thisSectsub =~ /Suggested_suggestedItem/ and $priority =~ /[D1-6]/);
    }

    exit if(&tooMuchLooping($startTime,120,'art430')); #stop if > 1 minute

 } #while

 if($ipform =~ /chaseLink/ and $selitem =~ /Z/) {
    $pgitemcnt = "9998";
    $thisSectsub = "";
    &get_select_form_values;   # in docitem.pl
    goto &storeform;  ## in docitem.pl -- the last item has no item ct and is as if it were alone and not in the list
 }


print "</font><p><br><br><font face=verdana size=3><b><a href=\"http://$scriptpath/article.pl?display_section%%%$thisSectsub%%%10\">Back to $thisSectsub List</a><br></b></font>\n";

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
       $rSectsubid  = $FORM{addsectsubs};
       &delete_from_index_by_list($rSectsubid,$DELETELIST);  #in indexes.pl
       &DB_delete_from_indexes_by_list ($rSectsubid,$DELETELIST) unless($DB_indexes < 1);
   }

   if($delselected eq 'Y') {
       $rSectsubid  = $FORM{thisSectsub};
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
# print "<html xmlns=\"http://www.w3.org/1999/xhtml\" ><head><title>$owner action on selected items $thisSectsub<\/title>\n";
# print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />\n";
# my $lc_owner = lc($owner);
# $aTemplate = $lc_owner . "Update";
 $aTemplate = $OWNER{oupdatetemplate}; 
 my $ownerformcss = $OWNER{ocsspath};
 print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/$ownerformcss.css\" media=\"Screen\" />\n" 
   if($owner);
 print "</head><body>\n";
 print "<h3>The following is a list of the items you have selected.<h3>\n";
 print "<p>&nbsp;They have been added to $addsectsubs. Sortorder is $sortorder and default is $dOrder</p>\n"
     if($addsectsubs =~ /[A-Za-z0-9]/ and $deleteto ne 'Y');
 print "<p>&nbsp;They have been deleted from $thisSectsub</p>\n"
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

##00460

sub do_selected
{
  &get_doc_data($docid,N);  #in docitem.pl

  &get_more_select_form_values if($ipform =~ /[Uu]pdate|[Uu]pdt/);  ## overrides prior doc values

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


sub select_email
{        #         CAPTURE EMAILED SUGGESTED ARTICLES 
 $rSectsubname = $rSectsubid = $emailedSS;  # Trying to rename sectsubid to sectsubname
 &split_section_ctrlB($rSectsubname);
 $SSid = $cSSid;    # primary key for section on DB
 local($lMaxItems) = $cMaxItems + 1;

 $pgItemnbr = 1;
 $pgitemcnt = &padCount4($pgItemnbr);
 local($startTime) = time;

 $selected = $FORM{"selitem$pgitemcnt"};

 while($selected !~ /Z/ and $pgitemcnt < $lMaxItems) {
### note: this docid is the email docid, not the regular docid
    $selectdocid  = $FORM{"sdocid$pgitemcnt"};
    $selected     = $FORM{"selitem$pgitemcnt"};

    if($selected =~ /Y/) {
         &process_popnews_email($selectdocid);  ## in docitem.pl   XXX
    }


# ZZZZ	print "art2790 del from index ..rSectsubname $rSectsubname ..selectdocid $selectdocid<br>\n";
#print "art770 TURNED OFF FOR TESTING: unlink $mailpath/$selectdocid.itm<br>\n";
    unlink "$mailpath/$selectdocid.itm";      #remove file and remove from Suggested_emailedItem index
#    &delete_from_index($rSectsubname,$selectdocid);  # in sections.pl  # this should be done in process_popnews_email
#    &DB_delete_from_indexes ($SSid,$selectdocid) unless($DB_indexes < 1);

    if($pgItemnbr ne "" and $pgItemnbr > 0) {
       $pgItemnbr = $pgItemnbr + 1;
       $pgitemcnt = &padCount4($pgItemnbr);
    }

    exit if(&tooMuchLooping($startTime,120,'art2801')); #stop if > 1 minute

 } #while

 undef $selectdocid;
 undef $selected;

##  now display the new Section again

print"<meta http-equiv=\"refresh\" content=\"0;url=http://$scriptpath/article.pl?display_section%%%Suggested_suggestedItem%%$userid%10\">";
}

1;