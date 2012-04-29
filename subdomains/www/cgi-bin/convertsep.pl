
	 if($sep_found =~ /Y/
	    and $separator_cnt > 1 ) {

	    &write_file;
	 }
	
	
sub close_it
{
##              write the last email
 if(($separator_cnt > 0) or
     $separator_cnt eq 0) {
       $separator_cnt += 1 if($separator_cnt > 0);

       &write_file if($msgbody =~ /[A-Za-z0-9]/);
 }
write to index as well
 close(CVRTIDX);
}

#!/usr/bin/perl --

# August 12, 2010

# convertsep.pl converts data from the old html format to autosubmit data.

#Separates as well. Parameters are name of page to convert, and index to write to.
#Display this section with Suggested form.

## called by article.pl


#### CONVERT SUBSECTIONS FROM OLD HTML ############
##               Comes here from  article.pl from the convert file in public_html 
##               prepared from old sections in old-style html

sub convert_old_subsection
{    
($woapage,$convertsectsub) = @_;
 require 'common.pl';
 require 'docitem.pl';
	
 $action = 'new';
 
 $first_time = 'Y';
 $emessage = "";
 $separator = "#####";
 
 ## we will write all items to suggested
 ## and from there they will go to their designated section idx(s)
 
 $convertsectpath = "$sectionpath/$convertsectsub\.idx";

 unlink $convertsectpath if(-f $convertsectpath);
 open(CVRTIDX, ">$convertsectpath");
 
 open(OLDHTML, "$publicdir/$woapage\.html");
 while(<OLDHTML>) {
    chomp;
    $cvrtline = $_;
##       if next item - 
 
    if($cvrtline =~ /^\[/) {
        &set_variables;
    }

    if($cvrtline =~ /$separator/) {       	
           &convert_item if($first_time !~ /Y/);
           $emessage = "";
           $first_time = 'N';	
    }
    $emessage = "$emessage\n$cvrtline" 
        if($cvrtline !~ /^$separator/);
 }
 close(OLDHTML);
  
##   do last item

 &convert_item if($emessage =~ /[A-Za-z0-9]/ and $docid !~ /[0-9]/); 
 
 close(CVRTIDX);
 
 print"<meta http-equiv=\"refresh\" content=\"0;url=http://$scriptpath/article.pl?display_section%selectUpdt_Item%%$convertsectsub%%%10\">";
}



### 100 ## COMES here from sepmail if convert articles are from email
###      ACTION::convert should be at the top of the message
###      Goes to convertsectsub

sub convert_from_email
{
 local($emessage) = @_;
 
 if($emessage =~ /[A-Za-z0-9]/) { 
##   require 'parsedata.pl';
   require 'docitem.pl';
   $action = 'new';
   $docid = "";
   &convert_item;
 }
}


## 00200

sub convert_item
{
 &clear_doc_variables;
 &clear_doc_data;
 &clear_doc_variables;
 
 &extract_docid if($emessage =~ /login%|%login/);
   
 if($docid =~ /[0-9]{6}/ and (-f "$itempath/$docid.itm") ) {
    &get_doc_data;
    $sectsubs = "$rSectsubid";
 }
 else {
    if($emessage =~ /<table|<TABLE|TEMPLATE::straight/) {
       $dTemplate = $straight;
       $body = $emessage;
    }
    else {     
       &extract_item_elements;
    }
    
    &get_docid;
    ($rSectsubid,$rest) = split(/;/,$rSectsubid);
##    ($rSectsubid,$rest) = split(/ /,$rSectsubid);
##    ($rSectsubid,$rest) = split(/;/,$rSectsubid);
    $sectsubs = "$rSectsubid";
 }

print"cvt200 Converted docid $docid ... body $body<p>\n"; ### KEEP
 
 &write_doc_item;

 print CVRTIDX "$docid^M\n";

 $docid = "";
 
## restore in case overridden
 $sTemplate = $cTemplate;
}

## 00250

sub extract_item_elements
{
 $chkline    = "";
 
 $fullbody = $emessage;
 
 $emessage =~ s/^=+//g;
 $emessage =~ s/B\>/b\>/g;
 $emessage =~ s/HTTP:\/\//http:\/\//g;
 $emessage =~ s/<FONT/<font/g;
 $emessage =~ s/<\/FONT/<\/font/g;
 $emessage =~ s/[Ss][Ii][Zz][Ee]=\"?1\"?/size=1/g;
 $emessage =~ s/<\/A>/<\/a>\>/g;
   
 ($preheadline,$headline)   = split(/<b\>/,$emessage,2);
 ($headline,$rest)   = split(/<\/b\>/,$headline);
 $headline           =~ s/\.$//;
 $headline           =~ s/\n/ /g;
 $headiine           =~ s/ $//;
 
 if($preheadline =~ /href=/) {
    ($rest,$link)        = split(/href=/,$preheadline,2);
    ($rest,$link,$rest2) = split(/\"/,$link,3) if($link =~ /\"/);
    ($link,$rest)        = split(/\<a/,$link) if($link =~ /\<a/);
    $link =~ s/http:\/\///g;
    undef $rest2;
 }
 if($emessage !~ /<\/b\>/ and $sTemplate =~ /linkBulletItem/ ) {
      ($rest,$body)  = split(/\"\>/,$emessage,2);
      ($body, $rest) = split(/<\/a\>/,$emessage,2);
      $pubdate = "0000-00-00";
      $region = "";
      $source = "";
 }
 else {
   &finish_extract;
 }
}

## 300

sub finish_extract 
{
		
 ($rest,$body)     = split(/a\>&nbsp;/,$emessage,2);
 ($rest,$body)     = split(/<\/b\>/,$emessage,2)  if($body eq "");
 ($rest,$body)     = split(/<\/a\>/,$body,2) if($body =~ /^<\/a\>/);
 ($rest,$body)     = split(/\>/,$body,2) if($body =~ /^\>/);

 ($smallend,$body) = split(/<\/font\>/,$body,2) if($body =~ /^<font size=1/);
 ($body,$smallend) = split(/<font ?\n? ?size=1/,$body,2) if($body !~ /^<font size=1/ and $body =~ /size=1/);
 ($body,$rest)     = split(/\'<a/,$body);  #strip off link to item at end
 $body             =~ s/<\/li\>//;
 $body             =~ s/<li\>//;
 $body             =~ s/\.$//;
 $body             =~ s/^=*//;
 $body             =~ s/^\n+//;
 $body             =~ s/^\r+//;
 $body             =~ s/^\>+//;

 $body = $emessage if($body !~ /[A-Za-z0-9]/ and $headline !~ /[A-Za-z0-9]/);
 if($body !~ /[A-Za-z0-9]/ and $headline !~ /[A-Za-z0-9]/
                          and $emessage =~ /[<\>]/) {
     $dTemplate = $straight;
     $body = $emessage;
 }

 ($rest,$source) = split(/size=1/,$emessage,2);
 ($rest,$source) = split(/>/,$source,2);
 ($source,$rest) = split(/<\/font>/, $source,2);
  
 if($$emessage =~ /^<font size=1/) {
 }
 else {
    ($source,$rest)     = split(/<\/a>/,$source,2);
     $source =~ s/&nbsp;//g;     
     ($rest,$smallend) = split(/>/,$smallend,2);
     
     ($smallend,$rest)     = split(/<\/font/,$smallend,2);
        
     ($rest,$comment)    = split(/\[/,$smallend,2);
     ($comment,$handle)  = split(/\]/,$comment,2) if($comment =~ /[A-Za-z0-9]/);
#     $comment            = "[$comment]" if($comment =~ /[A-Za-z0-9]/ and $comment !~ /\[|\]/);     
   
     ($handle,$rest)     = split(/<\/font>/,$smallend,2) if($handle != /[A-Za-z0-9]/);
     
     $skiphandle   = 'N';
     if($handle    =~ /[A-Za-z]/) {
       $ehandle    = $handle;
       $handle     = "";
       $userdata   = &read_contributors(N,N,$ehandle,_,);     ## args=print?, html file?, handle, email, acct# 
       $sumAcctnum = "$access$userid" if($userdata =~ /SAMEHANDLE/);
       $skiphandle = 'Y' if($access = 'A' or $handle eq 'kgp');
       $handle     = $ehandle;
     }
     else {
       $skiphandle = 'Y';
     }
   undef $smallend;
  }
    
 ##  look for date on source line or in whole item.
  if($source =~ /[A-Za-z0-9]/) {
    $chkline = $source;
  }
  else  {
    $chkline = $emessage;
  }
    
  if($dTemplate =~ /linkItem/) {
    $ckOrder = "M"; 
  }
  else {
    $ckOrder = "LMFYH";
  }
  &basic_date_parse;

  if($pubyear =~ /[0-9]{4}/) {
      ($rest,$source) = split(/$pubyear/,$source,2) ;
      $source =~ s/^\s//;  
  }
  else {
      $uDateloc    = "";
      $uDateformat = "";
      $chkline = $emessage;
      &basic_date_parse;
  }
  $pubdate = "0000-00-00" if($pubyear =~ /2005|2006|2007|2008|2009/);
  $uDateloc = "";
  $uDateformat = "";

  local($savesource) = $source;
  $print_src = 'N';
  
  &get_sources;
  $source =~  s/^\/+//;  #get rid of leading backslashes 
  $source = $savesource if($source !~ /[A-Za-z0-9]/);
  
  $printRegion = 'N';
  &get_regions;
  $region =~  s/^;+//;  #get rid of leading semi-colons
  $regionhead = 'N';
        
  $dTemplate = 'quoteItem' if($emessage =~ /AFOF00/);
  $wFormat = "$wFormat;div"       if($emessage =~ /div|DIV/);
  $wFormat = "$wFormat;BQ"        if($emessage =~ /blockquote|BLOCKQUOTE/);
  $wFormat = "$wFormat;CTRout"    if($emessage =~ /center|CENTER/);
  $wFormat = "$wFormat;BDRGrey"   if($emessage =~ /table|TABLE/ and $emessage =~ /bordercolor=.{1,2}000000/);
  $wFormat = "$wFormat;BDRRed"    if($emessage =~ /table|TABLE/ and $emessage =~ /AFOF00/);
  $wFormat = "$wFormat;BDRBlue"   if($emessage =~ /table|TABLE/ and $emessage =~ /339999/);
  $wFormat = "$wFormat;BDRindent" if($emessage =~ /table|TABLE/ and $emessage !~ /bordercolor/);
  $wFormat = "$wFormat;CTRin"     if($emessage =~ /td|TD.{1,3}center|CENTER/);
  $wFormat = "$wFormat;UL"        if($emessage =~ /ul|UL/);
  $wFormat = "$wFormat;OL"        if($emessage =~ /ol|OL/);
  $wFormat = "$wFormat;LI"        if($emessage =~ /li|li/);
  $wFormat = s/^;//;
  $emessage = s/<\/td><\/table>/~/i if($emessage =~ /<\/[tT][aA][bB][lL][eE]/);
  $endtable = 'Y' if($emessage =~ /table|TABLE/);
    
  &convert_html_to_text;
}


## 350

sub extract_docid
{
 $docid = "";

 if($emessage =~ /%login/) {
     ($rest,$docid) = split(/%login/,$emessage,2);
 }
 
 ($front,$docid,$rest) = split(/%/,$docid,3);
 ($docid,$rest) = split(/\n/,$docid,3);
  
 if(-f "$itempath/$docid.itm") {
 }
 else {
     print "<br>Item#$docid# not found ... 450<br>\n";
     $docid = "";
 }
 undef $front;
}

1;
