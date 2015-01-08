#!/usr/bin/perl --

# 2014 Sep 16 .................... SEE 2202 !!!!!!!!!!!!!!!!!!!!!
#      docitem.pl

# docitem.pl processes doc info to find headlines, source date, publisher, region, and other variables.
## docaction = new, before, after, clone, update, deleteitem, emailit
## docaction = N, C, D (after)
## doc sectsubs:  dSectid-dSubid`ddocloc^dNeardocid^dTemplate^
##                dSrcstyle^dHeadstyle^dBodystyle^dCmntstyle^dFullstyle

## 2012 Sep 14 - work on docitems to DB, continuing through Jan 2014
## 2012 Jan 23 - Broke off smartdata.pl - for parsing data

sub init_docitem     # was init_docitem_variables
{
    undef %D;
    %{$D} = ();
    %D = ();  # hash holding doc column (variable) values
    for (keys %D)
    {
        delete $D{$_};
    }
    for (keys %$D)
    {
        delete $href->{$_};
    }
    %DH = (); # hash holding docitem helper variable values
#    &init_doc_variable_lists; # Fills %DOCMETA with sql and other statements involving docitem data cols.
    &clear_doc_data; # Fills hash %D with initialize values
    &clear_doc_helper_variables;
#    &init_doc_variable_lists;
    $INSIDE = "";
    $INSIDE_FOUND = "";
    %INSIDEMERGE  = ();
    &clear_msgline_variables;   #in intake.pl
    undef %DOCARRAY;
    %DOCARRAY = ();  # hash holding all variables (doc and related) for merging print template
}

sub build_sql {
 my $sql_type = $_[0];
 my @Dnames = &get_Dnames;
 my $result = "";
 my $num_cols = 0;

 foreach my $docname (@Dnames) {
	$num_cols = $num_cols + 1;
    if($sql_type =~ /^select/)
        { $result = $result . "d\.$docname, "; }          # d.userid,
    elsif($sql_type =~ /^string/)
        { $result = $result . "\$" . "$docname^"; }       # ^userid,
	elsif($sql_type =~ /^cols/) {
		  $result = $result . "$docname, "; }       # userid
    elsif($sql_type =~ /^vars/)
        { $result = $result . "$docname, "; }       # userid
    elsif($sql_type =~ /^keys/)
        { $result = $result . "$docname, "; }              # d.userid,
    elsif($sql_type =~ /^hash/)
        { $result = $result . "\$" . "D{$docname}, "; }    # $D{userid},
    elsif($sql_type =~ /^update/)
        { $result = $result . "\$" . "$docname=?, "; }     # userid=?,
    elsif($sql_type =~ /^updateD/)
        { $result = $result . "\$" . "$docname=$D{$docname}, "; } # userid=$D{$docname},
    else { print "sql_type $sql_type invalid -- doclist $doclist\n<br>"; }
 }

 $result =~ s/^\^//g;
 $result =~ s/ $//g;
 $result =~ s/,$//g;

return($result,$num_cols);
}


sub init_doc_variable_lists_not_used {
  %doccol_order = (
    docid         => "0010",
    deleted       => "0020",
    reservetimeup => "0030",
    outdated      => "0040",
    nextdocid     => "0050",
    priority      => "0060",
    headline      => "0070",
    regionhead    => "0080",
    skipheadline  => "0090",
    subheadline   => "0095",
    special       => "0100",
    topic         => "0110",
    link          => "0120",
    skiplink      => "0130",
    selflink      => "0140",
    sysdate       => "0150",
    pubdate       => "0160",
    pubyear       => "0170",
    skippubdate   => "0180",
    woapubdatetm  => "0190",
    expdate       => "0200",
    reappeardate  => "0210",
	region        => "0220",
	regionfk      => "0230",
	skipregion    => "0240",
	source        => "0250",
	sourcefk      => "0260",
	skipsource    => "0270",
	author        => "0280",
	skipauthor    => "0290",
	needsum       => "0300",
	body          => "0310",
	fullbody      => "0320",
	freeview      => "0330",
	points        => "0340",
	comment       => "0350",
	bodyprenote   => "0360",
	bodypostnote  => "0370",
	note          => "0380",
	miscinfo      => "0390",
	precat        => "0395",
	sectsubs      => "0400",
	skiphandle    => "0410",
	dtemplate     => "0420",
	imagefile     => "0430",
	imageloc      => "0440",
	imagedescr    => "0450",
	worth         => "0460",
	summarizerfk  => "0470",
	suggesterfk   => "0480",
	changebyfk    => "0490",
	updated_on    => "0500", );

	my $select = "SELECT ";
	my $str = "";
	my $vars = "";
	my $hash = "";
	my $update = "UPDATE docitems SET ";
	my $updateD = "UPDATE docitems SET ";
	my $keys  = "";

    foreach my $docname (sort { ($doccol_order{$a} cmp $doccol_order{$b}) } keys  %doccol_order) {
		$select = $select . "d\.$docname,";               # d.userid,   for example
		$str    = "$str^\$" . $docname;                   # ^$userid
		$vars   = "$vars,\$" . $docname;                  # $userid,
		$keys   = "$keys, " . $docname;                  #  userid,
		$hash   = "$hash," . "\$D{'" . $docname . "'}";   # $D{'userid'},
		$update = "$update$docname=?,";                   # userid=?,
		$updateD = "$updateD$docname=$D{$docname},";                   # userid=?,
     }

    $select =~ s/,$//g;
    $select =~ s/,$//g;
    $str    =~ s/^\^//g;
    $vars   =~ s/^,//g;
    $hash   =~ s/^,//g;
    $update =~ s/,$//g;
    $updateD =~ s/,$//g;

#	print "doc111 sql $sql<br>\n\n";
#	print "doc112 str $str<br>\n\n";
#	print "doc113 vars $vars<br>\n\n";
#	print "doc114 hash $hash<br>\n\n";
#	print "doc115 update $update<br>\n\n";
#	print "doc116 updateD $updateD<br>\n\n";

#    my $sth_idx_count  = &DB_prepare_idx_count($DBH);   # not used?
    my $sth_doc_insert = &DB_prepare_docitem_insert($DBH);
 #  my $doc_update_sth = &DB_prepare_docitem_update($DBH);
    my $sth_idx_insert = &DB_prepare_idx_insert($DBH);   # in indexes.pl
	my $sth_docrow     = $DBH->prepare("$select FROM docitem as d WHERE d.docid = ?");
	my $sth_docupdt    = $DBH->prepare("$update WHERE docid = ?");

	$DOCMETA{'select'}         = $select;
	$DOCMETA{'str'}            = $str;
	$DOCMETA{'vars'}           = $vars;
	$DOCMETA{'hash'}           = $hash;
	$DOCMETA{'update'}         = $update;
	$DOCMETA{'updateD'}        = $updateD;
	$DOCMETA{'sth_docrow'}     = $sth_docrow;
	$DOCMETA{'sth_docupdt'}    = $sth_docupdt;
	$DOCMETA{'sth_docinsert'}  = $sth_doc_insert;
	$DOCMETA{'sth_idxinsert'}  = $sth_idx_insert;
	$DOCMETA{'sth_idxcount'}   = $sth_idx_count;
	return("");
}


sub clear_doc_data {
 %D = (
	docid         => "",
    deleted       => '',
    reservetimeup => $epoch_time,
    outdated      => 'N',
    nextdocid     => "",
    priority      => '5',
    headline      => "",
    regionhead    => "N",
    skipheadline  => "N",
    subheadline   => "",
    special       => "",
    topic         => "",
    link          => "",
    skiplink      => "N",
    selflink      => "N",
    sysdate       => $epoch_date,
    pubdate       => $epoch_date,
    pubyear       => "0000",
    skippubdate   => "N",
    woapubdatetm  => $epoch_time,
    expdate       => $epoch_date,
    reappeardate  => $epoch_date,
	region        => "",
	regionfk      => 0,
	skipregion    => "N",
	source        => "",
	sourcefk      => 0,
	skipsource    => "N",
	author        => "",
	skipauthor    => "N",
	needsum       => "N",
	body          => "",
	fullbody      => "",
	freeview      => "N",
	points        => "",
	comment       => "",
	bodyprenote   => "",
	bodypostnote  => "",
	note          => "",
	miscinfo      => "",
	precat        => "",
	sectsubs      => "",
	skiphandle    => "N",
	dtemplate     => "",
	imagefile     => "",
	imageloc      => "",
	imagedescr    => "",
	worth         => 0,
	summarizerfk  => 0,
	suggesterfk   => 0,
	changebyfk    => 0,
	updated_on    => $epoch_date, );

	$docid         = "";
	$deleted       = '';
	$reservetimeup = $epoch_time;
	$outdated      = 'N';
	$nextdocid     = "";
	$priority      = '5';
	$headline      = "";
	$regionhead    = "N";
	$skipheadline    = "N";
	$subheadline   = "";
	$special       = "";
	$topic         = "";
	$link          = "";
	$skiplink      = "N";
	$selflink      = "N";
	$sysdate       = "";
	$pubdate       = "";
	$pubyear       = "0000";
	$skippubdate   = "N";
	$woapubdatetm  = $epoch_time;
	$expdate       = $epoch_date;
	$reappeardate  = $epoch_date;
	$region        = "";
	$regionfk      = 0;
	$skipregion    = "N";
	$source        = "";
	$sourcefk      = 0;
	$skipsource    = "N";
	$author        = "";
	$skipauthor    = "N";
	$needsum       = "N";
	$body          = "";
	$fullbody      = "";
	$freeview      = "N";
	$points        = "";
	$comment       = "";
	$bodyprenote   = "";
	$bodypostnote  = "";
	$note          = "";
	$miscinfo      = "";
	$precat        = "";
	$sectsubs      = "";
	$skiphandle    = "N";
	$dtemplate     = "";
	$imagefile     = "";
	$imageloc      = "";
	$imagedescr    = "";
	$worth         = 0;
	$summarizerfk  = 0;
	$suggesterfk   = 0;
	$changebyfk    = 0;
	$updated_on    = $epoch_date;
}

