#!/usr/bin/perl --

push @INC, "/www/overpopulation.org/subdomains/www/cgi-bin";  ## telana
require 'common.pl';
require 'contributor.pl';
require 'sepmail.pl';
require 'docitem.pl';
require 'controlfiles.pl';

&get_site_info;        ## in common.pl
&set_date_variables;

 $sectsubs = "NewsDigest_NewsItem`M;NewsDigest_NewsItem`M;WhatWorks_healthCare`M";
 if($sectsubs =~ /[A-Za-z0-9]/) {
	local($oldsectubs) = "";
	@sectsubs = split(/;/, $sectsubs); 
	foreach $sectsub (@sectsubs) {  # get rid of duplicates
        $oldsectubs .= ";$sectsub" if($oldsectubs !~ /$sectsub/); 
    }
    $oldsectsubs =~  s/^;+//;  # get rid of leading ;
 }
print "sec27 oldsectsubs $oldsectsubs ... sectsubs $sectsubs\n";
exit;

sub do_sectsubs
{
 $sectsubs = "NewsDigest_NewsItem`M;NewsDigest_NewsItem`M;WhatWorks_healthCare`M";
 if($sectsubs =~ /[A-Za-z0-9]/) {
	local($oldsectubs) = "";
	@sectsubs = split(/;/, $sectsubs); 
	foreach $sectsub (@sectsubs) {  # get rid of duplicates
        $oldsectubs .= ";$sectsub" if($oldsectubs !~ /$sectsub/); 
    }
    $oldsectsubs =~  s/^;+//;  # get rid of leading ;
 }
print "sec27 oldsectsubs $oldsectsubs ... sectsubs $sectsubs\n";
return;

 $newschg = 'Y';
print "sec1206 xxx sectsubs $sectsubs<br />\n";
 if($sectsubs =~ /[A-Za-z0-9]/) {
	@sectsubs = split(/;/, $sectsubs); 
    $save_sectsubs = $sectsubs;
    local($found_news = 'N');
    $sectsubs = "";   #we will rebuild sectsubs if there are deletions
	foreach $sectsub (@sectsubs) {
	   ($dSectsubid,$rest) = split(/`/, $sectsub,2);   # get rid of stratus A...M...Z
	##                  If sectsub is in news processing sections
       if($sectsubs =~ /$dSectsubid/) { #skip dups
	       break;
	   }
  	   if($newsSections =~ /$dSectsubid/) {
	      $found_news = 'Y';
	##      If newprocsectsub has not changed from previous
  	     if($dSectsubid =~ /$newsprocsectsub/) { #If no change, 
	        $newschg = 'N';
	     }
	     else {
	        $delsectsubs .= ";$dSectsubid";
			$delsectsubs =~  s/^;+//;    #remove leading ;
			$addsectsubs .= $newsprocsectsub if($addsectsubs !~ /$newsprocsectsub/); # No dups allowed;
			$addsectsubs =~  s/^;+//;    #remove leading ;
	     } #end inner if/else
	   } #end middle if
	   else {
		$sectsubs .= ";$dSectsubid";
	   } #end middle else
	} #end foreach
	
 } # end outer if
 else {
   $addsectsubs .= ";$newsprocsectsub" if($newsprocsectsub !~ /NA/ or $newsprocsectsub =~ /[A-Za-z0-9]/);
   $addsectsubs =~  s/^;+//;    #remove leading ;
 } # end outer else
print "sec 1246 xxx newsprocsectsub $newsprocsectsub ... sectsubs $sectsubs ... addsectsubs $addsectsubs<br />\n";
 if( ($newsprocsectsub !~ /NA/ and $newsprocsectsub =~ /[A-Za-z0-9]/) 
    and $sectsubs !~ /$newsprocsectsub/) {
	  $sectsubs .= ";$newsprocsectsub";
	  $addsectsubs .= ";$newsprocsectsub";
 }
print "sec 1252 xxx newsprocsectsub $newsprocsectsub ... sectsubs $sectsubs ... addsectsubs $addsectsubs<br />\n";


 $sectsubs =~  s/^;+//;    #remove leading 
 $addsectsubs =~  s/^;+//;    #remove leading ;

  &add_addl_0123sections_subinfo(0,$addsectsubs0) if($addsectsubs0);
  &add_addl_0123sections_subinfo(1,$addsectsubs1) if($addsectsubs1);
  &add_addl_0123sections_subinfo(2,$addsectsubs2) if($addsectsubs2);
  &add_addl_0123sections_subinfo(3,$addsectsubs3) if($addsectsubs3);
	
print "sec 1261 xxx docaction $docaction ... sectsubs $sectsubs ... addsectsubs $addsectsubs ... delsectsubs $delsectsubs<br />\n";
  if($docaction eq 'D') {
      $delsectsubs = $sectsubs;
      $sectsubs    = $deleteSS;
      $addsectsubs = $deleteSS;
  }
  else {
   		
       &add_del_sectsubs;
  }

print "sec 1272 xxx docaction $docaction ... sectsubs $sectsubs ... addsectsubs $addsectsubs ... delsectsubs $delsectsubs<br />\n";
  	

    &add_subinfo if($docaction ne 'D');
 print "sec 1289 xxx docaction $docaction ... sectsubs $sectsubs ... addsectsubs $addsectsubs ... delsectsubs $delsectsubs<br />\n";

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

sub add_extra_sections_not_used
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
 foreach $sectsub (@sectsubs) {
   last if($sectsub !~ /[A-Za-z0-9]/);
   $newschg = 'Y';
   $newschg = 'N' if($sectsubid =~ /$newprocsectsub/);

   ($sectsubid, $subinfo) = split(/`/, $sectsub);
   ($sectid,$subid) = split(/_/, $sectsubid);

   $cSectsubid = $sectsubid;
   &split_section_ctrlB;    # get $cCategory

   if(  ( ($cmd eq "storeform") and ($updsectsubs !~ /$sectsubid/) and ($newsSections !~ /$sectsubid/) ) 
     or ( ($cCategory eq 'N') and ($newschg eq 'Y') )    ) {
#	   $delete_it = 'Y';
        $delsectsubs .= ";$sectsubid";
   }
#   if($delete_it eq 'Y') {
#        $delsectsubs .= ";$sectsubid";
#   }	
   else { 		
        $redosectsubs .= ";$sectsub";  # if not deleted, redo it
        $modsectsubs  .= ";$sectsubid" if($docaction eq 'C');
   }   
 } # end foreach

 $delsectsubs  =~  s/^;+//;  #get rid of leading semi-colons
 $redosectsubs =~  s/^;+//; 
 $modsectsubs  =~  s/^;+//; 
}

# 677            Delete if delsected from current sections dropdown,
#                or headlines being moved to newsDigest

sub chk_for_delete_dont_need_logic_inline
{
   $delete_it = 'N';

   $cSectsubid = $sectsubid;
   &split_section_ctrlB;

if(   ($cmd eq "storeform" and $updsectsubs !~ /$sectsubid/) 
   or ($cCategory eq 'N' and $sectsubid !~ /$newprocsectsub/) ) {
	   $delete_it = 'Y';
   }
}

sub chk_for_delete_old_not_used
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


#### 00470  SECTIONS CONTROL FILE ###


sub clear_section_ctrl
{
 $default_itemMax = '100';
 $totalItems     = 0;
 $cIdxSectsubid  = "";
 $cWebsite       = "";
 $cSubdir        = "";
 $cPage          = "";
 $cCategory      = "";
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
  ($cSubdir,$cPage,$cCategory,$cVisable,$cPreview,$cOrder,$cTemplate,$cTitleTemplate,$cTitle,$cBlockquote,$cRtCol,$cLogo,$cHeader,$cFooter,$cFTPinfo,$cMaxItems,$cFly,$cFTPtoInfo,$cPg2Header) 
        = split(/\^/,$cSectsubInfo);
 
## print "sec470c $cSectsubid docfile $cIdxSectsubid .. pg $cPage .. ord-$cOrder .. BRL $cBlockquote$cRtCol$cLogo .. hdr $cHeader .. ftr $cFooter .. ftp $cFTPinfo .. max $cMaxItems .. fly $cFly .. ftpto $cFTPtoInfo .. pg2Header $cPg2Header <br>\n";
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


1;


