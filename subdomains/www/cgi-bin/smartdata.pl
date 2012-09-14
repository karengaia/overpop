#!/usr/bin/perl --

# January 23 2012
#      smartdata.pl  ... replaces parsedata.pl


sub parse_popnews 
{
  my($pdfline,$emessage) = @_;
  
  &clear_doc_variables;   # establish variables

  $sectsubs = "$emailedSS" unless($sectsubs);
  $headline = "";
##  print "doc120 ehandle $ehandle emessage $emessage<br>\n";    	   
  $emessage = &apple_convert($emessage);
  $emessage = &choppedline_convert($emessage); 
  $emessage = &strip_leadingSPlineBR($emessage);
##               use $save_emessage for $fullbody - before line feeds gone
  my $save_emessage = $emessage;
  
  $emessage =~ s/\(/&#40;/g;    # helps parsing since () and [] are part of regexpr's
  $emessage =~ s/\)/&#41;/g;
  $emessage =~ s/\[/&#91;/g;
  $emessage =~ s/\]/&#93;/g;

  $emessage = &convert_html_to_text($emessage);

  &clear_msgline_variables;

  if($emessage =~ /\b(http.*)\b/) {
	 $link = $1;
	 $link = "htt$link" if($link !~ /http/);
  }

  $suggestAcctnum = $uUserid  if(!$suggestAcctnum);

  @msglines = split(/\n/,$emessage);    # switch to $msgline and @msglines to match docitem.pl
  $emsgbody = "";
  $linecnt += 1;   #start with 1

  foreach $msgline (@msglines) {
     chomp $msgline;
     if($msgline =~ /[a-zA-Z0-9]/) {
     	 $blankcount = 0;
         $paragr_linecnt = $paragr_linecnt + 1;
         &assign_msglines($msgline);
         $linecnt += 1;
         $paragraph = "$paragraph\n$msgline";
     }
     else {
     	 if($blankcount eq 0) {
            &assign_paragraphs;   #in docitem.pl
            $paragraph      = "";
            $paragr_linecnt = 0;
            $twolines       = "";
         }
         $blankcount = $blankcount + 1;
     }

     if($linecnt < 4 and $msgtop !~ /\n\n/) {
        $msgtop = "$msgtop$msgline\n";
     }
  } #end foreach

 $max_linecnt = $linecnt;
  &finish_msglines;  # assigns $msglineN and $msglineN1
  &assign_msglines($msglineN);
  &assign_msglines($msglineN1);
  &assign_paragraphs;         ## last paragraph     

  &do_handle_push;

  ######## set it at 'New' for now
  $docaction = 'N';

##   2nd pass assigns non-standard variables

#  &parse_out_headline unless($headline);  # All these are in docitem.pl

  &refine_headline unless($headline); 
	
  &refine_header_info;  #do before date

  &refine_link;

# print "sm85 chkmonths $chkmonths chkyear $chkyear todaydate $todaydate suggestAcctnum $suggestAcctnumm<br>\n";

  $pubdate = &refine_date($msgline_anydate,$msgline_date,$msgline_link,$link,$msgline_source,$paragr_source,$uDateloc) 
    if($pubdate =~ /0000-00-00/ or !$pubdate);

  $fullbody = $save_emessage;  #Need to do before &refine_source

  ($source,$src_region) = &refine_source($msgline_source,$link) if(!$source);

  ($region,$regionhead) = &refine_region($region,$src_region);   # found in regions.pl
 
  $fullbody = &refine_fullbody($fullbody);  
  
  $fullbody = &byebye_singleLF($pdfline,$fullbody); #do this after parsing for headline, date, etc

  $sectsubs = "$emailedSS"  unless($sectsubs);

  if($sectsubs =~ /Headlines_priority/) {
     $sectsubs = $headlinesSS;
     $priority = "6";
     $docloc_news = "A";    # priority 6 is the same as docloc (stratus) = "A"
         # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
  }
  elsif($sectsubs =~ /Headlines_sustainability/) {
     $priority = "5";
     $docloc_news = "M";    # priority 6 is the same as docloc (stratus) = "A"
  }
  elsif($sectsubs =~ /Suggested_suggestedItem/) {
     $priority = "5";
     $docloc_news = "M";
  }

  $miscinfo = "$miscinfo\nhandle: $handle" if($handle and $handle !~ /unk/);

  if($skip_item eq 'Y') {
    if(-f  "debugit.yes") {}
    else { 
       unlink "$inboxpath/$email_filename";
       print "$docid skipped item - $handle - $headline .. $link<br>\n"
         if($rSectsubid =~ /suggested/i);
    }
  } 

  $prev_headline = $headline;
#  &clear_email_variables;   #DANGEROUS!  ####################

  return($emessage);
}

