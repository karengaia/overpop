#!/usr/bin/perl --

use Net::FTP;

#my $host="ftp.telavant.com";
#my $directory="www/overpopulation.org";
#my $user = "overpop";
#my $pswd = "j0l02EMX";
my $host="motherlode.sierraclub.org";
my $directory="chapters/motherlode/population";
my $user = "www\chapml12";
my $pswd = "yedrel8";

my $ftp = Net::FTP->new("$host", Debug => 0);
die "Error connecting: $!" unless $ftp;

$ftp=Net::FTP->new("$host", Timeout => 600) or $newerr=1;
  push @ERRORS, "Can't ftp to $host: $!\n" if $newerr;
  myerr() if $newerr;
print "Connected\n";

$ftp->login($user,$pswd) or $newerr=1;
print "Logging in:<br>";
  push @ERRORS, "Can't login to $host: $!\n" if $newerr;
  $ftp->quit if $newerr;
  myerr() if $newerr; 
print "Logged in\n";

$ftp->cwd($directory) or $newerr=1; 
  push @ERRORS, "Can't cd  $!\n" if $newerr;
  myerr() if $newerr;
  $ftp->quit if $newerr;

@files=$ftp->dir or $newerr=1;
  push @ERRORS, "Can't get file list $!\n" if $newerr;
  myerr() if $newerr;
print "Got  file list\n";   
foreach(@files) {
  print "$_\n";
  }
$ftp->quit;


sub myerr {
  print "Error: \n";
  print @ERRORS;
  exit 0;
}
