#!/usr/bin/perl --

# January 23 2012
#      date.pl   : handles all the date parsing and checking for docitems (articles)


sub set_date_variables   # from article.pl
{                                         
  $todaydate = &get_nowdate;    #in date.pl
  $t3monthsago = &get_3monthsago;
  
  $chkmonth = "January|February|March|April|May|June|July|August|September|October|November|December";
  $chk_abbrvmonth = "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec";
  @months =
  ("January","February","March","April","May","June","July","August","September", "October","November","December");
  $dateadd = 0;

  $chkmonths = "$chkmonth|$chk_abbrvmonth";
  
  @abbrvmonths = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  
  $chkyear = "1990|1991|1992|1993|1994|1995|1996|1997|1998|1999|2000|2001|2002|2003|2004|2005|2006|2007|2008|2009|2010|2011|2012|2013";
  @pubyears = 
  ("1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011");
  $chkday = "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31";
  $nums_to29 = "1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29";

  $digit    = "[0-9]";
  $alphanum = "[A-Za-z0-9]";
  $nums_to12 ="01|02|03|04|05|06|07|08|09|10|11|12";
  $nums_to29 ="$nums_to12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29";

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

##builds abbreviated monthname hash list

 while( ($num, $mname) = each %hMonths )
 {
	$short = lc(substr($mname,0,3));
	$rshMonths{$short} = $num;
 }

 $ckOrder = "MFYLSNH";
 @ckOrder = split(//,$ckOrder);
}


sub assemble_pubdate  # from docitem.pl
{
   $pubyear = '0000' if($pubyear eq 'no date');
  if($pubyear eq '0000') {
     $pubmonth = "00";
     $pubday   = "00";
     $pubdate = "0000-00-00";
  }
  elsif($pubmonth eq "_" or $pubmonth eq "" or $pubmonth eq '00') {
     $pubdate = "$pubyear-00-00";
  }
  else {
    $pubdate = "$pubyear-$pubmonth-$pubday";
  }	
}


##        FROM template_ctrl.pl  check:: 1.source 2.uDateloc 3.link 4.paragr_month
sub print_srcdate
{
 my($pubyear,$pubmonth,$pubday) = split(/-/,$pubdate,3);
 if($pubdate =~ /no date/ or $pubdate = "" or $pubyear eq '0000' or $pubyear !~ /[0-9]{4}/) {
    $srcdate = "";
 }
 else {
    if($pubmonth !~ /$nums_to12/) {
    	$srcdate = $pubyear;
    }
    else {
      $pubmm = $pubmonth -1;
      $month = @months[$pubmm];
      $month = $month[1] if($month[0] = '0');
      if($pubday =~ /[A-Za-z0-9]/ and $pubday ne '00') {
        $srcdate= "$month $pubday, $pubyear";
      }
      else {
         $srcdate= "$month $pubyear";
      }
    }
    print MIDTEMPL "$srcdate &nbsp;" if($nodata =~ /N/);
 }
}


## ACCESSSED FROM SMARTDATA.PL

sub refine_date
{
 $pubdate = "";
 if($msgline_date) {
	$pubdate = &basic_date_parse($msgline_date);
 }	
 elsif($msgline_anydate) {
   $pubdate = &basic_date_parse($msgline_anydate);	
 }
 elsif($msgline_link) {
   $pubdate = &basic_date_parse($msgline_link);		
 }

 if(($pubyear =~ /0000/ or !pubyear) and !$pubdate) {
	 if($uDateloc !~ /linesrc/ and $msgline_source =~ /[A-Za-z0-9]/) {
	   $pubdate =  &basic_date_parse($msgline_source);	
	 }
	 elsif($uDateloc !~ /parasrc/ and $paragr_source =~ /[A-Za-z0-9]/) {
	   $pubdate =  &basic_date_parse($paragr_source);
	 }
	 elsif($uDateloc) {
	    $locname = $uDateloc;
	    &set_std_parseVars;
	    $pubdate =  &basic_date_parse($locline);
	 }
	 elsif($link) {
	    $uDateloc = 'link';
	    $pubdate = &basic_date_parse($link);
	 }
	 elsif($paragr_month =~ /[A-Za-z0-9]/) {
	    $pubdate = &basic_date_parse($paragr_month);
	 }
     elsif($sentdate) {
	     $pubdate = $sentdate;
	 }
	 else {
        $pubdate = $todaydate;
     }
 }
 return($pubdate);
}



##  00360  DAY   - must be done before month OLD OLD ##

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


##  00380  YEAR   OLD OLD ##

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
 $todaydate = &get_nowdate;
 
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
$chkyear = "1990|1991|1992|1993|1994|1995|1996|1997|1998|1999|2000|2001|2002|2003|2004|2005|2006|2007|2008|2009|2010|2011|2012|2013|2014|2015|2016";
$chkmonths = "$chkmonth|$chk_abbrvmonth";
##builds abbreviated monthname hash list

while( ($num, $mname) = each %hMonths )
{
	$short = lc(substr($mname,0,3));
	$rshMonths{$short} = $num;
}

$ckOrder = "MFYLSNH";
@ckOrder = split(//,$ckOrder);
}


sub basic_date_parse
 {
  my $chkline = $_[0];
##  line to be parsed should be in $chkline
 my $slash = '\/';
 my $dash  = '-';
 my $firstyear, $cktype;
 my $pubmm     = '--';
 my $pubday    = '--';
 my $pubmonth  = '--';
 my $pubyear   = '--';
 my $pubdate = "0000-00-00";
 $holdmonth = "--";
 $holdyear  = "--";
 $firstyear = 'N';

##  L=link M=month Y=yyyy F=formatted S=senddate N=now H=Held from LMYF

 if($uDateloc =~ /sent/ and $sentdate) {
   $cktype = "S";  ## else go with the default
 }
 if($chkline =~ /($chkmonths)/) {
   $pubmonth = $1;
   $cktype = 'M';
   if($chkline =~ /($chkyear)/) {
     $pubyear = $1;
     $pubday = &chk_month_date($pubmonth,$pubyear,$chkline);
     $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
   } 
 }
 elsif($chkline =~ /([0-9]{1,4})[-\/]([0-9]{1,4})[-\/]([0-9]{1,4})/ ) {
	$cktype = 'F';  # Could also be and 'L' for link
	my $ymd1 = $1;
    my $ymd2 = $2;
    my $ymd3 = $3;
    $cktype = 'F';

    ($pubyear,$pubmonth,$pubday) = &chk_formatted_date($ymd1,$ymd2,$ymd3);
    $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday)  if($pubyear =~ /[0-9]+/);
 }
 elsif($sentdate and ($cktype = "S" or $holdyear !~ /[0-9]{4}/) ) {
	$cktype = 'S';
    if($suggestAcctnum eq '3491') {
    	  ($pubyear,$pubmonth,$pubday) = &get_7daysago;
    }
    else {
        $hold_ckline = $chkline;
        $chkline = $sentdate;
        &chk_month_date("","",$chkline);
        $chkline = $hold_ckline;
        $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
    }	
 }
 elsif($holdyear !~ /[0-9]{4}/) {
 	 $cktype = 'H';
     ($pubyear,$pubmonth,$pubday) = &get_7daysago;
     $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
 }
 else {
	$pubdate = &get_nowdate;
	$lastmoth = &get_30daysago;
 }

 return($pubdate);
}

