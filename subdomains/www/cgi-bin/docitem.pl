#!/usr/bin/perl --

# September 14 2012
#      docitem.pl

# docitem.pl processes doc info including parsing popnews email and converted items
##   to find headlines, source date, publisher, region, and other variables.
## docaction = new, before, after, clone, update, deleteitem, emailit
## docaction = N, C, D (after)
## doc sectsubs:  dSectid-dSubid`ddocloc^dNeardocid^dTemplate^
##                dSrcstyle^dHeadstyle^dBodystyle^dCmntstyle^dFullstyle

## 2012 Sep 14 - work on docitems to DB
## 2012 Jan 23 - Broke off smartdata.pl - for parsing data

sub init_docitem_variables
{
   $DOCARRAY = "";
   &clear_doc_data; 
   &clear_doc_variables;
   &clear_helper_variables;
   &clear_msgline_variables;

   $doc_update_sql = "UPDATE docitem SET deleted=?,outdated=?,nextdocid=?,priority=?,headline=?,regionhead=?,skipheadline=?,
	subheadline=?,special=?,topic=?,link=?,skiplink=?,selflink=?,sysdate=?,pubdate=?,pubyear=?,skippubdate=?,woapubdatetm=?,
	expdate=?,reappeardate=?,region=?,regionfks=?,skipregion=?,source=?,sourcefk=?,skipsource=?,author=?,skipauthor=?,needsum=?,
	body=?,fullbody=?,freeview=?,points=?,comment=7,bodyprenote=?,bodypostnote=?,note=?,miscinfo=?,sectsubs=?,skiphandle=?,dtemplate=?,imagefile=?,imageloc=?,
	imagedescr=?,recsize=?,worth=?,sumAcctnum=?,suggestAcctnum=?,summarizerfk=?,suggesterfk=?,changebyfk=?,updated_on=CURDATE() WHERE docid = ?"
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
	 ($found,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
	 = &get_doc_data($docid,$print_it);
   if($sectsubs =~ /$suggestedSS|$emailedSS/ and $access !~ /[ABCD]/
      and $cmd eq "processlogin") {
     $errmsg = "Sorry, you cannot access this article until it has been pre-processed. Please check the various Headlines lists";
     &printInvalidExit;
   }
 }
  &put_data_to_array;
  &process_template($aTemplate,'Y','N','N');  #in template_ctrl.pl
}

