#!/usr/bin/perl --

require './bootstrap.pl';
require 'errors.pl';
require 'display.pl';
require 'template_ctrl.pl';  # merges data with template
require 'database.pl';
require 'dbtables.pl';
require 'db_controlfiles.pl';
require 'common.pl';
require 'sections.pl';
require 'sources.pl';
require 'regions.pl';
require 'controlfiles.pl';  #includes acronyms
require 'contributor.pl';
require 'email2docitem.pl';   ## require 'sepmail.pl'; 
require 'docitem.pl';
require 'smartdata.pl';
require 'date.pl';

print "Content-type:"."text/"."html\n\n";

&init_dateparse_varibles;

$maybe_headline = 'Y';

$msgline = "2011: A Year of Weather Extremes, with More to Come 2011-10";
print "ts35 chkyear found<br>\n" if($msgline =~ /$chkmonth/);
print "ts35 format date found<br>\n" 
  if($msgline =~ /[0-9]{1,4}[\/-][0-9]{1,4}[\/-][0-9]{1,4}/);
#	or $msgline =~ /[0-9]{1,4}$dash[0-9]{1,4}$dash$[0-9]{1,4}/ );

$maybe_headline = 'N' if($msgline =~ /\B[http|https]:\/\/.*\B/ 
	  or ($msgline =~ /[$chkyear]/ and $msgline =~ /$chkmonth/)
	  or $msgline =~ /[0-9]{1,4}$slash[0-9]{1,4}$slash[0-9]{1,4}/ 
	  or $msgline =~ /[0-9]{1,4}$dash[0-9]{1,4}$dash$[0-9]{1,4}/ );

print "ts37 ..maybe_headline $maybe_headline ml- $msgline<br>\n";

exit;

$msgline_anydate = "January 2, 2012";
my $pubdate = &refine_date;
print "test1 msgline_anydate $msgline_anydate ..pubdate $pubdate<br><br>\n";

$msgline_anydate = "25 January 2012";
my $pubdate = &refine_date;
print "test2 ..msgline_anydate $msgline_anydate pubdate $pubdate<br><br>\n";

$msgline_anydate = "Published 3 Jan 2012";
my $pubdate = &refine_date;
print "test3  ..msgline_anydate $msgline_anydate pubdate $pubdate<br><br>\n";

$msgline_anydate = "2012-5-10";
my $pubdate = &refine_date;
print "test4  ..msgline_anydate $msgline_anydate pubdate $pubdate<br><br>\n";

$msgline_anydate = "Date: 5/12/2010";
my $pubdate = &refine_date;
print "test5  ..msgline_anydate $msgline_anydate pubdate $pubdate<br><br>\n";

$msgline_link = "http:\/\/forum.parallels\.com\/showthread/2012/12/05/<br>\n";
my $pubdate = &refine_date;
print "test6  ..msgline_link $msgline_link pubdate $pubdate<br><br>\n";

$msgline_link = "http:\/\/forum.parallels\.com\/showthread/2012-Dec-15/<br>\n";
my $pubdate = &refine_date;
print "test7  ..msgline_link $msgline_link pubdate $pubdate<br><br>\n";



print "END<br>\n";
exit;