sub obsolete_was_in_above {
	 @ckOrder = split(//,$ckOrder);

	 foreach $cktype (@ckOrder) {
	#in a URL   
	   if($cktype eq 'L' and ($pubyear !~ /[0-9]{4}/ or $pubmonth !~ /[0-9]{2}/)) {
	      &chk_link_date;
	      &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/); 
	   }

	#separated by slashes, dashes, or other 
	   elsif($cktype eq 'F' and
	       ($chkline =~ /([0-9]{1,4})$slash[0-9]{1,4})$slash([0-9]{1,4})/ or
	        $chkline =~ /([0-9]{1,4})$dash([0-9]{1,4})$dash($[0-9]{1,4})/  ) ) 
	   {	
	     ($pubyear,$pubmonth,$pubday) = &chk_formatted_date;

	     $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday)  if($pubyear =~ /[0-9]+/);
	   }

	#alpha month 
	   elsif($cktype eq 'M' and $chkline =~ /($chkmonths)/ 
	       and ($pubyear !~ /[0-9]{4}/ or $pubmonth !~ /[0-9]{2}/)) {
		  $pubmonth = $1;
		  if($chkline =~ /($chkyear)/) {
		    $pubyear = $1;
	        $pubday = &chk_month_date($pubmonth,$pubyear,$chkline);
	        $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
	      }
	   }
	#4-digit year   
	   elsif($cktype eq 'Y' and $chkline =~ /($chkyear)/ and ($pubdate = "0000-00-00" or !$pubdate)) {
		   $pubyear = $1;
	       &chk_year_date;
	       $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
	   }

	# sentdate

	   elsif($cktype eq 'S' and $sentdate =~ /[A-Za-z0-9]/ and $holdyear !~ /[0-9]{4}/) {
	       if($suggestAcctnum eq '3491') {
	       	  ($pubyear,$pubmonth,$pubday) = &get_7daysago;
	       }
	       else {
	##       print " sent-$sentdate H-$holdyear";
	           $hold_ckline = $chkline;
	           $chkline = $sentdate;
	           &chk_month_date("","",$chkline);
	           $chkline = $hold_ckline;
	           $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
	      }
	   }

	# today less 7 days
	   elsif($cktype eq 'N' and $holdyear !~ /[0-9]{4}/ ) {
	     ($pubyear,$pubmonth,$pubday) = &get_7daysago;
	     $pubdate = &do_yyyymmdd($pubyear,$pubmonth,$pubday) if($pubyear =~ /[0-9]+/);
	   }
	#year held from one of the above methods   
	   elsif($cktype eq 'H' and $holdyear =~ /[0-9]{4}/ ) {
	  	 $pubyear  = $holdyear;
	  	 $pubmonth = $holdmonth;
	   }
	   else {
		$pubdate = &get_nowdate;
	   }
	   last unless(!$pubdate or $pubdate =~ /0000-00-00/);	
	 } ##end FOREACH
}