sub do_one_doc
 {
  my $index_insert_sth = $_[0];
  $docid =~ s/^\s//g;   ## trim non-alphanumerics
  $docid =~ s/\s$//g;   ## trim non-alphanumerics
  if(-f "$deletepath/$docid.del" and $doclistname !~ /$deleteSS/
      and -f "$printdeletedOFF") {
     return;
  }	    	                                
  ($found,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
	 = &get_doc_data($docid,'N');
   $expdate = "0000-00-00" if($expdate !~ /[0-9]/);    
#  $expired = "$expired;$docid"
#         if($sectsubs !~ /$expiredSS/ and $expdate ne "0000-00-00" and $expdate lt $nowdate);

  if($cmd eq 'init_section') {
       $sectsubs = $thisSectsub;
 ##    &write_doc_item($docid);   DISABLED UNTIL NEEDED
  }
  else {
     $select_item = &do_we_select_item;
     if($skip_item !~ /Y/ and $select_item eq 'Y') {
		  &print_one_doc ($aTemplate,$print_it,$email_it,$htmlfile_it,$ckItemnbr)
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
 ##   &write_doc_item($docid,$idx_insert_sth);
  }
#  &clear_doc_variables;
}

sub print_one_doc 
{
  ($aTemplate,$print_it,$email_it,$htmlfile_it,$ckItemnbr) = @_;

  &put_data_to_array;

  &process_template($aTemplate,'Y','N','N',$ckItemnbr);   #in template_ctrl
}

sub do_we_select_item
{
 my $select_item = "Y";	

# print "doc117 docid $docid listSectsub $listSectsub sectsubs $sectsubs ..cIdxSectsubid $cIdxSectsubid<br>\n";
 my $listSS = "";
 if($cIdxSectsubid) {
	$listSS = $cIdxSectsubid;
 }
 else {
	$listSS = $listSectsub;
 }
 if(!$listSS) {
	$select_item = 'Y';
 }
 elsif($listSS and $sectsubs and $sectsubs =~ /$listSS/) {
	$select_item = 'Y';
 }
 elsif($listSS and $sectsubs and $sectsubs !~ /$listSS/ and $listSS !~ /$emailedSS/) {
	$select_item = '';
 }
 else {
	$select_item = 'Y';
 }                     
                 # Don't print if sectsubs do not contain the list Sectsub (should have been deleted - bug fix)
                # Don't print if in headlines, etc; NewsDigest OK; no newsSections OK
 if($select_item eq 'Y') {
	 if($select_kgp eq 'Y'and ($sumAcctnum eq 'A3491' or $sumAcctnum !~ /[A-Z0-9]/) and $skiphandle ne 'Y') {
	 }
	 elsif($docid =~ /$startDocid/) {
	    $start_found = 'Y';
	 }
	 elsif($start_found eq 'Y') {
	 }
	 elsif($chk_pubdate =~ /[0-9]/ and $pubdate le $chk_pubdate) {
	 }
	 elsif($startDocid !~ /[0-9]/) {
	 }
	 else {
		$select_item = "";
	}
 }
 return($select_item);
}

sub do_body_comment   # from template_ctrl.pl
{
  ($body_sw,$bodycom) = @_;
##print "tem1102 now_email $now_email body $body\n";
  if($now_email eq 'Y') {
     $bodycom     =~ s/\r/" "/g;
     $bodycom     =~ s/\n/" "/g;
     $bodycom     =~ s/<i>/""/g;
     $bodycom     =~ s/<\/i>/""/g;
  }
  elsif($body_sw =~ /body/ and !$bodycom) {
     if($points and $needsum =~ /[45]/) {  #keypoints or keypoints + red arrow
	      $bodycom = $points;
     }
     else {
	      $bodycom = substr($fullbody,0,450);
     }  
  }
  else {
	 $bodycom =~ s/ {1-9}\n/\n/g;  # get rid of trailing spaces
	 my @bodylines = split(/\n/,$bodycom);
	 my $url = "";
	 my $acronym = "";
	 my $word = "";
	 my $title = "";
	 $bodycom = "";
	 foreach $bodycomline (@bodylines) {
	    if($bodycomline =~ /#http/ or $bodycomline =~ /#[A-Z]/ or $bodycomline =~ /#mp3#http/) { #link or acronym
		   my @words = split(/ /,$bodycomline);
		   $bodycomline = "";
		   foreach $word (@words) {
		       if($word =~ /^#([http|https]:\/\/.*)/ or $word =~ /##([http|https]:\/\/.*)/ or $word =~ /#mp3#(http:\/\/.*)/) {
				   $url = $1;
				   if($word =~ /##[http|https]:/) {   #   2 ##s = clickable url
					  $word = "<small><a target=\"blank\" href=\"$url\">$url<\/a><\/small>";
				   }
                   elsif($template eq "newsalertItem") {
				        $word = "Click left arrow ";
                   }
				   elsif($word =~ /#mp3#http:/) {   #   2 ##s = clickable url
					    $word .= "<object width=\"300\" height=\"42\"> <param name=\"src\" value=\"$url\">";
$word = <<ENDWORD;
<param name="autoplay" value="false">
<param name="controller" value="true">
<param name="bgcolor" value="#FFFFFF">
<embed 
ENDWORD
                         $word .= "src=\"$url\" autostart=\"false\" loop=\"false\" width=\"300\" height=\"42\" controller=\"true\" bgcolor=\"#FFFFFF\"><\/embed><\/object>";	
				   }
                   else {	
				        $word = "<a target=\"blank\" href=\"$url\">Click here<\/a>";
                   }	      
		       }
		       elsif($word =~ /^#([A-Za-z0-9\-]{2,30})/) {  
			      $acronym = $1;
			      $title = &get_title($acronym);  # in dbtables_ctrl.pl
                  if($title) {
			          $word = "<acronym title=\"$title\">$acronym<\/acronym>";
                  }
                  else {
	                  $word = $acronym;
                  }
		       }
		       $bodycomline = "$bodycomline$word ";
		   }
		   $bodycomline =~ s/^ +//;  #trim leading spaces
		   $bodycomline =~ s/ +$//;  #trim leading spaces
	    }
	    $bodycom = "$bodycom$bodycomline\n";
	 }
	 $bodycom =~ s/^\n+//;  #trim leading line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns
	 $bodycom =~ s/\n$//;  #trim trailing line returns	
	 $bodycom =~ s/\r$//;  #trim trailing line returns
	 $bodycom =~ s/\r$//;  #trim trailing line returns
	 $bodycom =~ s/\r$//;  #trim trailing line returns
	
     if($template =~ /straight|link/
	     or $bodycom =~ /<font|<center|<blockquote|<div|<table|<li|<dl|<dt|<dd/) {
	   $bodycom = &xhtmlify($docid,$template,$bodycom);  ## in docitem.pl
	 }
	 elsif ($bodycom =~ /\n\n/ and $template !~ /newsalertItem/) {
	      $bodycom =~ s/\n\n/<\/p><p>\n/g;
	 }
	 else {
	      $bodycom =~ s/\n/<br>\n/g;
	}
  }

  if($link and !$owner and $sectsubs =~ /$newsdigestSS/ and (!$body or $needsum =~ /[234579]/) ) {
	 $bodycom = "$bodycom <br><small>. . . more at <a target=\"_blank\" href=\"$link\">$source</a><\/small>";
  }
	
  $bodycom =~ s/\r/<br>/g;
  $bodycom =~ s/<\/p><p>$//g;   ## delete last paragraph
  $bodycom =~ s/<\/p><p>\n/<\/p>\n\n<p>/g;
  $bodycom =~ s/<br.{0-2}>//gi;   ## all line breaks
  $bodycom =~ s/<BR \/>//g;
  $bodycom = &apple_convert($bodycom);  # takes care of encoding
  $bodycom =~ s/ & / &#38; /g; ## ampersand to html code
  $bodycom =~ s/=27/&39#;/g;   ## single quote to html code
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  $bodycom =~ s/<br>$//;  #trim trailing line returns
  return($bodycom);
}



### ########  STOREFORM   ###########

sub storeform
{
#  &clear_doc_variables;
 &get_contributor_form_values if($ipform !~ /chaseLink/);
 &get_doc_form_values;
 &update_control_files;  # if add or update needed
 &main_storeform;
}

sub main_storeform {  #from above and also from write_email
 $docaction = 'N' unless($docid);
 &get_docid;
#          for sysdate if new
 $sysdate = &calc_date('sys',0,'+');
 &do_sectsubs;     # in sectsubs.pl

# &do_keywords if($selkeywords =~ /[A-Za-z0-9]/ and $docaction ne 'D');
 &write_doc_item($docid,$idx_insert_sth);

 &log_volunteer if($sectsubs =~ /$summarizedSS|$suggestedSS/ or $ipform =~ /chaseLink/);

 my @save_sort = ($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic);

 &ck_popnews_weekly 
    if($addsectsubs =~ /$newsdigestSectid/ or $delsectsubs =~ /$newsdigestSectid/); ## in article.pl

 ($sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic) = @save_sort;

 &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,'single'); ## add to index files in indexes.pl

 $sections="";
 $chgsectsubs = "$addsectsubs;$modsectsubs;$delsectsubs";
 $chgsectsubs =~  s/^;+//;  #get rid of leading semi-colons

 my $ipform = $FORM{'ipform'};

 $time4countfile = "$autosubdir/status/time4count.txt";
 system "touch $time4countfile" unless (-f $time4countfile); #If storeform, OK to write to countfile in indexes.pl

 if($owner) {
   &print_review($OWNER{'oreviewtemplate'});
   sleep 20;
   print "<br><br>Saved webpage:(you may need to reload the frame to get the most recent version)<br><iframe src=\"http://$publicUrl/$owner" . "_webpage/index.html\" width=\"1000\" height=\"1000\"></iframe>";
   print"</div></body></html>";
   return(0);
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
 &do_html_page($listSectsub,$aTemplate,1); ## create HTML file - this is in display.pl

}  ## END SUB


sub update_control_files {
 $addchgsource = $FORM{"addchgsource$pgitemcnt"};
 ($sourceid,$source,$rest) = split(/\^/,$source,3) if($addchgsource !~ /A/);
 $addchgregion = $FORM{"addchgregion$pgitemcnt"};
 ($regionid,$xseq,$xtyp,$region,$rest) = split(/\^/,$region,5) if($addchgregion !~ /A/);

# DON'T NEED -> &get_doc_source_crud_values if($addchgsource =~ /[AU]/ or $addchgregion =~ /[AU]/);

 $sourceid = &add_updt_source_values($source,$addchgsource,'docupdate');  #in sources.pl
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
  $listSectsub = $_[0];
  &clear_work_variables;

  $temp = $FORM{"sectsubs$pgitemcnt"};

 ($found,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
	 = &get_doc_data($docid,'N');  #in docitem.pl

  &get_more_select_form_values;  ## overrides prior doc values

  $fullbody = &line_fix($fullbody);
  $fullbody = &apple_line_endings($fullbody);
  $fullbody  =~ s/^\n*//g;
  $fullbody  =~ s/\n+$//g;

  if( ($fullbody =~ /^(DD|SS|MI|HH|SH|By:|RR) / or !$source) and $form_priority !~ /D/) {
     print "Redo docid $docid .... <small>doc264</small><br>\n";

     $fullbody = &parse_msg_4variables('R',$pdfline,$fullbody);   #smartdata.pl : P ep_type = parse from new form E = comes in from email R = redo
  }

  $doc_fullbody = $fullbody if($ipform =~ /chaseLink/);
##                   new priority overrides prior priority
  $priority = $form_priority;

  $priority = "4"  if($ipform =~ /chaseLink/ and $priority !~ /D/); ## drop priority since apparently volunteer didn't fill in form

  &change_sectsubs_for_updt_selected; # in sectsubs.pl  THIS IS LIKE DO_SECTSUBS IN STOREFORM.

  print "&nbsp;<font face=verdana><font size=1>$docid </font><font size=2>$headline </font><font size=1>ord-$sortorder $sectsubs</font><br>\n";

  &write_doc_item($docid,$idx_insert_sth);

#  &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic); ## add to index files -- in sectsubs.pl
  &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,'list'); ## -- in indexes.pl


  $sourceid = &add_updt_source_values($source,$addchgsource,'selupdate') if($addchgsource =~ /A/);  #in sources.pl
  $regionid = &add_updt_region_values($region,$addchgregion) if($adchgregion);  #in regions.pl
#  &add_new_source if($addsource =~ /Y/);
#  &add_new_region if($addregion =~ /Y/);

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
  undef $FORM{"addchgsource$pgitemcnt"};
  undef $FORM{"addchgregion$pgitemcnt"};
  undef $temp;

	undef  $FORM{'docid'};
	undef  $FORM{'deleted'};   ## New variables
	undef  $FORM{'outdated'};
	undef  $FORM{'nextdocid'};

	undef  $FORM{'skippubdate'};
	undef  $FORM{'woapubdatetm'};
	undef  $FORM{'reappeardate'};

	undef  $FORM{'sourcefk'};
	undef  $FORM{'skipsource'};
	undef  $FORM{'author'};
	undef  $FORM{'skipauthor'};
	undef  $FORM{'needsum'};

	undef  $FORM{'dtemplate'};

	undef  $FORM{'skiplink'};

	undef  $FORM{'skipheadline'};
	undef  $FORM{'subheadline'};

	undef  $FORM{'regionfks'};
	undef  $FORM{'skipregion'};
	undef  $FORM{'imagloc'};
	undef  $FORM{'imagefile'};
	undef  $FORM{'imagedescr'};
	undef  $FORM{'recsize'};
	undef  $FORM{'worth'};
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
 &put_data_to_array;
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


sub process_popnews_email       # from selecteditems_crud.pl when item selected from Suggested_emailedItem list
{
 ($edocid,$elink,$epriority,$index_insert_sth) = @_;
 my $found = "";
	
 ($found,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
	 = &get_doc_data($edocid,'N');
 if($found) {	
	 &get_more_select_form_values; #Overrides current docitem with values from form

	$docid = &get_docCount;        # replace emailed docid with new docid from the system
	if($fullbody =~ /^(DD|SS|MI|HH|SH|By:|RR) /) {
	    print "Redo doc370 docid $docid<br>\n";
	    $fullbody = &parse_msg_4variables('R',$pdfline,$fullbody)   # in smartdata.pl .. P ep_type = parse from new form E = comes in from email R = redo
	}
	$link = $elink;
	$priority = $epriority;

	$addsectsubs = $suggestedSS;
	$sectsubs = $suggestedSS;
	$delsectsubs = "";

	&write_doc_item($docid,$idx_insert_sth);

	# &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic); # in indexes.pl
	&hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,'list'); # in indexes.pl

	print "$edocid ...docid $docid ..headline $headline ... selected<br>\n";
 }
 else {
    print "$edocid ...docid $docid ............. not found ..doc402<br>\n";	
 }
}


sub do_expired
{
## if($expired =~ /[A-Za-z0-9]/) {
if($expired =~ /goofy/) {
	  $idx_insert_sth = &DB_prepare_idx_insert(""); #in indexes table; prepare only once
      @expired = split(/;/,$expired);
      foreach $docid (@expired) {
	   ($found,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
		 = &get_doc_data($docid,N);  ## in docitem.pl
   	   $delsectsubs = $sectsubs;
   	   $addsectsubs = $expiredSS;
   	   $sectsubs    = $expiredSS;
   	   &write_doc_item($docid,$idx_insert_sth);  ## in docitem.pl
#      &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic);
   	   &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,'single');  # in indexes.pl
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


####  00530    VARIBLE PROCESSING ######

sub fill_email_variables
{
    $sumAcctnum     = $EITEM{'sumAcctnum'}     if($EITEM{'sumAcctnum'}) ;
    $suggestAcctnum = $EITEM{'suggestAcctnum'} if($EITEM{'suggestAcctnum'});
    $priority       = $EITEM{'priority'}       if($EITEM{'priority'});
    $pubdate        = $EITEM{'pubdate'}        if(!$pubdate and $EITEM{'pubdate'});
    $woapubdatetm   = $EITEM{'woapubdatetm'}   if(!$woapubdatetm and $EITEM{'woapubdatetm'});
    $expdate        = $EITEM{'expdate'}        if($EITEM{'expdate'});
    $outdated        = $EITEM{'outdated'}      if($EITEM{'outdated'});
    $srcdate        = $EITEM{'srcdate'}        if($EITEM{'srcdate'});
    $source         = $EITEM{'source'}         if(!$source and $EITEM{'source'});
    $source         = "" if($source eq "(select one)");
    $straightHTML   = $EITEM{'straightHTML'};
    $dTemplate      = $EITEM{'dTemplate'}      if($EITEM{'dTemplate'});
    $dTemplate      = 'straight' if($straightHTML eq 'Y');
 ## we already checked for link because it was easier that way
    $link           = $EITEM{'link'}           if(!$link and $EITEM{'link'});
    $selflink       = $EITEM{'"selflink"'};
    $headline       = $EITEM{'headline'}       if(!$headline and $EITEM{'headline'});
    $topic          = $EITEM{'topic'}          if($EITEM{'topic'});
    $region         = $EITEM{'region'}         if(!$region and $EITEM{'region'});
	$regionfks       = $EITEM{'regionfks'}       if(!$regionfks and $EITEM{'regionfks'});
	$regionhead     = $EITEM{'regionhead'};
    $body           = $EITEM{'body'}           if(!$body and $EITEM{'body'});
    $points         = $EITEM{'points'}         if(!$points and $EITEM{'points'});
    $comment        = $EITEM{'comment'}        if(!$comment and $EITEM{'comment'});
    $bodyprenote    = $EITEM{'bodyprenote'}    if($EITEM{'bodyprenote'});
    $bodypostnote   = $EITEM{'bodypostnote'}   if($EITEM{'bodypostnote'});
    $fullbody       = $EITEM{'fullbody'}       if($EITEM{'fullbody'});
    $fullbody       = $EITEM{'fullbody'}       if($EITEM{'fullbody'});
    $miscinfo       = $EITEM{'miscinfo'}       if($EITEM{'miscinfo'});
    $freeview       = $EITEM{'freeview'};
    $note           = $EITEM{'note'}           if(!$note and $EITEM{'note'});
    $keywords       = $EITEM{'keywords'}       if($EITEM{'keywords'});
    $sectsubs       = $EITEM{'sectsubs'}       if(!$sectsubs and $EITEM{'sectsubs'});
    $special         = $EITEM{'special'}         if($EITEM{'special'});
    $skiphandle     = $EITEM{'skiphandle'};
    $imagefile      = $EITEM{'imagefile'}      if(!$imagefile and $EITEM{'imagefile'});
    $imageloc       = $EITEM{'imageloc'}       if(!$imageloc and $EITEM{'imageloc'});
	$imagedesc       = $EITEM{'imagedesc'}       if(!$imagealt and $EITEM{'imagedesc'});
	
	$deleted        = $EITEM{'deleted'};    ## Start new variables section
	$outdated       = $EITEM{'outdated'}; 
	$nextdocid      = $EITEM{'nextdocid'};

	$skippubdate  = $EITEM{'skippubdate'};
	$woapubdatetm  = $EITEM{'woapubdatetm'};
	$reappeardate = $EITEM{'reappeardate'};

	$sourcefk     = $EITEM{'sourcefk'};
	$skipsource   = $EITEM{'skipsource'};
	$author       = $EITEM{'author'}           if(!$author and $EITEM{'author'});
	$skipauthor   = $EITEM{'skipauthor'};
	$needsum      = $EITEM{'needsum'}           if(!$needsum and $EITEM{'needsum'});
	$skiplink     = $EITEM{'skiplink'};
	$skipheadline = $EITEM{'skipheadline'};
	$subheadline  = $EITEM{'subheadline'}      if(!$subheadline and $EITEM{'subheadline'});
    $recsize      = $EITEM{'recsize'}          if(!$recsize and $EITEM{'recsize'});
    $worth        = $EITEM{'worth'}            if(!$worth and $EITEM{'worth'});
	$skipregion   = $EITEM{'skipregion'};
	$summarizerfk = $EITEM{'summarizerfk'};
	$suggesterfk  = $EITEM{'suggesterfk'};
	$changebyfk   = $EITEM{'changebyfk'};
	$updated_on   = $EITEM{'updated_on'};  ###       End of new variables
}

sub clear_email_variables
{
 undef $EITEM{'sumAcctnum'};
 undef $EITEM{'suggestAcctnum'};
 undef $EITEM{'priority'}; 
 undef $EITEM{'pubdate'};
 undef $EITEM{'expdate'};
 undef $EITEM{'srcdate'}; 
 undef $EITEM{'source'};
 undef $EITEM{'straightHTML'};
 undef $EITEM{'dTemplate'};
 undef $EITEM{'dBoxStyle'};
 undef $EITEM{'link'};
 undef $EITEM{'titlize'};
 undef $EITEM{'selflink'};
 undef $EITEM{'headline'};
 undef $EITEM{'region'};
 undef $EITEM{'regionhead'};
 undef $EITEM{'topic'};
 undef $EITEM{'body'};;
 undef $EITEM{'comment'};
 undef $EITEM{'bodyprenote'};
 undef $EITEM{'bodypostnote'};
 undef $EITEM{'fullbody'};
 undef $EITEM{'freeview'};
 undef $EITEM{'note'};
 undef $EITEM{'miscinfo'};
 undef $EITEM{'keywords'};
 undef $EITEM{'special'};
 undef $EITEM{'skiphandle'};
 undef $EITEM{'imagefile'};
 undef $EITEM{'imageloc'};
 undef $EITEM{'imagedesc'};

undef  $EITEM{'deleted'};   ## New variables
undef  $EITEM{'outdated'};
undef  $EITEM{'nextdocid'};

undef  $EITEM{'skippubdate'};
undef  $EITEM{'woapubdatetm'};
undef  $EITEM{'reappeardate'};

undef  $EITEM{'sourcefk'};
undef  $EITEM{'skipsource'};
undef  $EITEM{'author'};
undef  $EITEM{'skipauthor'};
undef  $EITEM{'needsum'};

undef  $EITEM{'dtemplate'};

undef  $EITEM{'skiplink'};

undef  $EITEM{'skipheadline'};
undef  $EITEM{'subheadline'};
undef  $EITEM{'recsize'};
undef  $EITEM{'worth'};
undef  $EITEM{'regionfks'};
undef  $EITEM{'skipregion'};
undef  $EITEM{'summarizerfk'};
undef  $EITEM{'suggesterfk'};
undef  $EITEM{'changebyfk'};
undef  $EITEM{'updated_on'};   ## End NEW VARIABLES


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
  $priority       = "5";
  $docid          = $FORM{"docid$pgitemcnt"};
  $docid          = $FORM{"sdocid$pgitemcnt"} unless($docid);
  $priority       = $FORM{"priority$pgitemcnt"} if($FORM{"priority$pgitemcnt"} =~ /[D1-7]/);
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
 $fSectsubs      = $listSectsub if(!$fSectsubs and $listSectsub =~ /Suggested_suggestedItem/);
 $source         = $FORM{"source$pgitemcnt"}     if($FORM{"source$pgitemcnt"});
 $linkmatch      = $FORM{"linkmatch$pgitemcnt"}     if($FORM{"linkmatch$pgitemcnt"});
 $sstarts_with_the = $FORM{"sstarts_with_the$pgitemcnt"} if($FORM{"sstarts_with_the$pgitemcnt"});
 ($source,$sregionname) = &get_source_linkmatch($link) if($sourcelink eq 'Y' and $link);
 $addchgsource   = $FORM{"addchgsource$pgitemcnt"}  if($FORM{"addchgsource$pgitemcnt"} =~ /[AU]/);
 $addchgregion   = $FORM{"addchgregion$pgitemcnt"}  if($FORM{"addchgregion$pgitemcnt"} =~ /[AU]/);
 $sourcelink     = $FORM{"sourcelink$pgitemcnt"} if($FORM{"sourcelink$pgitemcnt"});
 $body           = $FORM{"body$pgitemcnt"}       if($FORM{"body$pgitemcnt"});
 $points         = $FORM{"points$pgitemcnt"}     if($FORM{"points$pgitemcnt"}     =~ /[A-Za-z0-9]/);
 $fullbody       = $FORM{"fullbody$pgitemcnt"};
 $lfx2           = $FORM{"lfx2$pgitemcnt"};
 $fullbody =~ s/\r/\n/g;
 if($lfx2 eq 'Y') {
#	$fullbody =~ s/\r/\n/g;
    $fullbody =~ s/\n\n/<p>/g;
    $fullbody =~ s/\n/\n\n/g;
    $fullbody =~ s/<p>/\n\n/g;
 }
 $miscinfo       = $FORM{"miscinfo$pgitemcnt"};
  
 $dDocloc        = $FORM{"docloc_add$pgitemcnt"} if($FORM{"docloc_add$pgitemcnt"} =~ /[A-Za-z0-9]/);

 $author         = $FORM{"author$pgitemcnt"}      if($FORM{"author$pgitemcnt"});
 $skipauthor     = $FORM{"skipauthor$pgitemcnt"}  if($FORM{"skipauthor$pgitemcnt"});
 $needsum        = $FORM{"needsum$pgitemcnt"}     if($FORM{"needsum$pgitemcnt"});
 $dtemplate      = $FORM{"dtemplate$pgitemcnt"}   if($FORM{"dtemplate$pgitemcnt"});
 $skipheadline   = $FORM{"skipheadline$pgitemcnt"} if($FORM{"skipheadline$pgitemcnt"});
 $subheadline    = $FORM{"subheadline$pgitemcnt"} if($FORM{"subheadline$pgitemcnt"});
 $linkmatch      = $FORM{"linkmatch$pgitemcnt"}   if($FORM{"linkmatch$pgitemcnt"});

 if($fSectsubs =~ /(Suggested_suggestedItem|$emailedSS)/ or $titlize =~ /Y/) {
    ($headline,$rest) = split(/Date:/,$headline,2) if($headline =~ /Date:/);
#    $headline = &titlize($headline);  #in smartdata.pl
 }
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
  $body =~ s/\r/\n/g;
#$temp = $body;
#$temp =~ s/\n/LF/g;
#$temp =~ s/\r/CR/g;
# print "doc835 temp $temp<br>\n";
  $points         = $FORM{"points$pgitemcnt"};
  $points =~ s/\r/\n/g;
  $comment        = $FORM{"comment$pgitemcnt"};
  $comment =~ s/\r/\n/g;
  $bodyprenote    = $FORM{"bodyprenote$pgitemcnt"};
  $bodyprenote =~ s/\r/\n/g;
  $bodypostnote   = $FORM{"bodypostnote$pgitemcnt"};
  $bodypostnote =~ s/\r/\n/g;
  $fullbody       = $FORM{"fullbody$pgitemcnt"};
  $fullbody =~ s/\r/\n/g;
  
  $docfullbody    = "";
  $docfullbody    = $FORM{"docfullbody$pgitemcnt"};
  $docfullbody =~ s/\r/\n/g;
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
  $special         = $FORM{"special$pgitemcnt"};
  $imagefile      = $FORM{"imagefile$pgitemcnt"};
  $imageloc       = $FORM{"imageloc$pgitemcnt"};
  $imagedescr     = $FORM{"imagedescr$pgitemcnt"};
  $docaction      = $FORM{"docaction$pgitemcnt"};
  $sectsubs       = $FORM{"sectsubs$pgitemcnt"};
  $worth          = $FORM{"worth$pgitemcnt"};
  $recsize        = $FORM{"recsize$pgitemcnt"};
  $thisSectsub    = $FORM{"thisSectsub$pgitemcnt"} if($FORM{"thisSectsub$pgitemcnt"});
  $listSectsub = $thisSectsub;

  $deleted      = $FORM{"deleted$pgitemcnt"};    ## Start new variables section
  $outdated     = $FORM{"outdated$pgitemcnt"}; 
  $nextdocid    = $FORM{"nextdocid$pgitemcnt"};

  $skippubdate  = $FORM{"skippubdate$pgitemcnt"};
  $woapubdatetm = $FORM{"woapubdatetm$pgitemcnt"};
  $reappeardate = $FORM{"reappeardate$pgitemcnt"};

  $sourcefk     = $FORM{"sourcefk$pgitemcnt"};
  $skipsource   = $FORM{"skipsource$pgitemcnt"};
  $author       = $FORM{"author$pgitemcnt"};
  $skipauthor   = $FORM{"skipauthor$pgitemcnt"};

  $needsum      = $FORM{"needsum$pgitemcnt"};

  $dtemplate    = $FORM{"dtemplate$pgitemcnt"};

  $skiplink     = $FORM{"skiplink$pgitemcnt"};

  $skipheadline = $FORM{"skipheadline$pgitemcnt"};
  $subheadline  = $FORM{"subheadline$pgitemcnt"};

  $regionfks     = $FORM{"regionfks$pgitemcnt"};
  $skipregion   = $FORM{"skipregion$pgitemcnt"};;
  $summarizerfk = $FORM{"summarizerfk$pgitemcnt"};
  $suggesterfk  = $FORM{"suggesterfk$pgitemcnt"};
  $changebyfk   = $FORM{"changebyfk$pgitemcnt"};
  $updated_on   = $FORM{"updated_on$pgitemcnt"};
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

  if($sectsubs =~ /(Suggested_suggestedItem|$emailedSS)/ or $titlize =~ /Y/) {
     ($headline,$rest) = split(/Date:/,$headline,2) if($headline =~ /Date:/);
#     $headline = &titlize($headline);  #in smartdata.pl
  }
    
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
  return("") unless($docid);
  my $found_it = "";
  
  &clear_doc_data;

  if($docid =~ /-/) {      
	  $filepath = "$mailpath/$docid.itm";
  }
  elsif($DB_docitems < 1 or $cmd eq 'import') {
	  $filepath = "$itempath/$docid.itm";
  }
  else {	## TODO DB return $row; if not $row: return ""
	  ($deleted,$priority,$headline,$regionhead,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$region,$regionfks,$source,$sourcefk,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum)
	   = &DB_get_docitem($docid);
	   return("");	
  }
##    flatfile processing
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

	($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
	= &extract_docitem_variables;
 }
 else {
   $found_it = "";
   $headline = "File not found at doc981 - docid *$docid*";
 }        
 return($found_it,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
}

sub extract_docitem_variables
{
    $sumAcctnum     = $DATA{'sumAcctnum'};
    ($sumAcctnum,$rest) = split(/;/,$sumAcctnum,2) if($sumAcctnum =~ /;/);
    $suggestAcctnum = $DATA{'suggestAcctnum'};
    $priority       = $DATA{'priority'};
    $priority       = '5' unless($priority =~ /[D1-7]/);
    $pubdate        = $DATA{'pubdate'};
    $woapubdatetm   = $DATA{'woapubdatetm'};
    $expdate        = $DATA{'expdate'};
    ($expyear,$expmonth,$expday) = split(/-/,$expdate,3);
    $sysdate        = $DATA{'sysdate'};
    $srcdate        = $DATA{'srcdate'};
    $source         = $DATA{'source'};
    $source         = "" if($source eq "(select one)");
    $straightHTML   = $DATA{'straightHTML'};
    if($straightHTML eq 'Y') {
    	$dTemplate = 'straight';
    }
    else {
        $dTemplate = $DATA{'dTemplate'}; 
    }
    $dBoxStyle      = $DATA{'dBoxStyle'}; 
    $link           = $DATA{'link'};
    $link =~ s/^\s+//; 
    $link2nd        = $DATA{'link2nd'};
    $link2nd =~ s/^\s+//;
    $selflink       = $DATA{'selflink'};
    $topic          = $DATA{'topic'};
    $region         = $DATA{'region'};           
    $regionhead     = $DATA{'regionhead'};
    $headline       = $DATA{'headline'};
    $body           = $DATA{'body'};
    $points         = $DATA{'points'};
    $body =~ s/\n+$//g;    ## trim trailing line feeds
    $body =~ s/\r+$//g;    ## trim trailing returns
    $body =~ s/\n\r+$//g;  ## trim trailing returns
    $body =~ s/\r\n+$//g;  ## trim trailing returns
    $points =~ s/\s+$//g;  ## trim white space
    $points =~ s/\n+$//g;  ## trim trailing line feeds
    $points =~ s/\r+$//g;  ## trim trailing returns
    $points =~ s/\n\r+$//g; ## trim trailing returns
    $points =~ s/\r\n+$//g; ## trim trailing returns
    $points =~ s/\s+$//g;   ## trim white space
    $comment        = $DATA{'comment'};
    $bodyprenote    = $DATA{'bodyprenote'};
    $bodypostnote   = $DATA{'bodypostnote'};
    $fullbody       = $DATA{'fullbody'};
    $freeview       = $DATA{'freeview'};
    $note           = $DATA{'note'};
    $miscinfo       = $DATA{'miscinfo'};
    $keywords       = $DATA{'keywords'};
    $sectsubs       = $DATA{'sectsubs'};
##                          correct error which added NA to sectsubs, wrote to NA index

    $sectsubs =~ s/NA`M;//;
    $sectsubs =~ s/NA;//;

    $special      = $DATA{'special'};
    $skiphandle   = $DATA{'skiphandle'};
    $imagefile    = $DATA{'imagefile'};
    $imageloc     = $DATA{'imageloc'}; 
	$imagedescr   = $DATA{'imagedescr'};    
    $dSectsubs    = $sectsubs;

	$deleted      = $DATA{'deleted'};          ## start new section of variables
	$outdated     = $DATA{'outdated'};
	$nextdocid    = $DATA{'nextdocid'};

	$skippubdate  = $DATA{'skippubdate'};
	$woapubdatetm = $DATA{'woapubdatetm'};
	$reappeardate = $DATA{'reappeardate'};

	$sourcefk     = $DATA{'sourcefk'};
	$skipsource   = $DATA{'skipsource'};
	$author       = $DATA{'author'};
	$skipauthor   = $DATA{'skipauthor'};
	$needsum      = $DATA{'needsum'};
	
	$dtemplate    = $DATA{'dtemplate'};

	$skiplink     = $DATA{'skiplink'};

	$skipheadline = $DATA{'skipheadline'};
	$subheadline  = $DATA{'subheadline'};
	$recsize      = $DATA{'worth'};
    $worth        = $DATA{'worth'};
	$regionfks    = $DATA{'regionfks'};
	$skipregion   = $DATA{'skipregion'};
	$summarizerfk = $DATA{'summarizerfk'};
	$suggesterfk  = $DATA{'suggesterfk'};
	$changebyfk   = $DATA{'changebyfk'};
	$updated_on   = $DATA{'updated_on'};                 ## end new section of variables

    $fullbody =  &reverse_regexp_prep($fullbody);   ##  common.pl

    if($rSectsubid =~ /(Suggested_suggestedItem|$emailedSS)/ or $titlize =~ /Y/) {
       ($headline,$rest) = split(/Date:/,$headline,2) if($headline =~ /Date:/);
       $headline = &titlize($headline);  #in smartdata.pl
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

	return($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on);
}


## 00555

sub clear_doc_data
{   
    $DATA{'sumAcctnum'}   = "";
    $DATA{'suggestAcctnum'} = "";

    $DATA{'deleted'} = 0;
    $DATA{'outdated'} = 0;
    $DATA{'nextdocid'} = 0;

    $DATA{'priority'}     = "";
    $DATA{'pubdate'}      = "";
    $DATA{'expdate'}      = "";
    $DATA{'outdated'}      = "";
    $DATA{'sysdate'}      = "";
    $DATA{'srcdate'}      = "";

    $DATA{'skippubdate'} = 0;
    $DATA{'woapubdatetm'} = $epoch_time;
    $DATA{'reappeardate'} = $nulldate;

    $DATA{'source'}       = "";

    $DATA{'sourcefk'}   = 0;
    $DATA{'skipsource'} = 0;
    $DATA{'author'}     = "";
    $DATA{'skipauthor'} = 1;
    $DATA{'needsum'}     = "";
    $DATA{'dTemplate'}    = "";
    $DATA{'dtemplate'}    = "";

    $DATA{'dBoxStyle'}    = "";
    $DATA{'straightHTML'} = "N";
    $DATA{'link'}         = "";
    $DATA{'link2nd'}      = "";
    $DATA{'selflink'}     = "";

    $DATA{'skiplink'}     = 0;

    $DATA{'headline'}     = "";

    $DATA{'skipheadline'} = 0;
    $DATA{'subheadline'}     = "";

    $DATA{'region'}       = "";
    $DATA{'regionhead'}   = "N";

    $DATA{'regionfks'} = 0;
    $DATA{'skipregion'} = 0;

    $DATA{'topic'}        = "";
    $DATA{'body'}         = "";
    $DATA{'fullbody'}     = "";
    $DATA{'freeview'}     = "N";
    $DATA{'bodyprenote'}  = "";
    $DATA{'bodypostnote'} = "";
    $DATA{'comment'}      = "";
    $DATA{'note'}         = "";
    $DATA{'miscinfo'}     = "";
    $DATA{'keywords'}     = "";
    $DATA{'special'}       = "";
    $DATA{'sectsubs'}     = "";
    $DATA{'newsprocsectsub'} = "";    ## Do we need?
    $DATA{'pointssectsub'} = "";
    $DATA{'skiphandle'}   = "N";
    $DATA{'imagefile'}    = "";
    $DATA{'imageloc'}     = "";
    $DATA{'imagealt'}     = "";
    $DATA{'recsize'}      = 0;
    $DATA{'worth'}      = 0;
    $DATA{'skipregion'}   = 0;
    $DATA{'summarizerfk'} = 0;
    $DATA{'suggesterfk'}  = 0;
    $DATA{'changebyfk'}   = 0;
    $DATA{'updated_on'}   = $nulldate;
#22
}

sub clear_doc_variables
{
	$nulldate           = '0000-00-00';
	$nulldatetime       = '0000-00-00 00:00:00';
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
    $woapubdatetm       = $nulldatetime;
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

    $needsum            = "";
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

    $regionfks           = 0;
    $skipregion         = 0;
    $topic              = "";
    $body               = "";
    $points             = "";
    $fullbody           = "";
    $freeview           = "N";
    $bodypostnote       = "";
    $bodyprenote        = "";
    $comment            = "";
    $note               = "";
    $miscinfo           = "";
    $emailnote          = "";
    $keywords           = "";
    $special             = "";
    $sectsubs           = "";
    $dSectsubs          = "";
    $fSectsubs          = "";
    $newsprocsectsub    = "";
    $pointssectsub      = "";
    $skiphandle         = "N";
    $imagefile          = "";
    $imageloc           = "";
    $imagedescr         = "";
    $recsize            = 0;
    $worth              = 0;
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
 $DOCARRAY{'deleted'}      = $deleted;
 $DOCARRAY{'outdated'}     = $outdated;
 $DOCARRAY{'nextdocid'}    = $nextdocid;

 $DOCARRAY{'skippubdate'}  = $skippubdate;
 $DOCARRAY{'woapubdatetm'} = $woapubdatetm;
 $DOCARRAY{'reappeardate'} = $reappeardate;

 $DOCARRAY{'sourcefk'}     = $sourcefk;
 $DOCARRAY{'skipsource'}   = $skipsource;
 $DOCARRAY{'author'}       = $author;
 $DOCARRAY{'skipauthor'}   = $skipauthor;
 $DOCARRAY{'needsum'}      = $needsum;

 $DOCARRAY{'dtemplate'}    = $dtemplate;

 $DOCARRAY{'skiplink'}     = $skiplink;

 $DOCARRAY{'skipheadline'} = $skipheadline;
 $DOCARRAY{'subheadline'}  = $subheadline;

 $DOCARRAY{'regionfks'}     = $regionfks;
 $DOCARRAY{'skipregion'}   = $skipregion;
 $DOCARRAY{'skipregion'}   = $skipregion;
 $DOCARRAY{'summarizerfk'} = $summarizerfk;
 $DOCARRAY{'suggesterfk'}  = $suggesterfk;
 $DOCARRAY{'changebyfk'}   = $changebyfk;
 $DOCARRAY{'updated_on'}   = $updated_on;


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
 $DOCARRAY{'sumAcctnum'}     = $sumAcctnum; 
 $DOCARRAY{'suggestAcctnum'} = $suggestAcctnum; 
 $DOCARRAY{'userid'}         = $userid; 
 $DOCARRAY{'useremail'}      = $useremail; 
 $DOCARRAY{'firstname'}      = $firstname; 
 $DOCARRAY{'lastname'}       = $lastname;
 $DOCARRAY{'pin'}            = $pin; 
 $DOCARRAY{'city'}           = $city; 
 $DOCARRAY{'zip'}            = $zip; 
 $DOCARRAY{'handle'}         = $sumHandle; 
 $DOCARRAY{'usercomment'}    = $usercomment; 
 $DOCARRAY{'pay'}            = $pay;
 
 $DOCARRAY{'docid'}       = $docid;
 $DOCARRAY{'priority'}    = $priority;
 $DOCARRAY{'pubdate'}     = $pubdate;
 $DOCARRAY{'pubday'}      = $pubday;
 $DOCARRAY{'pubmonth'}    = $pubmonth;
 $DOCARRAY{'pubyear'}     = $pubyear;
 $DOCARRAY{'expdate'}     = $expdate;
 $DOCARRAY{'expday'}      = $expday;
 $DOCARRAY{'expmonth'}    = $expmonth;
 $DOCARRAY{'expyear'}     = $expyear;
 $DOCARRAY{'sysdate'}     = $sysdate;
 $DOCARRAY{'srcdate'}     = $srcdate;
 $DOCARRAY{'source'}      = $source; 
 $DOCARRAY{'dTemplate'}   = $dTemplate; 
 $DOCARRAY{'straightHTML'} = $straightHTML;
 $DOCARRAY{'dBoxStyle'}    = $dBoxStyle;
 $DOCARRAY{'link'}        = $link;
 $DOCARRAY{'link2nd'}     = $link2nd;
 $DOCARRAY{'selflink'}    = $selflink;
 $DOCARRAY{'headline'}    = $headline; 
 $DOCARRAY{'region'}      = $region; 
 $DOCARRAY{'regionhead'}  = $regionhead;
 $DOCARRAY{'topic'}       = $topic;  
 $DOCARRAY{'body'}        = $body;
 $DOCARRAY{'points'}      = $points;
 $DOCARRAY{'fullbody'}    = $fullbody; 
 $DOCARRAY{'freeview'}    = $freeview; 
 $DOCARRAY{'comment'}     = $comment; 
 $DOCARRAY{'bodyprenote'} = $bodyprenote;
 $DOCARRAY{'bodypostnote'} = $bodypostnote;
 $DOCARRAY{'note'}        = $note; 
 $DOCARRAY{'miscinfo'}    = $miscinfo; 
 $DOCARRAY{'keywords'}    = $keywords; 
 $DOCARRAY{'special'}      = $special; 
 $DOCARRAY{'imagefile'}   = $imagefile; 
 $DOCARRAY{'imageloc'}    = $imageloc;
 $DOCARRAY{'imagedescr'}     = $imagealt;
 $DOCARRAY{'sectsubs'}    = $sectsubs;
 $DOCARRAY{'worth'}       = $worth;
 $DOCARRAY{'recsize'}     = $recsize;
 $DOCARRAY{'newsprocsectsub'}  = $newsprocsectsub;
 $DOCARRAY{'pointssectsub'} = $pointssectsub;
 $DOCARRAY{'skiphandle'}  = $skiphandle;
 $DOCARRAY{'thisSectsub'} = $listSectsub;
 $DOCARRAY{'rSectsubid'}  = $rSectsubid; 
 $DOCARRAY{'updsectsub'}  = $updsectsub; 
 $DOCARRAY{'addsectsub'}  = $addsectsub;
 $DOCARRAY{'itemformat'}  = $itemformat;
 $DOCARRAY{'srcstyle'}    = $srcstyle; 
 $DOCARRAY{'headstyle'}   = $headstyle; 
 $DOCARRAY{'bodystyle'}   = $bodystyle; 
 $DOCARRAY{'cmntstyle'}   = $cmntstyle; 
}

##564
sub clear_setvar
{
 $SETVAR{'separator'}   = "";
 $SETVAR{'dTemplate'}   = "";
 $SETVAR{'dBoxStyle'}   = "";
 $SETVAR{'rSectsubidb'} = "";
}

##565

##                WRITE_ITEM to file      
sub write_doc_item
{ 
  my($docid,$idx_insert_sth) = @_;   # if not in items directory, it is in popnews_mail
  $docid =~ s/\s+$//mg;

  return if(!$headline and !$link);

  if($addsectsubs =~ /$deleteSS|$expiredSS/) {
     system "touch $deletepath/$docid.del" if($docid ne "");
   ## TODO DB Set delete flag in record for DB processing.
  }

  if($docid =~ /-/) {       ##  from emailed 
	  $docpath = "$mailpath/$docid\.itm";
  }
  else {
	  $docpath = "$itempath/$docid\.itm";

	  if($SVRinfo{'environment'} == 'development') {   ## GITHUB_PATHS
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
     chmod 0777, $emailfile if($SVRinfo{'environment'} == 'development');  ## GIT_HUB PATHS
     unlink $lock_file if($lock_file);
  }
  else {
     print "Invalid sysdate=$sysdate or docid-$docid; Could not write out docitem at doc1185 Error message: $! <br>\n";
  }

  return($docid);
}

sub write_doc_data_out
{
  if($ipform eq "summarize") {
       print DATAOUT "sumAcctnum\^$userid\n";
       print DATAOUT "summarizerfk\^$summarizerfk\n";
  }
  else {
       print DATAOUT "sumAcctnum\^$sumAcctnum\n" ;
  }
  if($docaction eq 'N') {
       print DATAOUT "suggestAcctnum\^$userid\n";
  }
  else {
       print DATAOUT "suggestAcctnum\^$suggestAcctnum\n";
       print DATAOUT "suggesterfk\^$suggesterfk\n";
  }
  print DATAOUT "changebyfk\^$changebyfk\n";
  print DATAOUT "updated_on\^$updated_on\n";

  print DATAOUT "priority\^$priority\n"; 

  print DATAOUT "deleted\^$deleted\n";
  print DATAOUT "outdated\^$outdated\n";
  print DATAOUT "nextdocid\^$nextdocid\n";
	
  if($addsectsubs =~ /($newsdigestSS|$headlinesSS|$suggestedSS|$summarizedSS|$headlinesPriSS)/) {
	   $woapubdatetm = &get_nowdatetime;
  }
  elsif(!$woapubdatetm) {
	   $woapubdatetm = $epoch_time;
  }
  print DATAOUT "woapubdatetm\^$woapubdatetm\n";

  print DATAOUT "sysdate\^$sysdate\n";   
  print DATAOUT "pubdate\^$pubdate\n";
  print DATAOUT "skippubdate\^$skippubdate\n";

  print DATAOUT "reappeardate\^$reappeardate\n";
  print DATAOUT "expdate\^$expdate\n";

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

  if($docaction =~ /N/ and $region !~ /[A-Za-z0-9]/) {
	  $region = &get_regions('N',"",$headline,$fullbody,$link);  # print_regions=N, region="", # controlfiles.pl                
  }
  $region =~ s/^;//;
  print DATAOUT "region\^$region\n";
  print DATAOUT "regionhead\^$regionhead\n";
  print DATAOUT "regionfks\^$regionfks\n";
  print DATAOUT "skipregion\^$skipregion\n";

  $source = "" if($source =~ /select one/);
  $source =~ &strip_leadingSPlineBR($source);
##    $source = &strip_leadingNonAlphnum($source);
  $source =~ s/\s+$//;
#  $source = &titlize($source) if( ($docaction =~ /N/ and !$owner)  or $titlize =~ /Y/); #in smartdata.pl
  print DATAOUT "source\^$source\n";
  print DATAOUT "sourcefk\^$sourcefk\n";
  print DATAOUT "skipsource\^$skipsource\n";

  $author = &titlize($author) if($docaction =~ /N/);
  print DATAOUT "author\^$author\n";
  print DATAOUT "skipauthor\^$skipauthor\n";

  print DATAOUT "needsum\^$needsum\n";
		
  $link =~ s/\<//g;
  $link =~ s/\<//g;
  print DATAOUT "link\^$link\n";
  print DATAOUT "selflink\^$selflink\n";
  print DATAOUT "skiplink\^$skiplink\n";

  $headline = &strip_leadingSPlineBR($headline);
##    $headline = &strip_leadingNonAlphnum($headline);
  $headline =~ s/\s+$//;
  $headline =~ s/\s+$//;
  $headline =~ s/’/\'/g;  #E2 80 99 apostrophe
  $headline =~ s/&#40;/\(/g;    ## left parens
  $headline =~ s/&#41;/\)/g;    ## right parens  
  $headline =~ s/&#91;/\[/g;    ## left bracket
  $headline =~ s/&#93;/\]/g;    ## right bracket
  $headline = &titlize($headline) if( ($docaction =~ /N/ and !$owner)  or $titlize =~ /Y/); #in smartdata.pl
  print DATAOUT "headline\^$headline\n";
  print DATAOUT "skipheadline\^$skipheadline\n";

  print DATAOUT "subheadline\^$subheadline\n";   

  print DATAOUT "bodyprenote\^$bodyprenote\n";

  print DATAOUT "skiphandle\^$skiphandle\n";

  $body   = &apple_convert($body);
  print DATAOUT "body\^$body\n";

  print DATAOUT "bodypostnote\^$bodypostnote\n";

  print DATAOUT "comment\^$comment\n";

  $points = &apple_convert($points) if($points =~ /[A-Za-z0-9]/);
  print DATAOUT "points\^$points\n";

  $extract = "E" if(!$body and $points);

  $fullbody =~  s/^\n+//;  #get rid of leading line feeds

  if($fullbody =~ /^##FIX##/) {
      &refine_fullbody;
      $fullbody =~ s/##FIX##//;
  }

  $fullbody = &apple_convert($fullbody) if($docaction =~ /N/ or $fixfullbody =~ /Y/);

  print DATAOUT "fullbody\^$fullbody\n";
  print DATAOUT "freeview\^$freeview\n";

  print DATAOUT "note\^$note\n";
  print DATAOUT "miscinfo\^$miscinfo\n";

  print DATAOUT "topic\^$topic\n";
  print DATAOUT "keywords\^$keywords\n";
  print DATAOUT "special\^$special\n";

  print DATAOUT "imageloc\^$imageloc\n";
  print DATAOUT "imagefile\^$imagefile\n";
  print DATAOUT "imagedescr\^$imagedescr\n";

  $recsize = length($fullbody);
  print DATAOUT "recsize\^$recsize\n";

  print DATAOUT "worth\^$worth\n";	

  $sectsubs =~ s/NA`M;//;
  $sectsubs =~ s/NA;//;
  $sectsubs =~ s/`+$//;  # get rid of trailing tic marks

  print DATAOUT "sectsubs\^$sectsubs\n";

  if($DB_docitems eq 1) {
	  if(&DBdocitemExists($docid) ) {   #TODO: fix the DBdocitemExists sub
 		 $doc_update_sth = &DB_update($doc_update_sth,@docarray,$doc_update_sql); # in database.pl - $doc_update_sth set in article.pl at cmd processing
	  }
	  else {
         $doc_insert_sth = &DB_insert($doc_insert_sth,@docarray,$doc_insert_sql); #  in database.pl -  $doc_insert_sth set in article.pl at cmd processing
      }

	  my @sectsubs = split(/;/,$sectsubs);
	  foreach $sectsub (@sectsubs) {
	     my ($sectsubname,$docloc,$rest) = split(/`/, $sectsub,3);   # get rid of stratus A...M...Z
	          # will either add to or delete from index
	     &DB_update_sectsub_idx($idx_insert_sth,$sectsubname,$docid,$stratus,$delsectsubs); # in indexes.pl 
	  }
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
  $docCount = $num;
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


sub remove_dups_from_list    # removes duplicates from a semi-colon separated list
{
 my $list = $_[0];
 my @list = split(/;/,$list);
 foreach $item (@list) {
	$list = "$list;$item" unless($list =~ /$item/);
 }
 return($list);
}

####  DATABASE OPERATIONS ##########


sub write_docitem_to_DB_not_used  
{
	 unless($docid =~ /[0-6]{6}/) {
	      print "$docid Invalid docid <br>\n";
		  &write_index_flatfile ('Invalid_docid',$docid,'','P','Invalid_docid','');
	      last;
	 }

	 $n_docid = int($docid);
#                                                   # See if deleted	
	 my($delfilename,$rest) = strip(/\./,$filename,2);
	 $delfilename = $delfilename . '/\.del';
     $deleted = 1 if(-f "$deletepath/$delfilename");

     if($pubdate) {
          $pubyear  = substr($pubdate, 0, 5);
     }
     elsif($sysdate) {
          $pubyear  = substr($sysdate, 0, 5);	    
     }

     if($straightHTML eq 'Y') {
          $dtemplate = 'straight';
          print "$docid STRAIGHT -- $headline <br>\n";
	      &write_index_flatfile ('import_Straight_html',$docid,'','P','import_Straight_html','');  #log - in index.pl
     }

     $regionfks = &get_regionid($region) unless($regionfks);
	 $source   = &get_source_linkmatch($link) unless($source);
     $sourcefk = &get_sourceid($source) if($source and !$sousrcefk);

     $woapubdatetm = &get_nowdatetime; # in date.pl

     $recsize = length($fullbody);

     $dtemplate = $dTemplate;

	 $dbh = &db_connect() if(!$dbh);
	
	if($docaction eq 'N') {
		my $doc_insert_sth = &DB_prepare_doc_insert($dbh,$doc_insert_sql);
## DOTO fix this to subroutine
		
	    $doc_insert_sth->execute($n_docid,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
		$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,
		$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on);

	}
	else {
		my $doc_sth = $dbh->prepare( "UPDATE docitem SET deleted=?,outdated=?,nextdocid=?,priority=?,headline=?,regionhead=?,skipheadline=?,
		subheadline=?,special=?,topic=?,link=?,skiplink=?,selflink=?,sysdate=?,pubdate=?,pubyear=?,skippubdate=?,woapubdatetm=?,
		expdate=?,reappeardate=?,region=?,regionfks=?,skipregion=?,source=?,sourcefk=?,skipsource=?,author=?,skipauthor=?,needsum=?
		body=?,fullbody=?,freeview=?,points=?,comment=7,bodyprenote=?,bodypostnote=?,note=?,miscinfo=?,sectsubs=?,skiphandle=?,dtemplate=?,imagefile=?,imageloc=?,
		imagedescr=?,recsize=?,worth=?,sumAcctnum=?,suggestAcctnum=?,summarizerfk=?,suggesterfk=?,changebyfk=?,updated_on=CURDATE() WHERE docid = ?" );

		$doc_sth->execute($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
		$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,
		$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$docid);
	    
	}
}

sub DB_prepare_get_docitem
{
  my $sth = $dbh->prepare( "SELECT * FROM users where docid = ?" );
  return($sth);	
}

sub DB_get_docitem
{
  my ($sth,$docid) = @_;
  $row = $sth->exec($docid);
  return($row);	
}

sub DBdocitemExists   #TODO this does not work - TRY returning the row!!!!!!!!!!!!
{
   my($dbh,$docid) = $_[0];

  my $sth = $dbh->prepare('SELECT COUNT(*) FROM docitems  WHERE docid = ?') 
        or die("Couldn't prepare statement: " . $docitemexists_sth->errstr);	
  $sth->execute($docid);
  my @row = $sth->fetchrow_array();
  $sth->finish;
  if($row or $row > 0) {
     print "doc1808 Exists<br>\n";
     return("T");
  }
  else {
     return("");	
  }
}

sub DB_prepare_doc_insert
{
  my($dbh) = $_[0];  # Couldn't execute DB doc insert  : called with 52 bind variables when 50 are needed at docitem.pl line 2110

  my $doc_insert_sql = "INSERT IGNORE INTO docitems (docid,deleted,outdated,nextdocid,priority,headline,regionhead,skipheadline,subheadline,special,topic,link,skiplink,selflink,sysdate,pubdate,pubyear,skippubdate,woapubdatetm,expdate,reappeardate,region,regionfks,skipregion,source,sourcefk,skipsource,author,skipauthor,needsum,body,fullbody,freeview,points,comment,bodyprenote,bodypostnote,note,miscinfo,sectsubs,skiphandle,dtemplate,imagefile,imageloc,imagedescr,recsize,worth,sumAcctnum,suggestAcctnum,summarizerfk,suggesterfk,changebyfk,updated_on) 
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURDATE() )";

  my $doc_insert_sth = $dbh->prepare($doc_insert_sql) or die("Couldn't prepare DB doc insert @doc1818 : " . $sth_docrows_sth->errstr);
  return($doc_insert_sth);
}


sub export_docitems  # From DB to flatfiles, including indexes
{
 my($mindocid,$maxdocid) = @_;  # Do a chunk at a time
 my $filename = "";
 $export_docitem_cnt = 0;

 &read_sectCtrl_to_array;  #in sectsubs.pl - needed to get sectsubids

 $dbh = &db_connect() if(!$dbh);
 my $sth_docrows = $dbh->prepare( 'SELECT * FROM docitems WHERE docid BETWEEN ? AND ?') 
    or die("Couldn't prepare statement: " . $sth_docrows_sth->errstr);	
 $sth_docrows->execute($mindocid,$maxdocid);
 while (my @row = $sth_docrows->fetchrow_array()) { # print data retrieve	
	 &write_exp_docitem(@row);
 }
 $sth_docrows->finish;

# &export_indexes;  # Save this to be run separately

  print "Export item count $export_docitem_cnt .. mindocid $mindocid .. maxdocid $maxdocid </br>\n";
}

sub write_exp_docitem
{
 my ($docid,$deleted,$priority,$headline,$regionhead,$special,$topic,$link,$skiplink,$selflink,
	 $sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$region,$regionfks,$source,
	 $sourcefk,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,
	 $skiphandle,$dtemplate,$imagefile,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum) = @_;
	
 $docpath = "$expitempath/$docid\.itm";

 if(-f "$docpath") {
     print "$docid already exists <br>\n";
     &write_index_flatfile ('export_AlreadyExists',$docid,'','P','export_AlreadyExists','');
     return;
 }
	
 open(DOCITEM, ">$docpath") or die("Couldn't open $docpath<br>\n");
 print DOCITEM "deleted\^$deleted\n";
 print DOCITEM "outdated\^$outdated\n";
 print DOCITEM "nextdocid\^$nextdocid\n";
 print DOCITEM "priority\^$priority\n";  
 print DOCITEM "dtemplate\^$dtemplate\n";  
 print DOCITEM "pubdate\^$pubdate\n";
 print DOCITEM "skippubdate\^$skippubdate\n";
 print DOCITEM "pubyear\^$pubyear\n";
 print DOCITEM "expdate\^$expdate\n";
 print DOCITEM "sysdate\^$sysdate\n";
 print DOCITEM "woapubdatetm\^$woapubdatetm\n";
 print DOCITEM "reappeardate\^$reappeardate\n";
 print DOCITEM "author\^$author\n";
 print DOCITEM "skipauthor\^$skipauthor\n";
 print DOCITEM "needsum\^$needsum\n";
 print DOCITEM "source\^$source\n";
 print DOCITEM "sourcefk\^$sourcefk\n";
 print DOCITEM "skipsource\^$skipsource\n";
 print DOCITEM "link\^$link\n";
 print DOCITEM "selflink\^$selflink\n";
 print DOCITEM "skiplink\^$skiplink\n";
 print DOCITEM "freeview\^$freeview\n";
 print DOCITEM "headline\^$headline\n";
 print DOCITEM "skipheadline\^$skipheadline\n";
 print DOCITEM "subheadline\^$subheadline\n";
 print DOCITEM "region\^$region\n";
 print DOCITEM "regionhead\^$regionhead\n";
 print DOCITEM "regionfks\^$regionfks\n";
 print DOCITEM "skipregion\^$skipregion\n";
 print DOCITEM "topic\^$topic\n";
 print DOCITEM "body\^$body\n";
 print DOCITEM "points\^$points\n";
 print DOCITEM "fullbody\^$fullbody\n";
 print DOCITEM "comment\^$comment\n";
 print DOCITEM "bodyprenote\^$bodyprenote\n";
 print DOCITEM "bodypostnote\^$bodypostnote\n";
 print DOCITEM "note\^$note\n";
 print DOCITEM "miscinfo\^$miscinfo\n";
 print DOCITEM "imagefile\^$imagealt\n";
 print DOCITEM "imageloc\^$imageloc\n";
 print DOCITEM "imagedescr\^$imagedescr\n";
 print DOCITEM "recsize\^$recsize\n";
 print DOCITEM "worth\^$worth\n";
 print DOCITEM "sectsubs\^$sectsubs\n";
 print DOCITEM "keywords\^$keywords\n";
 print DOCITEM "special\^$special\n";
 print DOCITEM "skiphandle\^$skiphandle\n";
 print DOCITEM "sumAcctnum\^$sumAcctnum\n";
 print DOCITEM "suggestAcctnum\^$suggestAcctnum\n" ;
 print DOCITEM "summarizerfk\^$summarizerfk\n";
 print DOCITEM "suggesterfk\^$suggesterfk\n";
 print DOCITEM "changebyfk\^$changebyfk\n";
 print DOCITEM "updated_on\^$updated_on\n";

# $recsize; $worth; $imagedescr
 
 close(DOCITEM);
 chmod 0777, $docpath if($SVRinfo{'environment'} == 'development');

 $export_docitem_cnt = $export_docitem_cnt + 1;

########### TODO - export index here!! with stratus
}


sub import_docitems      
{
 my ($newsSSname,$mindocid_n,$maxdocid_n) = @_;  # one of the news or news archives SS - or - docid max and min

 $itemcnt = 0;
 $timesecs = time;
 my $filename = "";
 my $prevdocid = 0;
 my $returnURL = "";

 my $mindocid = padCount6($mindocid_n);   # in dbtables_ctrl.pl - counts
 my $maxdocid = padCount6($maxdocid_n);

 &read_sectCtrl_to_array;  #in sectsubs.pl - needed to get sectsubids

 $dbh = &db_connect() if(!$dbh);   # in database.pl

 my $idx_count_sth  = &DB_prepare_idx_count($dbh);     # maybe not used
 my $doc_insert_sth = &DB_prepare_doc_insert($dbh);
 my $idx_insert_sth = &DB_prepare_idx_insert($dbh);     # in indexes.pl


 unless($newsSSname eq 'nomoreSS') {   # Do for each version of NewsDigest
	 if($newsSSname =~ /NewsDigest_NewsItem/) {     # DO this list first - it is the latest TODO (later do this by year ???? - keep flatfile index by year)
	    $dbh->do("TRUNCATE TABLE docitems");
	    $dbh->do("TRUNCATE TABLE indexes");
	
	    $returnURL = "http://$scriptpath//article.pl?import%docitems%Headlines_sustainability%Suggested_suggestedItem%Suggested_summarizedItem%NewsScan_1_thru2010;NewsScan2_NewsItem;Archives2007Aug-2006Sep;ArchivesJan-Apr2003_item;ArchivesSep-Dec2002_item;ArchivesMay-Aug2002_item;ArchivesJan-Apr2002_item;ArchivesSep-Dec2001_item;ArchivesSep-Dec2000_item;ArchivesMay-Aug2000_item;noMoreSS%%";
     }
     else {                                        # Do each list successively until noMoreSS is reached, then work from items directory to pick up what is left
	   ($newsSSname,$otherNewsSS) = split(/;/,$newsSSname,2);
	     $returnURL = "http://$scriptpath//article.pl?import%docitems%$othernewsSS%%";
    }
	
	 $lock_file = "$newsSSname.busy";
     &waitIfBusy($lock_file, 'lock');
     my $doclistpath = "$sectionpath/$newsSSname.idx";

     open(INFILE, "$doclistpath");
     while(<INFILE>) {
	     chomp;
	     $line = $_;
	     ($docid,$stratus) = split(/\^/,$line,3);
	     $itemcnt = $itemcnt + 1;
		 $timesecs = $timesecs - 1;
		
		 last if($newsSSname eq 'Headlines_sustainability' and $itemcnt > 800);
		
		 &import_one_docitem($docid,$newsSSname,$itemcnt,$timesecs,$doc_insert_sth,$idx_insert_sth) 
		     unless($docid eq $prev_docid);
# unless(&DBdocitemExists($dbh,$docid) or $docid eq $prev_docid);
		 $prev_docid = $docid;
     } #end file
     close(INFILE);
 }
 else {   # Comes here last, when nomoreSS is reached - pick up what is left in items/ directory
     opendir(ITEMDIR, "$itempath");
     my @itemfiles = readdir(ITEMDIR);
     my @sortedfiles = sort @itemfiles;
     closedir(ITEMDIR);

     foreach $filename (@sorteditemfiles) {
	    if(-f "$itempath/$filename" and $filename =~ /\.itm/) {
		    $docid = split(/\./,$filename,2);
		    unless($docid =~ /[0-6]{6}/) {
			     print "$docid Invalid docid <br>\n";
				 &write_index_flatfile("import_InvalidDocid",$docid,"","P","import_InvalidDocid","");  #log - in index.pl
			     last;
		    }
			$itemcnt = $itemcnt + 1;
		    &import_one_docitem($docid,$newsSSname,$itemcnt,$timesecs,$doc_insert_sth,$idx_insert_sth);
#			&import_one_docitem($docid,$newsSSname,$itemcnt,$timesecs,$doc_insert_sth,$idx_insert_sth) unless(&DBdocitemExists($dbh,$docid));
	    }
    }
 }
 $doc_insert_sth->finish;
 $idx_insert_sth->finish;

 print "Source: $newsSSname completed ..min $mindocid ..max $maxdocid ..Item count: $itemcnt  .. doc2037<br>\n";
 print "<a target=\"_blank\" href=\"$returnURL\">Click here</a> for the next section<br>\n" unless $newsSSname =~ /noMoreSS/;
}



sub import_one_docitem
{
 my ($docid,$newsSSname,$itemcnt,$timesecs,$doc_insert_sth,$idx_insert_sth) = @_;

 my ($deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk,$updated_on)
 = &get_doc_data($docid,'N');

 if($headline =~ /File not found/) {
	 print "$docid NOTFOUND -- $headline <br>\n";
     &write_index_flatfile('import_NotFound',$docid,'','P','import_NotFound','');  #log - in index.pl
     return;
 }

 $n_docid = int($docid);
#                                                   # See if deleted	
 $delfilepath = "$deletepath/$docid\.del";
 my $deleted = 0;
 $deleted = 1 if(-f "$deletepath");

 if($newsSSname =~ /NewsDigest_NewsItem/ or $newsSSname =~ /Headlines_sustainability/ or $newsSSname=~ /Suggested_suggestedItem/) {
#       my($syssec,$sysmin,$syshh,$sysday,$sysmonth,$sysyear) 
    my($sec,$min,$hh,$dd,$mm,$yyyy,$wday,$yday,$isdst) = localtime($timesecs);
    $woapubdatetm = &datetime_prep('yyyy-mm-dd hh:mm:ss',$sec,$min,$hh,$dd,$mm,$yyyy);
 }
 else {
	$woapubdatetm = $epoch_time;
 }

 $pubdate = "" if($pubdate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);   # $epoch_time ?
 $sysdate = "" if($sysdate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);

 if($pubdate and $pubdate !~ /0000-00-00/) {
     $pubyear  = substr($pubdate,0,4);
 }
 elsif($sysdate) {
     $pubyear  = substr($sysdate,0,4);	    
 }
 else {
	 $pubyear = '0000';  
 }

 $expdate      = "" if($expdate      !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);
 $reappeardate = "" if($reappeardate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);

 if($straightHTML eq 'Y') {
      $dtemplate = 'straight';
      print "$docid STRAIGHT -- $headline <br>\n";
      &write_index_flatfile ('import_Straight_html',$docid,'','P','import_Straight_html','');  #log - in index.pl
 }

 $sumAcctnum     = &remove_dups_from_list($sumAcctnum);
 $suggestAcctnum = &remove_dups_from_list($suggestAcctnum);

 my @regions = split(/;/,$region);
 $region   = "";       # rebuild region - get rid of dups
 $regionfks = "";       # rebuild regionfks - get rid of dups
 my $regionx = "";
 my $regionfksx = "";
 my $regionCnt = 0;
 foreach $regionx (@regions) {
	$regionCnt = $regionCnt + 1;
	if($regionCnt > 10) {
		$region = "Global";
		$regionfks = 1;
		last;
	}
	$region = "$region;$regionx" unless($region =~ /$regionx/);
	$regionfkx = &get_regionid($regionx);     # in regions.pl
	$regionfks = "$regionfks;$regionfkx" unless($regionfks =~ /$regionfkx/)
 }
 $region   =~ s/^;//;  # get rid of leading semi-colons
 $regionfks =~ s/^;//;  # get rid of leading semi-colons

 $source   = &get_source_linkmatch($link) unless($source);
 $sourcefk = &get_sourceid($source) if($source and !$sousrcefk);
   
 $dtemplate = $dTemplate;

 $fullbody =~ s/\n+$//g;    ## trim trailing line feeds
 $fullbody =~ s/\r+$//g;    ## trim trailing returns
 $fullbody =~ s/\n\r+$//g;  ## trim trailing returns
 $fullbody =~ s/\r\n+$//g;  ## trim trailing returns
 $fullbody =~ s/^\n+//g;    ## trim leading line feeds
 $fullbody =~ s/^\r+//g;    ## trim leading returns
 $fullbody =~ s/^\n\r+//g;  ## trim leading returns
 $fullbody =~ s/^\r\n+//g;  ## trim leading returns

 $recsize = length($fullbody);

 $body =~ s/\n+$//g;    ## trim trailing line feeds
 $body =~ s/\r+$//g;    ## trim trailing returns
 $body =~ s/\n\r+$//g;  ## trim trailing returns
 $body =~ s/\r\n+$//g;  ## trim trailing returns
 $points =~ s/\s+$//g;  ## trim white space
 $points =~ s/\n+$//g;  ## trim trailing line feeds
 $points =~ s/\r+$//g;  ## trim trailing returns
 $points =~ s/\n\r+$//g; ## trim trailing returns
 $points =~ s/\r\n+$//g; ## trim trailing returns
 $points =~ s/\s+$//g;   ## trim white space

 $sectsubs =~ s/NA`M;//;
 $sectsubs =~ s/NA;//;

 $doc_insert_sth->execute($n_docid,$deleted,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfks,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,$miscinfo,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imageloc,$imagedescr,$recsize,$worth,$sumAcctnum,$suggestAcctnum,$summarizerfk,$suggesterfk,$changebyfk)
      or die("Couldn't execute DB doc insert @doc2108 : " . $doc_insert_sth->errstr);

 my @sectsubs = split(/;/,$sectsubs);
 foreach $sectsub (@sectsubs) {
    ($sectsubname,$stratus) = split(/`/, $sectsub,3);
    &DB_update_sectsub_idx($idx_insert_sth,$sectsubname,$n_docid,$stratus,""); # in indexes.pl - will add to index
 }
}


sub create_docitem_table {
#                        DO THIS MANUALLY ON THE DB SERVER
#                    	docid smallint auto_increment PRIMARY KEY,    # do this later, after conversion
	
$DOCITEM_SQL  = <<ENDDOCITEM
CREATE TABLE docitems (
   docid          smallint     unsigned not null,
   deleted        tinyint      unsigned not null   default 0,
   outdated       tinyint      unsigned not null   default 0,
   nextdocid      smallint     unsigned default 0,
   priority       char(1)      default '4',
   headline       varchar(200) default '',
   regionhead     char(1)      default 'N',
   skipheadline   tinyint      unsigned not null   default 0,
   subheadline    varchar(200) default '',
   special        varchar(50) default '',
   topic          varchar(50)  default '',
   link           varchar(200) default '',
   skiplink       tinyint      unsigned not null   default 0,
   selflink       char(1)      default 'N',
   sysdate        date         not null,
   pubdate        date         default null,
   pubyear        char(4)      default '',
   skippubdate    tinyint      unsigned not null   default 0,
   woapubdatetm   datetime     default null,
   expdate        date         default null,
   reappeardate   date         default null,
   region         varchar(100) default '',
   regionfks      varchar(50)  default '',
   skipregion     tinyint      unsigned not null   default 0,
   source         varchar(100) default '',
   sourcefk       smallint     unsigned default 0,
   skipsource     tinyint      unsigned not null   default 0,
   author         varchar(100) default '',
   skipauthor     tinyint      unsigned not null   default 1,
   needsum        char(1)      default ' ',
   body           text,
   fullbody       text,
   freeview       char(1)       default 'N',
   points         text,
   comment        varchar(1000) default '',
   bodyprenote    varchar(500)  default '',
   bodypostnote   varchar(500)  default '',
   note           varchar(300)  default '',
   miscinfo       varchar(300)  default '',
   sectsubs       varchar(200)  default '',
   skiphandle     char(1)       default 'N',
   dtemplate      varchar(20)   default '',
   imagefile      varchar(150)  default '',
   imageloc       varchar(150)  default '',
   imagedescr     varchar(150)  default '',
   recsize        smallint      unsigned default 0,
   worth          decimal(5,2)  default 0,
   sumAcctnum     char(15)      default '',
   suggestAcctnum char(15)      default '',
   summarizerfk   smallint      unsigned default 0,
   suggesterfk    smallint      unsigned default 0,
   changebyfk     smallint      unsigned default 0,
   updated_on     date          default null,
   UNIQUE (docid) );
ENDDOCITEM
#  indexes pubdate sysdate woapubdatetm headline (20)

# INSERT INTO tablename (col_date) VALUE (CURDATE() )";           ###   date type = 'YYYY-MM-DD'
}

1;