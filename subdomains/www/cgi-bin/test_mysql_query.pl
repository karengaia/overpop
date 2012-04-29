#!/usr/bin/perl --

## put this in common.pl -- skip the push @INC

  push @INC, "/Users/karenpitts/Sites/web/www/overpopulation.org/";
  push @INC, "/www/overpopulation.org/";  ## telana

print "Content-type:"."text/"."html\n\n";

require('DBsettings.pl');
@DB = &init_db_settings;

require ('settings.pl');   
@DB = &set_config(@DB);
	
push @INC, "/Users/karenpitts/Sites/web/www/overpopulation.org/cgi-bin/";
push @INC, "/www/overpopulation.org/subdomains/www/cgi-bin/cgiwrap/popaware/";  ## telana

###  anything after this is for testing

require('database.pl');

$dbh = &db_connect() if(!$dbh);

#$sql = "SELECT * from contributors";
$sql = "SELECT i.docid, i.lifonum, i.stratus, i.sortfield FROM indexes i, sectsubs s WHERE i.sectsubid = s.sectsubid AND s.sectsub = 'NewsDigest_NewsItem' ORDER BY i.lifonum LIMIT 30";


&print_query_results($dbh,$sql);

exit;