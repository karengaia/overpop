# March 15, 2005
#      parsedata.pl

# parsemail.pl parses and email from popnews and finds headlines, source date, publisher, region, and other variables.

## called by article.pl and convert

## 00100

sub parse_popnews_email
{ 
# $acctnum = "";
  $userid  = "";
  $newemail = $fromEmail;
  $userdata = &read_contributors(N,N,_,$fromEmail,);  ## args=print?, html file?, handle, email, acct# 

  &clear_doc_data;
  &clear_doc_variables;
  &calc_date('sys',0);
  
  $emessage =~ s/=20\n/\n/g;
  $emessage =~ s/=20//g;
  $emessage =~ s/=3D/*/g;
  $line = $emessage;
  &leadingSPlineBR;
  $emessage = $line;
  
  &convert_html_to_text;

  $msgtop = "";
  $msgbody = "";
  $linecnt = 0;
  $msgline1 = "";
  $msgline2 = "";
  $msgline3 = "";
  $msgline_link = "";
  $paragr_linecnt = 0;
  $paragr_cnt = 0;
  $paragraph  = "";
  $paragraph1 = "";
  $paragraph2 = "";
  $paragraph3 = "";
  $holdmonth  = "";
  $chkline    = "";
  $pyear      = "";
  $blankcount = 0;

  @stdVariables = split(/`/, $std_variables);

  undef @msglines;
  @msglines = split(/\n/,$emessage);
  foreach $msgline (@msglines) {
     chomp $msgline;
     if($msgline =~ /[a-zA-Z0-9]/) {
     	$blankcount = 0;
        $paragr_linecnt = $paragr_linecnt + 1;
        &assign_msglines;
        $paragraph = "$paragraph\n$msgline";
     }
     else {
     	if($blankcount eq 0) {
           &assign_paragraphs;
           $paragraph      = "";
           $paragr_linecnt = 0;
           $twolines       = "";
        }
        $blankcount = $blankcount + 1;
     }

     &assign_std_variables;

     if($linecnt < 3 and $msgtop !~ /\n\n/) {
        $msgtop = "$msgtop$msgline\n";
     }
     else {
        $msgbody = "$msgbody$msgline\n";
     }

     if($msgline =~ /only in Grist/ and $handle eq 'grist') {
        $source      = "Grist Magazine";
##        $uDateloc    = "link&&6&\/";
##        $uDateformat = "3#yy&1#mm&2#dd";
        $uDateloc    = "link";
        $uDateformat = "mmddyy";
     }
  }
    
  &finish_msglines;
  &assign_paragraphs;         ## last paragraph
  &fill_email_variables;

##   2nd pass assigns non-standard variables

  &parse_out_headline;

  &find_source;

  &refine_headline if($headline eq "");
  
  &check_for_skip;

  if($skip_item eq 'Y') { 	
  }
  else {	
     &refine_header_info;  #do before date
     
     &refine_link if($link eq "" and $msgline_link =~ /[A-Za-z0-9]/);
    
     &refine_date if($pubdate !~ /[0-9]/);
    
     &refine_source;
     
     &refine_fullbody;
     
     $miscinfo = "$handle";
                      
     &find_region;
     
     $suggestAcctnum = $euserid  if($suggestAcctnum eq "");
     $sectsubs = "$suggestedSS"  if($sectsubs eq "");
     
     if($handle =~ /grist|enn/) {
     	$sectsubs    = "$sectsubs;Volunteer_grist";
     }
     elsif($handle =~ /jhuccp|unwire/) {
    	$sectsubs    = "$sectsubs;Volunteer_womenFP";
     }
  }
     
  if($skip_item eq 'Y') { 	
    unlink "$sepmailpath/$email_filename";
    print "<p><font face=arial size=1>$docid skipped item - $handle - <b>$headline</b></font><br>\n"
      if($rSectsubid =~ /suggested/i);
  }
  
  &clear_email_variables;
}


##00516

sub assign_msglines
{
 $linecnt += 1;
 $msgline =~  s/^\s+//; # trim annoying leading whitespace
 $msgline =~  s/^ +//;

 $msgline1         = $msgline if($linecnt eq 1);
 $msgline2         = $msgline if($linecnt eq 2);
 $msgline3         = $msgline if($linecnt eq 3);
 $msgline_parens   = $msgline if($msgline =~ /\(/ and $msgline =~ /\)/);
 $msgline_source   = $msgline if($srckey ne ""    and $msgline =~ /$srckey/);
 $msgline_headline = $msgline if($hdkey ne ""     and $msgline =~ /$hdkey/);
 $msgline_date     = $msgline if($dtkey ne ""     and $msgline =~ /$dtkey/);
 
 $msgline_link     = $msgline if($msgline_link eq ""  
                                and $msgline =~ /http|www|(\.(org|com|net|uk\/|in\/))/ );

 $following_link   = $msgline if($prev_line =~ /http|www|grist\.org/);
## print"516 anydate msgline-$msgline<br>\n"  if($msgline_anydate !~ /$chkmonth/ and $msgline =~ /$chkmonth/);
 $msgline_anydate  = $msgline if($msgline_anydate !~ /$chkmonth/ and $msgline =~ /$chkmonth/);

 $twolines      = "$prev_line\n$msgline" if($paragr_linecnt eq 2);
 $prevprev_line = $prev_line;
 $prev_line     = $msgline;
}


sub assign_paragraphs
{
 $paragr_cnt = $paragr_cnt + 1 ;
 $paragraph1      = $paragraph if($paragr_cnt eq 1);
 $paragraph2      = $paragraph if($paragr_cnt eq 2);
 $paragraph3      = $paragraph if($paragr_cnt eq 3);
 $paragr_parens   = $paragraph if($paragraph =~ /\(/ and $paragraph =~ /\)/);
 $paragr_source   = $paragraph if($srckey ne ""      and $paragraph =~ /$srckey/);
 $paragr_headline = $paragraph if($hdkey ne ""       and $paragraph =~ /$hdkey/);
 $paragr_date     = $paragraph if($dtkey ne ""       and $paragraph =~ /$dtkey/);
 $paragr_link     = $paragraph if($paragr_link eq "" and $paragraph =~ /http|www|grist\.org/);
 foreach $pmonth (@months) {
    if($paragraph =~ /$pmonth/) {
       $paragr_anydate = $paragraph;
       last;
    }
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
  $msgline_source = $source if($source =~ /[A-Za-z0-9]/);
}


sub assign_std_variables
{
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
}


sub convert_html_to_text
{
   $emessage =~ s/<[Hh][1234]>/HEADLINE:/g; 
   $emessage =~ s/<\/[Tt][Aa][Bb][Ll][Ee]>/\n/g; 
   $emessage =~ s/<\/[Cc][Ee][Nn][Tt][Ee][Rr]>/\n/g; 
   $emessage =~ s/<[Bb][Ll][Oo][Cc][Kk][Qq][Uu][Oo][Tt][Ee].*>/\n/g;  
   $emessage =~ s/<[Aa][Hh][Rr][Ee][Ff]=\"{0,1}[Mm][Aa][Ii][Ll][Tt][Oo]:(\S+)\"{0,1}.*>/\($1\)/g; 
   $emessage =~ s/<[Aa][Hh][Rr][Ee][Ff]=\"{0,1}(\S+)\"{0,1}.*>/\($1\)/g;
# converts email address from angle brackets to left and right parens
   $emessage =~ s/<(\S+\@\S+\.\w{2,4})>/\($1\)/g;
   $emessage =~ s/<[Hh][Tt][Tt][Pp]:\/\/(.*)>/$1/g;
   $emessage =~ s/<.+>//g; 
   $emessage =~ s/\<\<//g;
   $emessage =~ s/\>\>//g;
   $emessage =~ s/<a name=\".*\">//g;
}


## OO516-1  EMAIL HEADERS   ##

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
  @link_words = split(/ /,$msgline_link);
  foreach $link_word (@link_words) {
      if($link_word =~ /http|www|(\.(org|com|net|uk\/|in\/))/ 
   	 and $link_word !~ /src=/ and $link_word !~ /\@/) {
   	    $link = $link_word;
   	    last;
   	 }
   }

#####  $link = "$link$following_link" if($link !~ />/ or $link !~ / /);

  if($link =~ /[A-Za-z0-9]/) {
     ($link,$rest) = split(/\">/,$link) if($link =~ /\">/);
     ($link,$rest) = split(/>/,$link) if($link =~ />/);
     ($link,$rest) = split(/ /,$link) if($link =~ / /);
     ($link,$rest) = split(/\n/,$link) if($link =~ /\n/);
     ($link,$rest) = split(/\)/,$link) if($link =~ /\)/);
     
     $link =~ s/\.$//;
     $link =~ s/^\s+//g;                         # eliminate leading white spaces
     $link =~ s/\[\t]+//g;                       # eliminate leading tabs
     
     $skip_item = 'Y' if($link =~ /smj\.org|sciencedirect|bmjjournals|\.ncbi|springerlink|ingentaconnect/ );
  }
}

   
##  0516-3 HEADLINE   ###

sub parse_out_headline
{  
  foreach $msgline (@msglines) 
  {    
    if($headline eq "") {
       if($msgline =~ /EDITORIAL:/) {
         ($rest,$headline)= split(/EDITORIAL:/,$msgline,2);
       }
       elsif($msgline =~ /TITLE:/) {
         ($rest,$headline)= split(/TITLE:/,$msgline,2);
       }
       elsif($msgline =~ /OP ED:/) {
         ($rest,$headline)= split(/OP ED:/,$msgline,2);
       }
       elsif($msgline =~ /OPINION:/) {
         ($rest,$headline)= split(/OP ED:/,$msgline,2);
       }
    }
  } #end foreach
}  

sub refine_headline
{  
  if($uHeadlineloc =~ /list:/) {
     $uHeadlineloc = 'paragr1&&1&';
  }
  
  if($headline !~ /[a-zA-Z0-9]/ ) {
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
    else {
       if($locname eq "") {
          $locline = $msgline_headline;
       }
       else {
         &set_std_parseVars;
       }
       &split_std_parseVars;
       $headline = $variable;
   }
  }

  if($headline !~ /[a-zA-Z0-9]/ ) {
     $locline = $msgline_headline;
     &split_std_parseVars;
     $headline = $variable;
  }
  
  $headline = $subject if($headline !~ /[a-zA-Z0-9]/ );
  
  ($headline,$rest) = split(/<a/,$headline);
  ($headline,$rest) = split(/Byline:|BYLINE:/,$headline);
  ($headline,$rest) = split(/DATELINE:/,$headline);
  ($headline,$rest) = split(/\([Rr]esearch/,$headline);
  ($headline,$rest) = split(/http:/,$headline);
  ($headline,$rest) = split(/\(news article/,$headline);
  ($rest,$headline) = split(/\?=/,$headline) if($headline =~ /\?=/);   
}


##  00516-4  SOURCE   ##

sub find_source
{
  ($locname,$lockey,$partnum,$sepsymbol) = split(/&/,$uSourceloc,4);

  if($source !~ /[a-zA-Z0-9]/ and $msgline_source ne "") {
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

  ($source,$rest) = split(/ [Ll]eased/,$source,2) if($source =~ / [Ll]eased/);
  ($source,$rest) = split(/ [Vv]ia/,$source,2)    if($source =~ / [Vv]ia/);
  $source =~ s/\s+$//;
}


sub refine_source
{ 
 if($source =~ /[A-Za-z0-9]/) {
    ($rest,$source) = split(/$pubyear/,$source,2) if($source =~ /$pubyear/);
    ($source,$rest) = split(/$pubmonth/,$source) if($source !~ /A-Za-z0-9/);
 }
  
 if($source !~ /[A-Za-z0-9]/ and $handle eq 'push') {
    ($rest,$source)  = split(/Source :/,$emessage);
    ($source,$rest)  = split(/Byline:/,$source,2);
    ($source,$rest)  = split(/\n/,$source,2);
    ($source,$rest)  = split(/\r/,$source,2);
 }

 if($source !~ /[A-Za-z0-9]/) {
   &get_sources($source,$headline,$body,$fullbody,$link); # print_src=N);
 }
 
 if($source =~ /[A-Za-z0-9]/) {
   ($source,$rest) =~ split(/[Aa]uthor/i,$source) if $source =~ /[Aa]uthor/;
   $source =~  s/^\/+//;  #get rid of leading backslashes
   $source =~ s/\s+$//;
   $source =~ s/[!@#\$%\&\*\(\)\+_\-=:\";'?\/,\.]+$//;
 }
}


sub find_region
{
 $region = &get_regions('N',"",$headline,$fullbody,$link) if($region !~ /[A-Za-z0-9]/);  # print_regions=N, region="", # controlfiles.pl 
}


sub refine_fullbody
{
 $msgtop =~ s/^\s+//;
 $msgbody =~ s/\n\n/#%#/g;
 $msgbody =~ s/\n/ /g;
 $msgbody =~ s/#%#/\n\n/g; 

 $fullbody = "$msgbody";
}


##  00516-5   ##

sub check_for_skip
{
  $skip_item = 'N';

  if($handle =~ /kaiser|push|jhuccp|ippf/ 
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
          or ($headline =~ /HIV|AIDS/i and $headline !~ /condoms|abstinence/i) 
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
     ) ){
     $skip_item = 'Y';
  }
}

##  0516-6 COMMON ROUTINE TO DETERMINE LOCATION & POSITION OF VARIABLE  ##

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
##  $locline = $msgline_date    if($locname =~ /linedate/ and $lockey ne "");
##  $locline = $paragr_date     if($locname =~ /paradate/ and $lockey ne "");
##  $locline = $msgline_source  if($locname =~ /linesrc/ and $lockey ne "");
##  $locline = $paragr_source   if($locname =~ /parasrc/ and $lockey ne "");
  $locline = $msgline_date    if($locname =~ /linedate/);
  $locline = $paragr_date     if($locname =~ /paradate/);
  $locline = $msgline_source  if($locname =~ /linesrc/);
  $locline = $paragr_source   if($locname =~ /parasrc/);
  $locline = $msgline_anysrc  if($locname =~ /anysrc/);
  $locline = $msgline_link    if($locname =~ /link/);
}



## 00516-7

sub split_std_parseVars
{
  $variable = $locline if($partnum != /[1-9]/ and $partnum ne 'N' and $partnum ne 'N-1');

  if($lockey ne "" and $locline =~ /$lockey/) {
      ($rest,$locline,$rest2) = split(/$lockey/,$locline,3);
  }

  ($variable,$rest)               = split(/$sepsymbol/,$locline,2) if($partnum eq '1');
  ($rest1,$variable,$rest)        = split(/$sepsymbol/,$locline,3) if($partnum eq '2');

  ($rest1,$rest2,$variable,$rest) = split(/$sepsymbol/,$locline,4) if($partnum eq '3');
  ($rest1,$rest2,$rest3,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,5) if($partnum eq '4');
  ($rest1,$rest2,$rest3,$rest4,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,6) if($partnum eq '5');
  ($rest1,$rest2,$rest3,$rest4,$rest5,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,7) if($partnum eq '6');

  if($partnum eq 'N') {
      ($rest1,$rest2,$rest3,$rest4,$variable) = split(/$sepsymbol/,$locline,5);
      $variable = $rest4 if($variable eq "");
      $variable = $rest3 if($variable eq "");
      $variable = $rest2 if($variable eq "");
      $variable = $rest1 if($variable eq "");
  }
  if($partnum eq 'N-1') {
      ($rest1,$rest2,$rest3,$rest4,$rest5) = split(/$sepsymbol/,$locline,5);
      $variable = $rest4 if($rest5 ne "");
      $variable = $rest3 if($rest5 eq ""  and $rest4 ne "");
      $variable = $rest2 if($rest5 eq ""  and $rest4 eq "" and $rest3 ne "");
      $variable = $rest1 if($rest5 eq "" and $rest4 eq "" and $rest3 eq "");
  }
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

## 00517    DATE   check:: 1.source 2.uDateloc 3.link 4.paragr_month

sub refine_date
{
  if($uDateloc !~ /linesrc/ and $msgline_source =~ /[A-Za-z0-9]/) {
   $chkline = $msgline_source;
   &basic_date_parse;
 }
 
 if($pubyear eq '00' and $uDateloc !~ /parasrc/ and $paragr_source =~ /[A-Za-z0-9]/) {
   $chkline = $paragr_source;
   &basic_date_parse;
 }

 if($pubyear eq '00' and $uDateloc =~ /[A-Za-z0-9]/) {
    $locname = $uDateloc;
    &set_std_parseVars;
    $chkline = $locline;
    &basic_date_parse;
 }
  
 if($pubyear eq '00' and $msgline_anydate =~ /[A-Za-z0-9]/) {
   $chkline = $msgline_anydate;
   &basic_date_parse;
 }
 
 if($pubyear eq '00' and $link =~ /[A-Za-z0-9]/) {
    $uDateloc = 'link';
    $chkline = $link;
    &basic_date_parse;
 }
 
 if($pubyear eq '00'and $paragr_month =~ /[A-Za-z0-9]/) {
    $chkline = $paragr_month;
    &basic_date_parse;
 }
}



##  00519  DAY   - must be done before month OLD OLD ##

sub refine_day
{
 if($dtsep ne "") {
   ($pdd,$rest)         = split(/$dtsep/,$pdate,2) if($daypos eq '1');
   ($rest,$pdd,$rest2)  = split(/$dtsep/,$pdate,3) if($daypos eq '2');
   ($rest1,$rest2,$pdd) = split(/$dtsep/,$pdate,3) if($daypos eq '3');
   $pdd =~ s/^\D+//;
   $pdd =~ s/\D+$//;
   $pdd_val = $pdd;
   $pdd_val =~ s/^0//;
 }
 
 if(p_mon =~ /[a-zA-Z0-9]/ and ($pdd eq "" or $pdd =~ /\D/ or $pdd_val eq 0 or $pdd > 31) ) {
    ($pdd,$rest) = split(/$p_mon/,$pdate,2) if($daypos eq '1');
    ($rest,$pdd) = split(/$p_mon/,$pdate,2) if($daypos eq '3');
    if($daypos eq '2' or $daypos !~ /[1-9]/) {
       ($rest,$pday) = split(/$p_mon/,$pdate,2);
       $pday =~ s/^\D+//;
       @pdaysplit = split(//,$pday);
       $pdd = "$pdaysplit[0]$pdaysplit[1]"; 
	 $pdd =~ s/^\D+//;
       $pdd =~ s/\D+$//;
       $pdd_val = $pdd;
       $pdd_val =~ s/^0//;
       
       if($pdd eq "" or $pdd =~ /\D/ or $pdd_val eq 0 or $pdd_val > 31) {
         ($pday,$rest) = split(/$p_mon/,$pdate,2);
         $pday =~ s/^\D+//;
         @pdaysplit = split(//,$pday);
         $pdd = "$pdaysplit[0]$pdaysplit[1]";
       }
    }
    $pdd =~ s/^\D+//;
    $pdd =~ s/\D+$//;
    $pdd_val = $pdd;
    $pdd_val =~ s/^0//;
    $pdd = "" if($pdd =~ /\D/ or $pdd > 31 or $pdd_val < 1);

    undef $pdaysplit;
    undef $pday;
 }

 if($pdd eq "" or $pdd =~ /\D/ or $pdd eq 0 or $pdd > 31) {
   $pdate =~ s/^\D+//;
   $pdate =~ s/\D+$//;
   @datesplit = split(//,$pdate);
   if($daypos eq '1' or $daypos !~ /[1-9]/) {
       $pdd = "$datesplit[0]$datesplit[1]";
   }
   elsif($yearpos eq 1 and $yearformat eq 'yyyy') {
        $pdd = "$datesplit[4]$datesplit[5]" if($daypos eq '2');
        $pdd = "$datesplit[6]$datesplit[7]" if($daypos eq '3');
   }
   else {
        $pdd = "$datesplit[2]$datesplit[3]" if($daypos eq '2');
        $pdd = "$datesplit[4]$datesplit[5]" if($daypos eq '3');
   }
   $pdd =~ s/^\D+//;
   $pdd =~ s/\D+$//;
   $pdd_val = $pdd;
   $pdd_val =~ s/^0//;
 }

 if($pdd eq "" or $pdd =~ /\D/ or $pdd_val eq 0 or $pdd > 31) {
   $sentdd =~ s/^\D+//;
   $pdd = $sentdd;
   $pdd_val = $pdd;
   $pdd_val =~ s/^0//;
 }
}


##  00522  YEAR   OLD OLD ##

sub refine_year
{
 foreach $pyear (@pubyears) {
    if($pdate =~ /$pyear/) {
        $pyyyy = $pyear;
        last;
    }
 }

 $pyy = "";
 if($pyyyy eq "" or $pyyyy =~ /\D/ or ($pyyyy > 99 and $pyyyy < 1850) or $pyyyy > 2030) {
     $pyyyy = "";
     ($yrpos,$yrformat) = split(/#/,$dtyear) if($dtyear ne "");

     if($dtsep ne "") {
        ($pyyyy,$rest)         = split(/$dtsep/,$pdate,2) if($yearpos eq '1');
        ($rest,$pyyyy,$rest2)  = split(/$dtsep/,$pdate,3) if($yearpos eq '2');
        ($rest1,$rest2,$pyyyy) = split(/$dtsep/,$pdate,3) if($yearpos eq '3');
        $pyyyy =~ s/^\D+//;
        $pyyyy =~ s/\D+$//;
     }

     if($dtsep eq "" or $pyyyy eq "" or $pyyyy =~ /\D/ 
         or ($pyyyy > 99 and $pyyyy < 1850) or $pyyyy > 2030) {
          $pdate =~ s/^\D+//;
	    @datesplit = split(//,$pdate);
          $pyy = "$datesplit[0]$datesplit[1]" if($yearpos eq '1');
          $pyy = "$datesplit[2]$datesplit[3]" if($yearpos eq '2');
          $pyy = "$datesplit[4]$datesplit[5]" if($yearpos eq '3');

          if($yearpos !~ /[1-9]/) {
                $pyyyy = "";
          }
          elsif($pyy > 0 and $pyy <= 99) {
             $pyyyy = $pyy+2000 if($pyy < 50);
             $pyyyy = $pyy+1900 if($pyy >= 50);
          }
     }
 }

 if($pyyyy eq "" or $pyyyy =~ /\D/ or ($pyyyy > 99 and $pyyyy < 1850) or $pyyyy > 2030) {
    foreach $pyear (@pubyears) {
      if($sentdate =~ /$pyear/) {
         $pyyyy = $pyear;
      }
    }
 }
}

#   OLD OLD

sub calc_sentmm
{
 $chkdate = $sentdate;
 &parse_abbrv_months;
 $sentmm = $pmm;
 $pmm = 0;
}


# 500 ############# COMMON DATE ROUTINES ##################3
### from article.pl when processing email data 
### also from convert.pl 

sub init_dateparse_varibles
{
 &get_nowdate;
 
 my $short;
	
%hMonths = (
	1 => "January",
	2 => "February",
	3 => "March",
	4 => "April",
	5 => "May",
	6 => "June",
	7 => "July",
	8 => "August",
	9 => "September",
	10 => "October",
	11 => "November",
	12 => "December"
  );

$chkmonth = "January|February|March|April|May|June|July|August|September|October|November|December";
$chk_abbrvmonth = "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec";
$chkyear = "1990|1991|1992|1993|1994|1995|1996|1997|1998|1999|2000|2001|2002|2003|2004|2005|2006|2007|2008|2009";
$chkmonths = "$chkmonth|$chk_abbrvmonth";
##builds abbreviated monthname hash list

while( ($num, $title) = each %hMonths )
{
	$short = lc(substr($title,0,3));
	$rshMonths{$short} = $num;
}

$ckOrder = "LMFYSNH";
@ckOrder = split(//,$ckOrder);

##allafrica.com/stories/200208120669.html
##arkcity.net/stories/060703/com_0002.shtml
##bbc.co.uk (not in link) ddmmmmyyyy
##commondreams.org/headlines03/1024-02
##csmonitor.com/2002/0827/p07s02-woaf.html
##dailytelegraph.co.uk/news/main.jhtml?xml=/news/2003/03/28/ncond28.xml&sSheet=/news/2003/03/28/ixhome.html
##english.peopledaily.com.cn/200308/07/eng20030807_121839.shtml
##ens-news.com/ens/oct2002/2002-10-30-06.asp
##eurekalert.org/pub_releases/2003-03/uoia-tcc032403.php
##fredericksburg.com/News/FLS/2003/032003/03092003/890429
##freelancestar.com/News/FLS/2003/042003/04132003/931545
##latimes.com/news/local/la-me-rwaste6mar06,1,2025819.story
##megastar.co.uk/ents/news/2003/04/15/sMEG01MTA1MDQxNjYyOTc.html
##nationalgeographic.com/ngm/9902/fngm/index.html
##nature.com/nsu/030407/030407-14.html
##nytimes.com/2002/08/20/science/earth/20POPU.html
##peopledaily.com.cn/200208/15/eng20020815_101491.shtml
##prnewswire.com/cgi-bin/stories.pl?ACCT=109&STORY=/www/story/03-30-2005
##sfgate.com/cgi-bin/article.cgi?file=/chronicle/archive/2002/08/25
##sltrib.com/2003/Feb/02232003/utah/32042.asp
##taipeitimes.com/News/taiwan/archives/2003/08/20
##telegraph.co.uk:80/et?ac=000135872017160&rtmo=0XxGJJRq&atmo=99999999&pg=/et/99/8/3/
##unfoundation.org/unwire/2002/08/15
##usatoday.com/usatonline/20030116/4784142s.htm
##washingtonpost.com/wp-dyn/articles/A38033-2002Aug19.html
##xinhuanet.com/english/2002-08/15/content_524936.htm
##yahoo.com/news?tmpl=story&u=/ap/20020819


@linkDateTable = (
   "allafrica.com^ymd^\/stories\/([0-9]{4})([0-9]{2})([0-9]{2})",
   "commondreams.org^ymd^\/headlines([0-9]{2})\/([0-9]{2})([0-9]{2})",
   "csmonitor.com^ymd^([0-9]{4})\/([0-9]{2})([0-9]{2})",
   "peopledaily.com.cn^ymd^([0-9]{4})([0-9]{2})\/([0-9]{1,2})",
   "prnewswire.com^mdy^([0-9]{2})\-([0-9]{1,2})\-([0-9]{4})",   
   "sfgate.com^ymd^(d{4})\/([0-9]{1,2})\/([0-9]{1,2})",
   "nationalgeographic.com^ymd^\/.*\/([0-9]{1,2})([0-9]{1,2})\/",
   "unfoundation.org^ymd^([0-9]{4})\/([0-9]{1,2})\/([0-9]{1,2})",
   "washingtonpost.com^ymd^([0-9]{4})([a-zA-Z]{3})([0-9]{1,2})", 
   "usatoday.com^ymd^([0-9]{4})([0-9]{2})([0-9]{2})",
   "xinhuanet.com^ymd^([0-9]{4})\-([0-9]{2})\/([0-9]{1,2})",
   "yahoo.com^ymd^\/([0-9]{4})([0-9]{2})([0-9]{2})",
   "telegraph.co.uk^ymd^et\\/([0-9]{2})\\/([0-9]{1,2})\\/([0-9]{1,2})\\/"
   );
}


sub basic_date_parse
 {
##  line to be parsed should be in $chkline
 my $slash = '\/';
 my $dash  = '-';
 my $firstyear, $cktype;
 $pubmm     = '--';
 $pubday    = '--';
 $pubmonth  = '--';
 $pubyear   = '--';
 $holdmonth = "--";
 $holdyear  = "--";
 $firstyear = 'N';
 
 @ckOrder = split(//,$ckOrder);

##  L=link M=month Y=yyyy F=formatted S=senddate N=now H=Held from LMYF
 	
 foreach $cktype (@ckOrder) {

#in a URL   
   if($cktype eq 'L' and ($pubyear !~ /[0-9]{4}/ or $pubmonth !~ /[0-9]{2}/)) {
      &chk_link_date;
      &do_yyyymmdd if($pubyear =~ /[0-9]+/); 
   }

#separated by slashes, dashes, or other 
   if($cktype eq 'F' and ($pubyear !~ /[0-9]{4}/ or $pubmonth !~ /[0-9]{2}/) and
       ($dDateformat =~ /[a-z]/ or 
        $chkline =~ /($alphanum{1,4})$slash($alphanum{1,4})$slash($alphanum{1,4})/ or
        $chkline =~ /($alphanum{1,4})$dash($alphanum{1,4})$dash($alphanum{1,4})/  ) ) 
   {
     &chk_formatted_date;
     &do_yyyymmdd  if($pubyear =~ /[0-9]+/);
   }

#alpha month 
   if($cktype eq 'M' and $chkline =~ /($chkmonths)/ and ($pubyear !~ /[0-9]{4}/ or $pubmonth !~ /[0-9]{2}/)) {
       &chk_month_date;
       &do_yyyymmdd if($pubyear =~ /[0-9]+/);
   }

#4-digit year   
   if($cktype eq 'Y' and $chkline =~ /$chkyear/ and $pubyear !~ /[0-9]{4}/) {
       &chk_year_date;
       &do_yyyymmdd if($pubyear =~ /[0-9]+/);
   }
 
# sentdate

   if($cktype eq 'S' and $sentdate =~ /[A-Za-z0-9]/ and $holdyear !~ /[0-9]{4}/) {
       if($suggestAcctnum eq '3491') {
       	  &get_7daysago;
       }
       else {
##       print " sent-$sentdate H-$holdyear";
           $hold_ckline = $chkline;
           $chkline = $sentdate;
           &chk_month_date;
           $chkline = $hold_ckline;
           &do_yyyymmdd if($pubyear =~ /[0-9]+/);
      }
   }

# today less 7 days
   if($cktype eq 'N' and $holdyear !~ /[0-9]{4}/ ) {
     &get_7daysago;
     &do_yyyymmdd if($pubyear =~ /[0-9]+/);
  }

#year held from one of the above methods   
  if($cktype eq 'H' and $holdyear =~ /[0-9]{4}/ ) {
  	$pubyear  = $holdyear;
  	$pubmonth = $holdmonth;
  }
 
  last if($pubmonth ne '--' and $pubyear =~ /[0-9]{4}/);	

 } ##end FOREACH
 
 $pubday = '00' if($pubday !~ /[0-9]{2}/);
 
 if($pubyear =~ /[0-9]{4}/) {
    if($pubmonth =~ /[0-9]{2}/) {
        $pubdate = "$pubyear-$pubmonth-$pubday";
    }
    else {
        $pubdate = $pubyear-00-00;
    }
    $sysdate = $pubdate if(substr($pubyear,0,2) =~ /19/);
 }
 else {
    $pubdate = "0000-00-00";
#     sysdate has already been calculated
 }
}

##00815

sub chk_link_date
{
my $domain, $formatexpr;

foreach $linkdate (@linkDateTable) {
    ($domain,$dDateformat,$formatexpr) = split(/\^/,$linkdate);

    if($chkline =~ /$domain/) {
    	if($chkline =~ /$formatexpr/) {
            $ymd1 = $1;
            $ymd2 = $2;
            $ymd3 = $3;
            &do_formatted_date;
        }
      last;
    }
 }
 $dDateformat = "";
}

sub chk_month_date
{
  if($chkline =~ /($chkmonths) +([0-9]{1,2}),? +'?[0-9]{2,4}/ ) {
  	$pubmonth = $1;
  	$pubday = $2;
##  	$pubyear = "$3";
##print "  mdy yy-$pubmonth-$pubday ";
  	if($chkline =~ /$pubmonth +$pubday,? +'?([0-9]{2,4})/ ) {
    	    $pubyear = "$1";
##    	print " mdy yr-$pubyear ";
       }
  }

  elsif($chkline =~ /([0-9]{1,2}) {0,2}($chkmonths) {0,2}'?[0-9]{2,4}/)
  {
   	$pubmonth = $2;
   	$pubday = $1;
   	if($chkline =~ /$pubday {0,2}$pubmonth {0,2}'?([0-9]{2,4})/ ) {
            $pubyear = "$1";
        }
##   print " dmy $pubyear-$pubmonth-$pubday ";
  }
}
  
##00820
  
sub chk_formatted_date
{                                
  if($chkline =~ /($alphanum{1,4})[-\/]($alphanum{1,4})[-\/]($alphanum{1,4})/ ) {
       $ymd1 = $1;
       $ymd2 = $2;
       $ymd3 = $3;
       if($dDateformat !~ /[a-z]/) {
            $dDateformat = 'ymd' if($ymd1 =~ /^[0-9]{4}$/);
            if($ymd1 =~ /[A-Za-z]/ or 
                 ($ymd1 =~ /../ and $ymd =~ /nums_to12/) or
                 ($ymd1 =~ /./ and $ymd =~ /[1-9]/) or
                  $ymd3 =~ /[0-9]{4}/) {
                     $dDateformat = 'mdy';
            }
            $dDateformat = 'dmy' if($dDateformat !~ /ymd|mdy/);       
       }
       
       &do_formatted_date if($dDateformat =~ /[A-Za-z]/);
  }
}



sub chk_year_date
{
  if($chkline =~ /($chkyear)/ and $chkline !~ /copyright ?($chkyear)/i) {
  	$pubyear = $1;

      if($chkline =~ /($chkmonth) ?([0-9]{0,2}),? ?$pubyear/ 
      or $chkline =~ /($chk_abbrvmonth) ?([0-9]{0,2}),? ?$pubyear/ ) {
              $pubmonth = $1;
              $pubday = $2;
      }
      elsif($chkline =~ /([0-9]{0,2}) ?($chkmonth),? ?$pubyear/ or
            $chkline =~ /([0-9]{0,2}) ?($chk_abbrvmonth),? ?$pubyear/) {
              $pubmonth = $2;
              $pubday = $1;
      }
      
      &get_pubmm if($pubmonth =~ /[A-Za-z]/);
      $pubday = '--' if($pubday =~ /[0-9]{3,}/ or $pubday !~ /$nums_to29|30|31/);
  }
}

## 0825

sub do_formatted_date
{
##	print "$dDateformat ";
    if($dDateformat =~ /ymd/) {
    	$pubyear  = $ymd1;
    	$pubmonth = $ymd2;
    	$pubday   = $ymd3;
    }
    elsif($dDateformat =~ /mdy/) {
    	$pubyear  = $ymd3;
    	$pubmonth = $ymd1;
    	$pubday   = $ymd2;
    }
    elsif($dDateformat =~ /dmy/) {
    	$pubyear  = $ymd3;
    	$pubday   = $ymd1;
    	$pubmonth = $ymd2;
    }
 }

sub do_yyyymmdd
{
  $pubyear  =~ s/\D//g;
  &Y2K if($pubyear =~ /^[0-9]{2}$/);
  
  if($pubyear =~ /[0-9]{4}/) {
      &get_pubmm if($pubmonth =~ /[A-Za-z]/);
      &ck_pubmm;    
      &ck_pubdd if($pubmonth =~ /^[0-9]{2}$/);
  }
  else {
     $pubyear = "00";
  }
 
  if($ckOrder =~ /LMFY/ and $pubyear =~ /[0-9]{4}/ and $holdyear !~ /^[0-9]{4}$/ ) {
     $holdyear  = $pubyear;
     $holdmonth = $pubmonth;
  }
}

sub Y2K 
{
  my @yr_digits;
  
  $pubyear =~ s/'//;
  @yr_digits = split(//, $pubyear);
  if(@yr_digits[0] =~ /[0-3]/) {
     $pubyear = "20$pubyear";
  }
  else {
     $pubyear = "19$pubyear";
  }
  
  $pubyear = "00" if($pubyear !~ /^[0-9]{4}$/);
}
     
## 00830

sub get_pubmm
{
  $short = lc(substr($pubmonth,0,3));
  $pubmonth = $rshMonths{$short};
  undef $short;
}

sub ck_pubmm
{
 $pubmonth =~ s/[^0-9]//g;
 $pubmonth = "0$pubmonth" if($pubmonth !~ /[0-9]{2,}/);
 if($pubmonth =~ /01|02|03|04|05|06|07|08|09|10|11|12/)  
 { }
 else {
   $pubmonth = "00";
 }
}


sub ck_pubdd
{
 $pubday =~ s/\D//g;  
 $pubday = "0$pubday" if($pubday =~ /^[0-9]$/);
 if(($pubday =~ /$nums_to29/ and $pubmonth =~ /02/)
    or ($pubday =~ /$nums_to29|30/    and $pubmonth =~ /04|06|09|11/ )
    or ($pubday =~ /$nums_to29|30|31/ and $pubmonth =~ /01|03|05|07|08|10|12/ ) )
      {  }
 else {
   $pubday = "00";
 }
}


sub get_7daysago
  { 	 
   $addsecs  = (-7 * 3600 * 24);
   &calc_date('sys',$addsecs);
   $pubyear  = $sysyear;
   $pubmonth = $sysmm;
   $pubday   = $sysdd;
}


1;