#!/usr/bin/perl --

#  volunteer.pl    May 7, 2010

## Added push @INC for Karens Mac Server

print "Content-type:"."text/"."html\n\n";

require './bootstrap.pl'
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
