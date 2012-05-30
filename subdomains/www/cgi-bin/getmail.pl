#!/usr/bin/perl

### testing:   cat ippf.email |./getmail.pl

## May 29  -- reversed to sip
## May 28, 2012 - changed from a sip to a slurp to accomodate CMCC
## Jul 1, 2011 - pulled out everything except getting the email; moved everything else to sepmail.pl; no use for parsemail.pl
##               Writes to overpoopulation.org/popnews_bkp, where it is read by sepmail.pl

## Feb 22, 2011 - Reduced functionality, moving most into parsemail.pl, due to large file processing resulting in NO results.
##                Now reading one line at a time. Hope this works on ippf

# 2011 Feb 16 - enlarged functionality: found date, subject, handle; did weird character conversion to ascii;
#              chopped off excess at top and bottom; added sepmail functionality
# 2010 July 22 - buffer too small; broke into lines while reading in

my $filename = &calc_date;             #sysdatetm
my $inboxfilepath = "";

if(-f "../../karenpittsMac.yes") { #Karens Mac
  print "Mac server\n";
  $inboxfilepath       = "/Users/karenpitts/Sites/web/www/overpopulation.org/popnews_inbox/$filename.email";
}
else {  #telavant
  $inboxfilepath       = "/www/overpopulation.org/popnews_inbox/$filename.email";
}

my $line = "";

open(EMAILBKP, ">>$inboxfilepath") or die();  #save entire email in bkp

#   File Slurping
# my $holdTerminator = $/;
# undef $/;
# my $buf = <STDIN>;
# $/ = $holdTerminator;
# my @lines = split /$holdTerminator/, $buf;
# foreach $line (@lines) {

 while (<STDIN>) 
 {          #      first pass
	$line = $_;
    exit(0) if($line =~ /^quit$/);	
 	chomp($line);
	print EMAILBKP "$line\n";
 }
close(EMAILBKP);
exit;

sub calc_date
{
my   $timesecs = time;
my   @current  = localtime($timesecs);
my   $sysmonth = $current[4];
my   $sysyear  = $current[5];
my   $sysday   = $current[3];
my   $syshour  = $current[2];
my   $sysmin   = $current[1];
my   $syssec   = $current[0];

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

my  $sysmm  = "$sysmonth";
  $sysmm  = "0$sysmm" if($sysmm < 10);
my  $sysdd  = "$sysday";
  $sysdd  = "0$sysdd" if($sysdd < 10) ;
my  $syshh  = "$syshour";
  $syshh  = "0$syshh" if($syshh < 10) ;
  $sysmin = $sysmin+1;
  $sysmin = "0$sysmin" if($sysmin < 10) ;
  $syssec = "0$syssec" if($syssec < 10) ;

#  $sysdatetm = "$sysyear-$sysmm-$sysdd-$syshh$sysmin$syssec";
  return("$sysyear-$sysmm-$sysdd-$syshh$sysmin$syssec");
}



1;

