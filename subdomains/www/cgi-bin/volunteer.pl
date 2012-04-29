#!/usr/bin/perl --

#  volunteer.pl    May 7, 2010

## Added push @INC for Karens Mac Server

push @INC, "/home/popaware/public_html/cgi-bin/";
push @INC, "/home/httpd/vhosts/overpopulation.org/cgi-bin/cgiwrap/popaware";
push @INC, "/home/vwww/overpopulation.org/cgi-bin/cgiwrap/popaware";
push @INC, "/www/overpopulation.org/subdomains/www/cgi-bin";  ## telana
push @INC, "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/www/cgi-bin"; ## Karen's Mac
 
print "Content-type:"."text/"."html\n\n";
 
require 'common.pl';
&get_site_info;
require 'contributor.pl';

if($ENV{QUERY_STRING})  {
  $cmd = $ENV{QUERY_STRING};
}
else {
  &parse_form;
  $cmd = $FORM{cmd};
}

if($cmd eq "start_acctapp") {
   &verify_new_acct;
}

elsif($cmd eq "write_acctapp") { 
  &write_acctapp;
}

exit;