sub clear_doc_variables
{                                       ## These are all globals
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
    $precat             = "";
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


sub clear_doc_helper_variables
{                                       ## These are all globals
    $extract            = "";
    $docaction          = "";
    $advance            = "";
    $ipform             = "";
    $pubday             = '00';
    $pubmonth           = '00';
    $woaday             = '00';
    $woamonth           = '00';
    $woayear            = '00';
    $expday             = '00';
    $expmonth           = '00';
    $expyear            = '00';
    $reappearday        = '00';
    $reappearmonth      = '00';
    $reappearyear       = '00';
    $srcdate            = $nulldate;
    $dTemplate          = "";
    $dtemplate          = "";
    $titlize            = "N";
    $emailnote          = "";
#    $keywords           = "";
    $dSectsubs          = "";
    $fSectsubs          = "";
    $newsprocsectsub    = "";
    $pointssectsub      = "";
    $linkmatch          = "";
    $first_addsectsub   = "";
    $first_sectsub      = "";
    $msgline_date       = "";
    $msgline_anydate    = "";
}


sub prepare_doc_insert_not_used {  ### NOT USED
my ($col_sql,$num_cols) = &build_sql('cols');
my $question_marks = ",?" x ($num_cols -3);
my $sql = "INSERT IGNORE INTO docitems($col_sql) VALUES (?$question_marks,CURDATE() )";
my $sth_doc_insert = $dbh->prepare($sql);
return($sth_doc_insert);
}


sub display_one   ## Comes here from article.pl
{
 my ($docid,$action,$aTemplate,$print_it,$email_it,$html_it) = @_;
 my $found = "";

 if($action eq 'new') {
   $pubday   = $nowdd;
   $pubmonth = $nowmm;
   $pubyear  = $nowyyyy;
   $pubdate  = "$pubyear-$pubmonth-$pubday";  #set default value of pubdate
   $expmonth = "00";
   $expday   = "00";
   $expyear  = "0000";
   $expdate = "$expyear-$expmonth-$expday";
 }
 elsif($docid =~ /[0-9]/) {
   $found = &get_doc_data($docid,$print_it);  # puts values in hash %D
   if($D{sectsubs} =~ /$suggestedSS|$emailedSS/ and $access !~ /[ABCD]/
       and $cmd eq "processlogin") {
      &printInvalidExit("Sorry, you cannot access this article until it has been pre-processed.
        <br>Please check the Headlines list. (This article is now on the $D{sectsubs} list) <small><small>(doc348)</small></small>");
    }
    elsif(!$found) {
	  &printSkipContinue("Item # $docid not found or deleted or inside is empty; normal. <small><small>(doc348)</small></small>");  ## in errors.pl
	  return("");
    }
 }
 &display_one_doc($aTemplate,$print_it,$email_it,$html_it);
}


sub display_one_doc  ## This does not look at inside or count articles
{   # data will have been put in the hash %D
  my ($aTemplate,$print_it,$email_it,$html_it) = @_;
  &put_data_to_array;
  &process_template($aTemplate,'Y','N','N');  #in template_ctrl.pl
}



sub do_each_doc {
  my($docid,$stratus) = @_;
  my $save_docid = $docid;

  $INSIDE = "";
  $INSIDE_FOUND = "";
  %INSIDEMERGE = ();
  $INLINE = "";
  $parent_docid = "";
  $parent_needsum = "";
  $parent_sectsubs = "";
  $DH{'parent_docid'} = "";
  $DH{'parent_needsum'} = "";
  $DH{'parent_sectsubs'} = "";

  &prt_one_doc($docid,"");  ## skip dups
  $docid = $save_docid;
  return($skip_item,$select_item);
}


sub prt_one_doc
 {
  my($docid,$intemplate) = @_;
  my $found = "";
  $aTemplate = $intemplate if($intemplate);

  if($DB_docitems < 1) { # If $DB_docitems > 0, then data is already read and in $D hash
	  $docid =~ s/^\s//g;   ## trim non-alphanumerics
	  $docid =~ s/\s$//g;   ## trim non-alphanumerics
      if(-f "$deletepath/$docid.del" and $doclistname !~ /$deleteSS/
	      and -f "$printdeletedOFF") {
          return("");
	  }
	  $found = &get_doc_data($docid,"");  # 2nd arg = $print_it ; data goes into hash $D
	  return("") if(!$found);
  }
  else {
	 # if doc is retrieved from the database, it will come here.
     return("") if($D{'deleted'} eq 'Y' and $doclistname !~ /$deleteSS/);
  }
  $expdate = "0000-00-00" if($expdate !~ /[0-9]/);

  if($cmd eq 'init_section') {
       $D{'sectsubs'} = $thisSectsub;
 ##    &write_doc_item($docid);   DISABLED UNTIL NEEDED
  }
  elsif($INSIDE) {   # This is an article inside a parent article
	   return("") if($D{'sectsubs'} =~ /$newsdigestSS/);  #skip if article moved to newsDigest
	   $INSIDE_FOUND = 'Y';
	   &put_data_to_array;
	   &process_inside_template($aTemplate,$docid);   #in template_ctrl
	   &IO_priority5($docid);
	   return("Y");   #found
 }
 else {
     $select_item = &do_we_select_item($docid);
     return("") if($skip_item =~ /Y/ or $select_item !~ /Y/);

	 &print_one_doc ($docid,$aTemplate,$print_it,$email_it,$htmlfile_it,$ckItemnbr);
	 return("Y");
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
 ##   &write_doc_item($docid);
  }
  return("Y");    # found, not skipped
}

sub print_one_doc
{
  ($docid,$aTemplate,$print_it,$email_it,$htmlfile_it,$ckItemnbr) = @_;
  &put_data_to_array;
  &process_template($aTemplate,'Y','N','N',$ckItemnbr);   #in template_ctrl
}


sub do_we_select_item
{
 my($docid) = $_[0];
 my $select_item = "Y";

# print "doc117 docid $docid listSectsub $listSectsub sectsubs $sectsubs ..fromtoSSname $SS{fromtoSSname}<br>\n";
 my $listSS = "";
 if($SS{fromtoSSname} and $SS{tofrom} ne 'T') {
	$listSS = $SS{fromtoSSname};
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
#	 if($select_kgp eq 'Y'and ($sumAcctnum eq 'A3491' or $sumAcctnum !~ /[A-Z0-9]/) and $skiphandle ne 'Y') {
	 if($select_kgp eq 'Y'and ($userid eq 'A3491' or $userid !~ /[A-Z0-9]/) and $skiphandle ne 'Y') {
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

 if ($bodycom =~ /\n\n/ and $DOCARRAY{template} =~ /straight/) {
   $bodycom =~ s/\n\n/<\/p><p>\n/g;
   $bodycom = "<p>$bodycom<\/p>";
   return($bodycom);
 }

 if($now_email eq 'Y') {
     $bodycom     =~ s/\r/" "/g;
     $bodycom     =~ s/\n/" "/g;
     $bodycom     =~ s/<i>/""/g;
     $bodycom     =~ s/<\/i>/""/g;
  }
  elsif($body_sw =~ /body/ and !$bodycom) {
     if($D{points} and $D{needsum} =~ /[45]/) {  #keypoints or keypoints + red arrow
	      $bodycom = $D{points};
     }
     else {
	      $bodycom = substr($D{fullbody},0,450) . "...";
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
	 foreach $bodycomline (@bodylines) {    # substitute inside template merged with data for this docid earlier in process
		if($bodycomline =~ /^@@([0-9]{6})/) {
		    my $indocid = $1;
#		print "doc200 ..indocid $indocid ... <br><br>*** $INSIDEMERGE{$indocid}*** <br><br>\n";
		    $bodycomline = $INSIDEMERGE{$indocid} if($INSIDEMERGE{$indocid});
#		    $INSIDEMERGE{$indocid} = "";
		}
	    elsif($bodycomline =~ /#http/ or $bodycomline =~ /#[A-Z]/ or $bodycomline =~ /#mp3#http/) { #link or acronym
		   my @words = split(/ /,$bodycomline);
		   $bodycomline = "";
		   foreach $word (@words) {
		       if($word =~ /^#([http|https]:\/\/.*)/ or $word =~ /##([http|https]:\/\/.*)/ or $word =~ /#mp3#(http:\/\/.*)/) {
				   $url = $1;
				   if($word =~ /##[http|https]:/) {   #   2 ##s = clickable url
					  $word = "<small><a target=\"blank\" href=\"$url\">$url<\/a><\/small>";
				   }
                   elsif( $DOCARRAY{template} eq "newsalertItem") {
				        $word = "Click left arrow ";
                   }
				   elsif($word =~ /#mp3#http:/) {   #   2 ##s = clickable url
					    $word .= "<object width=\"300\" height=\"42\"> <param name=\"src\" value=\"$url\">";
$word .= <<ENDWORD;
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

     if( $DOCARRAY{template} =~ /straight|link/
	     or $bodycom =~ /<font|<center|<blockquote|<div|<table|<li|<dl|<dt|<dd/) {
	   $bodycom = &xhtmlify($docid,$DOCARRAY{template},$bodycom);
	 }
	 elsif ($bodycom =~ /\n\n/ and  $DOCARRAY{template} !~ /newsalertItem/) {
	      $bodycom =~ s/\n\n/<\/p><p>\n/g;
	 }
	 else {
	      $bodycom =~ s/\n/<br>\n/g;
	}
  }

  if($D{link} and !$owner and $D{sectsubs} =~ /$newsdigestSS/ and (!$D{body} or $D{needsum} =~ /[234579]/) ) {
	 $bodycom = "$bodycom <br><small>. . . <a target=\"_blank\" href=\"$D{link}\">more</a><\/small>";
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
 my($docid) = $_[0];
# &get_contributor_form_values if($ipform !~ /chaseLink/);
 unless ($FORM{ipform} eq 'summarize') {
    &get_doc_form_values("");    #pgitemcnt = "" if template=$docUpdate
    &update_control_files;  # if add or update needed
 }
 else {
    $userid    = $FORM{userid};
 }
 &main_storeform($docid);
}

sub storeMaiduform
{
  my($docid) = $_[0];
  if($FORM{body} and $FORM{body} !~ /\*Not found/i ) {
     $docaction = 'C';   # change only
     $DH{docaction} = $docaction;
     $D{body} = &strip_lines_leadingSP_BR($FORM{body}) if($FORM{body});
     $docid = &write_doc_item($docid,$docaction);  # only body will be written
     print "<br><br><big>Maidu webpage updated</big><br>\n";
     print"<meta http-equiv=\"refresh\" content=\"10;url=http://http://motherlode.sierraclub.org/maidu/index.html\">";

  }
  else {
     print "<br><br><big>Maidu webpage invalid update request <small>#$docid @doc752</big><br>\n";
     print"<meta http-equiv=\"refresh\" content=\"10;url=http://www.population-awareness.net/cgi-bin/cgiwrap/popaware/article.pl?display%MaiduUpdate\">";
  }
}


sub main_storeform {  #from above and also from write_email
 my($docid) = $_[0];
 my $docation;

 unless($docid) {
   $docaction = 'N';
   $docid = &get_docid($docaction);
   $D{sysdate} = &calc_date('sys',0,'+');
 }

 if($D{sysdate} !~ /[0-9]/ or $D{sysdate} <= $DT{epoch_date}) {
   $D{sysdate} = &calc_date('sys',0,'+');
 }

 if($FORM{ipform} eq 'summarize') {
     my $found = &get_doc_data($docid,'N');  # data goes into global hash %D
	 $access      = "access";
	 $docaction = 'C';  # change
	
     $D{body} = $FORM{body};
     if($D{body}) {
	     $D{body} = &strip_leadingSPlineBR($D{body});
         $D{body} = &byebye_singleLF('N','N',$D{body});
     }

     $D{note} = $FORM{note};
     if($D{note}) {
	     $D{note} = &strip_leadingSPlineBR($D{note});
         $D{note} = &byebye_singleLF('N','N',$D{note});
     }

	 $sectsubs    = $summarizedSS;
	 $addsectsubs = $summarizedSS;
#	print "doc645 form $FORM{ipform} ..sectsubs $sectsubs ..addsectsubs $addsectsubs<br>\n";
 }
 else {
     $sectsubs = $D{sectsubs};
 }
 $DH{docaction} = $docaction;

 &do_sectsubs;     # in sectsubs.pl

 $D{sectsubs} = $sectsubs;
# &do_keywords if($selkeywords =~ /[A-Za-z0-9]/ and $docaction ne 'D');

	
 $docid = &write_doc_item($docid,$docaction);
 $D{docid} = $docid;

 my @save_sort = ($D{sectsubs},$addsectsubs,$delsectsubs,$chglocs,$D{pubdate},$D{woapubdatetm},$D{sysdate},$D{headline},$D{region},$D{topic});

 ($D{sectsubs},$addsectsubs,$delsectsubs,$chglocs,$D{pubdate},$D{woapubdatetm},$D{sysdate},$D{headline},$D{region},$D{topic}) = @save_sort;

 &hook_into_system($docid,$D{sectsubs},$addsectsubs,$delsectsubs,$chglocs,'single'); ## add to index files in indexes.pl

 &ck_popnews_weekly
    if($addsectsubs =~ /$newsdigestSectid/ or $delsectsubs =~ /$newsdigestSectid/); ## in article.pl

 &email_admin("Item $docid has been summarized by volunteer $userid A- $A{userid}\n
       Click here to process: http://www.overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?display%login%$docid")
       if($D{sectsubs} =~ /$summarizedSS/ and $userid and $userid !~ /A3491/);

 &log_volunteer($userid,$docid,$thisSectsub) if($D{sectsubs} =~ /$summarizedSS/ or $ipform =~ /chaseLink/);

 $sections="";
 $chgsectsubs = "$addsectsubs;$modsectsubs;$delsectsubs";
 $chgsectsubs =~  s/^;+//;  #get rid of leading semi-colons

 my $ipform = $FORM{'ipform'};

## TODO: we will replace this with DB count after we set $DB_docitems > 0
 system "touch $time4countfile" unless (-f $time4countfile); #If storeform, OK to write to countfile in indexes.pl

 if($owner) {
   &print_review($OWNER{'oreviewtemplate'});
   sleep 20;
   print "<br><br>Saved webpage:(you may need to reload the frame to get the most recent version)<br><iframe src=\"http://$publicUrl/$owner" . "_webpage/index.html\" width=\"1000\" height=\"1000\"></iframe>";
   print"</div></body></html>";
   return(0);
 }
 elsif($D{sectsubs} =~ /Suggested_suggestedItem/ and $ipform =~ /newItemParse/) {
	print "<div style=\"font-family:arial;font-size:1.2em;margin-top:13px;margin-left:7px;\">&nbsp;&nbsp;Item -- $docid -- has been submitted; Ready for next item:</div>\n";
	$D{fullbody} = "";
	$D = "";
	$DOCARRAY = "";   # get ready for the next one
	$FORM = "";
	return;    # return to article.pl to print next page: another newItemParse form
 }
 else {
    &print_review('review');
 }
 &do_html_page($docid,$listSectsub,$aTemplate,1,$chgsectsubs); ## create HTML file - this is in display_list.pl

}


sub update_control_files {
 my $sourceid = 0;
 my $regionid = 0;
 my($rest,$xseq,$xtyp);

 my $addchgsource = $FORM{"addchgsource$pgitemcnt"};
 if($addchgsource =~ /[AU]/) {
     $D{sourcefk} = &add_updt_source_values($D{source},$addchgsource,'docupdate');  #in sources.pl
 }
 else {
	 ($sourceid,$D{source},$rest) = split(/\^/,$D{source},3);
	 $D{sourcefk} = $sourceid if($D{sourcefk} < 1 and $sourceid =~ /[0-9]/);
 }

 my $addchgregion = $FORM{"addchgregion$pgitemcnt"};
 if($addchgregion =~ /[AU]/) {
     $D{regionfk} = &add_updt_region_values($D{region},$addchgregion);  #in regions.pl
 }
 else {
     ($regionid,$xseq,$xtyp,$D{region},$rest) = split(/\^/,$D{region},5);
     $D{regionfk} = $regionid if($D{regionfk} < 1 and $regionid =~ /[0-9]/);
 }

 my $addacronym = $FORM{"addacronym$pgitemcnt"};
 &add_acronym if($addacronym =~ /A/);       # in controlfiles.pl
}

#sub update_sectsubs {   ## NOT USED ###
# my $addchgsectsub = $FORM{"addchgsectsub$pgitemcnt"};
# my $rest;
# ($sectsubid,$D{sectsub},$rest) = split(/\^/,$D{sectsub},3) if($addchgsectsub !~ /A/);
# $sectsubid = &add_updt_sectsub_values($D{sectsub},$addchgsectsub);  #in sectsubs.pl
# }

## STOREFORM subroutines

sub get_docid
{
  my($docid,$docaction) = @_;
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
  return($docid);
}

# SIMILAR TO STOREFORM, BUT FROM A LIST OF ITEMS TO BE UPDATED

sub do_updt_selected   # from selecteditems_crud.pl
{
  my($docid,$listSectsub) = @_;

  &clear_work_variables;

  $found = &get_doc_data($docid,'N');  # data goes into global hash %D

  &get_more_select_form_values;  ## OVERRIDES prior doc values, but not yet sectsubs

  $D{fullbody} = &prepare_fullbody;  #in smartdata.pl

  $doc_fullbody = $D{fullbody} if($ipform =~ /chaseLink/);
##                   new priority overrides prior priority
  $D{priority} = $form_priority;

  $D{priority} = "4"  if($ipform =~ /chaseLink/ and $D{priority} !~ /D/); ## drop priority since apparently volunteer didn't fill in form

  if($D{headline} =~ /^\*\* / and ($fSectsubs =~ /$headlinesSS/ or $fSectsubs =~ /$suggestedSS/)) {
     $D{priority} = "7";
     $D{headline} =~ s/^\*\*//;
  }
  elsif($D{headline} =~ /^\* / and ($fSectsubs =~ /$headlinesSS/ or $fSectsubs =~ /$suggestedSS/)) {
     $D{priority} = "6";
     $D{headline} =~ s/^\*\*//;
  }
  elsif($D{headline} =~ /^>a / and $fSectsubs =~ /$headlinesSS/) {
     $fSectsubs = "Headlines_admin" ; #special article to be treated by admin or quick track
     $D{headline} =~ s/>a//;
  }

  ($D{sectsubs},$addsectsubs,$delsectsubs) =
    &change_sectsubs_for_updt_selected($D{priority},$ipform,$selitem,$pgitemcnt,$listSectsub,$cmd,$fSectsubs,$D{sectsubs},$dDocloc); # in sectsubs.pl  THIS IS LIKE DO_SECTSUBS IN STOREFORM.

 print "&nbsp;<font face=verdana><font size=1>$docid </font><font size=2>$D{headline} </font><font size=1>.. sectsubs $D{sectsubs}</font><br>\n";

  $D{docid} = $docid;
  $docid = &write_doc_item($docid,$docaction);

  &hook_into_system($docid,$D{sectsubs},$addsectsubs,$delsectsubs,$chglocs,'list'); ## -- in indexes.pl

  $sourceid = &add_updt_source_values($D{source},$addchgsource,'selupdate') if($addchgsource =~ /A/);  #in sources.pl
  $regionid = &add_updt_region_values($D{region},$addchgregion) if($addchgregion);  #in regions.pl

  &clear_doc_data;
}


sub print_review
{
 my $template = $_[0];
 $sectsubs = "$sectsubs;$mobileSS" if($sectsubs =~ /$newsdigestSS/);
 &get_pages("$addsectsubs;$sectsubs;$delsectsubs");   #in sectsubs.pl
##         print the receipt
 &put_data_to_array;
 &process_template($template,'Y','N','N');
 $aTemplate = $qTemplate;
 $print_it = 'N';
}


sub log_volunteer
{
 my ($userid,$docid,$sectsub) = @_;
 &DB_write_docid_to_user_log($userid,$docid,$thisSectsub);  # docid can be count if a list

 if($userid =~ /[A-Za-z0-9]/) {
	     $addsectsubs = "$addsectsubs;Volunteer_log$userid";
 }
 elsif($userid =~ /[A-Za-z0-9]/) {
     $addsectsubs = "$addsectsubs;Volunteer_log$userid";
 }
}


sub process_popnews_email       # from selecteditems_crud.pl when item selected from Suggested_emailedItem list
{
 ($edocid,$elink,$epriority,$index_insert_sth) = @_;
 my $found = "";

 $found = &get_doc_data($edocid,'N');

 if($found) {
	 &get_more_select_form_values; #Overrides current docitem with values from form

	$docid = &get_docCount;        # replace emailed docid with new docid from the system
	if($fullbody =~ /^(DD|SS|MI|HH|SH|By:|RR) /) {
	    $fullbody = &parse_msg_4variables('R','N',$fullbody)   # in smartdata.pl .. P ep_type = parse from new form E = comes in from email R = redo
	}
	$link = $elink;
	$priority = $epriority;

	$addsectsubs = $suggestedSS;
	$sectsubs = $suggestedSS;
	$delsectsubs = "";

	$docid = &write_doc_item($docid,$docaction);

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
	  $sth_idx_insert = &DB_prepare_idx_insert(""); #in indexes table; prepare only once
      @expired = split(/;/,$expired);
      foreach $docid (@expired) {
	    $found = &get_doc_data($docid,N);  ## goes into global hash %D
   	    $delsectsubs = $sectsubs;
   	    $addsectsubs = $expiredSS;
   	    $sectsubs    = $expiredSS;
   	    $docid = &write_doc_item($docid,$docaction);  ## in docitem.pl
#       &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,$pubdate,$woapubdatetm,$sysdate,$headline,$region,$topic);
   	    &hook_into_system($docid,$sectsubs,$addsectsubs,$delsectsubs,$chglocs,'single');  # in indexes.pl
     }
 }
}


sub check_for_skip_not_used
{
  my $skip_item = 'N';
  my $headline  = $D{headline};
  my $link      = $D{link};

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
  return($skip_item);
}


sub get_select_form_values
{
  $docid       = $FORM{"docid$pgitemcnt"};
  $docid       = $FORM{"sdocid$pgitemcnt"} unless($docid);
  $D{docid}    = $docid;
  $priority    = "5";
  $priority    = $FORM{"priority$pgitemcnt"} if($FORM{"priority$pgitemcnt"} =~ /[D1-7]/);
  $form_priority = $priority;
  $D{priority} = $priority;
  $selitem     = $FORM{"selitem$pgitemcnt"};

}

sub get_more_select_form_values  # comes here from selecteditems_crud.pl
{

 foreach $keyname (keys %D) {
    $D{$keyname} = $FORM{"$keyname$pgitemcnt"} if($FORM{"$keyname$pgitemcnt"} and $keyname !~ /(priority|docid|sectsubs)/);
 }
 unless($FORM{"source$pgitemcnt"}) {
   $D{source}  = $FORM{"selectsource$pgitemcnt"} if($FORM{"selectsource$pgitemcnt"} !~ /"select one"/);
 }
 my $rest = "";
 ($D{sourcefk},$D{source},$rest) = split(/\^/,$D{source},3) if($D{source} =~ /\^/);

 ($D{regionfk},my $seq,my $r_type,$D{regionname},$rest) = split(/\^/,$D{region},3) if($D{region} =~ /\^/);

 $D{changebyfk}  = &get_user_uid($userid);
 $pubday         = $FORM{"pubday$pgitemcnt"};
 $pubmonth       = $FORM{"pubmonth$pgitemcnt"};
 $pubyear        = $FORM{"pubyear$pgitemcnt"};
 $D{pubdate}     = &assemble_pubdate($pubdate,$pubday,$pubmonth,$pubyear); # in date.pl
 my($one,$regionid,$three,$rest);
 ($one,$regionid,$three,$D{region},$rest) = split(/^/,$region,5) if($D{region} =~ /\^/);
 $D{regionhead}  = $FORM{"regionhead$pgitemcnt"} if($FORM{"regionhead$pgitemcnt"} =~ /[YN]/);
 $addregion      = $FORM{"addregion$pgitemcnt"}  if($FORM{"addregion$pgitemcnt"} =~ /[AU]/);
 $fSectsubs      = $FORM{"sectsubs$pgitemcnt"}   if($FORM{"sectsubs$pgitemcnt"});
 $fSectsubs      = $listSectsub if(!$fSectsubs and $listSectsub =~ /Suggested_suggestedItem/);
 $linkmatch      = $FORM{"linkmatch$pgitemcnt"}     if($FORM{"linkmatch$pgitemcnt"});
 $sstarts_with_the = $FORM{"sstarts_with_the$pgitemcnt"} if($FORM{"sstarts_with_the$pgitemcnt"});
 ($D{source},$sregionname) = &get_source_linkmatch($D{link}) if($sourcelink eq 'Y' and $D{link} and !$D{source});
 $addchgsource   = $FORM{"addchgsource$pgitemcnt"}  if($FORM{"addchgsource$pgitemcnt"} =~ /[AU]/);
 $addchgregion   = $FORM{"addchgregion$pgitemcnt"}  if($FORM{"addchgregion$pgitemcnt"} =~ /[AU]/);
 $sourcelink     = $FORM{"sourcelink$pgitemcnt"} if($FORM{"sourcelink$pgitemcnt"});
 $lfx2           = $FORM{"lfx2$pgitemcnt"};
 $D{fullbody} =~ s/\r/\n/g;
 if($lfx2 eq 'Y') {
#	$D{fullbody} =~ s/\r/\n/g;
    $D{fullbody} =~ s/\n\n/<p>/g;
    $D{fullbody} =~ s/\n/\n\n/g;
    $D{fullbody} =~ s/<p>/\n\n/g;
 }
 $dDocloc        = $FORM{"docloc_add$pgitemcnt"} if($FORM{"docloc_add$pgitemcnt"} =~ /[A-Za-z0-9]/);
 if($fSectsubs =~ /(Suggested_suggestedItem|$emailedSS)/ or $D{titlize} =~ /Y/) {
    ($D{headline},$rest) = split(/Date:/,$D{headline},2) if($D{headline} =~ /Date:/);
 }
}


sub get_doc_form_values
{
 my $pgitemcnt = $_[0];
 foreach $keyname (keys %D) {
	my $value = $FORM{"$keyname$pgitemcnt"};
    $D{"$keyname"} = $FORM{"$keyname$pgitemcnt"} if($FORM{"$keyname$pgitemcnt"} and $keyname !~ /(priority|docid|pubdate)/)
 }

 unless($FORM{"source$pgitemcnt"}) {
    $D{source}  = $FORM{"selectsource$pgitemcnt"} if($FORM{"selectsource$pgitemcnt"} !~ /"select one"/);
 }
 ($D{sourcefk},$D{source},my $rest) = split(/\^/,$D{source},3) if($D{source} =~ /\^/);

 $D{source} =~ &strip_leadingSPlineBR($D{source});
 $D{source} =~ s/\s+$//;

 $advance        = $FORM{"advance$pgitemcnt"};
# do we need?  $ipform         = $FORM{"ipform$pgitemcnt"};
 $userid         = $FORM{"userid$pgitemcnt"} if($ipform =~ /'newArticle'/);
 $DH{userid} = $userid;
 $formSectsub    = $FORM{"cSectsubid$pgitemcnt"};

 $priority       = $FORM{"priority"} unless($priority);
 $priority       = $FORM{"priority$pgitemcnt"} unless($priority);
 $D{priority}  = $priority;

 $pubday         = $FORM{"pubday$pgitemcnt"};
 $pubmonth       = $FORM{"pubmonth$pgitemcnt"};
 $pubyear        = $FORM{"pubyear$pgitemcnt"};
 $D{pubyear}     = $pubyear;
 $D{pubdate} = &assemble_pubdate($pubdate,$pubday,$pubmonth,$pubyear); # in date.pl

 $expday         = $FORM{"expday$pgitemcnt"};
 $expmonth       = $FORM{"expmonth$pgitemcnt"};
 $expyear        = $FORM{"expyear$pgitemcnt"};

 $expyear = '0000' if($expyear eq 'no date');
 if($expyear !~ /20[1-9][0-9]/) {
     $D{expdate} = $epoch_date;
 }
 elsif($expmonth eq "_" or $expmonth eq "" or $expmonth eq '00') {
     $D{expdate} = "$expyear-00-00";
 }
 else {
    $D{expdate} = "$expyear-$expmonth-$expday";
 }

  $D{body}         =~ s/\r/\n/g;
  $D{points}       =~ s/\r/\n/g;
  $D{comment}      =~ s/\r/\n/g;
  $D{bodyprenote}  =~ s/\r/\n/g;
  $D{bodypostnote} =~ s/\r/\n/g;

  $docfullbody    = "";
  $docfullbody    = $FORM{"docfullbody$pgitemcnt"};
  $docfullbody    =~ s/\r/\n/g;
  $docfullbody    =~ s/&quote\;/\"/g;
  $D{fullbody}    = "$docfullbody\n\nFULLARTICLE:\n$fullbody"
        if($ipform =~ /chaseLink/ and $docfullbody =~ /[A-Za-z0-9]/);
  $D{fullbody}     =~ s/\r/\n/g;
  $fixfullbody     = $FORM{"fix$pgitemcnt"};   ## temporary variable

  $owner          = $FORM{"owner$pgitemcnt"};   ## temporary variable
  &get_owner($owner) if($owner);
  $DH{owner} = $owner;

  $linknote        = $FORM{"linknote$pgitemcnt"};
  $D{note}         = $FORM{"note$pgitemcnt"};
  $D{note}         = "$D{note} $linknote" if($linknote);
#  $selkeywords     = $FORM{"selkeywords$pgitemcnt"};
#  $newkeyword      = $FORM{"newkeyword$pgitemcnt"};
  $docaction        = $FORM{"docaction$pgitemcnt"};
  $DH{docaction}    = $docation;

  $thisSectsub      = $FORM{"thisSectsub$pgitemcnt"} if($FORM{"thisSectsub$pgitemcnt"});
  $listSectsub      = $thisSectsub;
  $DH{listsectsub}  = $listSectsub;
  $D{sourcefk}      = $FORM{"sourcefk$pgitemcnt"};

  $D{dtemplate}     = $FORM{"dTemplate$pgitemcnt"};
  $D{dtemplate}     = 'straight'  if($straightHTML eq 'Y');

  if($D{dtemplate} !~ /[A-Za-z0-9]/ or $D{dtemplate} =~ /default/) {
	 $D{dtemplate} = $default_class;  #derived from sections.html
  }
  $dtemplate       = $D{dtemplate};

  $D{regionfk}     = $FORM{"regionfk$pgitemcnt"};
  $updsectsubs     = $FORM{"updsectsubs$pgitemcnt"};
  $addsectsubs     = $FORM{"addsectsubs$pgitemcnt"};
  $DH{addsectsubs} = $addsectsubs;
  $newsprocsectsub = $FORM{"newsprocsectsub$pgitemcnt"} unless $newsprocsectsub;
  $pointssectsub   = $FORM{"pointssectsub$pgitemcnt"};
  $ownersectsub    = $FORM{"ownersectsub$pgitemcnt"};

  if($addsectsubs =~ /;/) {
    ($first_addsectsub,$rest) = split(/;/,$addsectsubs,2);
  }
  else {
    $first_addsectsub = $addsectsubs;
  }

  if($D{sectsubs} =~ /;/) {
    ($first_sectsub,$rest) = split(/;/,$D{sectsubs},2);
  }
  else {
    $first_sectsub = $D{sectsubs};
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

  $stratus_add  = $FORM{"docloc_add"};
  $stratus_news = $FORM{"docloc_news"} unless($stratus_news);

  $D{regionhead} = 'N' if($D{regionhead} !~ /Y/);

  $D{headline} = &strip_leadingSPlineBR($D{headline});
  $D{headline} =~ s/\s+$//;

  if($D{sectsubs} =~ /(Suggested_suggestedItem|$emailedSS)/ or $D{titlize} =~ /Y/) {
     ($D{headline},$rest) = split(/Date:/,$D{headline},2) if($D{headline} =~ /Date:/);
  }

  my ($rregionfk,$rseq,$r_type,$rregion,$rrest) = split(/\^/,$D{region},5);
  $D{region} = $rregion;
  $D{region} =~ s/^;//;
  $D{region} =~ s/;$//;

  @lines = split(/\n/,$D{body});
  $D{body} = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $D{body} = "$D{body}$line\n";
  }

  @lines = split(/\n/,$D{points});
  $D{points} = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $D{points} = "$D{points}$line\n";
  }

  @lines = split(/\n/,$D{fullbody});
  $D{fullbody} = "";
  foreach $line (@lines) {
     $line = &strip_leadingSPlineBR($line);
     $D{fullbody} = "$D{fullbody}$line\n";
  }
}

##      GET_ARTICLE FROM FLATFILE OR DATABASE

sub get_doc_data
{
  my($indocid,$print_it)  = @_;
 return("") unless($indocid);
  my $found_it = "";
  my $printout = "";
  &clear_doc_data;
  &clear_doc_helper_variables;
  my $docid = $indocid;

  if($DB_docitems > 0 and $cmd !~ /import/) {
	  my ($col_sql,$num_cols) = &build_sql('select');
	  my $sth = $DBH->prepare("$select FROM docitem as d WHERE d.docid = ?");
	  @row = &DB_get_docitem($sth,$docid,"");   # returns data in hash %D
	  $found_it = "Y" unless(!@row or $D{deleted} =~ /Y/);
  }
  else { # flatfile processing
	  if($docid =~ /-/) {
		  $filepath = "$mailpath/$docid.itm";  # emailed
	  }
	  else {
		   $docid =~ s/\s+$//mg;
           $filepath = "$itempath/$docid.itm";
      }
      %D = ();
	  if(-f "$filepath") {
		$found_it = "Y";
	    open(DATA, "$filepath");
	#                  one line per field
	    while(<DATA>)
	    {
	       chomp;
	       $line = $_;
	       if($line !~ /\^/) {



			 if($straightHTML eq 'Y') {
			      $D{dtemplate} = 'straight';
			      print "$docid STRAIGHT -- $headline <br>\n";
			      &write_index_flatfile ('import_Straight_html',$docid,'','P','import_Straight_html','');  #log - in index.pl
			 }
			 $dtemplate = $dTemplate;




		     $D{$name} = "$D{$name}\n$line";   #fill global hash
	       }
	       else {
	         ($name, $value) = split(/\^/,$line);
#	print "doc1235 name *$name* value $value<br>\n";
#			 $name = "sysdate"    if ($name =~ /sysdate/);
#			 $name = "skipheadline" if ($name =~ /skipheadline/);
#			 $name = "priority"   if ($name =~ /priority/);
#			 $name = "worth"     if ($name =~ /worth/);
             $D{$name} = $value;
	      }
	      $printout .= "$line<br>\n" if($print_it =~ /Y/); # printit not the same as $print_it passed in as arg
	    }
	    close(DATA);

#        @D{ keys %D } = @DT{ keys %DT };

	     return $printout if($print_it =~ /Y/);
	 }
	 else {
#				print "doc1067 NOT FOUND ..filepath $filepath<br>\n";
	     $D{headline} = "File not found at doc1159 - docid *$docid*";
	     return("");
	}
  }

  unless($found_it) {
	 $D{headline} = "File not found at doc1047 - docid *$docid*";
	 return("");
  }
  $found_it = 'Y';
  $D{docid} = $docid;

  return ($found_it) if($cmd =~ /import/);

  &massage_docitem_variables;	#massages data from hash %D
  if($D{body} =~ /@@[0-9]{6}/ and !$INSIDE and $D{sectsubs} =~ /$newsdigestSS/) {
	 $INSIDE = "Y";         ## needed to prevent looping in this recursive routine
	 $save_template = $aTemplate;
     my %D_save = %D;

     $parent_docid        = $docid;
     $DH{parent_docid}    = $docid;
     $DH{parent_template} = $aTemplate;
     $parent_sectsubs     = $D{sectsubs};  #global
     $parent_needsum      = $D{needsum};   #global - examined in template_ctrl.pl
     $DH{parent_sectsubs} = $D{sectsubs};  #global
     $DH{parent_needsum}  = $D{needsum};   #global - examined in template_ctrl.pl
# print "Parent $docid .. body $body ..parent_needsum $parent_needsum<br><br>\n";
     my $newbody = &get_inside_articles($D{body});  # builds html file (data married with template) of each docid of inside articles
     $aTemplate = $save_template;

     %D = ();   # restore %D
	 for (keys %D)
	    { delete $D{$_}; }
     %D = %D_save;
#	 $D{body} = $newbody;    # body is changed only on printout in do_body_comment

	 if($INSIDE_FOUND) {
		 $INSIDE_FOUND = "";
		 $INSIDE = "";
	 }
 }

 return ($found_it);
}

sub get_inside_articles {
 my $body = $_[0];
 my $word = "";
 my $bodybuild = "";
 my $indocid= "";
 my $intemplate = "";
 my $found = "";
 my $newbody = "";     #rebuild body
 my @bodylines = split(/\n/,$body);
 foreach my $bodyline (@bodylines) {
	 if($bodyline =~ /^@@[0-9]{6}/ and $DH{parent_sectsubs} =~ /$newsdigestSS/ and $DH{parent_template} =~ /newsitem/) {
		 my $indocid = substr($bodyline,2,7);
        my($rest,$insidetemplate) = split(/-/,$bodyline,2) if($bodyline =~ /@@[0-9]{6}-/);
		$insidetemplate = "news_insideItem" unless($insidetemplate);
		$insidetemplate = "email_insideItem" if($insidetemplate =~ /news_insideItem/ and $now_email =~ /Y/);
	    $found = &prt_one_doc($indocid,$insidetemplate);   #used recursively

#        $newbody = "$newbody\n$INSIDEMERGE{$indocid}" if($found and $newbody);
#	    $newbody = "$INSIDEMERGE{$indocid}" if($found and !$newbody);
     }
     else {
#	    $newbody = "$newbody\n$bodyline" if($newbody);
#		$newbody = "$bodyline\n" if(!$newbody);
	}
 }
 return($newbody);
}

sub massage_docitem_variables
{
    $D{priority} = '5' if($D{priority} !~ /[1-7]/ or -f "$priority5path/$docid.pri5");
    ($expyear,$expmonth,$expday) = split(/-/,$D{expdate},3);
    if($straightHTML eq 'Y') {
    	$D{dtemplate} = 'straight';
    }
    $D{link}   =~ s/^\s+//;

    $D{body}   =~ s/\n+$//g;    ## trim trailing line feeds
    $D{body}   =~ s/\r+$//g;    ## trim trailing returns
    $D{body}   =~ s/\n\r+$//g;  ## trim trailing returns
    $D{body}   =~ s/\r\n+$//g;  ## trim trailing returns
    $D{points} =~ s/\s+$//g;  ## trim white space
    $D{points} =~ s/\n+$//g;  ## trim trailing line feeds
    $D{points} =~ s/\r+$//g;  ## trim trailing returns
    $D{points} =~ s/\n\r+$//g; ## trim trailing returns
    $D{points} =~ s/\r\n+$//g; ## trim trailing returns
    $D{points} =~ s/\s+$//g;   ## trim white space
    $D{sectsubs} =~ s/NA`M;//;
    $D{sectsubs} =~ s/NA;//;
    $dSectsubs    = $D{sectsubs};

	$D{author}   =~ s/^\s+//g;    ## trim trailing white space
	$D{author}   =~ s/\s+$//g;    ## trim trailing white space
	$D{author}   &titlize($D{author});  #in smartdata.pl
    $D{fullbody} =  &reverse_regexp_prep($D{fullbody});   ##  common.pl
    if($rSectsubid =~ /(Suggested_suggestedItem|$emailedSS)/ or $D{titlize} =~ /Y/) {
       ($D{headline},$rest) = split(/Date:/,$D{headline},2) if($D{headline} =~ /Date:/);
       $D{headline} = &titlize($D{headline});  #in smartdata.pl
    }

    if( ($D{sectsubs} =~ /$suggestedSS/ or $D{sectsubs} =~ /$headlinesSS/ ) and $D{region} !~ /[A-Za-z0-9]/) {
	   $D{region} = &get_regions('N',"",$D{headline},$D{fullbody},$D{link}) if($D{region} !~ /[A-Za-z0-9]/);  # print_regions=N, region="", # controlfiles.pl
       $D{region} = "Global" unless($D{region});
    }
    if($aTemplate =~ /docUpdate/) {
       ($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index)
          = &get_regions($printit,$D{region});   #in regions.pl
        if($D{source} and $D{source} !~ /(select one)/) {
    	    ($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$regionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format)
              = &get_sources($printit,$D{source});   #in sources.pl
        }
    }
    return();
}


sub clear_work_variables
{
  $addsectsubs   = "";
  $newsprocsectsub = "";
  $pointssectsub   = "";
  $ownersectsub   = "";
  $delsectsubs   = "";
}

sub put_data_to_array {   #used in template_ctrl to marry templates with data
  foreach $keyname (keys %D) {
	$DOCARRAY{$keyname} = $D{$keyname};
  }
#           variables outside of docitem
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
 $DOCARRAY{'userid'}         = $userid;
 $DOCARRAY{'useremail'}      = $useremail;
 $DOCARRAY{'firstname'}      = $firstname;
 $DOCARRAY{'lastname'}       = $lastname;
 $DOCARRAY{'pin'}            = $pin;
 $DOCARRAY{'city'}           = $city;
 $DOCARRAY{'zip'}            = $zip;
 $DOCARRAY{'handle'}         = &get_user_handle($D{summarizerfk});  #in user.pl
 $DOCARRAY{'usercomment'}    = $usercomment;
 $DOCARRAY{'pay'}            = $pay;
 $DOCARRAY{'thisSectsub'}    = $listSectsub;
 $DOCARRAY{'rSectsubid'}     = $rSectsubid;
 $DOCARRAY{'updsectsub'}     = $updsectsub;
 $DOCARRAY{'addsectsub'}     = $addsectsub;
 $DOCARRAY{template}         = $D{dtemplate}; #This is the final version of the template that docitem is printed with
 $DOCARRAY{predate}          = $msgline_date;
}


##                WRITE_ITEM to file
sub write_doc_item
{
 my($docid,$docaction) = @_;   # if not in items directory, it is in popnews_mail
 $docid =~ s/\s+$//mg;

 return unless($D{headline} or $D{link} or $D{body} or $D{fullbody});

 if($addsectsubs =~ /$deleteSS|$expiredSS/) {
     &IO_delete($docid) if($docid ne "");
 }

 my $docpath = "";
 if($docid =~ /-/) {       ##  from emailed
	 $docpath = "$mailpath/$docid\.itm";
 }
 else {
	 $docpath = "$itempath/$docid\.itm";
 }

#          see if valid data
 if(($D{sysdate} =~ /[0-9]/ and $docid =~ /[0-9]/) or $D{sectsubs} =~ /$emailedSS/ ) {

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

	 open(DATAOUT, ">$docpath") or die("Could not open DATAOUT $...docpath $docpath");

     &write_doc_data_out;
     close (DATAOUT);
     chmod 0777, $emailfile if($SVRinfo{'environment'} == 'development');  ## GIT_HUB PATHS

	 if($DB_docitems > 0) {
		  if($docaction eq 'N') {
			 &DB_docitem_insert($docid);   #inserts from $D hash
		  }
		  else {
			 &DB_docitem_update($docid);
	      }
	 }

     unlink $lock_file if($lock_file);
  }
  else {
     print "Invalid sysdate=$D{sysdate} or docid-$docid; Could not write out docitem at # Error message: $! <br>\n";
  }

  return($docid);
}


sub write_doc_data_out
{
 my($uid) = &get_user_uid($userid);
 if($ipform eq "summarize") {
	   $D{summarizerfk} = $uid if($userid and !$D{summarizerfk});
       print DATAOUT "summarizerfk\^$D{summarizerfk}\n";
  }
  if($docaction eq 'N') {
	   $D{suggesterfk} = $uid if($userid and !$D{suggesterfk});
       print DATAOUT "suggesterfk\^$D{suggesterfk}\n";
  }
  $D{changebyfk} = $uid;
  print DATAOUT "changebyfk\^$D{changebyfk}\n";

  $D{updated_on} = &get_nowdate if(!$D{updated_on} or $D{updated_on} < $DT{earliest_date});
  print DATAOUT "updated_on\^$D{updated_on}\n";

  print DATAOUT "priority\^$D{priority}\n";

  print DATAOUT "deleted\^$D{deleted}\n";
  print DATAOUT "reserveuntil\^$D{reserveuntil}\n";
  print DATAOUT "outdated\^$D{outdated}\n";
  print DATAOUT "nextdocid\^$D{nextdocid}\n";

  if($docaction =~ /N/
  or $addsectsubs =~ /($newsdigestSS|Headlines|$suggestedSS|$summarizedSS)/
  or $D{woapubdatetm} < $DT{earliest_datetime} or !$D{woapubdatetm}) {
	   $D{woapubdatetm} = &get_woadatetm;
  }
  $woapubdatetm = $D{woapubdatetm};
  print DATAOUT "woapubdatetm\^$D{woapubdatetm}\n";

  if($DBdocitems < 1) {
     print DATAOUT "sysdate\^$D{sysdate}\n";
  }
  else {
     print DATAOUT "sysdate\^$D{sysdate}\n";
  }
  print DATAOUT "pubdate\^$D{pubdate}\n";
  print DATAOUT "skippubdate\^$D{skippubdate}\n";

  print DATAOUT "reappeardate\^$D{reappeardate}\n";
  print DATAOUT "expdate\^$D{expdate}\n";

  if($dTemplate eq 'default') {
   	 print DATAOUT "$D{dtemplate}\^\n";
  }
  elsif($straightHTML eq 'Y') {
	 $D{dtemplate} = 'straight';
     print DATAOUT "dTemplate\^straight\n";
  }
  else {
   	 print DATAOUT "dTemplate\^$D{dtemplate}\n";
  }

  if($docaction =~ /N/ and !$D{region}) {
	  $D{region} = &get_regions('N',"",$headline,$fullbody,$link);  # print_regions=N, region="", # controlfiles.pl
  }
  $D{region} =~ s/^;//;
  print DATAOUT "region\^$D{region}\n";
  print DATAOUT "regionhead\^$D{regionhead}\n";

  $D{regionfk} = &get_regionid($D{region}) if($D{region} and !$D{regionfk});
  print DATAOUT "regionfk\^$D{regionfk}\n";
  print DATAOUT "skipregion\^$D{skipregion}\n";

  $D{source} = "" if($D{source} =~ /select one/);
  $D{source} =~ &strip_leadingSPlineBR($D{source});
  $D{source} =~ s/\s+$//;
#  $source = &titlize($source) if( ($docaction =~ /N/ and !$owner)  or $titlize =~ /Y/); #in smartdata.pl
  print DATAOUT "source\^$D{source}\n";
  $D{sourcefk} = &get_sourceid($D{source}) if($D{source} and !$D{sourcefk});
  print DATAOUT "sourcefk\^$D{sourcefk}\n";
  print DATAOUT "skipsource\^$D{skipsource}\n";

  $D{author} =~ s/^\s+//;  # strip leading blanks
  $D{author} = &titlize($D{author}) if($docaction =~ /N/);
  print DATAOUT "author\^$D{author}\n";
  $D{skipauthor} = "" if($D{skipauthor} !~ /Y/ or !$D{skipauthor});
  print DATAOUT "skipauthor\^$D{skipauthor}\n";

  print DATAOUT "needsum\^$D{needsum}\n";

  $link =~ s/\<//g;
  $link =~ s/\<//g;
  print DATAOUT "link\^$D{link}\n";
  print DATAOUT "selflink\^$D{selflink}\n";
  print DATAOUT "skiplink\^$D{skiplink}\n";

  $D{headline} = &strip_leadingSPlineBR($D{headline});
##    $headline = &strip_leadingNonAlphnum($headline);
  $D{headline} =~ s/\s+$//;
  $D{headline} =~ s/\s+$//;
  $D{headline} =~ s/’/\'/g;  #E2 80 99 apostrophe
  $D{headline} =~ s/&#40;/\(/g;    ## left parens
  $D{headline} =~ s/&#41;/\)/g;    ## right parens
  $D{headline} =~ s/&#91;/\[/g;    ## left bracket
  $D{headline} =~ s/&#93;/\]/g;    ## right bracket
  $D{headline} = &titlize($D{headline}) if( ($docaction =~ /N/ and !$owner)  or $D{titlize} =~ /Y/); #in smartdata.pl
  print DATAOUT "headline\^$D{headline}\n";
  print DATAOUT "skipheadline\^$D{skipheadline}\n";

  print DATAOUT "subheadline\^$D{subheadline}\n";

  print DATAOUT "bodyprenote\^$D{bodyprenote}\n";

  print DATAOUT "skiphandle\^$D{skiphandle}\n";

  $D{body} =~  s/^\n+//;  #get rid of leading line feeds
  $D{body} =~  s/\n+$//;  #get rid of trailing line feeds

  $D{body} = &apple_convert($D{body});
  print DATAOUT "body\^$D{body}\n";
  print DATAOUT "bodypostnote\^$D{bodypostnote}\n";

  $D{comment} =~  s/\n+$//;  #get rid of trailing line feeds
  print DATAOUT "comment\^$D{comment}\n";

  $D{points} = &apple_convert($D{points}) if($D{points} =~ /[A-Za-z0-9]/);
  $D{points} =~  s/\n+$//;  #get rid of trailing line feeds
  print DATAOUT "points\^$D{points}\n";

  $extract = "E" if(!$D{body} and $D{points});

  $D{fullbody} =~  s/^\n+//;  #get rid of leading line feeds
  $D{fullbody} =~  s/\n+$//;  #get rid of trailing line feeds

  if($D{fullbody} =~ /^##FIX##/) {
      $D{fullbody} = &refine_fullbody($D{fullbody});
      $D{fullbody} =~ s/##FIX##//;
  }
  my $fullbodyx = $D{fullbody};
  $D{fullbody} = &apple_convert($fullbodyx) if($docaction =~ /N/ or $fixfullbody =~ /Y/);
  print DATAOUT "fullbody\^$D{fullbody}\n";

  print DATAOUT "freeview\^$D{freeview}\n";
  $D{note} =~  s/\n+$//;  #get rid of trailing line feeds
  print DATAOUT "note\^$D{note}\n";

  print DATAOUT "precat\^$D{precat}\n";

  print DATAOUT "miscinfo\^$D{miscinfo}\n";

  print DATAOUT "topic\^$D{topic}\n";
#  print DATAOUT "keywords\^$D{keywords}\n";
  print DATAOUT "special\^$D{special}\n";

  print DATAOUT "imageloc\^$D{imageloc}\n";
  print DATAOUT "imagefile\^$D{imagefile}\n";
  print DATAOUT "imagedescr\^$D{imagedescr}\n";

  print DATAOUT "worth\^$D{worth}\n";

  $D{sectsubs} =~ s/NA`M;//;
  $D{sectsubs} =~ s/NA;//;
  $D{sectsubs} =~ s/`+$//;  # get rid of trailing tic marks

#  $D{sectsubs} = &get_new_sectsubs($D{sectsubs});  #in sectsubs.pl

  print DATAOUT "sectsubs\^$D{sectsubs}\n";
}


sub get_docCount
 {
  my $docCount = "";
  my $num = 0;

  if($DB_docitems < 1) {
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
 }
 else {
	$num = &DB_get_docCount;
 }
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

####  IP/OP OPERATIONS ##########

sub IO_delete {
  my $docid = $_[0];
  system "touch $deletepath/$docid.del" unless (-f "$$deletepath/$docid.del");

  &DB_docitem_delete($docid) if($DB_docitems > 0);
}

sub IO_priority5 {  # set priority to 5 if promoted to newsDigest
	my $docid = $_[0];
	system "touch $priority5path/$docid.pri5" unless (-f "$priority5path/$docid.pri5");

	&DB_docitem_set_priority($docid,'5') if($DB_docitems > 0);
}


####  DATABASE OPERATIONS ##########

sub DB_get_lastpg2_woadatetm {
    my($sectsub) = $_[0];
    my $pg1pg2Limit = 0;
    $pg1pg2Limit = ($cPg1Items + $cPg2Items -1);
 	my $lastpg2woadatetm = $nulldate;
	my $sth = $DBH->prepare("SELECT d.woadatetm FROM docitems AS d, indexes AS i, sectsubs AS s WHERE i.sectsubid = s.sectsubid AND d.docid = s.docid AND d.deleted <> 'Y' AND s.sectsub = ? ORDER BY d.woadatetm DESC LIMIT ? , 1");

	if($sth) {
	    $sth->execute($sectsub,$pg1pg2Limit) or die "Couldn't execute statement: ".$sth->errstr;
	    $lastpg2woadatetm = $sth->fetchrow_array();
		$sth->finish();
	}
	else {
	   print" Couldn't prepare DB_getlastpg2_woadatetm query<br>\n";
	}
	return ($lastpg2woadatetm);
}


sub DB_get_docitem
{
  my ($sth,$docid,$print_it) = @_;
  undef %D;
  my @row = $sth->execute($docid);
  if(@row) {
     %D = $query->fetchhash;
     my %row;
     $sth->bind_columns( \( @row{ @{$sth->{NAME_lc} } } ));
     while ($sth->fetch) {
        %D = %$row;   # %D is a global hash where docitem column data is stored.
     }
     return(@row);
   }
   return("");
}

sub DB_prepare_get_docitem
{
  my $sth = $DBH->prepare( "SELECT * FROM docitems where docid = ?" );
  return($sth);
}

sub DB_docitem_delete
{
 my $docid = $_[0];
 my $sth = $DBH->prepare( "UPDATE docitems SET deleted='Y' WHERE docid = ?" );
 $sth->execute($docid);
}

sub DB_docitem_undelete
{
 my $docid = $_[0];
 my $sth = $DBH->prepare( "UPDATE docitem SET deleted='N' WHERE docid = ?" );
 $sth->execute($docid);
}

sub DB_docitem_set_priority
{
 my($docid,$priority) = @_;
 my $sth = $DBH->prepare( "UPDATE docitem SET priority=? WHERE docid = ?" );
 $sth->execute($docid,$priority);
}

sub DB_docitem_insert
{
	my $docid = $_[0];
	my $sth = &DB_prepare_docitem_insert($DBH);
    $D{'docid'} =  int($docid);
    $sth->execute_array(D{},\@keys, \@values); # OR CHANGE TO $DBH->DO LIKE UPDATE

#### TODO:  see change notes for other hash methods

 #   $sth->execute($n_docid,$deleted,$reservetimeup,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
#	$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,
#	$miscinfo,$precat,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagedescr,$worth,$summarizerfk,$suggesterfk,$changebyfk);
}

sub DB_prepare_docitem_insert
{
  my ($col_sql,$num_cols) = &build_sql('cols');
  my $question_marks = "?," x ($num_cols -2);
  my $sql = "INSERT IGNORE INTO docitems \($col_sql\) VALUES \(?,$question_marks CURDATE(\) \)";
print "doc1915 $num_cols $sql<br>\n";
  my $sth = $DBH->prepare($sql) or die("Couldn't prepare DB doc insert @doc1818 : " . $sth->errstr);
  return($sth);
}

sub DB_docitem_update
{
  my $docid = $_[0];
  my ($col_sql,$num_cols) = &build_sql('updateD');
  $DBH->do("$col_sql where docid = $docid"); # updates from hash $D

#	$doc_update_sth->execute($deleted,$reservetimeup,$outdated,$nextdocid,$priority,$headline,$regionhead,$skipheadline,$subheadline,$special,$topic,$link,$skiplink,$selflink,$sysdate,$pubdate,$pubyear,
#	$skippubdate,$woapubdatetm,$expdate,$reappeardate,$region,$regionfk,$skipregion,$source,$sourcefk,$skipsource,$author,$skipauthor,$needsum,$body,$fullbody,$freeview,$points,$comment,$bodyprenote,$bodypostnote,$note,
#	$miscinfo,$precat,$sectsubs,$skiphandle,$dtemplate,$imagefile,$imagloc,$imagedescr,$worth,$summarizerfk,$suggesterfk,$changebyfk,$n_docid);
}

sub DB_prepare_docitem_update_not_needed
{
 my $doc_update_sql = "UPDATE docitem SET deleted=?,reservetimeup=?,outdated=?,nextdocid=?,priority=?,headline=?,regionhead=?,skipheadline=?,
	subheadline=?,special=?,topic=?,link=?,skiplink=?,selflink=?,sysdate=?,pubdate=?,pubyear=?,skippubdate=?,woapubdatetm=?,
	expdate=?,reappeardate=?,region=?,regionfk=?,skipregion=?,source=?,sourcefk=?,skipsource=?,author=?,skipauthor=?,needsum=?,
	body=?,fullbody=?,freeview=?,points=?,comment=7,bodyprenote=?,bodypostnote=?,note=?,miscinfo=?,precat=?,sectsubs=?,skiphandle=?,dtemplate=?,imagefile=?,imageloc=?,
	imagedescr=?,worth=?,summarizerfk=?,suggesterfk=?,changebyfk=?,updated_on=CURDATE() WHERE docid = ?";
#
 my $doc_update_sth = $DBH->prepare($doc_update_sql);
 return($doc_update_sth);
}

sub DB_get_docCount
{
 $DBH->do("UPDATE counters SET doccount = doccount + 1");
 $sth = $DBH->prepare("SELECT doccount FROM counters");
 $sth->execute();
 my $docCount = $sth->fetchrow_array();
 return($docCount);
}

sub export_docitems  # From DB to flatfiles, including indexes; executed from dbtables_ctrl.pl
{
 my($mindocid,$maxdocid) = @_;  # Do a chunk at a time
 my $filename = "";
 %{$D} = ();
 $export_docitem_cnt = 0;

 &read_sectCtrl_to_array;  #in sectsubs.pl - needed to get sectsubids

 $DBH = &db_connect() if(!$DBH);
 my $sth = $DBH->prepare( 'SELECT * FROM docitems WHERE docid BETWEEN ? AND ?')
    or die("Couldn't prepare statement: " . $sth->errstr);
 $sth->execute($mindocid,$maxdocid);

# %D = $sth->fetchhash;
 my %row;
 $sth->bind_columns( \( @row{ @{$sth->{NAME_lc} } } ));
 while ($sth->fetch) {
    %D = %$row;   # %D is a global hash where docitem column data is stored

# while (my @row = $sth->fetchrow_array()) { # print data retrieve
   &write_exp_docitem;
   if($D{deleted} eq 'Y') { ### TODO: touch deleted file }
## TODO write to index files depending on $D{sectsubs}
   }
   $export_docitem_cnt = $export_docitem_cnt + 1;
 }
 $sth->finish;

# &export_indexes;  # NOTE: export_indexes are doen separately, unlike import

  print "Export item count $export_docitem_cnt .. mindocid $mindocid .. maxdocid $maxdocid </br>\n";
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
    my $sysdate        = $DATA{sysdate}; ## It is $sysdate for flatfiles and $sysdate for DB, byt $sysdate for internal variables
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

sub write_exp_docitem
{
 my ($docid) = &padCount6($D{'docid'});

 my $docpath = "$expitempath/$docid\.itm";

 if(-f "$docpath") {
     print "$docid already exists <br>\n";
     &write_index_flatfile ('export_AlreadyExists',$docid,'','P','export_AlreadyExists','');
     return;
 }

 open(DOCITEM, ">$docpath") or die("Couldn't open $docpath<br>\n");

 foreach my $docname (sort { ($doccol_order{$a} cmp $doccol_order{$b}) } keys  %doccol_order) {
     print DOCITEM "$docname\^$D{$docname}\n" unless($docname eq 'docid');
 }
 close(DOCITEM);
 chmod 0777, $docpath if($SVRinfo{'environment'} == 'development');
}


########### TODO - flag articles that are on wrong index (i.e. sectsubs =~ /headlines/ on newsdigest index)
########### TODO (later do this by year ???? - keep flatfile index by year)

sub import_docitems
{
 my ($newsSSname,$mindocid_n,$maxdocid_n) = @_;  # one of the news, headlines or news archives SS -or- docid max and min

 $itemcnt = 0;
 ##   $timesecs = time - (2*365*24*60*60); # subtract 2 years  DON'T NEED
 my $filename = "";
 my $prevdocid = 0;
 my $returnURL = "";
 my $sth_doc_insert = &DB_prepare_docitem_insert($DBH);
 my $sth_idx_insert = &DB_prepare_idx_insert($DBH);   # in indexes.pl

 my $mindocid = padCount6($mindocid_n) if($mindocid_n);   # in common.pl
 my $maxdocid = padCount6($maxdocid_n) if($maxdocid_n);

 &read_sectCtrl_to_array;  #in sectsubs.pl - needed to get sectsubids

 unless($newsSSname eq 'nomoreSS') {   # Do for each version of News types

	 if($newsSSname =~ /NewsDigest_NewsItem/) {     # DO this list first - it is the latest
	    $DBH->do("TRUNCATE TABLE docitems");
	    $DBH->do("TRUNCATE TABLE indexes");

	    $returnURL = "http://$scriptpath//article.pl?import%docitems%Headlines_sustainability%Suggested_suggestedItem%Suggested_summarizedItem%NewsScan_1_thru2010;NewsScan2_NewsItem;Archives2007Aug-2006Sep;ArchivesJan-Apr2003_item;ArchivesSep-Dec2002_item;ArchivesMay-Aug2002_item;ArchivesJan-Apr2002_item;ArchivesSep-Dec2001_item;ArchivesSep-Dec2000_item;ArchivesMay-Aug2000_item;noMoreSS%%";
     }
     else {  # Do each list successively until noMoreSS is reached, then work from items directory to pick up what is left
#	     $timesecs = &DBretrieve_timesecs;
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

		 last if($newsSSname eq 'Headlines_sustainability' and $itemcnt > 800);

#		 $timesecs = &import_one_docitem($docid,$newsSSname,$itemcnt,$sth_doc_insert,$sth_idx_insert,$timesecs)

		 &import_one_docitem($docid,$newsSSname,$itemcnt,$sth_doc_insert,$sth_idx_insert)
		     unless($docid eq $prev_docid);;
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
			&import_one_docitem($docid,$newsSSname,$itemcnt,$sth_doc_insert,$sth_idx_insert);
#		    $timesecs = &import_one_docitem($docid,$newsSSname,$itemcnt,$sth_doc_insert,$sth_idx_insert,$timesecs);
	    }
    }
 }
 $sth_doc_insert->finish;
 $sth_idx_insert->finish;

 #   &DBstore_timesecs($timesecs);

 print "Source: $newsSSname completed ..min $mindocid ..max $maxdocid ..Item count: $itemcnt  .. doc2037<br>\n";
 print "<a target=\"_blank\" href=\"$returnURL\">Click here</a> for the next section<br>\n" unless $newsSSname =~ /noMoreSS/;
}

sub import_one_docitem
{
 my ($docid,$newsSSname,$itemcnt,$sth_doc_insert,$sth_idx_insert) = @_;
 my $found= &get_doc_data($docid,'N');

 if($headline =~ /File not found/ or !$found) {
	 print "$docid NOTFOUND -- $headline <br>\n";
     &write_index_flatfile('import_NotFound',$docid,'','P','import_NotFound','');  #log - in index.pl
     return;
 }

 $n_docid = int($docid);
#                                                   # See if deleted
 $delfilepath = "$deletepath/$docid\.del";
 $D{deleted}  = 'N';
 $D{deleted} = 'Y' if(-f "$deletepath");
 my $pubdate = $D{pubdate};
 $pubdate = $DT{epoch_date} if($pubdate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);   # $epoch_time ?
 my $sysdate = $D{sysdate};
 $sysdate = $DT{epoch_date} if($sysdate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);

 if($pubdate and $pubdate >= $DT{epoch_date}) {
     $pubyear  = substr($pubdate,0,4);
 }
 elsif($sysdate) {
     $pubyear  = substr($sysdate,0,4);
 }
 else {
	 $pubyear = '0000';
 }

 $D{pubdate} = $pubdate;
 $D{sysdate} = $sysdate;  ##sysdate in a hash does not work, especially in DB processing

 my $woapubdatetm = $D{woapubdatetm};
 if($woapubdatetm < $DT{earliest_datetime} or !$woapubdatetm) {
	 if($newsSSname !~ "nomoreSS" and $item_count < 100) { # If still news type and for only most recent 100 of each
         $woapubdatetm = &get_woadatetm;	# in date.pl
	 }
	 else {
		if($pubdate > "1000-01-01") {
		    $woapubdatetm = "$pubdate 00:00:00";
		}
		else {
			$woapubdatetm = "$sysdate 00:00:00";
		}
	 }
 }
 $D{woapubdatetm} = $woapubdatetm;

 my $expdate      = $D{expdate};
 $expdate         = $DT{epoch_date} if(!$expdate or $expdate      !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);
 my $reappeardate = $D{reappeardate};
 $reappeardate    = $DT{epoch_date} if(!$reappeardate or $reappeardate !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/);

 $D{expdate} = $expdate;
 $D{reappeardate} = $reappeardate;

 my $region = $D{region};

 my @regions = split(/;/,$region);
 $region   = "";       # rebuild region - get rid of dups
 $regionfk = "";       # rebuild regionfk - get rid of dups
 my $regionx = "";
 my $regionfkx = "";
 my $regionCnt = 0;
 foreach $regionx (@regions) {
	$regionCnt = $regionCnt + 1;
	if($regionCnt > 8) {
		$region = "Global";
		$regionfk = 1;
		last;
	}
	$region = "$region;$regionx" unless($region =~ /$regionx/);
	$regionfkx = &get_regionid($regionx);     # in regions.pl
	$regionfk = "$regionfk;$regionfkx" unless($regionfk =~ /$regionfkx/)
 }
 $region   =~ s/^;//;  # get rid of leading semi-colons
 $regionfk =~ s/^;//;  # get rid of leading semi-colons

 $D{region} = $region;

 my $regionfk = $D{regionfk};

 my $source =  $D{source};
 $source   = &get_source_linkmatch($link) unless($source);
 $D{source}   = $source;

 my $sourcefk = $D{sourcefk};
 $sourcefk = &get_sourceid($source) if($source and !$sousrcefk);
 $D{sourcefk} = $sourcefk;

 my $fullbody = $D{fullbody};
 $fullbody =~ s/\n+$//g;    ## trim trailing line feeds
 $fullbody =~ s/\r+$//g;    ## trim trailing returns
 $fullbody =~ s/\n\r+$//g;  ## trim trailing returns
 $fullbody =~ s/\r\n+$//g;  ## trim trailing returns
 $fullbody =~ s/^\n+//g;    ## trim leading line feeds
 $fullbody =~ s/^\r+//g;    ## trim leading returns
 $fullbody =~ s/^\n\r+//g;  ## trim leading returns
 $fullbody =~ s/^\r\n+//g;  ## trim leading returns
 $D{fullbody} = $fullbody;

 my $body = $D{body};
 $body =~ s/\n+$//g;    ## trim trailing line feeds
 $body =~ s/\r+$//g;    ## trim trailing returns
 $body =~ s/\n\r+$//g;  ## trim trailing returns
 $body =~ s/\r\n+$//g;  ## trim trailing returns
 $D{body} = $body;

 my $points = $D{points};
 $points =~ s/\s+$//g;  ## trim white space
 $points =~ s/\n+$//g;  ## trim trailing line feeds
 $points =~ s/\r+$//g;  ## trim trailing returns
 $points =~ s/\n\r+$//g; ## trim trailing returns
 $points =~ s/\r\n+$//g; ## trim trailing returns
 $points =~ s/\s+$//g;   ## trim white space
 $D{points} = $points;

 my $author = $D{author};
 $author =~ s/\s+$//g;   ## trim white space
 $author =~ s/^\s+//g;   ## trim leading white space
 $D{author} = $author;

 my $sectsubs = $D{sectsubs};
 $sectsubs =~ s/NA`M;//;
 $sectsubs =~ s/NA;//;
#                            swap out old for new sectsubnames
 $sectsubs = &get_new_sectsubs($sectsubs);  #in sectsubs.pl
 $D{sectsubs} = $sectsubs;

## TODO: Use the same method for insert as the insert above

# $sth_doc_insert->execute_array(%D,\@keys, \@vars)
#	 or die("Couldn't execute DB doc insert @doc2108 : " . $sth_doc_insert->errstr);

 my @keys = &get_Dnames;
 my @values = ();
 my $ct = 0;
 foreach my $key (@keys) {
 	$ct = $ct +1;
 	print "$ct .. $key .. $D{$key}<br>\n";
	push (@values, $D{$key}) unless $ct > 50;
 }

 $sth_doc_insert->execute(@values);

 $sth_doc_insert->finish;

 my @sectsubs = split(/;/,$sectsubs);
 foreach my $sectsub (@sectsubs) {
   ($sectsubname,$stratus) = split(/`/, $sectsub,2);
   &DB_insert_sectsub_idx($sth_idx_insert,$sectsubname,$n_docid,$stratus,""); # in indexes.pl - will add to index
 }
 return;
}


sub get_Dnames {  ## 51 variables
 return ('docid','deleted','reservetimeup','outdated','nextdocid','priority','headline',
             'regionhead','skipheadline','subheadline','special','topic','link','skiplink','selflink',
             'sysdate','pubdate','pubyear','skippubdate','woapubdatetm','expdate','reappeardate',
             'region','regionfk','skipregion','source','sourcefk','skipsource','author','skipauthor',
             'needsum','body','fullbody','freeview','points','comment','bodyprenote','bodypostnote',
             'note','miscinfo','precat','sectsubs','skiphandle','dtemplate','imagefile','imageloc','imagedescr',
             'worth','summarizerfk','suggesterfk','changebyfk','updated_on');
}

sub create_docitem_table {
# 51 variables
#                        DO THIS MANUALLY ON THE DB SERVER
#                    	docid smallint auto_increment PRIMARY KEY,    # do this later, after conversion
	                              ## 51 variables
$DOCITEM_SQL  = <<ENDDOCITEM
CREATE TABLE docitems (
   docid          smallint     unsigned not null,
   deleted        char(1)      default '',
   reservetimeup  datetime     default null,
   outdated       char(1)      default '',
   nextdocid      smallint     unsigned default 0,
   priority       char(1)      default '4',
   headline       varchar(200) default '',
   regionhead     char(1)      default '',
   skipheadline   char(1)      default '',
   subheadline    varchar(200) default '',
   special        varchar(50)  default '',
   topic          varchar(50)  default '',
   link           varchar(200) default '',
   skiplink       char(1)      default '',
   selflink       char(1)      default '',
   sysdate        date         not null,
   pubdate        date         default null,
   pubyear        char(4)      default '',
   skippubdate    char(1)      default '',
   woapubdatetm   datetime     default null,
   expdate        date         default null,
   reappeardate   date         default null,
   region         varchar(100) default '',
   regionfk       varchar(50)  default '',
   skipregion     char(1)      default '',
   source         varchar(100) default '',
   sourcefk       smallint     unsigned default 0,
   skipsource     char(1)      default '',
   author         varchar(100) default '',
   skipauthor     char(1)      default '',
   needsum        char(1)      default '',
   body           text,
   fullbody       text,
   freeview       char(1)       default '',
   points         text,
   comment        varchar(1000) default '',
   bodyprenote    varchar(500)  default '',
   bodypostnote   varchar(500)  default '',
   note           varchar(300)  default '',
   miscinfo       varchar(300)  default '',
   precat         char(2)       default '',
   sectsubs       varchar(200)  default '',
   skiphandle     char(1)       default '',
   dtemplate      varchar(20)   default '',
   imagefile      varchar(150)  default '',
   imageloc       varchar(150)  default '',
   imagedescr     varchar(150)  default '',
   worth          decimal(5,2)  default 0,
   summarizerfk   smallint      unsigned default 0,
   suggesterfk    smallint      unsigned default 0,
   changebyfk     smallint      unsigned default 0,
   updated_on     date          default null,
   UNIQUE (docid) );
ENDDOCITEM
#  indexes pubyear regionfk pubdate sysdate woapubdatetm headline (20)
}

### TODO: Change this to population $D hash, not $EMAIL hash
###      See smartdata.pl assign_std_variables


1;
