#!/usr/bin/perl  --

## for select statements 
sub print_query_results
{
 local($dbh,$sql_query,@colheaders) = @_;   # get arguments: sql and array of column names
 
 $dbh = &db_connect if(!$dbh);
  
 my $sth = $dbh->prepare_cached($sql_query)
     or die "Error in preparing the query; must quit now: $dbh->errstr\n";

 $sth->execute( )
     or die "Error executing query; must quit now: $sth->errstr\n";
 
 if ($sth->rows == 0) {
    print "No matching rows found.<br>\n\n";
 }
 else {
	 $number = $sth->rows;
     print "Query results:<br>\n================================================<br>\n";
     print"<table>\n";
     if(@colheaders) {
         print"<tr>\n";
         foreach $colheader (@colheaders) {  # print column headers
            print "<td>$colheader</td>\n";
         }
         print"</tr>\n";
      }
      while (my @row = $sth->fetchrow_array()) { # print data retrieved         
         print"<tr>\n";
#         @row = $sth->fetchrow_array( );
         foreach $field (@row) {
           print "<td>$field</td>\n";
         }
         print"</tr>\n";
      }
      print"</table>\n";
 }
    
 warn "Problem in retrieving results", $sth->errstr( ), "\n"
        if $sth->err( );
 
 $sth->finish();

# $dbh->disconnect or warn "Disconnection error: $DBI::errstr\n";
}

sub db_connect {
use DBI;
use DBD::mysql;

if(-f "mactest.txt") {
	$hostname = "localhost";
#	$port     = ":3000";
	#$username = "root";
	$pswd     = "";
	$database = "overpop";
	#$dbdriver = "mysql";
	$user = "root";
	$platform = "mysql";
}
else {
	$host = "db.telana.com";
	$user = "overpop";
	$pswd     = "";
	$database = "overpop";
	$platform = "mysql";
}
  my $dbh = DBI->connect ("DBI:$platform:$database:$host", 
         $user,
         $pswd)
      or die "Connection Error: $DBI::errstr\n";
  return($dbh);
}

sub OpenDB {
use DBI;
$dbh = DBI->connect("DBI:mysql:$mysql_db:$mysql_host","$mysql_u","$mysql_p");
$mysqlopen = 1;
return; }

sub CloseDB {
$dbh->disconnect();
$mysqlclosed = 1;
return; }

sub DoSQL {
if (!$mysqlopen) { &OpenDB; }
$dbh->do("$_[0]");
return; }

sub PrepareSQL {
if (!$mysqlopen) { &OpenDB; }
$result = $dbh->prepare("$_[0]");
$result->execute();
return; }


1;