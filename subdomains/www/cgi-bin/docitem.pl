#!/usr/bin/perl --

# January 2012
#      docitem.pl

# docitem.pl processes doc info including parsing popnews email and converted items
##   to find headlines, source date, publisher, region, and other variables.
## docaction = new, before, after, clone, update, deleteitem, emailit
## docaction = N, C, D (after)
## doc sectsubs:  dSectid-dSubid`ddocloc^dNeardocid^dTemplate^
##                dSrcstyle^dHeadstyle^dBodystyle^dCmntstyle^dFullstyle

## 2012 Jan 23 - Broke off smartdata.pl - for parsing data
## 2010 Sep11 - Added dBoxStyle to CRUD functions in various places.
## 2010 Aug24 - restored skip of listing of deleted items; added check for printdeleted.off
## 2010 Aug11 - removed NA from sectsubs on the write of docitem; added also to sub get_doc_data
## 2010 Jul30 - fixed removal of NA from sectsubs (was NR)
## 2010 May 7 - Set permissions to 777 for open with write on Mac Server (Karens Mac)
## 2010 Apr12 - addsectsubs & updsectsubs - remove NR; - the deselect option on dropdowns and radio button;
##               fixed region in   sub - checked for alphanumeric first ????
## 2008 Dec28 - added $fix to form and $fixfullbody - forces &apple_convert.
## 2008 Dec27 - moved $fullbody and $body apple converts to &apple_convert and moved &apple_convert from common to here
## 2008 May26 - eliminated angle brackets from link; changed * to = in Grist links
##            - called common::choppedline_convert: change back to normal: lines that are broken to make short lines (usually 72) for email
              
## 2006 Aug23 - fixed dups in jhuccp articles
## 2006 Aug20 - reversed fix where single line feeds were previously dissolved because source not found

## 2006 Jul21 - fixed grist to pick up the 1st (and 2nd link), not the last
## 2006 Jul15 - eliminated title, date, source from push $fullbody; left parens ) in $source
## 2006 Jan06 - added docaction logic to parse popnews_email
##              added more std variables to make email processing go faster. Like DOCACTION, DOCID

## 2005 Sep10 - restored missing code to parse_popnews_email subroutine where $msgbody = "$msgbody$msgline\n";
##              and to $fullbody = $msgbody; in subroutine &refine_fullbody

sub init_docitem_variables
{
   $DOCARRAY = "";
   &clear_doc_data; 
   &clear_doc_variables;
   &clear_helper_variables;
   &clear_msgline_variables;
}

sub display_one
{
 my ($aTemplate,$print_it,$email_it,$html_it) = @_;
 if($action eq 'new') {
   $pubday   = $nowdd;
   $pubmonth = $nowmm;
   $pubyear  = $nowyyyy;
   $pubdate = "$pubyear-$pubmonth-$pubday";
   $pubday   = "00";
   $expmonth = "00";
   $expyear  = "00";
   $expdate = "$expyear-$expmonth-$expday";
 }
 elsif($docid =~ /[0-9]/) {
   &get_doc_data($docid,$print_it);

   if($sectsubs =~ /$suggestedSS|$emailedSS/ and $access !~ /[ABCD]/
      and $cmd eq "processlogin") {
     $errmsg = "Sorry, you cannot access this article until it has been pre-processed. Please check the various Headlines lists";
     &printInvalidExit;
   }
 }
  &process_template($aTemplate,'Y','N','N');  #in template_ctrl.pl
}


sub do_one_doc
 {
  $docid =~ s/\s//g;   ## trim non-alphanumerics
## TODO40: don't forget to delete it from the index in the first place -- THIS IS NOT BEING DONE!
  if(-f "$deletepath/$docid.del" and $doclistname !~ /$deleteSS/
      and -f "$printdeletedOFF") {
      return;
  }	    	                                

  &get_doc_data($docid,'N');

  $expdate = "0000-00-00" if($expdate !~ /[0-9]/);    
  $expired = "$expired;$docid"
         if($sectsubs !~ /$expiredSS/ and $expdate ne "0000-00-00" and $expdate lt $nowdate);

  if($cmd eq 'init_section') {
       $sectsubs = $thisSectsub;
 ##    &write_doc_item($docid);   DISABLED UNTIL NEEDED
  }
  else {
     &do_we_select_item;
     if($skip_item !~ /Y/ and $select_item eq 'Y') {
        &process_template($aTemplate,'Y','N','N');
     }                           
  } #end else

  if($fix_sectsub =~ /Y/) {
 ##       $body = "";
 ##       $pubdate = "0000-00-00";
 ##       $source  = "";
 ##       $sectsubs = "Impacts_pollution`M";
 
 ##      $pubdate = "0000-00-00" if($pubdate =~ /2003-06-27/ or  $pubdate !~ /[0-9]/);
 ##      $chkline = $fullbody;
 ##      &basic_date_parse;
   
 ##    &refine_source;

 ##   &fix_fullbody;       
    &write_doc_item($docid);
  }
#  &clear_doc_variables;
}


 
##0042

sub do_we_select_item
{
 $select_item = 'N';

 if($select_kgp eq 'Y') {
    $select_item = 'Y' if( ($sumAcctnum eq 'A3491' or $sumAcctnum !~ /[A-Z0-9]/)
                       and $skiphandle ne 'Y');
 }
 elsif($docid =~ /$startDocid/) {
    $select_item = 'Y';
    $start_found = 'Y';
 }
 elsif($start_found eq 'Y') {
    $select_item = 'Y';
 }
 elsif($chk_pubdate =~ /[0-9]/) {
    $select_item = 'Y' if($pubdate le $chk_pubdate);
 }
 elsif($startDocid !~ /[0-9]/	) {
    $select_item = 'Y'
 }
}


### ########  STOREFORM   ###########

sub storeform
{
#  &clear_doc_variables;
 &get_contributor_form_values if($ipform !~ /chaseLink/);
 &get_doc_form_values;
 &update_control_files;  # if add or update needed
# &add_new_source;  #in sources.pl
 &main_storeform;
}

sub main_storeform {

 $docaction = 'N' unless($docid);
 &get_docid;
#          for sysdate if new
 $sysdate = &calc_date('sys',0,'+');

 &do_sectsubs;     # in sectsubs.pl

# &do_keywords if($selkeywords =~ /[A-Za-z0-9]/ and $docaction ne 'D');
 &write_doc_item($docid);

&log_volunteer if($sectsubs =~ /$summarizedSS|$suggestedSS/ or $ipform =~ /chaseLink/);

 my @save_sort = ($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic);

 &ck_popnews_weekly 
    if($addsectsubs =~ /$newsdigestSectid/ or $delsectsubs =~ /$newsdigestSectid/); ## in article.pl

 my ($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic) = @save_sort;

# print "doc174 hook sectsubs $sectsubs ..pubdate $pubdate ..sysdate $sysdate ..headline $headline region $region ..topic $topic<br>\n" if($g_debug_prt > 0);

 &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); ## add to index files in index.pl

 $sections="";
 $chgsectsubs = "$addsectsubs;$modsectsubs;$delsectsubs";
 $chgsectsubs =~  s/^;+//;  #get rid of leading semi-colons

 my $ipform = $FORM{'ipform'};

 if($owner) {
    &print_review($OWNER{oreviewtemplate});
 }
 elsif($sectsubs =~ /Suggested_suggestedItem/ and $ipform =~ /newItemParse/) {
	print "<div style=\"font-family:arial;font-size:1.2em;margin-top:13px;margin-left:7px;\">&nbsp;&nbsp;Item -- $docid -- has been submitted; Ready for next item:</div>\n";
	$fullbody = "";
	$DOCARRAY = "";   # get ready for the next one
	$FORM = "";
	return;    # return to article.pl to print next page: another newItemParse form
 }
 else {
    &print_review('review');
 }
 
 &do_html_page(thisSectsub,$aTemplate,1); ## create HTML file - this is in display.pl

}  ## END SUB


sub update_control_files {
 $addchgsource = $FORM{"addchgsource$pgitemcnt"};
 ($sourceid,$source,$rest) = split(/\^/,$source,3) if($addchgsource !~ /A/);
 $addchgregion = $FORM{"addchgregion$pgitemcnt"};
 ($regionid,$xseq,$xtyp,$region,$rest) = split(/\^/,$region,5) if($addchgregion !~ /A/);

# DON'T NEED -> &get_doc_source_crud_values if($addchgsource =~ /[AU]/ or $addchgregion =~ /[AU]/);

 $sourceid = &add_updt_source_values($source,$addchgsource);  #in sources.pl
 $regionid = &add_updt_region_values($region,$addchgregion);  #in regions.pl

 $addacronym = $FORM{"addacronym$pgitemcnt"};
 &add_acronym if($addacronym =~ /A/);       # in controlfiles.pl
}

sub update_sectsubs {
 $addchgsectsubs = $FORM{"addchgsectsubs$pgitemcnt"};
 ($sectsubid,$sectsub,$rest) = split(/\^/,$sectsub,3) if($addchgsectsub !~ /A/);
 $sectsubid = &add_updt_sectsub_values($sectsub,$addchgsectsub);  #in sectsubs.pl
}

## 080 STOREFORM subroutines

sub get_docid
{ 
  my $oldDocid = $docid;

 if( ($action eq 'clone') 
     or ($docaction eq 'N') 
     or ($oldDocid !~ /[0-9]{6}/ and $action ne 'clone')
     or ($action eq 'new') ) {
    $docaction = 'N';
    $docid = &get_docCount;
  }
  elsif ( ($action eq 'update') 
          or ($action eq 'summarize') ) { 
    $docid = $oldDocid;
    $docaction = 'C';
#                  save old - we will write a new one
    system "mv $itempath/$docid.itm $statuspath/$docid.saveold";
  }
  elsif ($action eq 'deleteitem') { 
    $docid = $oldDocid;
    $docaction = 'D';
  }
}

