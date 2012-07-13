#!/usr/bin/perl --

## May 19, 2011

## 0. Contributors and subscribers are already on the DB - leave them
## 1. sectsubs - a. import only once from old sections.html (older format)
##    b. make all changes to the DB, not to the flatfile
##    c. fix sections.pl to accept from the new format
##    d. do export before doing indexes so the foreign key will be correct
##    e. thereafter, import will only be used if reloading DB from a flatfile backup

require './bootstrap.pl';

print "Content-type: text/html\n\n";

$query_string = $ENV{QUERY_STRING};


($cmd,$table)  = split(/%/,$query_string,2);

require 'database.pl';
require 'sectsubs.pl';
require 'indexes.pl';
require 'regions.pl';
require 'sources.pl';

# $sectionctrl   = "$controlpath/sections.html";
# $contributors  = "$controlpath/contributors.html";
# $sources       = "$controlpath/sources.html";
# $regions       = "$controlpath/regions.html";

$line = "";

if($cmd =~ /list|man/) {
   &list_functions("list");  # in dbtables.pl
   return;
}

if($table =~ /sectsubs/) {
    &import_sectsubs if($cmd =~ /import/);   # in sectsubs.pl
    &export_sectsubs if($cmd =~ /export/);
}
elsif($table =~ /indexes/) {
    &import_indexes if($cmd =~ /import/);   # in indexes.pl
    &import_exported_indexes if($cmd =~ /import_exported/);
    &export_indexes if($cmd =~ /export/);
    &restore_flatfile_indexes if($cmd =~ /restore_flatfile/);
    &restore_indexes if($cmd =~ /restore/);
#    &add_sortfields_to_indexes if($cmd =~ /add_sortfields/);
}
elsif($table =~ /regions/) {
    &import_regions if($cmd =~ /import/); # in regions.pl
#    &export_regions if($cmd =~ /export/);
}
elsif($table =~ /sources/) {
    &import_sources if($cmd =~ /import/);   # in sources.pl
#    &export_regions if($cmd =~ /export/);
}
else {
	print "Incorrect table<br>\n" if($cmd !~ /list/);
}
exit 0;
