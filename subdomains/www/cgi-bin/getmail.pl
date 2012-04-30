#!/usr/bin/perl

### testing:   cat ippf.email |./getmail.pl

## Jul 1, 2011 - pulled out everything except getting the email; moved everything else to sepmail.pl; no use for parsemail.pl
##               Writes to overpoopulation.org/popnews_bkp, where it is read by sepmail.pl

## Feb 22, 2011 - Reduced functionality, moving most into parsemail.pl, due to large file processing resulting in NO results.
##                Now reading one line at a time. Hope this works on ippf

# 2011 Feb 16 - enlarged functionality: found date, subject, handle; did weird character conversion to ascii;
#              chopped off excess at top and bottom; added sepmail functionality
# 2010 July 22 - buffer too small; broke into lines while reading in

require './bootstrap.pl';

$pophome       = $SVRinfo{home};
$publicdir     = $SVRinfo{public};

# $bkppath  = "$pophome/popnews_bkp";
$inboxpath  = "$pophome/popnews_inbox";

$filename = &calc_date;             #sysdatetm
$inboxfilepath = "$inboxpath/$filename.email";
print "file $filename $inboxfilepath\n";
$line = "";

open(EMAILBKP, ">>$inboxfilepath") or die("Failed to open inbox");  #save entire email in bkp

while (<STDIN>) 
{          #      first pass
	$line = $_;
	exit(0) if($line =~ /^quit$/);
	
	chomp($line);
print "**$line\n";
	print EMAILBKP "$line\n";
}
close(EMAILBKP);
exit;

sub calc_date
{
   $timesecs = time;
   @current  = localtime($timesecs);
   $sysmonth = $current[4];
   $sysyear  = $current[5];
   $sysday   = $current[3];
   $syshour  = $current[2];
   $sysmin   = $current[1];
   $syssec   = $current[0];

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

  $sysmm  = "$sysmonth";
  $sysmm  = "0$sysmm" if($sysmm < 10);
  $sysdd  = "$sysday";
  $sysdd  = "0$sysdd" if($sysdd < 10) ;
  $syshh  = "$syshour";
  $syshh  = "0$syshh" if($syshh < 10) ;
  $sysmin = $sysmin+1;
  $sysmin = "0$sysmin" if($sysmin < 10) ;
  $syssec = "0$syssec" if($syssec < 10) ;

  $sysdatetm = "$sysyear-$sysmm-$sysdd-$syshh$sysmin$syssec";
  return($sysdatetm);
}

1;