# SIMILAR TO STOREFORM, BUT FROM A LIST OF ITEMS TO BE UPDATED

sub do_updt_selected
{
  &clear_work_variables;

  $temp = $FORM{"sectsubs$pgitemcnt"};

  &get_doc_data($docid,'N');  #in docitem.pl

  $doc_fullbody = $fullbody if($ipform =~ /chaseLink/);
##                   new priority overrides prior priority
  $priority = $form_priority;

  $priority = "4"  if($ipform =~ /chaseLink/); ## drop priority since apparently volunteer didn't fill in form

  &get_more_select_form_values;  ## overrides prior doc values

  &change_sectsubs_for_updt_selected;   ## looks for delete if priority = D --  in sectsubs.pl  

 print "&nbsp;<font face=verdana><font size=1>$docid </font><font size=2>$headline </font><font size=1>ord-$sortorder $sectsubs</font><br>\n";

  &write_doc_item($docid);
 
#  if($priority =~ /D/ and $sectsubs =~ /Suggested_suggestedItem/ {
#	 &delete_from_index($rSectsubid,$docid);
#	 &DB_delete_from_indexes ($SSid,$selectdocid) unless($DB_indexes < 1);
#  }
#  else {
     &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); ## add to index files -- in sectsubs.pl
#  }
  &add_new_source if($addsource =~ /Y/);
  &add_new_region if($addregion =~ /Y/);

  $FORM = ();   #maybe this makes the following unnecessary

  undef $FORM{"docid$pgitemcnt"};
  undef $FORM{"priority$pgitemcnt"};
  undef $FORM{"headline$pgitemcnt"};
  undef $FORM{"link$pgitemcnt"};
  undef $FORM{"selflink$pgitemcnt"};
  undef $FORM{"topic$pgitemcnt"};
  undef $FORM{"pubday$pgitemcnt"};
  undef $FORM{"pubmonth$pgitemcnt"};
  undef $FORM{"pubyear$pgitemcnt"};
  undef $FORM{"sectsubs$pgitemcnt"};
  undef $FORM{"miscinfo$pgitemcnt"};
  undef $FORM{"docloc_add$pgitemcnt"};
  undef $FORM{"region$pgitemcnt"};
  undef $FORM{"regionhead$pgitemcnt"};
  undef $FORM{"addsource$pgitemcnt"};
  undef $FORM{"addregion$pgitemcnt"};
  undef $temp;

undef  $FORM{'docid'};
undef  $FORM{'deleted'};   ## New variables
undef  $FORM{'outdated'};
undef  $FORM{'nextdocid'};

undef  $FORM{'skippubdate'};
undef  $FORM{'woadatetime'};
undef  $FORM{'reappeardate'};

undef  $FORM{'sourcefk'};
undef  $FORM{'skipsource'};
undef  $FORM{'author'};
undef  $FORM{'skipauthor'};

undef  $FORM{'dtemplate'};

undef  $FORM{'skiplink'};

undef  $FORM{'skipheadline'};
undef  $FORM{'subheadline'};

undef  $FORM{'regionfk'};
undef  $FORM{'skipregion'};

undef  $FORM{'imagealt'};
undef  $FORM{'skipregion'};
undef  $FORM{'summarizerfk'};
undef  $FORM{'suggesterfk'};
undef  $FORM{'changebyfk'};
undef  $FORM{'updated_on'};   ## End NEW VARIABLES

  &clear_doc_variables;
}



sub print_review
{
 my $template = $_[0];
 $sectsubs = "$sectsubs;$mobileSS" if($sectsubs =~ /$newsdigestSS/);
 &get_pages;
##         print the receipt
 &process_template($template,'Y','N','N');
 $aTemplate = $qTemplate;
 $print_it = 'N';
}


sub log_volunteer
{
 if($sumAcctnum =~ /[A-Za-z0-9]/) {	
     $addsectsubs = "$addsectsubs;Volunteer_log$sumAcctnum"; 
 }
 elsif($userid =~ /[A-Za-z0-9]/) {
     $addsectsubs = "$addsectsubs;Volunteer_log$userid";
 }
}


## 00100 

sub process_popnews_email       # from article.pl when item selected from Suggested_emailedItem list
{
 my $maildocid = $_[0];
 &get_doc_data($maildocid,'N');

 $docid = &get_docCount;        # replace emailed docid with new docid from the system

 $addsectsubs = $suggestedSS;
 $sectsubs = $suggestedSS;
 $delsubs = $emailedSS;

 &write_doc_item($docid);

# $cSectsubid = $rSectsubid = $addsectsubs = "$suggestedSS";
# $delsectsubs    = "";
#  &delete_from_index($rSectsubid,$docid);
#  &DB_delete_from_indexes ($SSid,$selectdocid) unless($DB_indexes < 1);
#  &write_index_straight($suggestedSS,$docid);  # in sections.pl
# &index_suggested($docid);  # add to suggested index - in sections.pl
 &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); # in sections.pl
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
   	   &write_doc_item($docid);  ## in docitem.pl
   	   &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic);
     }
 }
}


##  0000290   ##

sub check_for_skip
{
  $skip_item = 'N';

  if($handle =~ /kaiser|jhuccp|ippf/ 
     and (   $headline =~ /anthrax/i
          or $headline =~ /artificial insemination/i 
          or $headline =~ /bioethics/i 
          or $headline =~ /birth defect/i
          or $headline =~ /caesarean|cesarean|chlamydia/i
          or $headline =~ /circumcision|cloning|Cloning|cytotec|cystic fibrosis/i
          or $headline =~ /dental|disabilities|disability|diabetes/i
          or $headline =~ /down syndrome/i
          or $headline =~ /embryo|episiotomy/i
          or $headline =~ /female circumcision/i
          or $headline =~ /fetal tissue|fetal homicide|fetal medicine|FGM/i
          or $headline =~ /gamete|gang-rape|gang rape|genital|gonorrhea/i
##          or ($headline =~ /HIV|AIDS/i and $headline !~ /condoms|abstinence/i) 
          or $headline =~ /hypertension|hysterectomy|hysterectomies|herpes/i 
          or $headline =~ /infertile|intensive-care|in vitro|IVF/i
          or $headline =~ /kaposi/i
          or $headline =~ /malpractice/i
          or $headline =~ /menopause|miscarriage/i
          or $headline =~ /neural Tube/i
          or $headline =~ /nevirapine/i
          or $headline =~ /Ob\/Gyn|OB-GYN|ovarian|Ovarian/i
          or $headline =~ /pap smear|pap test/i
          or $headline =~ /parental notification|Partial-Birth|partial-birth/i 
          or $headline =~ /paternity/i 
          or $headline =~ /preeclampsia/i 
          or $headline =~ /premature Birth/i   
          or $headline =~ /retroviral/i 
          or $headline =~ /sect members/i
          or $headline =~ /smoking/i
          or $headline =~ /stem cell/i
          or $headline =~ /symptoms|Syndromes|syndromes|syphilis/i
          or $headline =~ /test tube/i
          or $headline =~ /uterine/i
          or $headline =~ /vaccine/i 
          or $headline =~ /virus/i 
          or $headline =~ /Will Not Publish|will not publish/

          or $link =~ /foreignpolicy\.com/
          or $link =~ /smj\.org|dx\.doi|sciencedirect|bmjjournals|\.ncbi|springerlink|ingentaconnect/
          or $link =~ /oneoldvet|blogspot/
          
          or $msgline1 =~ /subscription needed/
          or $msgline2 =~ /subscription needed/
    ) ){
     $skip_item = 'Y';
  }
  
  if($headline =~ /google/ and $headline =~ /subscription/) {
     $skip_item = 'Y';
  }
}



####  00527

