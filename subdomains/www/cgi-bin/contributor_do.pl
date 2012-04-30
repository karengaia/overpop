#!/usr/bin/perl --

# July 18, 2009
#        contributor_do.pl

require './bootstrap.pl';
require 'contributor.pl';

if($parm =~ /[A-Za-z0-9]/) {
  $cmd  = $parm;
}
else {
  print "Content-type:"."text/"."html\n\n";
  
  if($ENV{QUERY_STRING})  {
    $cmd = $ENV{QUERY_STRING};
  }
  else {
    &parse_form;
    $cmd = $FORM{cmd};
  }
}

if($cmd eq "start_acctapp") {
   &verify_new_acct;
}

elsif($cmd eq "write_acctapp") { 
  &write_acctapp;
}

exit;