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
  my $dbh = DBI->connect ("DBI:mysql:$CONFIG{db_name}:$CONFIG{db_host}",
         $CONFIG{db_user},
         $CONFIG{db_password})
      or die "Connection Error: $DBI::errstr\n";
  return($dbh);
}

sub OpenDB {
  use DBI;
  $dbh = DBI->connect("DBI:mysql:$CONFIG{db_name}:$CONFIG{db_host}", $CONFIG{db_user}, $CONFIG{db_password});
  $mysqlopen = 1;
  return;
}

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