sub titlize_headline
{
	# TODO : read these in from acronym table
	
 @acronyms = ("ACLU","aclu","AGI","agi","AIDS","aids","ALL","CD-ROM","BMJ","CEDAW","CEDPA","CRLP","EC","EPA","epa",
"FAO","fao","FDA","GAO","GOP","ICDP","IPPF","ippf","II","III","IUD","iud","HHS","H1-B","H1B","HIV","hiv","HIV/AIDS","hiv/aids",
"LA","L.A.","NARAL","NCPTP","NGO","NGOs","N.J.","NPG","npg","NPR","NPR's","NWLC","OK",
"OPEC","PBS","pbs","RU-486","RU486","SARS","STI","STD","std","TFR","TV","tv",
"UK","uk","UNEP","unep","UNFPA","unfpa","(UNFPA)","UNICEF","unicef","UN","U.N.","US","U.S.","u.s.","USA","U.S.A.",
"WSSD","WTO","wto","ZPG","zpg");

 @noCapWords = ("a","and","as","at","but","by","in","is","it","for","of","on","to","the","was","with");
 
 @words = split(/ /,$headline);
 $headline = "";
 $word_cnt = 0;
 foreach $word (@words) {
    $word_cnt += 1;
    @wordsplit = split(//,$word);
    $postword = "";
    $chkword = "";
    $chkword2 = "";
    foreach $letter (@wordsplit) {
        if($letter =~ /[a-zA-Z0-9]/) {
           if($postword eq "") {
              $chkword = "$chkword$letter";
           }
           else {
              $postword = "$postword$letter";
           }
        }
        else { 
           $postword = "$postword$letter" if($chkword =~ /[a-zA-Z0-9]/);
        }
    }
    $chkword2 = "$chkword$postword";

    undef $acronym;
    $acronym_found = 'N';
    foreach $acronym (@acronyms) {
       if($word eq $acronym or $chkword eq $acronym or $chkword2 eq $acronym) {
          $acronym_found = 'Y';
          last;
       }
    }
    if($acronym_found eq 'Y')
       {}
    else {
       $word =~ tr/[A-Z]/[a-z]/;
    }
    if($word_cnt ne 1) {
       $lowercase = 'N';
       foreach $noCap (@noCapWords) {
           if($word eq $noCap) {
               $lowercase = 'Y';
               last; 
           }
       }
    }
    if($lowercase eq 'Y') {
    }
    else {
       ($letter1,$rest) = split(//,$word,2);
       $letter1 =~ tr/[a-z]/[A-Z]/;
       $word = "$letter1$rest";
   }

   $headline = "$headline$word "; 

 } #  end foreach

 undef @wordsplit;
 undef $lowercase;
 undef $acronym;
 undef $acronym_found;
 undef $noCap;
 undef $word_cnt;
}


####  00530    VARIBLE PROCESSING ######

sub fill_email_variables
{
    $sumAcctnum     = $EITEM{sumAcctnum}     if($EITEM{sumAcctnum}) ;
    $suggestAcctnum = $EITEM{suggestAcctnum} if($EITEM{suggestAcctnum});
    $priority       = $EITEM{priority}       if($EITEM{priority});
    $pubdate        = $EITEM{pubdate}        if(!$pubdate and $EITEM{pubdate});
    $expdate        = $EITEM{expdate}        if($EITEM{expdate});
    $expired        = $EITEM{expired}        if($EITEM{expired});
    $srcdate        = $EITEM{srcdate}        if($EITEM{srcdate});
    $source         = $EITEM{source}         if(!$source and $EITEM{source});
    $source         = "" if($source eq "(select one)");
    $straightHTML   = $EITEM{straightHTML};
    $dTemplate      = $EITEM{dTemplate}      if($EITEM{dTemplate});
    $dTemplate      = 'straight' if($straightHTML eq 'Y');
 ## we already checked for link because it was easier that way
    $link           = $EITEM{link}           if(!$link and $EITEM{link});
    $selflink       = $EITEM{"selflink"};
    $headline       = $EITEM{headline}       if(!$headline and $EITEM{headline});
    $topic          = $EITEM{topic}          if($EITEM{topic});
    $region         = $EITEM{region}         if(!$region and $EITEM{region});
    $regionhead     = $EITEM{regionhead};
    $body           = $EITEM{body}           if(!$body and $EITEM{body});
    $points         = $EITEM{points}         if(!$points and $EITEM{points});
    $comment        = $EITEM{comment}        if(!$comment and $EITEM{comment});
    $fullbody       = $EITEM{fullbody}       if($EITEM{fullbody});
    $miscinfo       = $EITEM{miscinfo}       if($EITEM{miscinfo});
    $freeview       = $EITEM{freeview};
    $note           = $EITEM{note}           if(!$note and $EITEM{note});
    $keywords       = $EITEM{keywords}       if($EITEM{keywords});
    $sectsubs       = $EITEM{sectsubs}       if(!$sectsubs and $EITEM{sectsubs});
    $unique         = $EITEM{unique}         if($EITEM{unique});
    $skiphandle     = $EITEM{skiphandle};
    $imagefile      = $EITEM{imagefile}      if(!$imagefile and $EITEM{imagefile});
    $imageloc       = $EITEM{imageloc}       if(!$imageloc and $EITEM{imageloc});
	$imagealt       = $EITEM{imagealt}       if(!$imagealt and $EITEM{imagealt});
	
	$deleted        = $EITEM{deleted};    ## Start new variables section
	$outdated       = $EITEM{outdated}; 
	$nextdocid      = $EITEM{nextdocid};

	$skippubdate  = $EITEM{skippubdate};
	$woadatetime  = $EITEM{woadatetime};
	$reappeardate = $EITEM{reappeardate};

	$sourcefk     = $EITEM{sourcefk};
	$skipsource   = $EITEM{skipsource};
	$author       = $EITEM{author}           if(!$author and $EITEM{author});
	$skipauthor   = $EITEM{skipauthor};
	$skiplink     = $EITEM{skiplink};
	$skipheadline = $EITEM{skipheadline};
	$subheadline  = $EITEM{subheadline}      if(!$subheadline and $EITEM{subheadline});

	$regionfk     = $EITEM{regionfk};
	$skipregion   = $EITEM{skipregion};
	$summarizerfk = $EITEM{summarizerfk};
	$suggesterfk  = $EITEM{suggesterfk};
	$changebyfk   = $EITEM{changebyfk};
	$updated_on   = $EITEM{updated_on};  ###       End of new variables
}

sub clear_email_variables
{
 undef $EITEM{sumAcctnum};
 undef $EITEM{suggestAcctnum};
 undef $EITEM{priority}; 
 undef $EITEM{pubdate};
 undef $EITEM{expdate};
 undef $EITEM{srcdate}; 
 undef $EITEM{source};
 undef $EITEM{straightHTML};
 undef $EITEM{dTemplate};
 undef $EITEM{dBoxStyle};
 undef $EITEM{link};
 undef $EITEM{titlize};
 undef $EITEM{selflink};
 undef $EITEM{headline};
 undef $EITEM{region};
 undef $EITEM{regionhead};
 undef $EITEM{topic};
 undef $EITEM{body};;
 undef $EITEM{comment};
 undef $EITEM{fullbody};
 undef $EITEM{freeview};
 undef $EITEM{note};
 undef $EITEM{miscinfo};
 undef $EITEM{keywords};
 undef $EITEM{sectsubs};
 undef $EITEM{unique};
 undef $EITEM{skiphandle};
 undef $EITEM{imagefile};
 undef $EITEM{imageloc};

undef  $EITEM{deleted};   ## New variables
undef  $EITEM{outdated};
undef  $EITEM{nextdocid};

undef  $EITEM{skippubdate};
undef  $EITEM{woadatetime};
undef  $EITEM{reappeardate};

undef  $EITEM{sourcefk};
undef  $EITEM{skipsource};
undef  $EITEM{author};
undef  $EITEM{skipauthor};

undef  $EITEM{dtemplate};

undef  $EITEM{skiplink};

undef  $EITEM{skipheadline};
undef  $EITEM{subheadline};

undef  $EITEM{regionfk};
undef  $EITEM{skipregion};

undef  $EITEM{imagealt};
undef  $EITEM{skipregion};
undef  $EITEM{summarizerfk};
undef  $EITEM{suggesterfk};
undef  $EITEM{changebyfk};
undef  $EITEM{updated_on};   ## End NEW VARIABLES


 @EITEM = ();
  undef $paragraph;
  undef $paragr_cnt;
  undef $paragr_linecnt;
  undef $paragraph1;
  undef $paragraph2;
  undef $paragraph3;
  undef $paragr_parens;
  undef $paragr_source;
  undef $paragr_headline;
  undef $paragr_date;
  undef $paragr_link;
  undef $paragr_anydate;
  undef $paragr_anysrc;
  undef $prev_line;
  undef $prevprev_line;
  undef $pdate;
  undef $msgline1;
  undef $msgline2;
  undef $msgline3;
  undef @msglines;
  undef $msgline_parens;
  undef $msgline_source;
  undef $msgline_headline;
  undef $msgline_date;
  undef $msgline_link;
  undef $nextline_link;
  undef $msgline_anydate;
  undef $msgline_anysrc;
  undef $hdline;
  undef $srcsep;
  undef @stdVariables;
  undef $msgline;
  undef $dweek;
  undef $sentdd;
  undef $sentmon;
  undef $sentyyyy;
  undef $fromEmail;
  undef $emailuser;
  undef $msgtop;
  undef $msgbody;
  undef $locline;
  undef $locname;
  undef $variable;
  undef $holdmonth;
  undef $chkline;
  undef $pyear;

undef $deleted;     ## NEW VARIABLES
undef $outdated;
undef $nextdocid;

undef $skippubdate;
undef $woadatetime;
undef $reappeardate;

undef $sourcefk;
undef $skipsource;
undef $author;
undef $skipauthor;

undef $dtemplate;

undef $skiplink;

undef $skipheadline;
undef $subheadline;

undef $regionfk;
undef $skipregion;

undef $imagealt;
undef $skipregion;
undef $summarizerfk;
undef $suggesterfk;
undef $changebyfk;
undef $updated_on;    ## END NEW VARIABLES
}

##00540

sub get_select_form_values
{
  $priority       = "_";
  $docid          = $FORM{"docid$pgitemcnt"};
  $priority       = $FORM{"priority$pgitemcnt"} if($FORM{"priority$pgitemcnt"} =~ /[D1-6]/);
  $selitem        = $FORM{"selitem$pgitemcnt"};
}

sub get_more_select_form_values
{
 $pubday         = $FORM{"pubday$pgitemcnt"};
 $pubmonth       = $FORM{"pubmonth$pgitemcnt"};
 $pubyear        = $FORM{"pubyear$pgitemcnt"};
 &assemble_pubdate;
 $link           = $FORM{"link$pgitemcnt"}       if($FORM{"link$pgitemcnt"});
 $selflink       = $FORM{"selflink$pgitemcnt"};
 $headline       = $FORM{"headline$pgitemcnt"}   if($FORM{"headline$pgitemcnt"});
 $topic          = $FORM{"topic$pgitemcnt"}      if($FORM{"topic$pgitemcnt"});
 $titlize        = $FORM{"titlize$pgitemcnt"};
 $selflink       = $FORM{"selflink$pgitemcnt"};
 $region         = $FORM{"region$pgitemcnt"}     if($FORM{"region$pgitemcnt"});
 $regionhead     = $FORM{"regionhead$pgitemcnt"} if($FORM{"regionhead$pgitemcnt"} =~ /[YN]/);
 $addregion      = $FORM{"addregion$pgitemcnt"}  if($FORM{"addregion$pgitemcnt"} =~ /[AU]/);
 $fSectsubs      = $FORM{"sectsubs$pgitemcnt"}   if($FORM{"sectsubs$pgitemcnt"});
 $source         = $FORM{"source$pgitemcnt"}     if($FORM{"source$pgitemcnt"});
 ($source,$sregionname) = &get_source_linkmatch($link) if($sourcelink eq 'Y' and $link);
 $addsource      = $FORM{"addsource$pgitemcnt"}  if($FORM{"addsource$pgitemcnt"} =~ /[AU]/);
 $sourcelink     = $FORM{"sourcelink$pgitemcnt"} if($FORM{"sourcelink$pgitemcnt"});
 $body           = $FORM{'body$pgitemcnt'}       if($FORM{'body$pgitemcnt'});
 $points         = $FORM{'points$pgitemcnt'}     if($FORM{'points$pgitemcnt'}     =~ /[A-Za-z0-9]/);
 $fullbody       = $FORM{"fullbody$pgitemcnt"};
 $miscinfo       = $FORM{"miscinfo$pgitemcnt"};
  
 $dDocloc        = $FORM{"docloc_add$pgitemcnt"} if($FORM{"docloc_add$pgitemcnt"} =~ /[A-Za-z0-9]/);

 $author       = $FORM{"author$pgitemcnt"}      if($FORM{"author$pgitemcnt"});
 $skipauthor   = $FORM{"skipauthor$pgitemcnt"}  if($FORM{"skipauthor$pgitemcnt"});
 $dtemplate    = $FORM{"dtemplate$pgitemcnt"}   if($FORM{"dtemplate$pgitemcnt"});
 $skipheadline = $FORM{"skipheadline$pgitemcnt"} if($FORM{"skipheadline$pgitemcnt"});
 $subheadline  = $FORM{"subheadline$pgitemcnt"} if($FORM{"subheadline$pgitemcnt"});
 $linmatch  = $FORM{"linkmatch$pgitemcnt"}   if($FORM{"linkmatch$pgitemcnt"});
}


sub get_doc_form_values
{
  if($FORM{"source$pgitemcnt"} =~ /[a-zA-Z0-9]/) {
    $source  = $FORM{"source$pgitemcnt"};
   }
  elsif ($FORM{"selectsource$pgitemcnt"} !~ /"select one"/) {
    $source = $FORM{"selectsource$pgitemcnt"};
  };
   $region         = $FORM{"region$pgitemcnt"};  

  $advance        = $FORM{"advance$pgitemcnt"};
# do we need?  $ipform         = $FORM{"ipform$pgitemcnt"};
  $sumAcctnum     = $FORM{"sumAcctnum$pgitemcnt"};
  $suggestAcctnum = $FORM{"suggestAcctnum$pgitemcnt"};
  $suggestAcctnum = $FORM{"userid"} if($ipform =~ /'newArticle'/);
  $formSectsub    = $FORM{"cSectsubid$pgitemcnt"};
  $priority       = $FORM{"priority"} unless($priority);
  $priority       = $FORM{"priority$pgitemcnt"} unless($priority);
  $sysdate        = $FORM{"sysdate$pgitemcnt"};
  $pubday         = $FORM{"pubday$pgitemcnt"};
  $pubmonth       = $FORM{"pubmonth$pgitemcnt"};
  $pubyear        = $FORM{"pubyear$pgitemcnt"};
  $expday         = $FORM{"expday$pgitemcnt"};
  $expmonth       = $FORM{"expmonth$pgitemcnt"};
  $expyear        = $FORM{"expyear$pgitemcnt"};

  &assemble_pubdate; 
  $expyear = '0000' if($expyear eq 'no date');
  if($expyear eq '0000') {
     $expmonth = "";
     $expday   = "00";
     $expdate = "0000";
  }
  elsif($expmonth eq "_" or $expmonth eq "" or $expmonth eq '00') {
     $expdate = "$expyear-00-00";
  }
  else {
    $expdate = "$expyear-$expmonth-$expday";
  }
  $straightHTML   = $FORM{"straightHTML$pgitemcnt"};
  $dTemplate      = $FORM{"dTemplate$pgitemcnt"};
  $dTemplate      = 'straight'  if($straightHTML eq 'Y');
  $dBoxStyle      = $FORM{"dBoxStyle$pgitemcnt"};
  if($dTemplate !~ /[A-Za-z0-9]/ or $dTemplate =~ /default/) {
	 $dTemplate = $default_class;  #derived from sections.html
  }
  if($dBoxStyle !~ /[A-Za-z0-9]/ or $dBoxStyle =~ /default/) {
	 $dBoxStyle = $default_2nd_class;  #derived from sections.html
  }
  $dStyleClass = "$dTemplate";  ## one or two classes
  $dStyleClass = "$dStyleClass $dBoxStyle" if($dBoxStyle =~ /[A-Za-z0-9]/);
  $link           = $FORM{"link$pgitemcnt"};
  $selflink       = $FORM{"selflink$pgitemcnt"};
  $headline       = $FORM{"headline$pgitemcnt"};
  $regionhead     = $FORM{"regionhead$pgitemcnt"};
  $topic          = $FORM{"topic$pgitemcnt"};
  $titlize        = $FORM{"titlize$pgitemcnt"};
  $body           = $FORM{"body$pgitemcnt"};
  $points         = $FORM{"points$pgitemcnt"};
  $comment        = $FORM{"comment$pgitemcnt"};
  $fullbody       = $FORM{"fullbody$pgitemcnt"};
  
  $docfullbody    = "";
  $docfullbody    = $FORM{"docfullbody$pgitemcnt"};
#print "<font size=1 face=\"comic sans ms\" color=\"#CCCCCC\">540 docfullbody $docfullbody</font><br>\n";

  $docfullbody    =~ s/&quote\;/\"/g;
  $fullbody       = "$docfullbody\n\nFULLARTICLE:\n$fullbody" if($ipform =~ /chaseLink/ and $docfullbody =~ /[A-Za-z0-9]/);

  $owner          = $FORM{"owner$pgitemcnt"};   ## temporary variable
  &get_owner($owner) if($owner);

  $fixfullbody    = $FORM{"fix$pgitemcnt"};   ## temporary variable
  $freeview       = $FORM{"freeview$pgitemcnt"};
  $linknote       = $FORM{"linknote$pgitemcnt"};
  $note           = $FORM{"note$pgitemcnt"};
  $note           = "$note $linknote" if($linknote);
  $miscinfo       = $FORM{"miscinfo$pgitemcnt"};
  $skiphandle     = $FORM{"skiphandle$pgitemcnt"};
  $selkeywords    = $FORM{"selkeywords$pgitemcnt"};
  $newkeyword     = $FORM{"newkeyword$pgitemcnt"};
  $unique         = $FORM{"unique$pgitemcnt"};
  $imagefile      = $FORM{"imagefile$pgitemcnt"};
  $imageloc       = $FORM{"imageloc$pgitemcnt"};
  $docaction      = $FORM{"docaction$pgitemcnt"};
  $sectsubs       = $FORM{"sectsubs$pgitemcnt"};
  $thisSectsub    = $FORM{"thisSectsub$pgitemcnt"} if($FORM{"thisSectsub$pgitemcnt"});

  $deleted      = $FORM{'deleted'};    ## Start new variables section
  $outdated     = $FORM{'outdated'}; 
  $nextdocid    = $FORM{'nextdocid'};

  $skippubdate  = $FORM{'skippubdate'};
  $woadatetime      = $FORM{'woadatetime'};
  $reappeardate = $FORM{'reappeardate'};

  $sourcefk     = $FORM{'sourcefk'};
  $skipsource   = $FORM{'skipsource'};
  $author       = $FORM{'author'};
  $skipauthor   = $FORM{'skipauthor'};

  $dtemplate    = $FORM{'dtemplate'};

  $skiplink     = $FORM{'skiplink'};

  $skipheadline = $FORM{'skipheadline'};
  $subheadline  = $FORM{'subheadline'};

  $regionfk     = $FORM{'regionfk'};
  $skipregion   = $FORM{'skipregion'};

  $imagealt     = $FORM{'imagealt'};
  $skipregion   = $FORM{'skipregion'};
  $summarizerfk = $FORM{'summarizerfk'};
  $suggesterfk  = $FORM{'suggesterfk'};
  $changebyfk   = $FORM{'changebyfk'};
  $updated_on   = $FORM{'updated_on'};
                              ###       End of new variables

  $updsectsubs     = $FORM{"updsectsubs$pgitemcnt"};
  $addsectsubs     = $FORM{"addsectsubs$pgitemcnt"};
  $newsprocsectsub = $FORM{"newsprocsectsub$pgitemcnt"} unless $newsprocsectsub;
  $pointssectsub   = $FORM{"pointssectsub$pgitemcnt"};
  $ownersectsub    = $FORM{"ownersectsub$pgitemcnt"};

   $sectsubs = 'CSWP_Calendar' if($sectsubs =~ /CSWP_event/ or $ownersectsub =~ /CSWP_event/); #fix a problem

  if($addsectsubs =~ /;/) {
    ($first_addsectsub,$rest) = split(/;/,$addsectsubs,2);
  }
  else {
    $first_addsectsub = $addsectsubs;
  }
  
  if($sectsubs =~ /;/) {
    ($first_sectsub,$rest) = split(/;/,$sectsubs,2);
  }
  else {
    $first_sectsub = $sectsubs;
  }
  
  if($first_addsectsub) {
    $first_sectsub = $first_addsectsub;
  }

  $addsectsubs0    = $FORM{"addsectsubs0$pgitemcnt"};
  $addsectsubs1    = $FORM{"addsectsubs1$pgitemcnt"};   
  $addsectsubs2    = $FORM{"addsectsubs2$pgitemcnt"};     
  $addsectsubs3    = $FORM{"addsectsubs3$pgitemcnt"};

  $addsectsubs  =~ s/NA;//;   ## remove NA (deselect option)
  $updsectsubs  =~ s/NA;//;
  $newsprocsectsub =~ s/NA;//;
  $pointssectsub =~ s/NA;//;
  $addsectsubs0 =~ s/NA;//;
  $addsectsubs1 =~ s/NA;//;
  $addsectsubs2 =~ s/NA;//;
  $addsectsubs3 =~ s/NA;//;

  $docloc_add  = $FORM{"docloc_add"};
  $docloc_news = $FORM{"docloc_news"} unless($docloc_news);
#print "doc777 ..priority $priority ..docloc_news $docloc_news ..newsprocsectsub $newsprocsectsub<br>\n";   
  if($FORM{"skiphandle$pgitemcnt"}) {
     $skiphandle  = $FORM{"skiphandle$pgitemcnt"};
  }
  
  $regionhead = 'N' if($regionhead !~ /Y/);

  $headline = &strip_leadingSPlineBR($headline);
  $headline =~ s/\s+$//;
    
  $source =~ &strip_leadingSPlineBR($source);
  $source =~ s/\s+$//;
  
  $region =~ s/^;//;
  $region =~ s/;$//;
  
  @lines = split(/\n/,$body);
  $body = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $body = "$body$line\n";
  }

  @lines = split(/\n/,$points);
  $points = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $points = "$points$line\n";
  }
  
  @lines = split(/\n/,$fullbody);
  $fullbody = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $fullbody = "$fullbody$line\n";
  }
}