sub assign_msglines
{
 my $msgline = $_[0];
 $msgline =~  s/^\s+//; # trim annoying leading whitespace
 $msgline =~  s/^ +//;
 $msgline1         = $msgline if($linecnt eq 1);
 $msgline2         = $msgline if($linecnt eq 2);
 $msgline3         = $msgline if($linecnt eq 3);
 $msgline4         = $msgline if($linecnt eq 4);
 $msgline_parens   = $msgline if($msgline =~ /\(/ and $msgline =~ /\)/);

 my $head = "";

 &assign_std_variables($msgline); #Use keywords to fill field variables; like Opinion: , then it is a headline

 if($linecnt < 9 or $linecnt eq $max_linecnt) {  ## CHANGED = to eq in GIT_PATHS
	
	$link = &chk_linkline($msgline) if(!$link);
	
    my $date ="";
##               A LOT OF THIS IS REDUNDANT WITH &assign_std_variables
	if($msgline =~ /^HH /) {
        ($rest,$headline) = split(/HH /,$msgline,2);
		if($headline =~ /[DATE:|date:|DATELINE|DD ]/) {
			($headline,$date) = split(/DATE:/,$headline,2) if $headline =~ /DATE:/;
			($headline,$date) = split(/Date:/,$headline,2) if $headline =~ /Date:/;
			($headline,$date) = split(/DD /,$headline,2) if $headline =~ /DD /;
			($headline,$date) = split(/DATELINE/,$headline,2) if $headline =~ /DATELINE/;
		    $msgline_anydate = $date if(!$msgline_anydate);
		}
	}
	elsif($msgline =~ /^RR /) {
		($rest,$region) = split(/RR /,$msgline,2);
		$region = "" if($region eq 'Global');  #This is the default; if not found elsewhere, will set to 'Global'
	}
	elsif($msgline =~ /^SS /) {
		($rest,$source) = split(/SS /,$msgline,2);
	}
    else {
	    ($msgline_anydate,$msgline_date,$head) = &find_date_in_line($dtkey,$msgline_anydate,$msgline_date,$msgline); #in date.pl
	 	if($msgline_date =~ /HH /) {
			($msgline_date, $headline) = split(/HH /,$$msgline_date,2);
		}
		elsif($msgline_anydate =~ /HH /) {
			($msgline_anydate, $headline) = split(/HH /,$$msgline_anydate,2);
		}
	}
	if($hdkey and $msgline =~ /$hdkey/) { 
	    $head = $msgline;
	}
	elsif($msgline =~ /$link/) {
	}
	elsif($msgline =~ /^SOURCE:/i) {
	    $msgline_source = $msgline if(!$source);
	}
	elsif($msgline =~ /.{5,}?SOURCE:/) {
		($head,$msgline_source) = split(/SOURCE:/,$msgline,2);
	}
	else {
		$head = $msgline;
	}
    $headline = $head if($head and !$headline);
 }

 if($srckey and $msgline =~ /$srckey/ and !$msgline_source) {
      $msgline_source   = $msgline;
 }

 $twolines      = "$prev_line\n$msgline" if($paragr_linecnt eq 2);
 $prevprev_line = $prev_line;
 $prev_line     = $msgline;
}


sub assign_paragraphs
{
 $paragr_cnt      = $paragr_cnt + 1 ;
 $paragraph1      = $paragraph if($paragr_cnt eq 1);
 $paragraph2      = $paragraph if($paragr_cnt eq 2);
 $paragraph3      = $paragraph if($paragr_cnt eq 3);
 $paragr_parens   = $paragraph if($paragraph =~ /\(/ and $paragraph =~ /\)/);

 &assign_std_variables($paragraph); #Use keywords to fill field variables; like Opinion: , then it is a headline

 if($paragr_link eq "" and $paragraph =~ /http|www|\.org|\.com|\.uk|\.in/) {
    $paragr_link = $paragraph;
    $p_notheadline = 'Y';
 }
 if($srckey and $paragraph =~ /$srckey/) {
    $paragr_source = $paragraph;
    $p_notheadline = 'Y';
 }
 if($dtkey and $paragraph =~ /$dtkey/) {
	$paragr_date = $paragraph;
	$p_notheadline = 'Y';
 }
 foreach $pmonth (@months) {
    if($paragraph =~ /$pmonth/) {
       $paragr_anydate = $paragraph;
       $p_notheadline = 'Y';
       last;
    }
 }
 if(($hdkey and $paragraph =~ /$hdkey/) or !$not_pheadline) {
	 $paragr_headline = $paragraph if($paragr_cnt < 5);
 }
}

sub finish_msglines
{
  if($msgline ne "") {
    $msglineN  = $msgline;
    $msglineN1 = $prev_line;
  }
  else {
    $msglineN  = $prev_line;
    $msglineN1 = $prevprev_line;
  } 
}

sub refine_nonstd_variables
{
  my $seq = $_[0];
  $source = &find_source;

  &refine_headline if(!$headline); 
#  &check_for_skip;   DISABLED THIS - WAS KILLING GOOD ARTICLES


  if($skip_item eq 'Y') { 	
  }
  else {	
     &refine_header_info;  #do before date

     goto end_parse_popnews_old if($seq eq 1);

     &refine_link;
     ##and $msgline_link =~ /[A-Za-z0-9]/);

     $pubdate = &refine_date($msgline_anydate,$msgline_date,$msgline_link,$link,$msgline_source,$paragr_source,$uDateloc,$sentdate,$todaydate) if($pubdate !~ /[0-9]/);

     ($source,$src_region) = &refine_source($msgline_source,$link) if(!$source);

     $region = &refine_region($region,$src_region) if(!$region or $region eq 'Global');   # found in regions.pl

     $fullbody = $save_emessage;

     $fullbody = &refine_fullbody($fullbody); 

##  print "doc120b ehandle $ehandle headline $headline \n\n fullbody $fullbody\n";

     $miscinfo = "$miscinfo\n$handle $emailpath";
     $miscinfo = &strip_leadingSPlineBR($miscinfo);

	 $region = &get_regions('N',"",$headline,"","") if($region !~ /[A-Za-z0-9]/);  # print_regions=N, region="", # controlfiles.pl                

	 $region = &get_regions('N',"","",$fullbody,$link) if($region !~ /[A-Za-z0-9]/);
     $region = "Global" unless($region);

     $suggestAcctnum = $euserid  if($suggestAcctnum eq "");
     $sectsubs = "$suggestedSS"  if($sectsubs eq "");
 }
}