sub chk_month_date
{
  my($pubmonth,$pubyear,$chkline) = @_;
  my $pubday = "";
  if($chkline =~ /([0-9]{1,2}).?[A-Za-z]{3,10}.?[0-9]{1,4}/) {
   	 $pubday = $1;
  }
  elsif($chkline =~ /[A-Za-z]{3,10}.?([0-9]{1,2})/) {
      $pubday = $1;	
  }
  return($pubday);
}
  
##00820
  
sub chk_formatted_date
{            
	my($ymd1,$ymd2,$ymd3) = @_;   
	my $dDateformat = "";
	my($pubyear,$pubmonth,$pubday);  
               
    $dDateformat = 'ymd' if($ymd1 =~ /^[0-9]{4}$/);
    if($ymd3 =~ /[0-9]{4}/) {
	    $dDateformat = 'dmy';
    }
    if($ymd1 =~ /[A-Za-z]/ or 
         ($ymd2 =~ /../ and $ymd2 !~ /$nums_to12/) ) { # suppose month > 12
             $dDateformat = 'mdy';
    }
    $dDateformat = 'mdy' if($dDateformat !~ /ymd|dmy/);
        
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
	return($pubyear,$pubmonth,$pubday);
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


sub do_yyyymmdd
{
  my($pubyear,$pubmonth,$pubday) = @_;
  my $pubdd = "00";
  my $pubmm = "00";
  my $pubyyy = "0000";
  $pubyear  =~ s/\D//g;
  $pubyear = &Y2K($pubyear) if($pubyear =~ /^[0-9]{2}$/); 
  if($pubyear =~ /[0-9]{4}/) {
	  $pubyyyy = $pubyear;
	  if($pubmonth =~ /[A-Za-z]/) {
         $pubmm = &get_pubmm($pubmonth);
      }
      else {
	     $pubmm = $pubmonth;
      }
      $pubmm = &ck_pubmm($pubmm);    
      $pubdd = &ck_pubdd($pubday,$pubmm) if($pubmm =~ /^[0-9]{2}$/);
  }
 
  if($ckOrder =~ /LMFY/ and $pubyear =~ /[0-9]{4}/ and $holdyear !~ /^[0-9]{4}$/ ) {
     $holdyear  = $pubyear;
     $holdmonth = $pubmmm;
  }
  return("$pubyyyy-$pubmm-$pubdd");
}

sub Y2K 
{
  my $pubyear = $_[0];
  my @yr_digits;
  
  $pubyear =~ s/'//;
  @yr_digits = split(//, $pubyear);
  if(@yr_digits[0] =~ /[0-3]/) {
     $pubyear = "20$pubyear";
  }
  else {
     $pubyear = "19$pubyear";
  }
  
  $pubyear = "0000" if($pubyear !~ /^[0-9]{4}$/);
  return($pubyear);
}
     
## 00830

sub get_pubmm
{
  my($pubmonth) = $_[0];
  my $short = lc(substr($pubmonth,0,3));
  my $pubmm = $rshMonths{$short};
  return($pubmm);
}

sub ck_pubmm
{
 my $pubmonth = $_[0];
 $pubmonth =~ s/[^0-9]//g;
 $pubmonth = "0$pubmonth" if($pubmonth !~ /[0-9]{2,}/);
 if($pubmonth =~ /01|02|03|04|05|06|07|08|09|10|11|12/)  
 { }
 else {
   $pubmonth = "00";
 }
 return($pubmonth);
}


sub ck_pubdd
{
 my($pubday,$pubmm) = @_;
 $pubday =~ s/\D//g;  
 $pubday = "0$pubday" if($pubday =~ /^[0-9]$/);
 if($pubday =~ /[1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29]/) {}
 elsif( ($pubday =~ /30/ and $pubmm !~ /02/ ) or
    ($pubday =~ /31/ and $pubmm =~ /[01|03|05|07|08|10|12]/) )
      {}
 else {
   $pubday = "00";
 }

 return($pubday);
}


sub get_7daysago
  { 	 
   $addsecs  = (7 * 3600 * 24);
   $sysdt = &calc_date('sys',$addsecs,'-');
   $pubyear  = $sysyear;
   $pubmonth = $sysmm;
   $pubday   = $sysdd;
   return($pubyear,$pubmonth,$pubday);
}

sub get_3monthsago
{
   $diffsecs  = (90 * 3600 * 24);
   $sysdt = &calc_date('3mo',$diffsecs,'-');
   $yyyy  = $sysyear;
   $mm    = $sysmm;
   $dd    = $sysdd;
   return("$yyyy$mm$dd");
}

sub get_last_month
{
 my $pubdate  = $_[0];
 my($yyyy,$mm,$dd) = split(/-/,$pubdate,3);
 if($mm eq '01') {
	$mm = '12';
	$yyyy = $yyyy - $yyyy;
 }
 else {
	$mm = $mm -1;
 }
 return("$yyyy-$mm-$dd");
}

## calculates nowyyyy nowmm nowdd

sub get_nowdate
{
 $sysdt = &calc_date('now',0,'+');
($nowyyyy,$nowmm,$nowdd,$nowhh,$nowmn,$nowss) = split(/-/,$nowdate,6);
 $todaydate = "$nowyyyy-$nowmm-$nowdd";
 return($todaydate);
}


sub get_futuredate
{
 $dateadd  = $_[0];
 $dateadd = 0 if($dateadd !~ /[0-9]/);

 $addsecs  = ($dateadd * 3600 * 24);
 $sysdt = &calc_date('future',$addsecs,'+');
 $future = "$sysyear-$sysmm-$sysdd-$syshh-$sysmin-$syssec";
 $addsecs  = 0;
}


## calculates date and time

sub calc_date
{
   my($datetype,$diff,$addsub) = @_;
   my $timesecs = time;
   my @datetime = localtime(time);
   if($addsub eq '-' and $diff > 0) {
      $timesecs = $timesecs - $diff;
      @datetime = localtime($timesecs);
   }
   elsif($addsub eq '+' and $diff > 0) {
      $timesecs = $timesecs + $diff;
      @datetime = localtime($timesecs);
   }
   $sysdatetm   = &datetime_prep('yyyymmddhhmmss',@datetime);
   $sysdatetime = &datetime_prep('yyyy-mm-dd-hh-mm-ss',@datetime);
   my $sysdate  = &datetime_prep('yyyy-mm-dd',@datetime); #not the same as the global $sysdate
   ($sysyear,$sysmm,$sysdd,$syshh,$sysmin,$syssec) = split(/-/,$sysdatetime);
   if($datetype =~ /now/) {
      $nowdate = $sysdate;
   }
   elsif($datetype =~ /future/) {
      $future = $sysdate;
   }
   return($sysdate);
}

## 300

sub datetime_prep
{   
 local($dateformat,$syssec,$sysmin,$syshh,$sysday,$sysmonth,$sysyear) = @_;
  while($sysmonth > 11) {
     $sysmonth = $sysmonth-12;
     $sysyear  = $sysyear+1;
   }
  $sysmonth=$sysmonth+1;
  if($sysyear < 50) {
    $sysyear=$sysyear+2000;
   }
 else {
    $sysyear=$sysyear+1900;
  }
 local($sysmm)  = "$sysmonth";
 local($sysmm)  = "0$sysmm" if($sysmm < 10);
 local($sysdd)  = "$sysday";
 local($sysdd)  = "0$sysdd" if($sysdd < 10) ;
 local($syshh)  = "$syshour";
 local($syshh)  = "0$syshh" if($syshh < 10) ;
 local($sysmin) = $sysmin+1;
 local($sysmin) = "0$sysmin" if($sysmin < 10) ;
 local($syssec) = "0$syssec" if($syssec < 10) ;
 
 return "$sysyear-$sysmm-$sysdd" 
     if($dateformat =~ /yyyy-mm-dd/);
 return "$sysyear$sysmm$sysdd$syshh$sysmin$syssec" 
     if($dateformat =~ /yyyymmddhhmmss/);
 return "$sysyear-$sysmm-$sysdd-$syshh-$sysmin-$syssec" 
     if($dateformat =~ /yyyy-mm-dd-hh-mm-ss/);
}


##            find date time stamp from arg - yyyy-mm-dd
sub TimeInSecs
{
  local($year,$month,$day)  = split(/-/,$_[0],3);

  if(($month > 12) || ($day > 31))  {
    print"Invalid date.  Use yyyy.mm.dd\n";
    return 1;
  }
  local($ypast) = $year - 1970;
  local($leaps) = $ypast / 4;
  local($yleap) = $year / 4;
  local($whole,$not) = split(/\./,$leaps,2);
  local($ywhole,$ynot) = split(/\./,$yleap,2);
  local($dpast) = $day;
  $dpast = $dpast + 31 if($month > 1);
  $dpast = $dpast + 28 if($month > 2);
  $dpast = $dpast + 1 if(($month > 2) && ($ynot));
  $dpast = $dpast + 31 if($month > 3);
  $dpast = $dpast + 30 if($month > 4);
  $dpast = $dpast + 31 if($month > 5);
  $dpast = $dpast + 30 if($month > 6);
  $dpast = $dpast + 31 if($month > 7);
  $dpast = $dpast + 31 if($month > 8);
  $dpast = $dpast + 30 if($month > 9);
  $dpast = $dpast + 31 if($month > 10);
  $dpast = $dpast + 30 if($month > 11);
  $dpast = $dpast + $whole + ($ypast * 365);
  local($past)  = $dpast * 3600 * 24;
  $past = $past - (18 * 3600);
  
  return $past;
}


1;