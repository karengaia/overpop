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


sub display_one
{
 my ($print_it,$aTemplate) = @_;
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
  &process_template('Y',$aTemplate);  #in template_ctrl.pl
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
        &process_template('Y',$aTemplate);
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
  &clear_doc_variables;
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
 &get_contributor_form_values if($ipform !~ /chaseLink/);
 &get_doc_form_values;

 &update_control_files;  # if add or update needed
# &add_new_source;  #in sources.pl

 &get_docid;
##          for sysdate if new
 $sysdate = &calc_date('sys',0,'+');

# 0070  Do sections (most sections logic is in sections.pl)

 &do_sectsubs;     # in sectsubs.pl
## &do_keywords if($selkeywords =~ /[A-Za-z0-9]/ and $docaction ne 'D');

 &write_doc_item($docid);

 &log_volunteer if($sectsubs =~ /$summarizedSS|$suggestedSS/ or $ipform =~ /chaseLink/);

 my @save_sort = ($sectsubs,$pubdate,$sysdate,$headline,$region,$topic);

 &ck_popnews_weekly 
    if($addsectsubs =~ /$newsdigestSectid/ or $delsectsubs =~ /$newsdigestSectid/); ## in article.pl

 if($owner) {
   &print_review('ownerReview');
 }
 elsif($sectsubs =~ /Suggested_suggestedItem/ and $ipform =~ /newItemParse/) {
	print "<div style=\"font-family:arial;font-size:1.2em;margin-top:13px;margin-left:7px;\">&nbsp;&nbsp;Item has been submitted; Ready for next item:</div>\n";
	$fullbody = "";
	$DOCARRAY = "";   # get ready for the next one
	return;    # return to article.pl to print next page: another newItemParse form
 }
 else {
    &print_review('review');
 }

# my ($sectsubs,$pubdate,$sysdate,$headline,$region,$topic) = @save_sort;

 &hook_into_system($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); ## add to index files

 $sections="";
 $chgsectsubs = "$addsectsubs;$modsectsubs;$delsectsubs";
 $chgsectsubs =~  s/^;+//;  #get rid of leading semi-colons
 
 &do_html_page; ## create HTML file - this is in display.pl

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
  local($oldDocid) = $docid;

  if( ($action eq 'clone') 
     or ($docaction eq 'N') 
     or ($oldDocid !~ /[0-9]{6}/ and $action ne 'clone')
     or ($action eq 'new') ) {
    $docaction = 'N';
    $docid = &get_docCount;

#print "320  oldDocid $oldDocid docid $docid action $action docaction $docaction<br>\n";
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
     &hook_into_system($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); ## add to index files -- in sectsubs.pl
#  }
  &add_new_source if($addsource =~ /Y/);
  &add_new_region if($addregion =~ /Y/);

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

##  &ftp_trans_elements;

  &clear_doc_variables;
}



sub print_review
{
 my $template = $_[0];
 $sectsubs = "$sectsubs;$mobileSS" if($sectsubs =~ /$newsdigestSS/);
 &get_pages;
##         print the receipt
 &process_template('Y',$template);
 $aTemplate = $qTemplate;
 $print_it = 'N';
}


sub log_volunteer
{
 if($sumAcctnum =~ /[A-Za-z0-9]/) {	
     $addsectsubs .= ";Volunteer_log$sumAcctnum"; 
 }
 elsif($userid =~ /[A-Za-z0-9]/) {
     $addsectsubs .= ";Volunteer_log$userid";
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
 &hook_into_system($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic); # in sections.pl
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
   	   &hook_into_system($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$sysdate,$headline,$region,$topic);
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
    $sumAcctnum     = $EITEM{sumAcctnum};
    $suggestAcctnum = $EITEM{suggestAcctnum};
    $priority       = $EITEM{priority};
    $pubdate        = $EITEM{pubdate} if(!$pubdate);
    $expdate        = $EITEM{expdate};
    $expired        = $EITEM{expired};
    $srcdate        = $EITEM{srcdate};
    $source         = $EITEM{source} if(!$source);
    $source         = "" if($source eq "(select one)");
    $straightHTML   = $EITEM{straightHTML};
    $dTemplate      = $EITEM{dTemplate};
    $dTemplate      = 'straight' if($straightHTML eq 'Y');
    $dBoxStyle      = $EITEM{dBoxStyle};
 ## we already checked for link because it was easier that way
    $link           = $EITEM{link} if(!$link);
    $selflink       = $EITEM{"selflink"};
    $headline       = $EITEM{headline} if(!$headline);
    $topic          = $EITEM{topic};
    $region         = $EITEM{region};
    $regionhead     = $EITEM{regionhead};
    $body           = $EITEM{body};
    $points         = $EITEM{points};
    $comment        = $EITEM{comment};
    $fullbody       = $EITEM{fullbody};
    $miscinfo       = $EITEM{miscinfo};
    $freeview       = $EITEM{freeview};
    $note           = $EITEM{note};
    $keywords       = $EITEM{keywords};
    $sectsubs       = $EITEM{sectsubs};
    $unique         = $EITEM{unique};
    $skiphandle     = $EITEM{skiphandle};
    $imagefile      = $EITEM{imagefile};
    $imageloc       = $EITEM{imageloc};
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
 %EITEM = {};
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
 $headline       = $FORM{"headline$pgitemcnt"}   if($FORM{"headline$pgitemcnt"} =~ /[A-Za-z0-9]/);
 $topic          = $FORM{"topic$pgitemcnt"}      if($FORM{"topic$pgitemcnt"}    =~ /[A-Za-z0-9]/);
 $titlize        = $FORM{"titlize$pgitemcnt"};
 $selflink       = $FORM{"selflink$pgitemcnt"};
 $region         = $FORM{"region$pgitemcnt"}     if($FORM{"region$pgitemcnt"}   =~ /[A-Za-z0-9]/);
 $regionhead     = $FORM{"regionhead$pgitemcnt"} if($FORM{"regionhead$pgitemcnt"} =~ /[YN]/);
 $addregion      = $FORM{"addregion$pgitemcnt"}  if($FORM{"addregion$pgitemcnt"} =~ /[AU]/);
 $fSectsubs      = $FORM{"sectsubs$pgitemcnt"}   if($FORM{"sectsubs$pgitemcnt"} =~ /[A-Za-z0-9]/);
 $source         = $FORM{"source$pgitemcnt"}     if($FORM{"source$pgitemcnt"}   =~ /[A-Za-z0-9]/);
 ($source,$sregionname) = &get_source_linkmatch($link) if($sourcelink eq 'Y' and $link);
 $addsource      = $FORM{"addsource$pgitemcnt"}  if($FORM{"addsource$pgitemcnt"} =~ /[AU]/);
 $sourcelink     = $FORM{"sourcelink$pgitemcnt"} if($FORM{"sourcelink$pgitemcnt"});
 $body           = $FORM{"body$pgitemcnt"}       if($FORM{"body$pgitemcnt"}     =~ /[A-Za-z0-9]/);
 $points         = $FORM{"points$pgitemcnt"}     if($FORM{"points$pgitemcnt"}     =~ /[A-Za-z0-9]/);
 $fullbody       = $FORM{"fullbody$pgitemcnt"};
 $miscinfo       = $FORM{"miscinfo$pgitemcnt"};
  
 $dDocloc        = $FORM{"docloc_add$pgitemcnt"} if($FORM{"docloc_add$pgitemcnt"} =~ /[A-Za-z0-9]/);
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

  $updsectsubs     = $FORM{"updsectsubs$pgitemcnt"};
  $addsectsubs     = $FORM{"addsectsubs$pgitemcnt"};
  $newsprocsectsub = $FORM{"newsprocsectsub$pgitemcnt"} unless $newsprocsectsub;
  $pointssectsub   = $FORM{"pointssectsub$pgitemcnt"};
  $ownersectsub     = $FORM{"ownersectsub$pgitemcnt"};

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
	
    $unique         = $DATA{unique};
    $skiphandle     = $DATA{skiphandle};
    $imagefile      = $DATA{imagefile};
    $imageloc       = $DATA{imageloc};     
    $dSectsubs      = $sectsubs;
        
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
    &printSysErrExit(" File not found at filepath $filepath <small>doc2595 - docid *$docid*  ....itempath $itempath</small>");
    $found_it = "N";
 }
}



## 00555

sub clear_doc_data
{   
    $DATA{sumAcctnum}   = "";
    $DATA{suggestAcctnum} = "";
    $DATA{priority}     = "";
    $DATA{pubdate}      = "";
    $DATA{expdate}      = "";
    $DATA{expired}      = "";
    $DATA{sysdate}      = "";
    $DATA{srcdate}      = "";
    $DATA{source}       = "";
    $DATA{dTemplate}    = "";
    $DATA{dBoxStyle}    = "";
    $DATA{straightHTML} = "N";
    $DATA{link}         = "";
    $DATA{link2nd}      = "";
    $DATA{selflink}     = "";
    $DATA{headline}     = "";
    $DATA{region}       = "";
    $DATA{regionhead}   = "Y";
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
    $DATA{skiphandle}   = "N";
    $DATA{imagefile}    = "";
    $DATA{imageloc}     = "";
    $DATA{newsprocsectsub} = "";
    $DATA{pointssectsub} = "";
}

sub clear_doc_variables
{
    $advance            = "";
    $ipform             = "";
    $sumAcctnum         = "";
    $suggestAcctnum     = "";
    $priority           = "";
    $pubdate            = "";
    $pubday             = '00';
    $pubmonth           = '00';
    $pubyear            = '00';
    $expdate            = "";
    $expday             = '00';
    $expmonth           = '00';
    $expyear            = '00';
    $sysdate            = "$sysyear-$sysmm-$sysdd";
    $srcdate            = "";
    $source             = "";
    $dTemplate          = "";
    $dBoxStyle          = "";
    $wFormat            = "";
    $format             = "";
    $straightHTML       = "N";
    $link               = "";
    $link2nd            = "";
    $selflink           = "";
    $titlize            = "N";
    $headline           = "";
    $region             = "";
    $regionhead         = "N";
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
}


sub clear_work_variables
{
    $addsectsubs   = "";
    $newsprocsectsub = "";
    $pointssectsub   = "";
    $delsectsubs   = "";
}
   
## 00560
             
sub put_data_to_array
{
 $DOCARRAY{owner}          = $owner;
 $DOCARRAY{dir}            = $dir;
 $DOCARRAY{action}         = $action;
 $DOCARRAY{filedir}        = $filedir;
 $pgitemcnt = &padCount4($pgItemnbr);
 $DOCARRAY{pgitemcnt}      = $pgitemcnt; 
 $DOCARRAY{ssitemcnt}      = $ssItemcnt; 
 $DOCARRAY{selecttype}     = $selecttype;
 $DOCARRAY{svrdestCgisite} = $SVRdest{cgiSite};
 $DOCARRAY{svrinfoMaster}  = $SVRinfo{master};
 $DOCARRAY{svrinfoSvrname} = $SVRinfo{svrname};
 $DOCARRAY{adminEmail}     = $SVRinfo{adminEmail};
 $DOCARRAY{nowdate}        = $nowdate;
 $DOCARRAY{docCount}       = $docCount;
 $DOCARRAY{hitCount}       = $hitCount;
 $DOCARRAY{userCount}      = $userCount; 
 
 $DOCARRAY{acctnum}        = $acctnum;
 $DOCARRAY{access}         = $access;
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

  if($docid =~ /-/) {       ##  from emailed 
	  $docpath = "$mailpath/$docid\.itm";
  }
  else {
	  $docpath = "$itempath/$docid\.itm";

	  if(-f "../../karenpittsMac.yes") {
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
    chmod 0777, $emailfile if(-f "../../karenpittsMac.yes");
    unlink $lock_file if($lock_file);
  }
  else {
    print "Invalid sysdate=$sysdate or docid-$docid; Could not write out docitem at doc1185 Error message: $! <br>\n";
  }
  if($docid =~ /-/) {
     &write_index_straight($emailedSS,$docid);     # in sections.pl
     &DB_add_docid_to_index ($emailedSS,$docid) unless($DB_indexes < 1);    # in sections.pl
  }
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
  $docCount = "";

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

sub create_docitem_table {
#	CREATE TABLE docitems (
#		docid smallint unsigned not null,
# author
# subheadline
# deleted
#		PRIMARY KEY (docid)  # do this later, after conversion
#		)
}



1;