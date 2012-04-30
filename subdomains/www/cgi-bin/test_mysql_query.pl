#!/usr/bin/perl --

require './bootstrap.pl';

push @INC, $SVRinfo{app_dir}

print "Content-type:"."text/"."html\n\n";

# TODO This file doesn't exist in the Git repository
require('DBsettings.pl');
@DB = &init_db_settings;

require ('settings.pl');   
@DB = &set_config(@DB);

###  anything after this is for testing

require('database.pl');

$dbh = &db_connect() if(!$dbh);

#$sql = "SELECT * from contributors";
$sql = "SELECT i.docid, i.lifonum, i.stratus, i.sortfield FROM indexes i, sectsubs s WHERE i.sectsubid = s.sectsubid AND s.sectsub = 'NewsDigest_NewsItem' ORDER BY i.lifonum LIMIT 30";


&print_query_results($dbh,$sql);

exit;