##00200

sub assign_std_variables
{
 my $msgline = $_[0];
	#     for newsclip email parsing - need to do this with hashed pairs
 $std_variables =
"docid^DOCID::`docaction^DOCACTION::`handle^HANDLE::`headline^HH |HEADLINE:|HEADLINE :|HEADLINE::|Headline :|Review:|Blog:|Opinion:|EDITORIAL:|OPINION:`source^SS |SOURCE:|Source:|Source :|SOURCE :|SOURCE::`region^RR `pdate^DD |DATE::|Date :|DATE:`userid^USERID:|USERID::`body^SUMMARY::`fullbody^FULL_ARTICLE::`author^AA |By:|AUTHOR:|AUTHOR :|Author :|AUTHOR::`priority^PRIORITY::`";

  @stdVariables = split(/`/, $std_variables);
 $splitter = "";
 foreach $pair (@stdVariables) {
    ($name, $splitter) = split(/\^/, $pair);
     if($msgline =~ /$splitter/) {
       $end_variable = 'N';
       ($rest,$value) = split(/$splitter/,$msgline);
       $value =~  s/^\s+//; # trim annoying leading whitespace
       $EITEM{$name} = $value;
       last;
    }
 }
 $end_variable = 'Y'
     if(($msgline eq "\n" and $name != /fullbody|summary/)
        or $msgline =~ /:END/);

 if($splitter eq "" and $end_variable ne 'Y') {
   $EITEM{$name} = "$EITEM{$name}$msgline";
 }
 
  &fill_email_variables;  #in docitem.pl --- we don't use email variables anymore

 if($msgline =~ /EDITORIAL:/) {
    ($rest,$head)= split(/EDITORIAL:/,$msgline,2);
  }
  elsif($msgline =~ /TITLE:/) {
    ($rest,$head)= split(/TITLE:/,$msgline,2);
  }
  elsif($msgline =~ /OP ED:/) {
    ($rest,$head) = split(/OP ED:/,$msgline,2);
  }
  elsif($msgline =~ /OPINION:/) {
    ($rest,$head)= split(/OPINION:/,$msgline,2);
  }
  return($head);
}


sub do_handle_push {
  if($handle =~ /push/) {
	 if($msgline1) {
	    if($msgline1 =~ /Date:/) {
	       ($headline,$msgline_date) = split(/Date:/,$msgline1);
	    }
	    else {
		    $headline = $msgline1;
		}
	 }
	 if(!$msgline_date and $msgline2 =~ /Date:/) {
		 $msgline_date = $msgline2;
	     $msgline_date =~ s/Date://;
	 }	 
	 if($msgline3 =~ /Source:/) {
		 $source = $msgline3;
	     $source =~ s/Source://;
	     $source =~ s/^ //;   # get rid of leading space
     }
     elsif($msgline2 =~ /Source:/) {
		 $source = $msgline2;
	     $source =~ s/Source://;
	     $source =~ s/^ //;   # get rid of leading space	
     }

#     &refine_nonstd_variables('2'); #2 = 2nd pass
  } #end if push
}

sub convert_html_to_text
{
  my($emessage) = $_[0];
##   $emessage =~ s/<[Hh][1234]>/HEADLINE:/g; 
   $emessage =~ s/<([Hh][Tt][Tt][Pp]:\/\/)(.*)>/$1$2/g;
   $emessage =~ s/<\/[Tt][Aa][Bb][Ll][Ee]>/\n/g; 
   $emessage =~ s/<\/[Cc][Ee][Nn][Tt][Ee][Rr]>/\n/g; 
   $emessage =~ s/<[Bb][Ll][Oo][Cc][Kk][Qq][Uu][Oo][Tt][Ee].*>/\n/g;  
   $emessage =~ s/<[Aa][Hh][Rr][Ee][Ff]=\"{0,1}[Mm][Aa][Ii][Ll][Tt][Oo]:(\S+)\"{0,1}.*>/\($1\)/g; 
   $emessage =~ s/<[Aa][Hh][Rr][Ee][Ff]=\"{0,1}(\S+)\"{0,1}.*>/\($1\)/g;
# converts email address from angle brackets to left and right parens
   $emessage =~ s/<(\S+\@\S+\.\w{2,4})>/\($1\)/g;
   $emessage =~ s/<.+>//g; 
   $emessage =~ s/\<\<//g;
   $emessage =~ s/\>\>//g;
   $emessage =~ s/<a name=\".*\">//g;
   return($emessage);
}


## OO240  EMAIL HEADERS   ##

sub refine_header_info
{
 if($uFixcol66 eq 'Y') {
### Remove the space at col. 65

    @subj = split(//,$subject);

    if($subj[65] =~ /\s/ and $ehandle =~ /ccmc/ and $subj[66] =~ /[a-z]/) {
      $subjcnt = 0;
      $subject = "";
      foreach $subj (@subj) {
         if($subjcnt ne 65) {
             $subject = "$subject$subj";
         }
         $subjcnt = $subjcnt +1;
      } 
    } 
 } 

 $datehead    = "Sent: $sentdate";
 $subjecthead = "$subject";
}

##   LINK   ##

sub refine_link
{ 
#####  $link = "$link$following_link" if($link !~ />/ or $link !~ / /);
  $link = $msgline_link unless($link);
  if($link =~ /[A-Za-z0-9]/) {
     ($link,$rest) = split(/\">/,$link) if($link =~ /\">/);
     ($link,$rest) = split(/>/,$link) if($link =~ />/);
     ($link,$rest) = split(/ /,$link) if($link =~ / /);
     ($link,$rest) = split(/\n/,$link) if($link =~ /\n/);
     ($link,$rest) = split(/\)/,$link) if($link =~ /\)/);
     
     $link =~ s/\.$//;
     $link =~ s/^\s+//g;                         # eliminate leading white spaces
     $link =~ s/\[\t]+//g;                       # eliminate leading tabs
     $link =~ s/^<//g;                          # eliminate leading angle brackets
     $link =~ s/>$//g;                          # eliminate trailing angle brackets
     $link =~ s/\*/=/g if($handle =~ /grist/);
  }
  if($link2nd =~ /[A-Za-z0-9]/) {
     ($link2nd,$rest) = split(/\">/,$link2nd) if($link2nd =~ /\">/);
     ($link2nd,$rest) = split(/>/,$link2nd) if($link2nd =~ />/);
     ($link2nd,$rest) = split(/ /,$link2nd) if($link2nd =~ / /);
     ($link2nd,$rest) = split(/\n/,$link2nd) if($link2nd =~ /\n/);
     ($link2nd,$rest) = split(/\)/,$link2nd) if($link2nd =~ /\)/);
     
     $link2nd =~ s/\.$//;
     $link2nd =~ s/^\s+//g;                         # eliminate leading white spaces
     $link2nd =~ s/\[\t]+//g; 
     $link2nd =~ s/^<//g;                          # eliminate leading angle brackets
     $link2nd =~ s/>$//g;                          # eliminate trailing angle brackets
     $link2nd =~ s/\*/=/g if($handle =~ /grist/);
  }          
  
  $skip_item = 'Y' if($link =~ /smj\.org|sciencedirect|bmjjournals|\.ncbi|springerlink|ingentaconnect/ );
}


sub chk_linkline {
 local($cklink) = $_[0];
 local($foundlink) = "";
 
## print "doc420 cklinkline $cklinkline\n";
 
 if(&is_link($cklinkline)){  	
       @link_words = split(/ /,$cklink);	
       foreach $link_word (@link_words) {
         if( &is_link($link_word) eq 'Y' and $link_word !~ /src=/ and $link_word !~ /\@/) {
   	      $foundlink = $link_word;
   	      last;	
   	 }
       }
 }
## print "doc422 foundlink $foundlink\n";
 return($foundlink);
}


sub is_link {
 local($cklink) = $_[0];
 if( ($cklink =~ /http:\/\// or $cklink =~ /www|www2|grist\./)
    and $cklink =~ /\.org|\.com|\.net|\.uk|\.in\// ) {
      return('Y');
 }
 else {
      return('');
 }
}

  
##  0250 HEADLINE   ###
 

sub refine_headline
{  
  if($uHeadlineloc =~ /list:/) {
     $uHeadlineloc = 'paragr1&&1&';
  }
  
  if(!$headline and $uHeadlineloc) {
	    ($locname,$lockey,$partnum,$sepsymbol) = split(/&/,$uHeadlineloc,4);
	    if($locname =~ /line1/ and $lockey =~ /ALLCAPS/) {
	    	$headline  = $msgline1 if($msgline1 =~ /[A-Z]/ and $msgline1 !~ /[a-z]/);
	    	$headline .= $msgline2 if($msgline2 =~ /[A-Z]/ and $msgline2 !~ /[a-z]/);
	    	$headline .= $msgline3 if($msgline3 =~ /[A-Z]/ and $msgline3 !~ /[a-z]/);
	    }
	    elsif($locname =~ /line1/) {
	    	$headline  = $msgline1 if($msgline1 =~ /[A-Za-z0-9]/);
	    	$headline .= $msgline2 if($headline !~ /[A-Za-z0-9]/ and $msgline2 =~ /[A-Za-z0-9]/);
	    	$headline .= $msgline3 if($headline !~ /[A-Za-z0-9]/ and $msgline3 =~ /[A-Za-z0-9]/);
	    }
	    elsif($locname =~ /paragr1/) {
	    	$headline  = $paragraph1 if($paragraph1 =~ /[A-Za-z0-9]/);
	    	$headline .= $paragraph2 if($headline !~ /[A-Za-z0-9]/ and $paragraph2 =~ /[A-Za-z0-9]/);
	    	$headline .= $paragraph3 if($headline !~ /[A-Za-z0-9]/ and $paragraph3 =~ /[A-Za-z0-9]/);
	    }
  }
  else {
	  &set_std_parseVars;
	  &split_std_parseVars;
  }

  if(!$headline) {
     $locline = $msgline_headline;
     &split_std_parseVars;
     $headline = $variable;
  }
  
  $headline = $msgline_headline if($msgline_headline and !$headline);

  if(!$headline) {
  $subject = &prep_subject($subject_line,$handle) if(!$subject and $subject_line);
  $headline = $subject if($subject);
  }

  ($headline,$rest) = split(/<a/,$headline);
  ($headline,$rest) = split(/Byline:|BYLINE:/,$headline);
  ($headline,$rest) = split(/DATELINE:/,$headline);
  ($headline,$rest) = split(/\([Rr]esearch/,$headline);
  ($headline,$rest) = split(/http:/,$headline);
  ($headline,$rest) = split(/\(news article/,$headline);
  ($headline,$rest) = split(/\(/,$headline) if($ehandle =~ /jhuccp/); ## delete after parens
  ($rest,$headline) = split(/\?=/,$headline) if($headline =~ /\?=/);   
  
  ($rest,$headline) = split(/Articles/,$headline) if($ehandle =~ /push/ and $headline =~ /Articles/);
  $headline = &strip_leadingSPlineBR($headline);
}


##  00260  SOURCE   ##

sub refine_source
{ 
 my($msgline_source,$link) = @_;
 ($source,$sregionname) = &get_source_linkmatch($link) if($link);  # in source.pl
 $source = $msgline_source unless($source);
 if($source and $pubyear) {
    ($rest,$source) = split(/$pubyear/,$source,2) if($source =~ /$pubyear/);
 }

 ($source,$rest) = split(/\(/,$source,2) if($source and $source =~ /\(/ );
 $source =~  s/ +$//;  #get rid of trailing spaces
 if(!$source and $ehandle =~ /push/) {
    ($rest,$source)  = split(/Source :/,$emessage) if($emessage =~ /Source :/);
    ($source,$rest)  = split(/Byline :/,$source,2) if($source =~ /Byline :/);
    ($source,$rest)  = split(/Author :/,$source,2) if($source =~ /Author :/);
    ($source,$rest)  = split(/\n/,$source,2);
    ($source,$rest)  = split(/\r/,$source,2);
 }

 $source = &find_source unless($source);
 $chkline = "$msgline1\n$msgline2\n$msgline3\n$msgline4\n$msglineN\n$msglineN1";

  ($source,$sregionname) = &get_sources('N',"",$headline,$chkline,$link) if(!$source); #   - in source.pl

 if($source) {
   ($source,$rest) = split(/Author/,$source,2) if($source =~ /Author/);
##   &printShadowMsg("doc516-4c $source");
   $source =~  s/^\/+//;  #get rid of leading backslashes
   $source =~ s/\s+$//;   #get rid of trailing garbage
   $source =~ s/[!@#\$%\&\*\+_\-=:\";'?\/,\.]+$//;
 }
 return($source,$sregionname);
}

sub find_source
{
  my $source = "";
  ($locname,$lockey,$partnum,$sepsymbol) = split(/&/,$uSourceloc,4);
  my $lenSepsymbol = length($sepsymbol);
##  print "doc00260 sepsymbol $sepsymbol lenSepsymbol $lenSepsymbol source $source uSourceloc $uSourceloc msgline_source $msgline_source\n";

  if($lenSepsymbol eq '0') {}
  elsif($source =~ /[a-zA-Z0-9]/) {
     $source = &separate_variable_into_parts($variable,$sepsymbol,1);
  }
  
  else {
     if($msgline_source ne "") {
        $locline = $msgline_source;
     }
     else {
        &set_std_parseVars;
     }
     
     &split_std_parseVars;
    
     $source = $variable;
   
   ##      any source
     if($source !~ /[a-zA-Z0-9]/ and $msgline_anysrc ne "") {
        $locline = $msgline_anysrc;
        &split_std_parseVars;
        $source = $variable;
     }
     
     if($source !~ /[a-zA-Z0-9]/ and $msgline_source !~ /straight to the source/ and $handle eq 'grist') {
           $source = "Grist Magazine";
        }
  }
  
  ($source,$rest) = split(/ [Ll]eased/,$source,2) if($source =~ / [Ll]eased/);
  ($source,$rest) = split(/ [Vv]ia/,$source,2)    if($source =~ / [Vv]ia/);
  $source =~ s/\s+$//;
  return($source);
}


sub refine_fullbody
{
  my $fullbody = $_[0];
  @fullbodylines = split(/\n/,$fullbody);    # switch to $msgline and @msglines to match docitem.pl
  $fullbody = "";
  my $line = "";
  my $linecnt += 1;   #start with 1

  foreach $line (@fullbodylines) {
     chomp $line;
     if($line =~ /^HH / or $line =~ /^RR / or $line =~ /^DD / or $line =~ /^SS / or $line =~ /^http:/ or $line =~ /^MI /) {
	    $miscinfo = "$miscinfo\n\n$line";
	    next;
     }
     $fullbody = "$fullbody\n$line";
  }  

  &fix_fullbody;  

  return($fullbody);
}

sub fix_fullbody
{
 my($firstline,$restofbody) = split(/\n/,$fullbody,2);
 if($firstline =~ /Content-Type:/) {
     $fullbody = $restofbody if($restofbody =~ /[A-Za-z0-9]/);
 }

## we have to go through hoops because of the parens
## local($endsource) = "";
 my($first);

 if($source =~ /\(/  or $fullbody =~ /\(/ ) { }
 elsif ($source =~ /[A-Za-z0-9]/ 
     and $msgtop =~ /$source/) {
   ($fulbdy1,$fulbdy2) = split(/$source/,$fullbody,2);
       	     	 
   $fullbody = "$fulbdy1 $fulbdy2";     
 }    	  
## $source = "$source$endsource";
 $fullbody = &strip_leadingSPlineBR($fullbody);
 $fullbody =~ s/^\n//;
 $fullbody =~ s/^\n//;	 
 $fullbody = &apple_convert($fullbody);
}

##    HTML TO XHTML  -----

## Use [BODY] for all templates
## Need tableonlyitem, linebulletitem (already have), olonlytiem, ulonlytierm

## Do not escape angle brackets -- meta characters to be escaped are .^$|*+?()[{\

sub xhtmlify {
local($docid,$template,$body)  = @_;

## 1. change all upper case html to lower

&decap_html;

local($ext) = "";
local $sv_template = "";

$template = $cTemplate if($template =~ /straight/);

$body =~ s/ {1-9}\n/\n/g;  # get rid of trailing spaces
		
## 2. Detect errant html and log it

if($body =~ /<center/) {
  $body =~ s/<center>//g;
  $body =~ s/<\/center>//g;
  $ext = $ext."ctr_";
}

if($body =~ /^<blockquote/) {  #remove beginning blockquote
  $body =~ s/<blockquote>//g;
  $body =~ s/<\/blockquote>//g;
  $ext = $ext."blk_";
}

if($body =~ /<img/) {
  $ext = $ext."img_"; 
}

if($body =~ /<font/) {
  $ext = $ext."fnt_"; 
}

##  3. get rid of blank lines at top and bottom
$body =~ s/<br[^>]$>/<br>/g;   ## change <br /> to <br>
$body =~ s/<br>\n\n/\n/g;   ## delete all ending line breaks - we will add them back in below
$body =~ s/<br>\n/\n/g;   ## delete all ending line breaks - we will add them back in below
$body =~ s/<\/p><p>\n\n/\n\n/g;   ## delete all ending paragraphs
$body =~ s/<p>\n\n/\n\n/g;   ## delete all ending paragraphs
$body =~ s/<\/p>\n\n/\n\n/g;   ## delete all ending paragraphs

$body =~ s/<table[^>]*?>/<table>/ if($body =~ /<table/);  #clean table
$body =~ s/<tr[^>]*?>/<tr>/ if($body =~ /<tr/);  #clean tr
$body =~ s/<td[^>]*?>/<td>/ if($body =~ /<td/);  #clean td

#4 In 1st three lines, look for header info (<b> and <font)
#   and convert to <h5>
use integer;
$line = "";
$linectr = 0;
$newbody = "";
$prev_line = "";
 
@lines = split(/\n/,$body);
foreach $ln (@lines) {
	$linectr++;
	$line = $ln;
	$newbody = "$newbody$prev_line\n" if($linectr > 1);

##  5 look for header in 1st 3 lines
	if($line =~ /<b/ and $line =~ /<font/ and $linectr < 4) {
		$line =~ s/<b>/<h5>/;
		$line =~ s/<\/b>/<\/h5>/;
		$line =~ s/<font[^>]*?>//; #remove font tags
	    $line =~ s/<\/font>//; #remove font tags
        $ext = $ext."h5_"; 
	}

##  6 deal with font tags 

	if($line =~ /<font|\/font>/ and $linectr > 2) {
	    ##    replace <font size=1> with <small> and <font .comic . .> with <cite>
	      if($line =~ /size=1/) {
			 ($front,$rest) = split(/<font/,$line,2);
			 ($font,$back) = split(/>/,$rest,2);
			 $line = "$front<small>$back";
			 ($front,$back) = split(/<\/font>/,$line,2);
			 $line = "$front</small>$back";
	      }
	      if($line =~ /"comic/) {
	         $line =~ s/<font[^>]*?>/<cite>/g;
		     $line =~ s/<\/font>/<\/cite>/g;
	      }
	}
	if($line =~ /<font/ or $line =~ /font>/) {
	   $line =~ s/<font[^>]*?>//g; #remove beginning font tags
	   $line =~ s/<\/font>//g; #remove ending font tags
	   $line =~ s/size=[1-9]//g;
	   $line =~ s/face=//g;
	   $line =~ s/"comic sans ms"//g;
#	   $line =~ s/verdana|ariel/arial//g;
#	   $line =~ s/color=#?"?"[A-Za-z0-9]{6,6}"?//g;
	   $line =~ s/<p>/ /g if($line =~ /<li|<tr|<td|ol|ul/);  # remove paragraphs imbedded in li or td
	}
## 7. Do tables and lists
	&ck_first_table_ul if($linectr == 1);
    $in_ul = 'Y' if($line =~ /<ul|ol/ 
		                or ($line =~ /^\./
			              and $template =~ /(?:linkbulletitem|ulonlyitem|olonlyitem)/) );
	$in_table = 'Y' if($line =~ /<table/ 
					    or ($line =~ /^\./
							and $template =~ /(?:tableonlyitem|table)/) );

	$in_ul = '' if($line =~ /\/ul|\/ol>/ or $line !~ /^\./);

	$in_table = '' if($line =~ /\/table>/ or $line !~ /^\./);


## 8. If in a table or list, change periods at beginning of line as <li> or <td>

	if($in_ul and $line =~ /^\./) {
		$line =~ s/^\./<li>/;
		$line = "$line</li>";
	}
	elsif($in_table and $line =~ /^\./) {
		$line =~ s/^\./<tr><td>/;
		$line = "$line</td></tr>";
	}
## 9. If not a table or list line, change EOLs to <p> or <br>; Beginning and ending <p>s are on template
	elsif($line =~ /<li|<td|<tr|<ul|<ol|<dl|<dt|<dd/ or $line =~ /li>|td>|tr>|ul>|ol>|dl>|dt>|dd>/) { 
	}
    else {
#		$line =~ s/\r/<br>/g;
#		$line =~ s/\n\n/<\/p><p>/g;
#		$line =~ s/\n/<br>\n/g;
#		$line =~ s/<\/p><p>/<\/p>\n\n<p>/g;
	}
			
	$prev_line = $line;
 } #end foreach

##  do last line

&ck_last_table_ul;

$body = "$newbody$prev_line\n"; # add last line

if($body !~ /<li|<td|<tr|dd|dt/) {
  $body = "<p>$body";
  $body = "$body<\/p>";
}

$template = $sv_template if($sv_template =~ /[A-Za-z0-9]/);

$body = &apple_convert($body);  # takes care of encoding

$logfile = "$itempath/$docid.log$ext";
### &write_log if($ext =~ /[A-Za-z0-9]/);  HAVE NO USE FOR LOG FILE WHICH GOES TO ITEMS directory

return($body);
}


sub decap_html {
	$body =~ s/<A/<a/g;
	$body =~ s/\/A>/\/a>/g;
	$body =~ s/ALIGN=/align=/g;
	$body =~ s/ALIGN =/align =/g;
	$body =~ s/ALT/alt/g;
	$body =~ s/<B/<b/g;
	$body =~ s/\/B>/\/b>/g;
	$body =~ s/<BR/<br/g;
	$body =~ s/<BLOCKQUOTE/<blockquote/g;
	$body =~ s/<CENTER/<center/g;
	$body =~ s/<DIV/<div/g;
	$body =~ s/\/DIV>/\/div>/g;
	$body =~ s/<FONT/<font/g;
	$body =~ s/\/FONT>/\/font>/g;
	$body =~ s/<H2/<h2/g;
	$body =~ s/\/H2>/\/h2>/g;
	$body =~ s/<H3/<h3/g;
	$body =~ s/\/H3>/\/h3>/g;
	$body =~ s/<H4/<h4/g;
	$body =~ s/\/H4>/\/h4>/g;
	$body =~ s/<H5/<h5/g;
	$body =~ s/\/H5>/\/h5>/g;
	$body =~ s/<H6/<h6/g;
	$body =~ s/\/H6>/\/h6>/g;
	$body =~ s/<HREF/<href/g;
	$body =~ s/<HR/<hr/g;
	$body =~ s/<LI/<li/g;
	$body =~ s/\/LI>/\/li>/g;
	$body =~ s/<P/<p/g;
	$body =~ s/\/P>/\/p>/g;
	$body =~ s/SIZE=/size=/g;
	$body =~ s/SIZE =/size=/g;
	$body =~ s/size="([1-9])"/size=$1/g;
	$body =~ s/<SPAN/<span/g;
	$body =~ s/\/SPAN>/\/span>/g;
	$body =~ s/SRC/src/g;
	$body =~ s/<TABLE/<table/g;
	$body =~ s/\/TABLE>/\/table>/g;
	$body =~ s/<TD/<td/g;
	$body =~ s/\/TD>/\/td>/g;
	$body =~ s/<TR/<tr/g;
	$body =~ s/\/TR>/\/tr>/g;
	$body =~ s/<UL/<ul/g;
	$body =~ s/\/UL>/\/ul>/g;
	$body =~ s/WIDTH=/width=/g;
	$body =~ s/WIDTH =/width=/g;
}


sub ck_first_table_ul {
 if($line =~ /^<table/) {
    $sv_template = $tableonlyitem;
	$line =~ s/<table.*?\/table>//; #remove entire table tag
 }
 if($line =~ /^<ul/) {
    $sv_template = $ulonlyitem;
	$line =~ s/<ul>//; #remove entire table tag
 }
 if($line =~ /^<ol/) {
    $sv_template = $olonlyitem;
	$line =~ s/<ol>//; #remove entire table tag
 }
}

sub ck_last_table_ul {
	if($line =~ /table>/) {
		$line =~ s/<\/table>//; #remove entire end able tag
	}
	elsif($line =~ /ul>/) {
		$line =~ s/<\/ul>//; #remove entire end ul tag
	}
	elsif($line =~ /ol>/) {
		$line =~ s/<\/ol>//; #remove entire end ul tag
	}
}

##  00300 COMMON ROUTINE TO DETERMINE LOCATION & POSITION OF VARIABLE  ##

sub set_std_parseVars
{
  $locline = $msgline3        if($locname =~ /line3/);
  $locline = $msgline2        if($locname =~ /line2/);
  $locline = $msgline1        if($locname =~ /line1/);
  $locline = $paragraph1      if($locname =~ /paragr1/);
  $locline = $paragraph2      if($locname =~ /paragr2/);
  $locline = $paragraph3      if($locname =~ /paragr3/);
  $locline = $msglineN        if($locname =~ /lineN/);
  $locline = $msglineN-1      if($locname =~ /lineN-1/);
  $locline = $subject         if($locname =~ /subject/);
  $locline = $msgline_parens  if($locname =~ /lineparens/);
  $locline = $paragr_parens   if($locname =~ /paraparens/);
  $locline = $msgline_anydate if($locname =~ /anydate/);
  $locline = $msgline_date    if($locname =~ /linedate/);
  $locline = $paragr_date     if($locname =~ /paradate/);
  $locline = $msgline_source  if($locname =~ /linesrc/);
  $locline = $paragr_source   if($locname =~ /parasrc/);
  $locline = $msgline_anysrc  if($locname =~ /anysrc/);
  $locline = $msgline_link    if($locname =~ /link/);
}

sub split_std_parseVars
{
  $variable = $locline if($partnum != /[1-9]/ and $partnum ne 'N' and $partnum ne 'N-1');

  if($lockey ne "" and $locline =~ /$lockey/) {
      ($rest,$locline,$rest2) = split(/$lockey/,$locline,3);
  }
##print"doc516-7 testippf variable $variable locline $locline partnum $partnum lockey $lockey\n";
  
  $variable = &separate_variable_into_parts($variable,$sepsymbol,$partnum);
   
  $variable =~  s/^\s+//; # trim annoying leading whitespace
  $variable =~  s/^ +//;
  $variable =~  s/^[!@#\$%&\*\(\)\+_\-=:\";'?\/,\.]+//;
  $variable =~  s/[!@#\$%&\*\(\)\+_\-=:\";'?\/,\.]+$//;

  undef $partnum;
  undef $rest1;
  undef $rest2;
  undef $rest3;
  undef $rest4;
  undef $rest5;
}

sub strip_leadingSPlineBR
{ 
  local($datafield) = $_[0];
  $datafield =~ s/^\s+//g;                         # eliminate leading white spaces
  $datafield =~ s/\[\t]+//g;                       # no need for tabs
  $datafield =~ s/\r\n/\n/g;                       # eliminate DOS line-endings
  $datafield =~ s/\n\r/\n/g;
  $datafield =~ s/\r/\n/g;
  $datafield =~ s/\n\s\n/\n\n/g;
  if(!$dTemplate) {
     $datafield =~ s/\n[\n]+/<P>/g;                   # temporary
     $datafield =~ s/<[Pp]>(<[Pp]>)*/\n\n/g;
  }
  return($datafield);
}


sub byebye_singleLF {  
  my ($pdfline,$datafield) = @_;
  $datafield =~ s/\n\n/#%#/g;         #change double line feeds temporarily 
  $datafield =~ s/\n/ /g if($uSingleLineFeeds eq 'N' and $pdfline ne 'Y'); # single LF go bye-bye
  $datafield =~ s/\n/\n\n/g if($pdfline eq 'Y'); # single LF to double LF if from a pdf
  $datafield =~ s/#%#/\n\n/g;         #change double line feeds back
  return($datafield);
}

##                converts quotes, hyphens and other wayword perversions
sub apple_convert
{
 my $datafield = $_[0];
 
 ##                             line feeds, returns
 $datafield =~ s/=20\n/\n/g;
 $datafield =~ s/=20//g;
 $datafield =~ s/=3D/*/g;
 $datafield =~ s/\r/ /g;
 $datafield =~ s/\r/ /;
 
 $datafield =~ s/=3D([a-z])/$1/g;   ## next line starts with lower case - not a paragraph
 $datafield =~ s/=0D=0A([a-z])/$1/g;
  
# $datafield =~ s/([a-z0-9] )\n\n/$1/ig;  ## THIS SHOULD BE DONE ELSEWHERE  -- GIT_PATHS
# $datafield =~ s/([a-z0-9] )\n/$1/ig;
 
 $datafield =~ s/ = $/ /g;  #end of line
      
 ##                             # single quote
 $datafield =~ s/``/"/g;
 $datafield =~ s/L/'/g;    #81
 $datafield =~ s/&rsquo;/'/g; 
 $datafield =~ s/=92/'/g;  #92 
 $datafield =~ s/Â´/'/;
 $datafield =~ s/â€˜/'/g;
 $datafield =~ s/â€™/&#39;/g;
 $datafield =~ s/=E2=90=99/&#39;/g; # same as proceeding
 $datafield =~ s/’/'/g;      # single quote
 
 ##                    # double quotes             
 $datafield =~ s/=93/"/g; #93
 $datafield =~ s/=94/"/g; #94
 $datafield =~ s/E/"/g;   #81
 $datafield =~ s/''/"/;   #doublequote
 $datafield =~ s/”/"/;    #backquote
 $datafield =~ s/“/"/;    #frontquote
 $datafield =~ s/``/"/g;  #double back tick
 $datafield =~ s/â€/"/g;  #double quote 2
 $datafield =~ s/â€œ/"/g; #double quote 3
 $datafield =~ s/=E2=80=9C/"/;  #double quote 3 - same as preceeding
 $datafield =~ s/“A/"/g; #double quote 4
 $datafield =~ s/”/"/g; #end quote
 

 $datafield =~ s/&#40;/\(/g;  # left parens
 $datafield =~ s/&#41;/\)/g;  # right parens
 
 $datafield =~ s/&#91;/\[/g;  # left bracket
 $datafield =~ s/&#93;/\]/g;  # right bracket

 $datafield =~ s/=95/-/g;    # 95    hyphen
 $datafield =~ s/=3F/-/g;    # 95    hyphen
 $datafield =~ s/â€“/-/g;    #hyphen
 $datafield =~ s/–/-/g;    #hyphen
 return($datafield);  	
}

sub choppedline_convert
{
 local($datafield) = $_[0];
 $datafield =~ s/=\r\n$//g;     #change back to normal: lines that are broken to make short lines (usually 72) for email
 return($datafield);  	
}


1;