##  00550         GET_ARTICLE

sub get_doc_data
{
  ($docid,$print_it)  = @_;

  return unless($docid);
  &clear_doc_data;

  if($docid =~ /-/) {       ##  from emailed 
	  $filepath = "$mailpath/$docid\.itm";
  }
  else {
	  $filepath = "$itempath/$docid\.itm";
  }
  $docid =~ s/\s+$//mg;
  $found_it = "Y";

  $printout = "";
  
  if(-f "$filepath") {
    open(DATA, "$filepath");
#                  one line per field
    while(<DATA>)
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
    close(DATA);
    
    return $printout if($printit =~ /Y/);
    
    $sumAcctnum     = $DATA{sumAcctnum};
    ($sumAcctnum,$rest) = split(/;/,$sumAcctnum,2) if($sumAcctnum =~ /;/);
    $suggestAcctnum = $DATA{suggestAcctnum};
    $priority       = $DATA{priority};
    $pubdate        = $DATA{pubdate};
    $expdate        = $DATA{expdate};
    ($expyear,$expmonth,$expday) = split(/-/,$expdate,3);
    $sysdate        = $DATA{sysdate};
    $srcdate        = $DATA{srcdate};
    $source         = $DATA{source};
    $source         = "" if($source eq "(select one)");
    $straightHTML   = $DATA{straightHTML};
    if($straightHTML eq 'Y') {
    	$dTemplate = 'straight';
    }
    else {
        $dTemplate = $DATA{dTemplate}; 
    }
    $dBoxStyle      = $DATA{dBoxStyle}; 
    $link           = $DATA{link};
    $link =~ s/^\s+//; 
    $link2nd        = $DATA{link2nd};
    $link2nd =~ s/^\s+//;
    $selflink       = $DATA{selflink};
    $topic          = $DATA{topic};
    $region         = $DATA{region};           
    $regionhead     = $DATA{regionhead};
    $headline       = $DATA{headline};
    $body           = $DATA{body};
    $points         = $DATA{points};
    $body =~ s/\n+$//g;    ## trim trailing line feeds
    $body =~ s/\r+$//g;    ## trim trailing returns
    $body =~ s/\n\r+$//g;    ## trim trailing returns
    $body =~ s/\r\n+$//g;    ## trim trailing returns
    $points =~ s/\s+$//g;    ## trim white space
    $points =~ s/\n+$//g;    ## trim trailing line feeds
    $points =~ s/\r+$//g;    ## trim trailing returns
    $points =~ s/\n\r+$//g;    ## trim trailing returns
    $points =~ s/\r\n+$//g;    ## trim trailing returns
    $points =~ s/\s+$//g;    ## trim white space
    $comment        = $DATA{comment};
    $fullbody       = $DATA{fullbody};
    $freeview       = $DATA{freeview};
    $note           = $DATA{note};
    $miscinfo       = $DATA{miscinfo};
    $keywords       = $DATA{keywords};
    $sectsubs       = $DATA{sectsubs};
##                          correct error which added NA to sectsubs, wrote to NA index

    $sectsubs =~ s/NA`M;//;
    $sectsubs =~ s/NA;//;
	
    $unique       = $DATA{unique};
    $skiphandle   = $DATA{skiphandle};
    $imagefile    = $DATA{imagefile};
    $imageloc     = $DATA{imageloc};     
    $dSectsubs    = $sectsubs;

	$deleted      = $DATA{deleted};          ## start new section of variables
	$outdated     = $DATA{outdated};
	$nextdocid    = $DATA{nextdocid};

	$skippubdate  = $DATA{skippubdate};
	$woadatetime      = $DATA{woadatetime};
	$reappeardate = $DATA{reappeardate};

	$sourcefk     = $DATA{sourcefk};
	$skipsource   = $DATA{skipsource};
	$author       = $DATA{author};
	$skipauthor   = $DATA{skipauthor};

	$dtemplate    = $DATA{dtemplate};

	$skiplink     = $DATA{skiplink};

	$skipheadline = $DATA{skipheadline};
	$subheadline  = $DATA{subheadline};

	$regionfk     = $DATA{regionfk};
	$skipregion   = $DATA{skipregion};

	$imagealt     = $DATA{imagealt};
	$skipregion   = $DATA{skipregion};
	$summarizerfk = $DATA{summarizerfk};
	$suggesterfk  = $DATA{suggesterfk};
	$changebyfk   = $DATA{changebyfk};
	$updated_on   = $DATA{updated_on};                 ## end new section of variables
	
        
    $fullbody =  &reverse_regexp_prep($fullbody);   ##  common.pl
   
    if($rSectsubid =~ /Suggested_suggestedItem/) {
       ($headline,$rest) = split(/Date:/,$headline,2) if($headline =~ /Date:/);
       &titlize_headline;
    }
##     2010 Apr15  --- ck for empty region
    if( ($sectsubs =~ /$suggestedSS/ or $sectsubs =~ /$headlinesSS/ ) and $region !~ /[A-Za-z0-9]/) {
	   $region = &get_regions('N',"",$headline,$fullbody,$link) if($region !~ /[A-Za-z0-9]/);  # print_regions=N, region="", # controlfiles.pl                
       $region = "Global" unless($region);
    }
    if($aTemplate =~ /docUpdate/) {
       ($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index)
          = &get_regions($printit,$region);   #in regions.pl
    	($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$regionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format) 
          = &get_sources($printit,$source);   #in sources.pl
    }
 }
 else {
   $headline =  "File not found at filepath $filepath <small>doc2595 - docid *$docid*  ....itempath $itempath</small>";
 }
}



## 00555

sub clear_doc_data
{   
    $DATA{sumAcctnum}   = "";
    $DATA{suggestAcctnum} = "";

    $DATA{deleted} = 0;
    $DATA{outdated} = 0;
    $DATA{nextdocid} = 0;

    $DATA{priority}     = "";
    $DATA{pubdate}      = "";
    $DATA{expdate}      = "";
    $DATA{expired}      = "";
    $DATA{sysdate}      = "";
    $DATA{srcdate}      = "";

    $DATA{skippubdate} = 0;
    $DATA{woadatetime} = $nulldate;
    $DATA{reappeardate} = $nulldate;

    $DATA{source}       = "";

    $DATA{sourcefk}   = 0;
    $DATA{skipsource} = 0;
    $DATA{author}     = "";
    $DATA{skipauthor} = 1;


    $DATA{dTemplate}    = "";

    $DATA{dtemplate}    = "";

    $DATA{dBoxStyle}    = "";
    $DATA{straightHTML} = "N";
    $DATA{link}         = "";
    $DATA{link2nd}      = "";
    $DATA{selflink}     = "";

    $DATA{skiplink}     = 0;

    $DATA{headline}     = "";

    $DATA{skipheadline} = 0;
    $DATA{subheadline}     = "";

    $DATA{region}       = "";
    $DATA{regionhead}   = "N";

    $DATA{regionfk} = 0;
    $DATA{skipregion} = 0;

    $DATA{topic}        = "";
    $DATA{body}         = "";
    $DATA{fullbody}     = "";
    $DATA{freeview}     = "N";
    $DATA{comment}      = "";
    $DATA{note}         = "";
    $DATA{miscinfo}     = "";
    $DATA{keywords}     = "";
    $DATA{unique}       = "";
    $DATA{sectsubs}     = "";
    $DATA{newsprocsectsub} = "";    ## Do we need?
    $DATA{pointssectsub} = "";
    $DATA{skiphandle}   = "N";
    $DATA{imagefile}    = "";
    $DATA{imageloc}     = "";

    $DATA{imagealt}     = "";
    $DATA{skipregion}   = 0;
    $DATA{summarizerfk} = 0;
    $DATA{suggesterfk}  = 0;
    $DATA{changebyfk}   = 0;
    $DATA{updated_on}   = $nulldate;
#22
}

sub clear_doc_variables
{
	$nulldate           = '0000-00-00';
	$docaction          = "";
	$docid              = "";
    $advance            = "";
    $ipform             = "";

    $deleted            = 0;
    $outdated           = 0;
    $nextdocid          = 0;

    $sumAcctnum         = "";
    $suggestAcctnum     = "";
    $priority           = "";
    $pubdate            = $nulldate;
    $pubday             = '00';
    $pubmonth           = '00';
    $pubyear            = '00';

    $skippubdate        = 0;
    $woadatetime            = $nulldate;
    $woaday             = '00';
    $woamonth           = '00';
    $woayear            = '00';

    $expdate            = "";
    $expday             = '00';
    $expmonth           = '00';
    $expyear            = '00';

    $reappeardate       = $nulldate;
    $reappearday        = '00';
    $reappearmonth      = '00';
    $reappearyear       = '00';

    $sysdate            = "$sysyear-$sysmm-$sysdd";
    $srcdate            = $nulldate;
    $source             = "";

    $sourcefk           = 0;
    $skipsource         = 0;
    $author             = "";
    $skipauthor         = 1;


    $dTemplate          = "";

    $dtemplate          = "";

    $format             = "";
    $straightHTML       = "N";
    $link               = "";
    $link2nd            = "";

    $skiplink           = 0;

    $selflink           = "";
    $titlize            = "N";
    $headline           = "";

    $skipheadline       = 0;
    $subheadline        = "";

    $region             = "";
    $regionhead         = "N";

    $regionfk           = 0;
    $skipregion         = 0;


    $topic              = "";
    $body               = "";
    $points             = "";
    $fullbody           = "";
    $freeview           = "N";
    $comment            = "";
    $note               = "";
    $miscinfo           = "";
    $emailnote          = "";
    $keywords           = "";
    $unique             = "";
    $sectsubs           = "";
    $dSectsubs          = "";
    $fSectsubs          = "";
    $newsprocsectsub    = "";
    $pointssectsub      = "";
    $skiphandle         = "N";
    $imagefile          = "";
    $imageloc           = "";

    $imagealt           = "";
    $summarizerfk       = 0;
    $suggesterfk        = 0;
    $changebyfk         = 0;
    $updated_on         = $nulldate;
    $linkmatch          = "";
}


sub clear_work_variables
{
    $addsectsubs   = "";
    $newsprocsectsub = "";
    $pointssectsub   = "";
    $ownersectsub   = "";
    $delsectsubs   = "";
}
   
## 00560
             
sub put_data_to_array    #used in template_ctrl to marry templates with data
{
 $DOCARRAY{deleted}      = $deleted;
 $DOCARRAY{outdated}     = $outdated;
 $DOCARRAY{nextdocid}    = $nextdocid;

 $DOCARRAY{skippubdate}  = $skippubdate;
 $DOCARRAY{woadatetime}      = $woadatetime;
 $DOCARRAY{reappeardate} = $reappeardate;

 $DOCARRAY{sourcefk}     = $sourcefk;
 $DOCARRAY{skipsource}   = $skipsource;
 $DOCARRAY{author}       = $author;
 $DOCARRAY{skipauthor}   = $skipauthor;

 $DOCARRAY{dtemplate}    = $dtemplate;

 $DOCARRAY{skiplink}     = $skiplink;

 $DOCARRAY{skipheadline} = $skipheadline;
 $DOCARRAY{subheadline}  = $subheadline;

 $DOCARRAY{regionfk}     = $regionfk;
 $DOCARRAY{skipregion}   = $skipregion;

 $DOCARRAY{imagealt}     = $imagealt;
 $DOCARRAY{skipregion}   = $skipregion;
 $DOCARRAY{summarizerfk} = $summarizerfk;
 $DOCARRAY{suggesterfk}  = $suggesterfk;
 $DOCARRAY{changebyfk}   = $changebyfk;
 $DOCARRAY{updated_on}   = $updated_on;


 $DOCARRAY{'owner'}          = $owner;
 $DOCARRAY{'ocsspath'}       = $ocsspath;
 $DOCARRAY{'dir'}            = $dir;
 $DOCARRAY{'action'}         = $action;
 $DOCARRAY{'filedir'}        = $filedir;
 $pgitemcnt = &padCount4($pgItemnbr);
 $DOCARRAY{'pgitemcnt'}      = $pgitemcnt; 
 $DOCARRAY{'ssitemcnt'}      = $ssItemcnt; 
 $DOCARRAY{'selecttype'}     = $selecttype;
 $DOCARRAY{'svrdestCgisite'} = $SVRdest{'cgiSite'};
 $DOCARRAY{'svrinfoMaster'}  = $SVRinfo{'master'};
 $DOCARRAY{'svrinfoSvrname'} = $SVRinfo{'svrname'};
 $DOCARRAY{'adminEmail'}     = $SVRinfo{'adminEmail'};
 $DOCARRAY{'nowdate'}        = $nowdate;
 $DOCARRAY{'docCount'}       = $docCount;
 $DOCARRAY{'hitCount'}       = $hitCount;
 $DOCARRAY{'userCount'}      = $userCount;
 $DOCARRAY{'summarizedcnt'}  = $summarizedCnt;
 $DOCARRAY{'suggestedcnt'}   = $suggestedCnt; 
 $DOCARRAY{'acctnum'}        = $acctnum;
 $DOCARRAY{'access'}         = $access;
 $DOCARRAY{sumAcctnum}     = $sumAcctnum; 
 $DOCARRAY{suggestAcctnum} = $suggestAcctnum; 
 $DOCARRAY{userid}         = $userid; 
 $DOCARRAY{useremail}      = $useremail; 
 $DOCARRAY{firstname}      = $firstname; 
 $DOCARRAY{lastname}       = $lastname;
 $DOCARRAY{pin}            = $pin; 
 $DOCARRAY{city}           = $city; 
 $DOCARRAY{zip}            = $zip; 
 $DOCARRAY{handle}         = $sumHandle; 
 $DOCARRAY{usercomment}    = $usercomment; 
 $DOCARRAY{pay}            = $pay;
 
 $DOCARRAY{docid}       = $docid;
 $DOCARRAY{priority}    = $priority;
 $DOCARRAY{pubdate}     = $pubdate;
 $DOCARRAY{pubday}      = $pubday;
 $DOCARRAY{pubmonth}    = $pubmonth;
 $DOCARRAY{pubyear}     = $pubyear;
 $DOCARRAY{expdate}     = $expdate;
 $DOCARRAY{expday}      = $expday;
 $DOCARRAY{expmonth}    = $expmonth;
 $DOCARRAY{expyear}     = $expyear;
 $DOCARRAY{sysdate}     = $sysdate;
 $DOCARRAY{srcdate}     = $srcdate;
 $DOCARRAY{source}      = $source; 
 $DOCARRAY{dTemplate}   = $dTemplate; 
 $DOCARRAY{straightHTML} = $straightHTML;
 $DOCARRAY{dBoxStyle}    = $dBoxStyle;
 $DOCARRAY{link}        = $link;
 $DOCARRAY{link2nd}     = $link2nd;
 $DOCARRAY{selflink}    = $selflink;
 $DOCARRAY{headline}    = $headline; 
 $DOCARRAY{region}      = $region; 
 $DOCARRAY{regionhead}  = $regionhead;
 $DOCARRAY{topic}       = $topic;  
 $DOCARRAY{body}        = $body;
 $DOCARRAY{points}      = $points;
 $DOCARRAY{fullbody}    = $fullbody; 
 $DOCARRAY{freeview}    = $freeview; 
 $DOCARRAY{comment}     = $comment; 
 $DOCARRAY{note}        = $note; 
 $DOCARRAY{miscinfo}    = $miscinfo; 
 $DOCARRAY{keywords}    = $keywords; 
 $DOCARRAY{unique}      = $unique; 
 $DOCARRAY{imagefile}   = $imagefile; 
 $DOCARRAY{imageloc}    = $imageloc;
 $DOCARRAY{sectsubs}    = $sectsubs;
 $DOCARRAY{newsprocsectsub}  = $newsprocsectsub;
 $DOCARRAY{pointssectsub} = $pointssectsub;
 $DOCARRAY{skiphandle}  = $skiphandle;
 $DOCARRAY{thisSectsub} = $thisSectsub;
 $DOCARRAY{rSectsubid}  = $rSectsubid; 
 $DOCARRAY{updsectsub}  = $updsectsub; 
 $DOCARRAY{addsectsub}  = $addsectsub;
 $DOCARRAY{itemformat}  = $itemformat;
 $DOCARRAY{srcstyle}    = $srcstyle; 
 $DOCARRAY{headstyle}   = $headstyle; 
 $DOCARRAY{bodystyle}   = $bodystyle; 
 $DOCARRAY{cmntstyle}   = $cmntstyle; 
 
 $DOCARRAY{cPage}       = $cPage;
 $DOCARRAY{cTitle}      = $cTitle;
 $DOCARRAY{cTitle2nd}   = $cTitle2nd;
 $DOCARRAY{cSubtitle}   = $cSubtitle;
 $DOCARRAY{cSubid}      = $cSubid; 
 $DOCARRAY{rSectsubid}  = $rSectsubid;
 $DOCARRAY{cSectsubid}  = $cSectsubid;
}

##564
sub clear_setvar
{
 $SETVAR{separator}   = "";
 $SETVAR{dTemplate}   = "";
 $SETVAR{dBoxStyle}   = "";
 $SETVAR{rSectsubidb} = "";
}

##565

##                WRITE_ITEM to file      
sub write_doc_item
{ 
  my $docid = $_[0];   # if not in items directory, it is in popnews_mail
  $docid =~ s/\s+$//mg;
  return if(!$headline and $pubdate eq '-00-00');

  if($docid =~ /-/) {       ##  from emailed 
	  $docpath = "$mailpath/$docid\.itm";
  }
  else {
	  $docpath = "$itempath/$docid\.itm";

	  if($SVRinfo{environment} == 'development') {   ## GITHUB_PATHS
		 if(-f "$docpath") {
			  unlink $docpath or printDataErr_Continue("Could not delete $docpath : $! @ doc2800<br>\n");
		 }
	  }
	  elsif(-f "$docpath") {
		  $lock_file = "$statuspath/$docid.busy";
	      &waitIfBusy($lock_file, 'lock');  
	      system "cp $docpath $itempathsave/$docid.itm" if(-f "$itempath/$docid.itm");
	  }
  }
#          see if valid data
  if(($sysdate =~ /[0-9]/ and $docid =~ /[0-9]/) or $sectsubs =~ /$emailedSS/ ) { 
	open(DATAOUT, ">$docpath") or die();

    &write_doc_data_out;
    close (DATAOUT);
    chmod 0777, $emailfile if($SVRinfo{environment} == 'development');  ## GIT_HUB PATHS
    unlink $lock_file if($lock_file);
  }
  else {
    print "Invalid sysdate=$sysdate or docid-$docid; Could not write out docitem at doc1185 Error message: $! <br>\n";
  }
  if($docid =~ /-/) {
     &write_index_straight($emailedSS,$docid);     # in sections.pl
     &DB_add_docid_to_index ($emailedSS,$docid) unless($DB_indexes < 1);    # in sections.pl
  }
  return($docid);
}

sub write_doc_data_out
{
   if($ipform eq "summarize") {
       print DATAOUT "sumAcctnum\^$userid\n";
   }
   else {
       print DATAOUT "sumAcctnum\^$sumAcctnum\n" ;
   }
   if($docaction eq 'N') {
       print DATAOUT "suggestAcctnum\^$userid\n";
   }
   else {
       print DATAOUT "suggestAcctnum\^$suggestAcctnum\n" ;
   }

   &titlize_headline if( ($docaction =~ /N/ and !$owner)  or $titlize =~ /Y/);

   if($docaction =~ /N/ and $region !~ /[A-Za-z0-9]/) {
	  $region = &get_regions('N',"",$headline,$fullbody,$link);  # print_regions=N, region="", # controlfiles.pl                
   }

	print DATAOUT "deleted\^$deleted\n";
	print DATAOUT "outdated\^$outdated\n";
	print DATAOUT "nextdocid\^$nextdocid\n";

	print DATAOUT "skippubdate\^$skippubdate\n";
	print DATAOUT "woadatetime\^$woadatetime\n";
	print DATAOUT "reappeardate\^$reappeardate\n";

	print DATAOUT "sourcefk\^$sourcefk\n";
	print DATAOUT "skipsource\^$skipsource\n";
	print DATAOUT "author\^$author\n";
	print DATAOUT "skipauthor\^$skipauthor\n";

	print DATAOUT "dtemplate\^$dtemplate\n";

	print DATAOUT "skiplink\^$skiplink\n";

	print DATAOUT "skipheadline\^$skipheadline\n";
	print DATAOUT "subheadline\^$subheadline\n";

	print DATAOUT "regionfk\^$regionfk\n";
	print DATAOUT "skipregion\^$skipregion\n";

	print DATAOUT "imagealt\^$imagealt\n";
	print DATAOUT "skipregion\^$skipregion\n";
	print DATAOUT "summarizerfk\^$summarizerfk\n";
	print DATAOUT "suggesterfk\^$suggesterfk\n";
	print DATAOUT "changebyfk\^$changebyfk\n";
	print DATAOUT "updated_on\^$updated_on\n";

   print DATAOUT "priority\^$priority\n";    
   print DATAOUT "pubdate\^$pubdate\n";
   print DATAOUT "expdate\^$expdate\n";
   print DATAOUT "sysdate\^$sysdate\n";

   $source = "" if($source =~ /select one/);
   print DATAOUT "source\^$source\n";

   $link =~ s/\<//g;
   $link =~ s/\<//g;

   print DATAOUT "link\^$link\n";
   print DATAOUT "selflink\^$selflink\n";

   $headline =~ s/&#40;/\(/g;    ## left parens
   $headline =~ s/&#41;/\)/g;    ## right parens  
   $headline =~ s/&#91;/\[/g;    ## left bracket
   $headline =~ s/&#93;/\]/g;    ## right bracket

   print DATAOUT "headline\^$headline\n";
   print DATAOUT "region\^$region\n";
   print DATAOUT "regionhead\^$regionhead\n";
   print DATAOUT "topic\^$topic\n";

   if($dTemplate eq 'default') {
   	 print DATAOUT "dTemplate\^\n";
   }
   elsif($straightHTML eq 'Y') {
        print DATAOUT "dTemplate\^straight\n";
   }
   else {
   	 print DATAOUT "dTemplate\^$dTemplate\n";
   }
   print DATAOUT "dBoxStyle\^$dBoxStyle\n";    

   $body = &apple_convert($body);
   $points = &apple_convert($points) if($points =~ /[A-Za-z0-9]/);

   print DATAOUT "body\^$body\n";
   print DATAOUT "points\^$points\n";

   if($fullbody =~ /^##FIX##/) {
      &refine_fullbody;
      $fullbody =~ s/##FIX##//;
   }

   $fullbody =~  s/^\n//;  #get rid of leading line feeds

   $fullbody = &apple_convert($fullbody) if($docaction =~ /N/ or $fixfullbody =~ /Y/);

   $headline = &strip_leadingSPlineBR($headline);
##    $headline = &strip_leadingNonAlphnum($headline);
   $headline =~ s/\s+$//;

   $headline =~ s/\s+$//;
   $headline =~ s/’/\'/g;  #E2 80 99 apostrophe

   $datafield = $source;
   $source =~ &leadingSPlineBR($source);
   $source = $datafield;

##    $source =~ &strip_leadingSPlineBR($source);


##    $source = &strip_leadingNonAlphnum($source);

   $source =~ s/\s+$//;

   $region =~ s/^;//;

   print DATAOUT "fullbody\^$fullbody\n";
   print DATAOUT "freeview\^$freeview\n";
   print DATAOUT "comment\^$comment\n";
   print DATAOUT "note\^$note\n";
   print DATAOUT "miscinfo\^$miscinfo\n";
   print DATAOUT "keywords\^$keywords\n";
   print DATAOUT "unique\^$unique\n";
   print DATAOUT "skiphandle\^$skiphandle\n";
   print DATAOUT "imageloc\^$imageloc\n";
   print DATAOUT "imagefile\^$imagefile\n";

   $sectsubs =~ s/NA`M;//;
   $sectsubs =~ s/NA;//;
   $sectsubs =~ s/`+$//;  # get rid of trailing tic marks

   print DATAOUT "sectsubs\^$sectsubs\n";
}


sub get_doc_data_for_DB
{
  my($docid) = $_[0];
  $filepath = "$itempath/$docid\.itm"; 
  if(-f "$filepath") {
    open(DATA, "$filepath");
    while(<DATA>)
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
    }
    close(DATA);

    my $priority       = $DATA{priority};
    my $pubdate        = $DATA{pubdate};
    my $sysdate        = $DATA{sysdate};
    my $topic          = $DATA{topic};
    my $region         = $DATA{region};           
    my $headline       = $DATA{headline};
    my $sectsubs       = $DATA{sectsubs};
#    require('sections.pl');
#    $stratus = &splitout_sectsub_info($sectsubname,$sectsubs,);
    return($priority,$pubdate,$sysdate,$pubyear,$topic,$region,$headline);
 }
 else {
    print "Docitem file not found $docid (line 336)<br>\n";
    return('', '','','','','','');
 }
}


sub get_docCount
 {
  my $docCount = "";

 open(COUNT, "$doccountfile") or die;
  while(<COUNT>)
  {
   chomp;
   $docCount = $_;
  }
  close(COUNT);
  open(NEWCOUNT, ">$doccountfile");
  $num = $docCount+1;
  print(NEWCOUNT"$num\n");
  close(NEWCOUNT);
  $docCount = $num;     ## ADDED THIS LINE IN GIT_PATHS
if($docCount < 10)
 {$docCount = "00000$docCount";
 }
elsif($docCount < 100)
 {$docCount = "0000$docCount";
 }
elsif($docCount < 1000)
 {$docCount = "000$docCount";
 }
elsif($docCount < 10000)
 {$docCount = "00$docCount";
 }
elsif($docCount < 100000)
 {$docCount = "0$docCount";
 }
 return($docCount);
}


sub read_docCount
{
  open(COUNT, "$doccountfile") or printCompleteExit("Could not open docCount file : doc2754 : $doccountfile : $!");
  while(<COUNT>) {
   chomp;
   $docCount = $_;
  }
  close(COUNT);
}


sub get_docdata_DB
{
	 my($docid) = $_[0];
	 my $sth_doc = $dbh->prepare( 'SELECT deleted,outdated,nextdocid,priority,headline,regionhead,skipheadline,subheadline,unique,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,skippubdate,woadatetime,expdate,reappeardate,region,regionfk,skipregion,source,sourcefk,skipsource,author,skipauthor,body,fullbody,freeview,points,comment,note,miscinfo,sectsubs,skiphandle,dtemplate,imagefile,imageloc,imagealt,sumAcctnum,suggestAcctnum,summarizerfk,suggesterfk,changebyfk,updated_on
	 FROM users where docid = ?' );
	 $sth_doc->execute($docid);
	 ($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
		$skippubdate,$woadatetime,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$body,$fullbody,$freeview,$points,$comment,$note,
		$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagealt,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk) = $sth_usr->fetchrow_array();
	 $sth_doc->finish();
}

sub write_docitem_to_DB   #### Still need to add new variables to clear_doc_data variables and other places
{
	 unless($docid =~ /[0-6]{6}/) {
	      print "$docid Invalid docid <br>\n";
		  &write_index_flatfile ('Invalid_docid',$docid,'','');
	      last;
	 }

	 $n_docid = int($docid);
#                                                   # See if deleted	
	 my($delfilename,$rest) = strip(/\./,$filename,2);
	 $delfilename = $delfilename . '/\.del';
     $deleted = 1 if(-f "$deletepath/$delfilename");

     if($pubdate) {
          $pubyear  = substr($pubdate, 4, 5);
     }
     elsif($sysdate) {
          $pubyear  = substr($sysdate, 4, 5);	    
     }

     if($straightHTML eq 'Y') {
          $dtemplate = 'straight';
          print "$docid STRAIGHT -- $headline <br>\n";
	      &write_index_flatfile ('Straight_html',$docid,'','');  #log all straight templates - these may not really be data
	 }

     $regionfk = &get_regionid($region) unless($regionfk);

	 $source   = &get_source_linkmatch($link) unless($source);

     $sourcefk = &get_sourceid($source) if($source and !$sousrcefk);

     $woadatetime = &get_nowdatetime;

     $dtemplate = $dTemplate;

	 $dbh = &db_connect() if(!$dbh);
	
	if($docaction eq 'N') {
		my $doc_sth = $dbh->prepare("INSERT INTO docitem (docid,deleted,outdated,nextdocid,priority,headline,regionhead,skipheadline,subheadline,unique,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,skippubdate,woadatetime,expdate,reappeardate,region,regionfk,skipregion,source,sourcefk,skipsource,author,skipauthor,body,fullbody,freeview,points,comment,note,miscinfo,sectsubs,skiphandle,dtemplate,imagefile,imageloc,imagealt,sumAcctnum,suggestAcctnum,summarizerfk,suggesterfk,changebyfk,updated_on)
	     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE() )" );

	    $doc_sth->execute($docid,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
		$skippubdate,$woadatetime,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$body,$fullbody,$freeview,$points,$comment,$note,
		$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagealt,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on);

	}
	else {
		my $doc_sth = $dbh->prepare( "UPDATE docitem SET deleted=?,outdated=?,nextdocid=?,priority=?,headline=?,regionhead=?,skipheadline=?,
		subheadline=?,unique=?,topic=?,link=?,skiplink=?,selflink=?,sysdate=?,pubdate=?,pubyear=?,skippubdate=?,woadatetime=?,
		expdate=?,reappeardate=?,region=?,regionfk=?,skipregion=?,source=?,sourcefk=?,skipsource=?,author=?,skipauthor=?,
		body=?,fullbody=?,freeview=?,points=?,comment=?,note=?,miscinfo=?,sectsubs=?,skiphandle=?,dtemplate=?,imagefile=?,imageloc=?,
		imagealt=?,sumAcctnum=?,suggestAcctnum=?,summarizerfk=?,suggesterfk=?,changebyfk=?,updated_on=CURDATE() WHERE docid = ?" );
		$doc_sth->execute($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
		$skippubdate,$woadatetime,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$body,$fullbody,$freeview,$points,$comment,$note,
		$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagealt,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$docid);
	    
	}
	
	#########  DO INDEXES ELSEWHERE ##############
	
}

sub create_docitem_table {
	#                        DO THIS MANUALLY ON THE DB SERVER
#                    	docid smallint auto_increment PRIMARY KEY,    # do this later, after conversion
	
$DOCITEM_SQL  = <<ENDDOCITEM
 CREATE TABLE docitems (
   docid          smallint unsigned not null,
   deleted        bit(1)       default 0,
   outdated       bit(1)       default 0,
   nextdocid      smallint  unsigned default 0,
   priority       char(1)      default '4',
   headline       varchar(200) default '',
   regionhead     char(1)      default 'N',
   skipheadline   bit(1)       default 0,
   subheadline    varchar(200) default '',
   unique         varchar(50)  default '',
   topic          varchar(50)  default '',
   link           varchar(200) default '',
   skiplink       bit(1)  default 0,
   selflink       char(1) default 'N',
   sysdate        char(8) default '',
   pubdate        char(8) default '',
   pubyear        char(4) default '',
   skippubdate    bit(1)  default 0,
   woadatetime    datetime default null,
   expdate        char(8) default '',
   reappeardate   char(8) default '',
   region         varchar(100) default '',
   regionfk       smallint  unsigned default 0,
   skipregion     bit(1)       default 0,
   source         varchar(100)  default '',
   sourcefk       smallint  unsigned default 0,
   skipsource     bit(1)       default 0,
   author         varchar(100) default '',
   skipauthor     bit(1)       default 1,
   body           text,
   fullbody       text,
   freeview       char(1)       default 'N',
   points         text,
   comment        varchar(1000) default '',
   note           varchar(300)  default '',
   miscinfo       varchar(300)  default '',
   sectsubs       varchar(200)  default '',
   skiphandle     char(1)       default 'N',
   dtemplate      varchar(20)   default '',
   imagefile      varchar(150)  default '',
   imagealt       varchar(150)  default '',
   imagealt       char(1)       default '',
   sumAcctnum     char(15)      default '',
   suggestAcctnum char(15)      default '',
   summarizerfk   smallint  unsigned default 0,
   suggesterfk    smallint  unsigned default 0,
   changebyfk     smallint  unsigned default 0,
   updated_on     date default null);
ENDDOCITEM

# INSERT INTO tablename (col_date) VALUE (CURDATE() )";           ###   date type = 'YYYY-MM-DD'
}
#48
#docid,deleted,outdated,nextdocid,priority,headline,regionhead,skipheadline,subheadline,unique,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,skippubdate,woadatetime,expdate,        char(8) default '',
#reappeardate,region,regionfk,skipregion,source,sourcefk,skipsource,author,skipauthor,body,fullbody,freeview,points,comment,note,miscinfo,
#sectsubs,skiphandle,dtemplate,imagefile,imageloc,imagealt,sumAcctnum,suggestAcctnum,summarizerfk,suggesterfk,changebyfk,updated_on   

#48
#$docid,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
#$skippubdate,$woadatetime,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$body,$fullbody,$freeview,$points,$comment,$note,
#$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagealt,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on CURDATE()

#33
#docid,deleted,priority,headline,regionhead,unique,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,expdate,region,regionfk,source,sourcefk,body,
#fullbody,freeview,points,comment,note,miscinfo,sectsubs,skiphandle,dtemplate,imagefile,imageloc,sumAcctnum,suggestAcctnum,updated_on   

#33
#$docid,$deleted,$priority,$headline,$regionhead,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$expdate,$region,$regionfk,$source,$sourcefk,$body,
#$fullbody,$freeview,$points,$comment,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagealt,$sumAcctnum,$suggestAcctnum,$updated_on CURDATE()


sub import_docitems      ####     WE REALLY SHOULD DO CONTRIBUTORS AND INDEXES FIRST  ###################
{
  opendir(ITEMDIR, "$itempath");
  my @itemfiles = readdir(ITEMDIR);
  closedir(ITEMDIR);

  $dbh = &db_connect() if(!$dbh);

#  $dbh->do("TRUNCATE TABLE docitems");

  my $doc_sth = $dbh->prepare("INSERT INTO docitem (docid,deleted,priority,headline,regionhead,unique,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,expdate,region,regionfk,source,sourcefk,body,ullbody,freeview,points,comment,note,miscinfo,sectsubs,skiphandle,dtemplate,imagefile,imageloc,sumAcctnum,suggestAcctnum,updated_on)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE() )" );
	
  my $filename = "";
  foreach $filename (@itemfiles) {

     unless(-f "$itempath/$filename" and $filename =~ /\.itm/) {
	     last;
	 }
	     
	 &get_doc_data($filename,'N');
	
	 unless($docid =~ /[0-6]{6}/) {
	      print "$docid Invalid docid <br>\n";
		  &write_index_flatfile ('Invalid_docid',$docid,'','');
	      last;
	 }
	
	 $n_docid = int($docid);
#                                                   # See if deleted	
	 my($delfilename,$rest) = strip(/\./,$filename,2);
	 $delfilename = $delfilename . '/\.del';
     $deleted = 1 if(-f "$deletepath/$delfilename");
      
     if($pubdate) {
          $pubyear  = substr($pubdate, 4, 5);
     }
     elsif($sysdate) {
          $pubyear  = substr($sysdate, 4, 5);	    
     }

     if($straightHTML eq 'Y') {
          $dtemplate = 'straight';
          print "$docid STRAIGHT -- $headline <br>\n";
	      &write_index_flatfile ('Straight_html',$docid,'','');  #log all straight templates - these may not really be data
	 }
 
     $regionfk = &get_regionid($region) unless($regionfk);

	 $source   = &get_source_linkmatch($link) unless($source);
	
     $sourcefk = &get_sourceid($source) if($source and !$sousrcefk);
      
     $dtemplate = $dTemplate;

     $doc_sth->execute($docid,$deleted,$priority,$headline,$regionhead,$unique,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$expdate,$region,$regionfk,$source,$sourcefk,$body,$fullbody,$freeview,$points,$comment,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagealt,$sumAcctnum,$suggestAcctnum);

     my @sectsubs = split(/;/,$sectsubs);
     foreach $sectsub (@sectsubs) {
		 my $index_exists = &if_exists_DBindex($sectsub,$docid);
		 unless($index_exists or $DB_indexes < 1) {
              my $lifo_sth = &DB_prepare_lifonum; #Prepare for execute in &updt_subsection_index
              my $maxsth   = &DB_prepare_getnew_lifo;
    	      &DB_add_to_indexes ($lifo_sth,$maxsth,$SSid,$docid,$stratus,$pubdate,$sysdate,$region,$headline,$topic,$stratus,$fLifonum);
## ??? Which? &DB_add_to_indexes  - or - &updt_subsection_index ??????
	          my($sectsubname,$rSectid,$rSubid,$stratus,$lifonum) = &split_sectsub($sectsub);  ## in indexes.pl
	          &split_section_ctrlB($sectsubname);
	          &updt_subsection_index($lifo_sth,$maxsth,$sectsubname,$cSSid,$cOrder,$pubdate,$sysdate,$headline,$region,$topic,$stratus,$lifonum);
         }
     }

#	Error message is "failed in fetchrow for maxlifo at indexes.pl". Location of error is in sub DB_getnew_lifo . A comment from an earlier attempt says "There is another way to get the max - see regions table in controlfiles (changed to regions.pl).
#	DB_indexes in the switches_codes table must be set to 1 in order for the indexes table to be accessed. Otherwise the script falls back to the flat files where order is determined by the physicalorder in the index flatfile rather than by Lifo.
	
  }
	
}

1;