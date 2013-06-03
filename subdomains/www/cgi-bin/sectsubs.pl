#!/usr/bin/perl --

# February 2012
#        sectsubs.pl  : maintains sections.html control file and sectsubs table

sub read_sectCtrl_to_array
{
 my $qOrder = $_[0];    #query string qOrder - overrides sectsubs table cOrder
 @SSARRAY = ();
 $SSARRAY{'qOrder'} = $qOrder;

 &clear_section_ctrl;    # set Globals

 &read_sections_control_2array; 

##   special sections that we work with

 $newsdigestSS     = "NewsDigest_NewsItem";
 $publogSS         = "PublicLog_pubLogEntry";
 $deleteSS         = "delete_deleteItem";
 $expiredSS        = "expired_expiredItem";
 $newsdateSS       = "NewsDigest_date";
 $newsmthlySS      = "NewsMthly";
 $newsWeeklySS     = "NewsWeekly_WeeklyItem";
 $mthlyItemSS      = "NewsMthly_MthlyItem";
 $newsIndexSS      = "NewsDigest_newsindex";
 $mobileSS         = "NewsDigest_newsmobile";
 $headlinesSS      = "Headlines_sustainability";
 $headlinesPriSS   = "Headlines_priority";
 $newsHeadlinesSS  = "NewsDigest_headlines";
 $newsAlertsSS      = "NewsDigest_alerts";
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

sub read_sections_control_2array
{
  $CSidx = 0;
  %CSINDEX = {};
  @CSARRAY = ();
  $newsSections = "";

  if($DB_sectsubs eq 1) {
	 &DB_getrows_2array;
  }
  else {
	 &flatfile_getrows_2array;
  }
  $pointsSections = "NewsDigest_pointsSolutions|NewsDigest_pointsImpacts";
  require 'owner.pl';
  &owner_set_sectsubs($ownerSections,$ownerSubs);  # in owner.pl - set globals for $ownerSections,$ownerSubs derived in sub saveNewsSections
}

sub flatfile_getrows_2array
{
   open(SECTIONS, "$sectionctrl");
   while(<SECTIONS>)
   {
	    chomp;
	    $line = $_;
	    if($line =~ /#sectsubid/) { }
	    else {
	       ($id,$seq,$sectsub,$value) = split(/\^/,$line,4);
	       $sectsubinfo = "$id^$seq^$sectsub^$value";
	       $CSINDEX{$sectsub} = $line;
	       $CSARRAY[$CSidx] = $line;
           $CSSEQ{$seq} = 'T';   #sequence numbers should be unique
		   $cSectsub = $line;
		   &split_sectionCtrl($cSectsub);  ## split the section info line into the section variables for the next two subroutines
	       &savePageinfo;
	       &saveNewsSections;
	       $CSidx = $CSidx + 1;
	       $line = "";
	    }
    }
    close(SECTIONS);
    undef $savepage;
}

sub DB_getrows_2array
{
 my $ssline = "";
 my $ss_sql = "SELECT sectsubid,seq,sectsub,fromsectsubid,fromsectsub,subdir,page,category,visable,preview,order1,pg2order,template,titletemplate,title,allor1,mobidesk,doclink,header,footer,ftpinfo,pg1items,pg2items,pg2header,more,subtitle,subtitletemplate,menutitle,keywordsmatch FROM sectsubs ORDER BY ABS(seq) ASC;";
 my $ss_sth = $dbh->prepare($ss_sql) or die("Couldn't prepare statement: ".$ss_sth->errstr);	

 if($ss_sth) {
    $ss_sth->execute() or die "Couldn't execute sectsubs table select statement: ".$ss_sth->errstr;
    if ($ss_sth->rows == 0) {
    }
    else {
	    while( ($sectsubid,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate, $title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch) 
	          = $ss_sth->fetchrow_array() ) 
	    {
		  $ssline = "$sectsubid^$seq^$sectsub^$fromsectsubid^$fromsectsub^$subdir^$page^$category^$visable^$preview^$order1^$pg2order^$template^$titletemplate^$title^$allor1^$mobidesk^$doclink^$header^$footer^$ftpinfo^$pg1items^$pg2items^$pg2header^$more^$subtitle^$subtitletemplate^$menutitle^$keywordsmatch";
		  $cSectsub = $ssline;
		  ($id,$seq,$sectsub,$value) = split(/\^/,$ssline,4);
		  $sectsubinfo = "$id^$seq^$sectsub^$value";
          $CSINDEX{$sectsub} = $ssline;
          $CSARRAY[$CSidx] = $ssline;
		  $cSectsub = $ssline;
		  &split_sectionCtrl($ssline);  ## split the section info line into the section variables for the next two subroutines	      
          &savePageinfo;
	      &saveNewsSections;
	      $CSidx = $CSidx + 1;
	      $ssline = "";
	   }
	}
	$ss_sth->finish() or die "DB sectsubs failed finish";
 }
 else {
    print "Couldn't prepare sectsubs table query<br>\n";
 }
}

sub clear_section_ctrl
{                                    #Set Globals
 $ckItemcnt = 0;    ## ck for max
 $pgitemcnt = "";   ##page
 $pg1Max    = 0;
 $pg2Max    = 0;
 $start_count = '000001';
 $ckItemnbr = 1;
 $ckItemcnt = &padCount6($ckItemnbr);
 $default_itemMax = '100';
 $totalItems     = 0;
 $seq            = 0;
 $sectsub        = "";
 $fromsectsubid  = 0;
 $fromsectsub    = "";
 $cIdxSectsubid  = "";
 $cWebsite       = "";
 $cSubdir        = "";
 $cPage          = "";
 $cCategory      = "";
 $cVisable       = "";
 $cPreview       = "";
 $cOrder         = "";
 $cPg2order      = "";
 $cTemplate      = "";
 $cTitleTemplate = "";
 $cTitle         = "";
 $cSubtitle      = "";
 $cAllOr1        = "";
 $cMobidesk      = "";
 $cDoclink       = "";
 $cHeader        = "";
 $cFooter        = "";
 $cFTPinfo       = "";
 $cMaxItems      = "";
 $cPg1Items      = "";
 $cPg2Items      = "";
 $cPg2Header     = ""; 
 $cMore          = "";
 $cSubtitle      = "";
 $cSubtitletemplate = "";
 $cMenuTitle     = "";
 $cKeywordsmatch = "";
 $cPg1max        = "";
 $cFly           = "";
}

sub get_section_ctrl {
	my $thisSectsub = $_[0];
	&split_section_ctrlB($thisSectsub);
}

sub split_section_ctrlB
{
 my($sectsubname) = $_[0];
 $sectsubinfo = $CSINDEX{$sectsubname};
 &split_sectionCtrl($sectsubinfo);
}

sub split_sectionCtrl
{
	my($sectsubinfo) = $_[0];
	&clear_section_ctrl;
	($id,$seq,$cSectsubid,$fromsectsubid,$cIdxSectsubid,$cSubdir,$cPage,$cCategory,$cVisable,$cPreview,$cOrder,$cPg2order,$cTemplate,$cTitleTemplate,$cTitle,$cAllOr1,$cMobidesk,$cDocLink,$cHeader,$cFooter,$cFTPinfo,$cPg1Items,$cPg2Items,$cPg2Header,$cMore,$cSubtitle,$cSubtitletemplate,$cMenuTitle,$cKeywordsmatch)
	      = split(/\^/,$sectsubinfo);
	($cSectid,$cSubid) = split(/_/,$cSectsubid,2);
	  $cSSid = $id;
		
#print "sec787 ..id $id ..seq $seq ..sectsub $cSectsubid ..fromsectsubid $fromsectsubid ..fromsectsub $cIdxSectsubid ..cSubdir $cSubdir ..cPage $cPage ..cCategory $cCategory ..cVisable $cVisable ..cPreview $cPreview ..cOrder $cOrder ..cPg2order $cPg2order ..cTemplate $cTemplate ..cTitleTemplate $cTitleTemplate ..cTitle $cTitle ..cAllOr1 $cAllOr1 cMobidesk $cMobidesk ..cDoclink $cDocLink ..cHeader $cHeader ..cFooter $cFooter ..cFTPinfo $cFTPinfo ..cPage1Items $cPg1Items ..cPg2Items $cPg2Items ..cPage2Header $cPg2Header ..cMore $cMore ..cSubtitle $cSubtitle ..cSubtitletemplate $cSubtitletemplate ..cMenuTitle $cMenuTitle ..cKeywordsmatch $cKeywordsmatch<br>\n";	
	$cPg2Items = $cPg1Items if($cPg2Items == 0);
	
	if($pg_num eq 1 and $cPg1Items =~ /[A-Za-b0-9]/) {
		$cMaxItems = $cPg1Items;
	}
	elsif($pg_num > 1 and $cPg2Items =~ /[A-Za-z0-9]/) {
		$cMaxItems = $cPg2Items;
		$cOrder = $cPg2order;
	}
	else {
		$cMaxItems = $default_itemMax;
	}
	if($cOrder =~ /A-Za-z0-9/) {}
	else {
#          $cOrder = $default_order ;
    }
    $cCategory = &trim($cCategory);  #found in common.pl
 
	$SSARRAY{'id'}            = $id;
	$SSARRAY{'seq'}           = $seq;
	$SSARRAY{'cSectsubid'}    = $cSectsubid;
	$SSARRAY{'fromsectsubid'} = $fromsectsubid;
	$SSARRAY{'cIdxSectsubid'} = $cIdxSectsubid;
	$SSARRAY{'cSubdir'}       = $cSubdir;
	$SSARRAY{'cPage'}         = $cPage;
	$SSARRAY{'cCategory'}     = $cCategory;
	$SSARRAY{'cVisable'}      = $cVisable;
	$SSARRAY{'cPreview'}      = $cPreview;
	$SSARRAY{'cOrder'}        = $cOrder;
	$SSARRAY{'cPg2order'}     = $cPg2order;
	$SSARRAY{'cTemplate'}      = $cTemplate;
	$SSARRAY{'cTitleTemplate'} = $cTitleTemplate;
	$SSARRAY{'cTitle'}         = $cTitle;
	$SSARRAY{'cAllOr1'}        = $cAllOr1;
	$SSARRAY{'cMobidesk'}      = $cMobidesk;
	$SSARRAY{'cDocLink'}       = $cDocLink;
	$SSARRAY{'cHeader'}        = $cHeader;
	$SSARRAY{'cFooter'}        = $cFooter;
	$SSARRAY{'cFTPinfo'}       = $cFTPinfo;
	$SSARRAY{'cPg1Items'}      = $cPg1Items;
	$SSARRAY{'cPg2Items'}      = $cPg2Items;
	$SSARRAY{'cPg2Header'}     = $cPg2Header;
	$SSARRAY{'cMore'}          = $cMore;
	$SSARRAY{'cSubtitle'}      = $cSubtitle;
	$SSARRAY{'cSubtitletemplate'} = $cSubtitletemplate;
	$SSARRAY{'cMenuTitle'}     = $cMenuTitle;
	$SSARRAY{'cKeywordsmatch'} = $cKeywordsmatch;
}

sub ck_headlines_priority_not_used {   #from article.pl
  my ($sectsubs,$priority) = @_;
  if($sectsubs =~ /Headlines_priority/) {
     $sectsubs = $headlinesSS;
     $priority = "6" unless($priority =~ /[1-7]/);
     $docloc_news = "A" if($priority =~ /7/);    # priority 7 is the same as docloc (stratus) = "A"
     $docloc_news = "B" if($priority =~ /6/);
# headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
	 return("T");
  }
  else {
	 return("");
  }	
}

sub get_sectsubid
{
  my $sectsubname = $_[0];
  if($DB_sectsubs > 0) {
	 $id = &DB_get_sectsubid
  }
  elsif($CSINDEX{$sectsubname}) {
     $sectsubinfo = $CSINDEX{$sectsubname};
     &split_sectionCtrl($sectsubinfo);
  }
  else {
     $id = 0;
  }
  return($id);
}

sub DB_get_sectsubid
{
 my $sectsubname = $_[0];
 my $sth = $dbh->prepare( 'SELECT sectsubid FROM sectsubs where sectsub = ?' );
 $sth->execute($sectsubname);
 my $SSid = $sth->fetchrow_array();
 $sth->finish();
 $SSid = 0 unless($SSid);
 return($SSid);
}

sub DB_get_sectsubinfo
{
 my($sth,$sectsub) = @_;
 if($sth =~ /prepare/) {
	my $sth = $dbh->prepare( 'SELECT * FROM sectsubs where sectsub = ?' );
	return($sth)
 }
 else {
	$sth->execute($sectsub);
	my @row = $sth->fetchrow_array();
	$sth->finish();
	return(@row);
 }
}

sub savePageinfo
{
  if($cPage =~ /[A-Za-z0-9]/) {
##   print "<br>460 C $cSectsubid .. pg-$cPage ..V-$cVisable ..P-$cPreview ..O-$cOrder ..templ-$cTemplate ..titltemp-$cTitleTemplate ..AllOr1-$cAllOr1 ..R-$cMobidesk L-$cDoclink ..H-$cHeader ..F-$cFooter ..FTP-$cFTPinfo\n";
     if($PAGEINFO{$cPage}) {
     }
     else{    # if a new page, save the FTP info
        $PAGEINFO{$cPage} = "$cFTPinfo";
     }
  }
}

	##          get the page(s) 
sub get_pages
{
 $chksectsubs = "$addsectsubs;$sectsubs;$delsectsubs";
 if($chksectsubs) {
    @chksectsubs = split(/;/,$chksectsubs);
    foreach $rSectsub (@chksectsubs) {
       &split_rSectsub;
       $cSectsubid = $rSectsubid;
       &split_section_ctrlB($cSectsubid);
       $pagenames = "$pagenames;$cPage" if($pagenames !~ /$cPage/ and $PAGEINFO{$cPage} =~ /ftpdefault/);
    }
  $pagenames =~  s/^;+//;  #get rid of leading semi-colons
 }
}

sub saveNewsSections
{ 
  my $oSScategory = $OWNER{'oSScategory'}; 
  $oSScategory = trim($oSScategory);
  if($cCategory eq 'N') {
	if($newsSections) {
	   $newsSections .= '|'.$cSectsubid;
    }
    else {
	   $newsSections .= $cSectsubid;
    }
  }
  elsif($cCategory eq $oSScategory) {
	 my $l_owner = "";
	 if($ownerSections) {
	    $ownerSections .= ';'.$cSectsubid;
     }
     else {
	    $ownerSections .= $cSectsubid;
     }

     ($l_owner, $sub) = split(/_/,$cSectsubid,2);
	 if($ownerSubs) {
	     $ownerSubs = "$ownerSubs;$sub";
	 }
	 else {
		   $ownerSubs = $sub;
	 } 
  }
}

###### ADD, SUBTRACT SECTSUBS ON A DOCITEM  #####

sub do_sectsubs
{			

# 1st, add missing sectsub (from doclist this docitem was on)
 if($docaction ne 'N' and $sectsubs !~ /$listSectsub/ and !$newsprocsectsub and !$pointssectsub and !$ownersectsub) {
      $sectsubs = "$sectsubs;$listSectsub`M";
  }

 # If New
 $docaction = 'N' unless($docid);

 if($owner) {
     &do_ownersectsub;     # outside user stuff
     return;
  }

 if($docaction eq 'N') {
     $addsectsubs = $sectsubs;
     $delsectsubs = "";
     return;
 }

 # 2nd, delete if 'Delete' requested

  if($docaction eq 'D') {
      $delsectsubs = $sectsubs;
      $sectsubs    = $deleteSS;
      $addsectsubs = $deleteSS;
      return;
  }

 # 3rd, do expired - DOES NOT WORK

  $expdate = "0000-00-00" if($expdate !~ /[0-9]/);
  if($expdate > "0000-00-00" and $expdate lt $nowdate and $sectsubs !~ /$expiredSS/) {
     if($docaction eq 'N') {
      $errmsg = "This date has expired - $expdate. Please correct if you wish it to be published.";
       &printBadContinue;
     }
     $delsectsubs = $sectsubs;
     $addsectsubs = $expiredSS;
     $sectsubs    = $expiredSS;
  }

 # 4th, delete duplicates and NA's ---

  if($sectsubs =~ /[A-Za-z0-9]/) {   # get rid of duplicates
   	 $oldsectubs = "";
	 @sectsubs = split(/;/, $sectsubs);
	 foreach $sectsub (@sectsubs) {
        $oldsectsubs .= ";$sectsub" if($oldsectubs !~ /$sectsub/ and $sectsub !~ /NA/);
     }
     $oldsectsubs =~  s/^;+//;  # get rid of leading ;
  }

# 5th - Process News sectsubs - Headlines, Summarize, Suggested, Archives, etc
     
   &do_newsprocsectsub;  # uses oldsectsubs from above
   &do_pointssectsub;    # uses sectsubs from do_newsprocsectsub


 # 6th - add additional sectsubs

  &add_addl_0123sections_subinfo(0,$addsectsubs0) if($addsectsubs0);
  &add_addl_0123sections_subinfo(1,$addsectsubs1) if($addsectsubs1);
  &add_addl_0123sections_subinfo(2,$addsectsubs2) if($addsectsubs2);
  &add_addl_0123sections_subinfo(3,$addsectsubs3) if($addsectsubs3);

 # 7th - add some, delete some sectsubs
  &add_del_sectsubs;
	
 # 8th, if no sectsubs, go to default

  if($addsectsubs !~ /[0-9A-Za-z]/
	and $updsectsubs !~ /[0-9A-Za-z]/
	and $newsprocsectsub !~ /[0-9A-Za-z]/
	and $pointssectsub !~ /[0-9A-Za-z]/
	and $sectsubs !~ /[0-9A-Za-z]/
	and $addsectsubs0  !~ /[0-9A-Za-z]/
	and $addsectsubs1  !~ /[0-9A-Za-z]/
	and $addsectsubs2  !~ /[0-9A-Za-z]/
	and $addsectsubs3  !~ /[0-9A-Za-z]/) {
	  $sectsubs = "$headlinesSectid`M";
	  $addsectsubs = "$headlinesSectid`M";
	  return;
   }

# 9th - add subinfo - like stratus

  &add_subinfo;
}

# New types (categories) are mutually exclusive: news type sections:

sub do_newsprocsectsub { # NewsDigest, Headlines, Suggested, Summarized, Archives
  my($newschg) = 'Y';
  my($newsfound) = 'N';
  if($oldsectsubs =~ /[A-Za-z0-9]/) {
	@sectsubs = split(/;/, $oldsectsubs);
    $sectsubs = "";   #we will rebuild sectsubs
	foreach $sectsub (@sectsubs) {
		($dSectsubname,$docloc,$lifonum) = split(/`/, $sectsub,3);   # get rid of stratus A...M...Z
		if($newsSections =~ /$dSectsubname/) { # Find the sectsub that is a News type
			if($dSectsubname =~ /$newsprocsectsub/) { #If no change,
				$newschg = 'N';
				$sectsubs .= ";$dSectsubname`$docloc`$lifonum" if($sectsubs !~ /$dSectsubname/); # add back in to list of sectsubs
			}
			else { # Delete the old News type SS - we can only have one
				$delsectsubs .= ";$dSectsubname" if($delsectsubs !~ /$dSectsubname/);
			} #end inner if/else
			$newsfound = 'Y';
		} #end middle if

		else {  # This sectsub is not a News Type or CWSP or Maidu; it is not deleted, so add back in to rebuild $sectsubs
			$sectsubs .= ";$dSectsubname`$docloc`$lifonum" if($sectsubs !~ /$dSectsubname/);
		} #end middle else
	} #end foreach
  } # end outer if
#  There are no existing sectsubs
  elsif($newsprocsectsub !~ /NA/ and $newsprocsectsub) {
     $addsectsubs .= ";$newsprocsectsub" if($addsectsubs !~ /$newsprocsectsub/);
  }

  if($newsfound eq 'N' and $newsprocsectsub !~ /NA/ and $newsprocsectsub) {
     $addsectsubs .= ";$newsprocsectsub" if($addsectsubs !~ /$newsprocsectsub/);
  }
  elsif( $newsprocsectsub !~ /NA/ and $newsprocsectsub and $sectsubs !~ /$newsprocsectsub/) {
		if($newschg eq 'Y') {
			$addsectsubs .= ";$newsprocsectsub" if($addsectsubs !~ /$newsprocsectsub/);
		}
		else {
			$updsectsubs .= ";$newsprocsectsub" if($updsectsubs !~ /$newsprocsectsub/);
		}
  }

 $sectsubs =~     s/^;+//;    #remove leading ;
 $addsectsubs =~  s/^;+//;    #remove leading ;
 $updsectsubs =~  s/^;+//;    #remove leading ;
 $delsectsubs =~  s/^;+//;    #remove leading ;
}

sub do_pointssectsub { # Talking Points: Impacts and Solutions
  my($pointsschg) = 'Y';
  my($pointsfound) = 'N';
  my $savesectsubs = $sectsubs;     # Start with sectsubs from do_newsprocsectsub
  if($savesectsubs) {
	@sectsubs = split(/;/, $savesectsubs);
    $sectsubs = "";   #we will rebuild sectsubs
	foreach $sectsub (@sectsubs) {
		($dSectsubname,$docloc,$lifonum) = split(/`/, $sectsub,2);   # get rid of stratus A...M...Z
		if($pointsSections =~ /$dSectsubname/) { # Find the sectsub that is a Points type
			if($dSectsubname =~ /$pointssectsub/) { #If no change,
				$pointschg = 'N';
				$sectsubs .= ";$dSectsubname`$docloc`$lifonum" if($sectsubs !~ /$dSectsubname/); # add back in to list of sectsubs
			}
			else { # Delete the old Points type SS - we can only have one
				$delsectsubs .= ";$dSectsubname" if($delsectsubs !~ /$dSectsubname/);
			} #end inner if/else
			$pointsfound = 'Y';
		} #end middle if
		else {  # This sectsub is not a Points Type; it is not deleted, so add back in to rebuild $sectsubs
			$sectsubs .= ";$dSectsubname`$docloc`$lifonum" if($sectsubs !~ /$dSectsubname/);
		} #end middle else
	} #end foreach
  } # end outer if
#  There are no existing sectsubs
  elsif($pointssectsub !~ /NA/ and $pointssectsub =~ /[A-Za-z0-9]/) {
     $addsectsubs .= ";$pointssectsub" if($addsectsubs !~ /$pointssectsub/);
  } # end outer elseif
  if($pointsfound eq 'N' and $pointssectsub !~ /NA/ and $pointssectsub =~ /[A-Za-z0-9]/) {
     $addsectsubs .= ";$pointssectsub" if($addsectsubs !~ /$pointssectsub/);
  }
  elsif( $pointssectsub !~ /NA/ and $pointssectsub =~ /[A-Za-z0-9]/
    and $sectsubs !~ /$pointssectsub/) {
		if($pointschg eq 'Y') {
			$addsectsubs .= ";$pointssectsub" if($addsectsubs !~ /$pointssectsub/);
		}
		else {
			$updsectsubs .= ";$pointssectsub" if($updsectsubs !~ /$pointssectsub/);
		}
  }

 $sectsubs =~     s/^;+//;    #remove leading ;
 $addsectsubs =~  s/^;+//;    #remove leading ;
 $updsectsubs =~  s/^;+//;    #remove leading ;
 $delsectsubs =~  s/^;+//;    #remove leading ;
}

sub do_ownersectsub { # CSWP, Maidu, any owner other than WOA
 $ownerchg = 'N'; 
                      
 if($docaction eq 'N') {
	$addsectsubs = $ownersectsub; 
	$sectsubs = $ownersectsub;
 }
 elsif($docaction eq 'D') {
	print "docaction $docaction ..ownersectsub $ownersectsub<br>\n";
    $delsectsubs = $ownersectsub;
    $sectsubs    = $deleteSS;
    $addsectsubs = $deleteSS;
    return;
 }
 else {		                        
	 if($sectsubs) {
	     if($ownersectsub eq $sectsubs) {
		    $ownerchg = 'N';
	     }
	     else {
	        $delsectsubs = $sectsubs;
		    $addsectsubs = $ownersectsub;
		 }
	 }
	 else {
		   $addsectsubs = $ownersectsub;
	
	 }
	 $sectsubs = $ownersectsub;
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
##      $docloc = 'A' if($addsectsubs =~ /$headlinesSectid|$suggestedSS|$summarizedSS/ and $priority =~ /7/);
      $sectsubs = "$sectsubs;$first_addsectsub`$docloc";
      $sectsubs =~  s/^;+//;

       $redosectsubs = "";

       @sectsubs = split(/;/,$sectsubs);
       foreach $sectsub (@sectsubs) {
          ($sectsubname,$subinfo) = split(/`/,$sectsub);
          if($delsectsubs =~ /$sectsubname/) {
          	 }
          else {
          	$redosectsubs .= ";$sectsub`$subinfo";
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

 &delete_sectsubs;

 $redosectsubs .= ";$addsectsubs" if($addsectsubs);
 $redosectsubs =~  s/^;+//;  #get rid of leading semi-colons
 $sectsubs = $redosectsubs;

## Add sections not shown on document record.
##### $addsectsubs = "$mobileSS;$newsIndexSS;$newsHeadlinesSS;$addsectsubs" if($addsectsubs =~ /$newsdigestSS/);
 $addsectsubs =~  s/^;+//;  #get rid of leading semi-colons
 $addsectsubs =~  s/;$//;   #ditto trailing semi-colons

 if(!$sectsubs) {
    $sectsubs    = $deleteSS;
    $addsectsubs = $deleteSS;
 }
}

sub add_extra_sections
{
 if(($ipform eq 'suggest' or $docaction eq 'N') and
         $addsectsubs !~ /[A-Za-z0-9]/ and $sectsubs !~ /[A-Za-z0-9]/) {
            $addsectsubs = "$headlinesSectid" if($sectsubs !~ $addsectsubs);
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

 if($listSectsub and ($listSectsub !~ /$suggestedSS/ and $ipform =~ /selectUpdt_Top/)) {   ## sectsubs have already been set for Suggested)
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

 my $oSScategory = $OWNER{oSScategory}; 

 my @sectsubs = split(/;/,$sectsubs);
 foreach $xsectsub (@sectsubs) {
   my $sectsub = $xsectsub;
   last if(!$sectsub);

   my($sectsubname,$subinfo) = split(/`/, $sectsub);
   &split_section_ctrlB($sectsubname);    # get $cCategory
   if(($cmd eq "storeform" and $updsectsubs !~ /$sectsubname/ 
#           and $newsSections !~ /$sectsubname/ and $cswpSections !~ /$sectsubname/ and $maiduSections !~ /$sectsubname/)
           and $newsSections !~ /$sectsubname/ and $ownerSections !~ /$sectsubname/)
     or ($cCategory eq 'N' and $newschg eq 'Y' and $newsprocsectsub !~ /$sectsubname/)
     or ($cCategory eq $oSScategory and $ownerchg eq 'Y' and $ownerprocsectsub !~ /$sectsubname/) ## NO $ownerchg or $ownerprocsectsub FOUND
     or ( $pointschg eq 'Y' and $pointssectsub !~ /$sectsubname/)) {
   }
   else {
        $redosectsubs .= ";$sectsub" if($redosectsubs !~ /$sectsubname/);  # if not deleted, redo it
        $modsectsubs  .= ";$sectsubname" if($docaction eq 'C' and $modsectsubs !~ /$sectsubname/);
   }
 } # end foreach

 $delsectsubs  =~  s/^;+//;  #get rid of leading semi-colons
 $redosectsubs =~  s/^;+//;
 $modsectsubs  =~  s/^;+//;
}

sub add_addl_0123sections_subinfo
{
 my($ct0123,$addsectsubs0123) = @_;
 my($first_addsectsub,$rest) = split(/;/,$addsectsubs0123,2);
## print"sect677 ct $ct .. addsectsubs0123 $addsectsubs0123 .. first_addsectsub $first_addsectsub<br>\n";
 my(@asectsubs) = split(/;/,$addsectsubs0123);
 foreach $dSectsub (@asectsubs) {
    my($dSectsubname,$xSectid,$xSubid,$dDocloc,$dLifonum) = &split_sectsub($dSectsub);
#   &split_dSectsub;    # No lifonum will be found here, but will be below
   if($FORM{"docloc_add$ct"} and $first_addsectsub =~ /$dSectsubname/) {
        $dDocloc = $FORM{"docloc_add$ct"};
   }
   $dDocloc = 'M' unless($dDocloc);
   $dLifonum = "";

   $addsectsubs .= ";$dSectsubname`$dDocloc`$dLifonum";
   $addsectsubs =~  s/`+$//;   #get rid of trailing ticks
   $addsectsubs =~  s/^;+//;  #get rid of leading semi-colons
 }
}

sub add_temporary_sectsubs {
#                    date for news page and Pop news monthly
   $addsectsubs .= ";$newsDateSS"
      if($addsectsubs =~ /$newsdigestSS/ and $addsectsubs !~ /$newsDateSS/);

   $addsectsubs =~  s/^;+//;   #get rid of leading semi-colons
}


sub add_subinfo
{
 $redosectsubs = "";
 $chglocs      = "";

 my @sectsubs = split(/;/,$sectsubs);

 my $fDocloc = "";           # d = document on flatfile (old); f = form (new); ss = old on sectsubs
 foreach $dSectsub (@sectsubs) {
	my($dSectsubname,$xsectid,$xsubid,$dDocloc,$xlifonum) = &split_sectsub($dSectsub);
#   &split_dSectsub;
    my $ssDocloc = $FORM{"docloc_$dSectsubname$pgitemcnt"};

    if($dSectsubname =~ /$newsprocsectsub/) {
	   $fDocloc = $docloc_news;
    }
    elsif($ssDocloc) {
        $dDocloc = $ssDocloc;
    }
    elsif($docloc_add and $first_addsectsub =~ /$dSectsubname/) {
        $fDocloc = $docloc_add;
    }

    if($fDocloc and $dDocloc ne $fDocloc) {
        $dDocloc = $fDocloc;
##         if change in docloc, del and add back in with new docloc
        $chglocs .= ";$dSectsubname";
    }
    $dDocloc = 'M' if($dDocloc !~ /[A-Z]/ and $cAllOr1 =~ /all/);
    $dDocloc = 'd' if($dDocloc !~ /[A-Z]/  and $cAllOr1 =~ /1only/); ## 'd' = please display

    $fLifonum = $FORM{"lifonum_$dSectsubname$pgitemcnt"};
	if($fLifonum and $fLifonum ne $dLifonum ) {
		$dLifonum = $fLifonum;
		$chglocs .= ";$dSectsubname" if($chglocs !~ /$dSectsubname/);
	}
	
    $redosectsubs .= ";$dSectsubname`$dDocloc`$dLifonum";
    $redosectsubs =~  s/^;+//;  #get rid of leading semi-colons

    $chglocs =~  s/^;+//;   #get rid of leading semi-colons
 }

 $sectsubs = $redosectsubs;
}


sub change_sectsubs_for_updt_selected
{
   if($priority  =~ /D/
   or ($ipform =~ /chaseLink/ and $selitem =~ /Y/ and $pgitemcnt !~ /9998/) ) {
     $delsectsubs = $listSectsub;
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
     &add_subinfo;
  }
}


###############

sub add_updt_sectsub_values 
{
  $addchgsectsub    = $FORM{"addchgsectsub$pgitemcnt"};
  $sectsub          = $FORM{"sectsub$pgitemcnt"};
  if($addchgsectsub !~ /[AUD]/ or (!$sectsub)) {
     printBadContinue('Missing Sectsub name or not add(A) or update(U)');
     return();
  }
  $sectsubid        = $FORM{"sectsubid$pgitemcnt"};
  $ss_seq           = $FORM{"ss_seq$pgitemcnt"};
  $fromsectsubid    = $FORM{"fromsectsubid$pgitemcnt"};
  $fromsectsub      = $FORM{"fromsectsub$pgitemcnt"};
  $subdir           = $FORM{"subdir$pgitemcnt"};
  $page             = $FORM{"page$pgitemcnt"};
  $category         = $FORM{"category$pgitemcnt"};
  $visable          = $FORM{"visable$pgitemcnt"};
  $preview          = $FORM{"preview$pgitemcnt"};
  $order1           = $FORM{"order1$pgitemcnt"};
  $pg2order         = $FORM{"pg2order$pgitemcnt"};
  $template         = $FORM{"template$pgitemcnt"};
  $titletemplate    = $FORM{"titletemplate$pgitemcnt"};
  $title            = $FORM{"title$pgitemcnt"};
  $allor1           = $FORM{"allor1$pgitemcnt"};
  $mobidesk         = $FORM{"mobidesk$pgitemcnt"};
  $doclink          = $FORM{"doclink$pgitemcnt"};
  $header           = $FORM{"header$pgitemcnt"};
  $footer           = $FORM{"footer$pgitemcnt"};
  $ftpinfo          = $FORM{"ftpinfo$pgitemcnt"};
  $pg1items         = $FORM{"pg1items$pgitemcnt"};
  $pg2items         = $FORM{"pg2items$pgitemcnt"};
  $pg2header        = $FORM{"pg2header$pgitemcnt"};
  $more             = $FORM{"more$pgitemcnt"};
  $subtitle         = $FORM{"subtitle$pgitemcnt"};
  $subtitletemplate = $FORM{"subtitletemplate$pgitemcnt"};
  $menutitle        = $FORM{"menutitle$pgitemcnt"};
  $keywordsmatch    = $FORM{"keywordsmatch$pgitemcnt"};
  if($addchgsectsub =~ /A/) {	
	 if($CSINDEX{$sectsub}) {
		printBadContinue("This sectsub $sectsub already exists. Sectsub must be unique. Can't add it.");
		return;
	 }
	 if($CSSEQ{$ss_seq}) {
		printBadContinue("This sectsub $sectsub sequence $ss_seq already exists. Seq must be unique. Can't add it.");
		return;
	 }
     my $ssadd_sth = $dbh->prepare("REPLACE INTO sectsubs (seq,sectsub,fromsectsubid,fromsectsub,subdir,page,category,visable,preview,order1,pg2order,template,titletemplate,title,allor1,mobidesk,doclink,header,footer,ftpinfo,pg1items,pg2items,pg2header,more,subtitle,subtitletemplate,menutitle,keywordsmatch) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

     $ssadd_sth->execute($ss_seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page, 
			$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate, 
			$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,
			$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch);
	 $sectsubid = $dbh->do("SELECT MAX(sectsubid) FROM sectsubs");
  }
  elsif($addchgsectsub =~ /U/) {   #update
	 if(!$CSINDEX{$sectsub}) {
		printBadContinue("This sectsub $sectsub does not exist. Can't update it.");
		return;
	 }
     my $ss_update_sql = 
	"UPDATE sectsubs SET seq = ?,sectsub = ?,fromsectsubid = ?, " .
	"fromsectsub = ?,subdir = ?,page = ?,category = ?,visable = ?, " .
	"preview = ?, order1 = ?, pg2order = ?, template = ?, titletemplate = ?, " .
	"title = ?, allor1 = ?, mobidesk = ?, doclink = ?, header = ?, " .
	"footer = ?, ftpinfo = ?, pg1items = ?, pg2items = ?, pg2header = ?, " .  
	"more = ?, subtitle = ?, subtitletemplate = ?, menutitle = ?, keywordsmatch = ? " .
	"WHERE sectsubid = ?;";
		
    my $ss_updt_sth = $dbh->prepare($ss_update_sql);
	$ss_updt_sth->execute($ss_seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page, 
			$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate, 
			$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,
			$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch,$sectsubid) 
		or die "DB Update sectsub $sectsub failed<br>\n";
  }
  elsif($addchgsectsub =~ /D/) {  
	 if(!$CSINDEX{$sectsub}) {
		printBadContinue("This sectsub $sectsub does not exist. Can't delete it.");
		return;
	 }
     my $ss_delete_sql = "DELETE FROM sectsubs WHERE sectsubid = ?";
     my $ss_delete_sth = $dbh->prepare($ss_delete_sql);
	 $ss_delete_sth->execute($sectsubid)
		or die "DB delete sectsub $sectsub ..sectsubid $sectsubid failed<br>\n";
  }
  return($sectsubid);
}




#### 200 PRINTING FOR ARTICLE.PL

#########  for printing sections dropdowns from a template

## if templage contains [NEWS_ONLY_SECTIONS]
sub get_news_only_sections
{
  if(!$dSectsubs) {
	 if($ipform =~ /newArticle/) {
	    $dSectsubs = "Headlines_sustainability"
	 }
     else {
        $dSectsubs = "Suggested_suggestedItem";
     }
  }
  $dSectsubs = "Headlines_priority" if($dSectsubs =~ /Headlines_sustainability/ and $priority =~ /[6-7]/);
  my (@xsects) = split(/\|/,$newsSections);  #newsSections created in sub read_sectCtrl_to_array
  my $checked = "";
  my $current_newsSS = "";
  my $docloc = ""; 
  foreach $xsect (@xsects) {
	$checked = "";
	
    if($dSectsubs =~ /$xsect/ ) {	
	   $checked = "checked";
	   $current_newsSS = $xsect;
	} # end if
	
	&print_output('M',"<input type=\"radio\" name=\"newsprocsectsub\" value=\"$xsect\" $checked ><b><small>$xsect</small></b><br>\n");
  } # end outer foreach
  &print_output('M',"<input type=\"radio\" name=\"newsprocsectsub\" value=\"$emailedSS\"><b><small>$xsect</small></b><br>\n");
  &print_output('M',"<input type=\"radio\" name=\"newsprocsectsub\" value=\"NA\"><b><small>None of the above</small></b><br>\n");

  my $op = <<STRATUSEND2;
  <table><tr><td valign="top">
  <cite class="verdana"><b>Item stratification</b> <br>
  M=middle (normal)<br>&nbsp;</cite></td>
STRATUSEND2
  &print_output('M',$op);
  &print_output('M',"<td><select name=\"docloc_news\">\n"); # goes with whatever newsprocsectsub chosen
  $docloc_news = 'M' unless($docloc_news);
  $ck_docloc = $docloc_news;
  &print_doc_order;
  &print_output('M',"<\/td><\/tr><\/table>\n");
  if($current_newsSS =~ /[A-Za-z0-9]/ and $action ne 'new' and $lifonum and $lifonum > 0) {
	  $SSid = &get_SSid($current_newsSS);
	  my($docloc,$lifonum) = &DB_get_lifo_stratus($SSid,$docid); #For now we won't use stratus; later move this up to do docloc
      &print_output('M', "<cite class=\"verdana\">Change <b>LIFOnum</b>&nbsp; <\/cite><input type=\"text\" name=\"lifonum_$current_newsSS\" value=\"$lifonum\" size=\"6\" maxlength=\"10\"><br>\n");
      &print_output('M', "<cite>Cannot change Lifonum if changing News Section above</cite><br>\n");
  }
}


## if templage contains [POINTS_SECTIONS]
sub get_points_sections
{
  my (@xsects) = split(/\|/,$pointsSections);  #pointsSections created in sub read_sectCtrl_to_array
  my $checked = "";
  my $current_pointsSS = "";
  my $docloc = ""; 
  foreach $xsect (@xsects) {
 	 $checked = "";
     if($dSectsubs =~ /$xsect/) {	
	    $checked = "checked";
	    $current_pointsSS = $xsect;
	 } # end if
	 my($rest,$pointtype) = split("points",$xsect,2);
     &print_output('M',"<input type=\"radio\" name=\"pointssectsub\" value=\"$xsect\" $checked ><cite>$pointtype</cite>&nbsp;&nbsp;");
  } # end outer foreach
}


sub get_owner_sections
{
  my $ownerSections = $_[0];
### change this to get_owner_sections and $ownerSections; put owner code in sectsubs table (sections flatfile)
### where category is.
  my $expSections = "$ownerSections;$deleteSS";
  my (@xsects) = split(/\;/,$expSections);  #newsSections created in sub read_sectCtrl_to_array
  my $currentSS = "";
  my $docloc = "";

#  $ownerDefaultSS = "CWSP_Calendar";

  $dSectsubs = trim($OWNER{odefaultSS}) unless($dSectsubs);
  foreach $xsect (@xsects) {
    $xsect =~ s/`+$//;  #get rid of trailing tic marks
    $xsect = trim($xsect);
    $selected = "";
    if($dSectsubs eq $xsect) {	
	   	$selected = "selected=\"selected\"";
	   $currentSS = $xsect;
	} # end if
	my $option = $xsect;
	$option = 'Deleted' if($xsect =~ /delete/);
	&print_output('M',"<option value=\"$xsect\" $selected >$option</option>\n");
  } # end outer foreach

  if($currentSS and $action ne 'new' and $lifonum and $lifonum > 0) {
	  $SSid = &get_SSid($currentSS);
	  my($docloc,$lifonum) = &DB_get_lifo_stratus($SSid,$docid); #For now we won't use stratus; later move this up to do docloc
      &print_output('M',"<cite class=\"verdana\">Change <b>LIFOnum</b>&nbsp; <\/cite><input type=\"text\" name=\"lifonum_$currentSS\" value=\"$lifonum\" size=\"6\" maxlength=\"10\"><br>\n");
      &print_output('M',"<cite>Cannot change Lifonum if changing CSWP Section above</cite><br>\n");
  }
}


## if template contains [CURRENT_SECTIONS]

sub get_current_sections
{
 $first_time = 0;
 my @lSectsubs = split(/;/,$dSectsubs);  #d = current data; l=local
 foreach $lSectsub (@lSectsubs) {
	  my($lSectsubname,$xSectid,$xSubid,$ldocloc,$xlifonum) = &split_sectsub($lSectsub);
	  $dSectsubname = $lSectsubname;
	  $docloc = $lDocloc;

      my $SSid = &get_SSid($dSectsubname);
	  my ($iDocloc,$iLifonum) = &DB_get_lifo_stratus($SSid,$docid) if($DB_indexes > 0); # replaces docloc and lifonum above (lifonum is empty above)
      $docloc = $iDocloc if($iDocloc);
      $lifonum = $iLifonum if($iLifonum);

      &split_section_ctrlB($dSectsubname);  #get section control variables
      $first_time = $first_time + 1;
      if($first_time eq 1) {
          &print_output('M',"<font color=\"#666666\" size=1 face=verdana>If you do not have admin access<br> to a section, none of the above<br>will be available for that section.</font>\n")
             if($operator_access !~ /[AB]/);
      }
      &ck_visability;

      if($cCategory eq 'N') { #Skip News sections which are handled with the radio buttons
      }
      else {
         if($tVisable eq 'Y' and $tPreview eq 'Y') {
             &print_current_section;
         }
         else {
             &print_cant_change_section;
        }
     } #end else
 } #end foreach

}

sub print_current_section
{
  my ($checked) = "checked=\"checked\"";

  my $op = <<END;
  <hr>
  <font size="2" face="verdana">
  <input type="checkbox" name="updsectsubs" value="$dSectsubname" $checked><b>$dSectsubname</b><br>
END

  &print_output('M',$op);
  &print_end_sections;
}

sub print_end_sections
{
  &print_output('M',"<table><tr><td><font size=\"1\" face=\"verdana\">\n");
  if($dSectsubs) {
     &print_output('M',"<select name=\"docloc_$dSectsubname\">\n");
     $ck_docloc = $docloc;
  }
  else {
     &print_output('M',"<select name=\"docloc_add\">\n");
     $ck_docloc = 'M';
  }

  &print_doc_order;

  ny $op = <<STRATUSEND;
     </td><td valign="top">
     <cite class="verdana"><b>Item stratification</b> <br>
      M=middle (normal)</cite></td></tr>
STRATUSEND

  &print_output('M',$op);

  if($dSectsubid =~ /[A-Za-z0-9]/ and $lifonum and $lifonum > 0) {
    &print_output('M',"<input type=\"text\" name=\"lifonum_$dSectsubid\" value=\"$lifonum\" size=\"8\"><br>\n");
    &print_output('M',"<cite class=\"verdana\">Change LIFO num<\/cite>\n");
  }

  &print_output('M',"<\/td><\/tr><\/table>\n");
}

sub print_cant_change_section
{
  &print_output('M',"<input type=\"hidden\" name=\"updsectsubs\" value=\"$dSectsubid\">\n");
  &print_output('M',"<input type=\"hidden\" name=\"docloc_$dSectsubid\" value=\"$docloc\">\n");
  &print_output('M',"<input type=\"hidden\" name=\"lifonum_$dSectsubid\" value=\"$lifonum\">\n");
}


#####


## if template contains [NEWS_SECTION] ----- NOT USED ANY MORE

sub get_news_section    ### see get_news_only_sections
{
 $dSectsubid = "$newsdigestSS";
 if($aTemplate =~ /docUpdate/) {
	&catnum = 'N';
    &print_stratus_add;
 }

 &print_current_section(add); ## print current sections
}


## if template contains [ADD_COUNTRIES]

sub get_country_sections_old
{
 &get_addl_sections(C,1,'');
}


## if template contains [ADD_NON_COUNTRIES]

sub get_nonCountry_sections_old
{
 &get_addl_sections(O,2,'');
}

## if template contains [WORKLIST_SECTIONS]

sub get_other_sections_old
{
 &get_addl_sections(W,3,'');
}


sub get_addl_sections
{
 my($catCode,$catnum,$info)  = @_;

 $catnum =  "" if($catnum eq '_');
 if($info eq 'I') {
 }
 elsif($template =~ /docUpdate/) {
   &print_output('M', "<select size=\"15\" multiple name=\"addsectsubs$catnum\">\n");
 }
 elsif($template !~ /selectUpdt|commonDropdowns/) {
   my $op = <<SELECTEND;
    <font size="1"><select size="10" multiple name="addsectsubs">
SELECTEND
   &print_output('M',$op);
 }

 $save_sectsubinfo = $CSINDEX{$rSectsubid};

 foreach $cSectsub (@CSARRAY) {
      &split_sectionCtrl($cSectsub);
      if(($catCode eq 'X' and $cCategory eq 'X')
      or ($catCode eq 'C' and  $cCategory eq 'C')
      or ($catCode eq 'A' and $operator_access =~ /[ABCDP]/ and $cCategory =~ /w|ad/)
      or ($catCode eq 'O' and $cCategory !~ /N|X|C|w|ad/)
      or $catCode eq '_') {
         if(&ck_visability) {
	         if($info eq 'I') {  
				 &print_output('M',"<option value=\"$cSectsub\">$cSectsubid</option>\n");
		     }
		     else {
		         &print_output('M',"<option value=\"$cSectsubid\">$cSectsubid</option>\n");
		     }
         }
      }
 } #end foreach

 if($info eq 'I') {
 }
 else {
	my $op = <<ENDSELECT;
	  <option value="NA">NA</option>
ENDSELECT
    &print_output('M', $op);

	if($aTemplate =~ /docUpdate/) {
	     &print_stratus_add;
	}
 }

 &split_sectionCtrl($save_sectsubinfo);

} #end sub

sub print_stratus_add {
  &print_output('M',"<br></font><font face=\"comic sans ms\" size=\"1\">\n");
  my $op = <<ENDHERE;
   (the following tools do not work with multiple adds <br> in this category. Add one at a time
   if <br> using other than default)</font><br>

      <table width="70%"><tr><td><cite class="verdana"><b>Item stratification</b> <br>
      &nbsp;&nbsp;&nbsp;M=middle (normal)</cite></td>
ENDHERE
  &print_output('M',$op);
  &print_output('M',"<td><select name=\"docloc_add$catnum\">\n");


  $ck_docloc = $default_docloc;
  &print_doc_order;
  &print_output('M',"<\/tr><\/td><\/table>\n");
}

sub print_stratus_current {     # NOT USED ???
  my $op = <<ENDHERE;
      <br></font>
      <table width="70%"><tr><tr><td><font face="verdana" size="1">Stratus M=default</font></td>
ENDHERE
  &print_output('M',$op);
  &print_output('M',"<td><font size=\"1\" face=\"verdana\"><select name=\"docloc_$rSectsub\">\n");
  $ck_docloc = $default_docloc;
  &print_doc_order;
  &print_output('M',"<\/td><\/tr><\/table>\n");
}

sub print_doc_order   ## stratus
{
 @doc_order_codes =
 ("A", "B", "C", "D", "E", "F",
  "M",
  "U", "V", "W", "X", "Y", "Z");
  $ck_docloc = 'M' unless($ck_docloc =~ /[A-Z]/);
  foreach $tdocloc(@doc_order_codes) {
     if($tdocloc =~ /$ck_docloc/) {
          &print_output('M',"<option value=\"$tdocloc\" selected>$tdocloc</option>\n");
     }
     else {
          &print_output('M',"<option value=\"$tdocloc\">$tdocloc</option>\n");
     }
  }
  &print_output('M',"</select>\n");
}


#                 called from article.pl
sub php_do_pages {
  &print_output('M',"<table width=\"100%\" border=\"0\">\n");
  my $prev_pagename = "";	
  $saveCsectsub = $cSectsub;
  foreach $cSectsub (@CSARRAY) {
      &split_sectionCtrl($cSectsub);

      &ck_visability;
      if($tVisable eq 'Y' and ($tPreview eq 'Y')) {
          if($cPage and $cPage ne $prev_pagename) {
              if($cSectsubid =~ /$newsdigestSS/) { #news digest has both newsItem and index
                   &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$scriptpath/article.pl?display_subsection%%%$cSectsubid\">News fly</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$cgiSite/prepage/savePagePart.php?$cPage%$cSectsubid\">Save $cPage</a></td></tr>\n");

                   &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$cgiSite/prepage/index.php?$cSectsubid\">Index view</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$cgiSite/php/saveindex.php?$cPage\">Save index</a></td></tr>\n");
              }
              elsif($cVisable =~ /mo/) { # mobile does not go through php 
	               &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$scriptpath/article.pl?display_subsection%%%NewsDigest_newsmobile\">NewsMobile fly</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$scriptpath/moveutil.pl?move%$cPage\">Move $cPage</a></td></tr>\n");
              }
              elsif($cVisable =~ /hd/) {   # head info is invisible unless it is in a textbox box - But it doesn't work because TB becomes part of meta or cssjs
	               &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$scriptpath/article.pl?display_subsection%%%$cSectsubid%\">$cSectsubid fly</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$cgiSite/prepage/savePagePart.php?$cPage%$cSectsubid\">Save $cPage</a></td></tr>\n");
              }
              elsif($cVisable =~ /pp/) {   # page parts other than head parts (mostly Page 1) 
	               &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$scriptpath/article.pl?display_subsection%%%$cSectsubid%\">$cSectsubid fly</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$cgiSite/prepage/savePagePart.php?$cPage%$cSectsubid\">Save $cPage</a></td></tr>\n");
              }
              else {            # all sections (page 2) 
                   &print_output('M',"<tr><td><a target=\"_blank\" href=\"http://$cgiSite/prepage/viewsection.php?$cSectsubid\">$cPage view</a></td>\n");
                   &print_output('M',"<td><a target=\"_blank\" href=\"http://$cgiSite/php/savesection.php?$cPage%$cSectsubid\">Save/View</a></td></tr>\n");	
              }
              $prev_pagename = $cPage;
          }  #cPage
      } # visable        
   }
   &print_output('M',"</tr></table>\n");
   
   $cSectsub = $saveCsectsub;  ## restore previous sectsub and split it
   &split_sectionCtrl($cSectsub);
}

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
##                           pp = visable page part (menu, quotes, meta, cssjs, etc)
##                           mo = mobile
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

   $tVisable = 'Y' if($cVisable =~ /[VP]/ or $cVisable =~ /pp|mo|hd/
          or ($cVisable =~ /[STB]/ and $operator_access =~ /[ABCD]/ and $user_visable eq 'Y')
          or ($cVisable eq 'A' and $operator_access =~ /[ABCD]/)
          or ($cVisable eq 'H' and $operator_access =~ /[ABCDP]/) );

   $tPreview = 'Y' if($cPreview =~ /A/ and ($operator_access =~ /[AB]/ or $op_permissions =~ /$cSectid/));
   $tPreview = 'Y' if(   ($cPreview =~ /[DR]/ and $operator_access =~ /[ABC]/)
                      or ($operator_access =~ /D/ and $op_permissions =~ /$cSectid/) );
   $tPreview = 'Y' if($template =~ /selectUpdt|commonDropdowns|article_control/);
   return(1) if(($tPreview eq 'Y' and $tVisable eq 'Y') or $template =~ /selectUpdt|commonDropdowns|article_control/);
   return(0); #otherwise not visable
}

#                 called from article.pl
sub prt_move_mauve_pages
{
 $saveCsectsub = $cSectsub;
 foreach $cSectsub (@CSARRAY) {
     &split_sectionCtrl($cSectsub);
     &ck_visability;
     if($tVisable eq 'Y' and $tPreview eq 'Y') {  
	     &print_output($printmode,"<a target=\"_blank\" href=\"http://$cgiSite/php/savesection.php?$cPage%$cSectsubid\">$cSectsubid</a><br>\n");
     }
 } #end foreach

  $cSectsub = $saveCsectsub;  ## restore previous sectsub and split it
  &split_section_ctrlA;
} #end sub


sub get_SSid
{
 my($sectsubname) = $_[0];
 my $sectsubinfo = $CSINDEX{$sectsubname};
 &split_sectionCtrl($sectsubinfo);
 return($cSSid);
}

sub getpagename {
	my($sectsubname) = $_[0];
	$cSectsubInfo = $CSINDEX{$sectsubname};
	&split_sectionCtrl($cSectsubInfo);
	return $cPage;
}


sub import1st_sectsubs
{          #### One time only
	
  $seq = 0;
  $ctr = 0;
  $default_itemmax = 7;

  $sections_import = "$controlpath/sections_import.html";

print "<b>Import sectsubs</b> sectionctrl $sectionctrl<br>\n";
print "Goes to $sections_import, then to sectsubs.rb (import)<br><br>\n";

  unlink $sections_import if(-f $sections_import);
  open(SSIMPORT, ">$sections_import");

  open(SECTIONS, "$sectionctrl") or die("Can't open sections control");
  while(<SECTIONS>)
  {
    chomp;
    $line = $_;

    &clear_sectsubs_variables;

	next if($line =~ /sectid_subid/ or $line =~ /sectsubid^seq^sectsub/);
	
	if($pass =~ /pass1/) {
		&do_1st_pass;
	}
    else {
	    &do_2nd_pass;	
    }
	
	$ctr = $ctr + 1;	
	$seq = $ctr * 10;
	$sectsubid = $ctr;

    $sql_line = "$sectsubid^$seq^$sectsub^$fromsectsubid^$fromsectsub^$subdir^$page^$category^$visable^$preview^$order^$pg2order^$template^$titletemplate^$title^$allor1^$mobidesk^$doclink^$header^$footer^$ftpinfo^$pg1items^$pg2items^$pg2header^$more^$subtitle^$subtitletemplate^$menutitle^$keywordsmatch\n";

    print SSIMPORT $sql_line;

    print "<br>$line <br>\n";
    print "$sql_line <br>\n";
  }
  close(SECTIONS);
  close(SSIMPORT);
}

sub clear_sectsubs_variables {
	$cSectsubid = "";
	$fromsectsubid = "";
	$cIdxSectsubid = "";
	$cSubdir = "";
	$cPage = "";
	$cCategory = "";
	$cVisable = "";
	$cPreview = "";
	$cOrder = "";
	$cPg2order = "";
	$cTemplate = "";
	$cTitleTemplate = "";
	$cTitle = "";
	$cAllOr1 = "";
	$cMobidesk = "";
	$cDocLink = "";
	$cHeader = "";
	$cFooter = "";
	$cFTPinfo = "";
	$cPg1Items = "";
	$cPg2Items = "";
	$cPg2Header = "";
	$cMore = "";
	$cSubtitle = "";
	$cSubtitletemplate = "";
	$cMenuTitle = "";
	$cKeywordsmatch = "";
}

sub old_clear_sectsubs_variables {
	$id = 0;
	$fromsectsubid = 0;
	$subdir = "";
	$page = "";
	$category = "";
	$visable = "";
	$preview = "";
	$order = "";
	$template = "";
	$titletemplate = "";
	$title = "";
	$allor1 = "";
	$mobidesk = "";
	$doclink = "";
	$header = "";
	$footer = "";
	$maxitems = 0;
	$pg1limit = 0;
	$ftpinfo = "";
	$printlimit = "";
	$pg2header = "";
	$more = "";
	$fromsectsub = "";
	$subtitle = "";
	$subtitletemplate = "";
	$menutitle = "";
	$keywordsmatch = "";
}

sub do_1st_pass_not_used {
	($sectsub,$sectsubinfo) = split(/\`/, $line);

    if($sectsubinfo =~ /^>>/) {
        ($fromsectsub,$sectsubinfo) = split(/\^/,$sectsubinfo,2);
         $fromsectsub =~ s/^>>+//g;  ## delete leading arrows
    }
	
	($subdir,$page,$category,$visable,$preview,$order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$maxitems,$fly,$ftptoinfo,$pg2header)
	               = split(/\^/,$sectsubinfo);
	    
	($page,$website,$subdir) = split(/;/,$page,3) if($title =~ /;/);  ## why two subdir?
	   
	($title,$title2nd,$subtitle) = split(/#/,$title,3) if($title =~ /#/);

	if($maxitems =~ /:/) {
	   ($pg2items,$pg1items,$rest) = split(/:/,$maxitems,3);
    }
    else {
	   $pg1items = $maxitems;
	}

	($order,$pg2order) = split(/;/,$order) if($order =~ /;/);
	$pg2order = $order if($pg2order !~ /[0-9]/);
}

sub do_2nd_pass_not_used {
	#	($subdir,$page,$category,$visable,$preview,$order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$maxitems,$fly,$ftptoinfo,$pg2header)
	($id,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch)
	   = split(/\^/,$line);	
}


sub create_sectsubs
{
	$dbh = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS sectsubs");

$sql = <<ENDSECTSUBS;
	CREATE TABLE sectsubs (
		sectsubid smallint unsigned not null,
		seq smallint not null, 
		sectsub varchar(100) not null,
		fromsectsubid smallint default 0, 
		fromsectsub varchar(100), 
		subdir varchar(100), 
		page varchar(50), 
		category char(2) default "N", 
		visable char(1)  default "V", 
		preview char(1) default "D", 
		order1 char(1) default "P", 
		pg2order char(1) default "P", 
		template varchar(50), 
		titletemplate varchar(50), 
		title varchar(100), 
		allor1 varchar(10) default "all", 
		mobidesk varchar(10) default "desk",
		doclink varchar(10) default "doclink",
		header varchar(50),
		footer varchar(50),
		ftpinfo varchar(50),
		pg1items tinyint unsigned default 7,
		pg2items tinyint unsigned default 70,
		pg2header varchar(100),
		more tinyint unsigned,
		subtitle varchar(100),
		subtitletemplate varchar(50),
		menutitle varchar(60),
		keywordsmatch varchar(300)
)
ENDSECTSUBS

$sth2 = $dbh->prepare($sql);
$sth2->execute();
$sth2->finish();
}

sub export_sectsubs
{
  $dbh = &db_connect() if(!$dbh);

print "Exporting sectsubs to sections.html and saving old in sections_bkp.html<br>\n";

  $sth_exportSS = $dbh->prepare("SELECT * FROM sectsubs ORDER BY seq");
  if(!$sth_exportSS) {
	 print "Failed in prepare sectsubs export at prepare command, sec89 " . $sth_exportSS->errstr . "<br>\n";
	 exit;	
  }
  $sth_exportSS->execute();
  if (!$sth_exportSS->rows) {
	 print "Unexpected error in sectsubs export at rows command, sec139 " . $sth_exportSS->errstr . "<br>\n";
	 exit;
  }
  else {
	  my $sectionsbkppath = "$expcontrolpath/sections_bkp.html";
	  my $sectionspath    = "$expcontrolpath/sections.html";
	  unlink $sectionexppath if(-f $sectionexppath);
	  sleep (3);
	  print "File was not deleted - $sectionsexppath<br>\n" if(-f $sectionexppath);
	  unlink($sectionsbkppath)  if(-f $sectionbkppath);
	  sleep (3);
	  print "File was not deleted - $sectionsbkppath <br>\n" if(-f $sectionbkppath);
	
	  my $sectionsexppath = "$controlpath/sections_exported.html";
	  open(EXPSS, ">$sectionsexppath");
      my $line = "#sectsubid^seq^sectsub^fromsectsubid^fromsectsub^subdir^page^category^visable^preview^order1^pg2order^template^titletemplate^title^allor1^mobidesk^doclink^header^footer^ftpinfo^pg1items^pg2items^pg2header^more^subtitle^subtitletemplate^menutitle^keywordsmatch\n";
      print EXPSS "$line";  # first line is headers
      while (my @row = $sth_exportSS->fetchrow_array()) { # print data retrieved
         my ($sectsubid,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch)
         = @row;
         $line = "$sectsubid^$seq^$sectsub^$fromsectsubid^$fromsectsub^$subdir^$page^$category^$visable^$preview^$order1^$pg2order^$template^$titletemplate^$title^$allor1^$mobidesk^$doclink^$header^$footer^$ftpinfo^$pg1items^$pg2items^$pg2header^$more^$subtitle^$subtitletemplate^$menutitle^$keywordsmatch\n";	
         print EXPSS "$line";
         print "$line<br\n";
      }
      close(EXPSS);
	  $sth_exportSS->finish() or die "DB failed finish";

	  system "cp $sectionspath $sectionsbkppath";   # back up old sections.html path
	  sleep (3);
	  print "File was not copied to bkp - $sectionsbkppath <br>\n" unless(-f $sectionbkppath);
	
      unlink($sectionspath);
 	  sleep (3);
 	  print "File was not deleted - $sectionspath<br>\n" if(-f $sectionpath);
 	  system "cp $sectionsexppath $sectionspath";   # exported sections becomes new sections.html
 	  sleep (3);
 	  print "File was not copied to sections file - $sectionspath <br>\n" unless(-f $sectionspath);
  }
}

sub import_sectsubs
{ 
  $dbh = &db_connect() if(!$dbh);
  print "<b>Import sectsubs</b> sectionctrl $sectionctrl<br>\n";
  print "<b>DON'T FORGET TO CHANGE SECTSUBID TO PRIMARY AND AUTOINCREMENT AFTER IMPORTING 1ST TIME ONLY!- ALTER table sectsubs add primary key (sectsubid)</b><br>\n";

  my $sectionsctrl = "$controlpath/sections.html";
  my $sth = $dbh->prepare( "INSERT INTO sectsubs (sectsubid,seq,sectsub,fromsectsubid,fromsectsub,subdir,page,category,visable,preview,order1,pg2order,template,titletemplate,title,allor1,mobidesk,doclink,header,footer,ftpinfo,pg1items,pg2items,pg2header,more,subtitle,subtitletemplate,menutitle,keywordsmatch)
VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )" );

  open(SECTIONS, "$sectionctrl") or die("Can't open sections control");
  while(<SECTIONS>)
  {
    chomp;
    $line = $_;
	next if($line =~ /sectsubid\^seq/);
	($id,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch)
	   = split(/\^/,$line);
	$sth->execute($id,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch);								
print "<br>$line <br>\n";
  }
  $sth->finish;
  close(SECTIONS);
}

1;