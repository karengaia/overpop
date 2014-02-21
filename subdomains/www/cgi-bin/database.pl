#!/usr/bin/perl  --

## for select statements 

sub get_print_query_results  #Replace sub below with this
{
 my ($print_it,$DBH,$sql_query,@colheaders) = @_;   # get arguments: sql and array of column names
 
 $DBH = &db_connect if(!$DBH);
  
 my $sth = $DBH->prepare_cached($sql_query)
     or die "Error in preparing the query; must quit now: $DBH->errstr db12\n";

 $sth->execute( )
     or die "Error executing query; must quit now: $sth->errstr  db15\n";
 
 if ($sth->rows == 0) {
    if($print_it) {print "No matching rows found.<br>\n\n";}
    else {return(0);}
 }
 else {
	unless($print_it) {
		$number = $sth->rows;
		return($number,$sth);
	}

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

	  warn "Problem in retrieving results", $sth->errstr( ), "\n" if($sth->err( ));
	  $sth->finish();
 }
}

sub print_query_results
{
 local($DBH,$sql_query,@colheaders) = @_;   # get arguments: sql and array of column names
 
 $DBH = &db_connect if(!$DBH);
  
 my $sth = $DBH->prepare_cached($sql_query)
     or die "Error in preparing the query; must quit now: $DBH->errstr\n";

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
}

sub db_connect {
  use DBI;
  use DBD::mysql;
  my $DBH = DBI->connect ("DBI:mysql:$CONFIG{db_name}:$CONFIG{db_host}",
         $CONFIG{db_user},
         $CONFIG{db_password})
      or die "Connection Error: $DBI::errstr\n";
 return($DBH);
}

sub OpenDB {
  use DBI;
  $DBH = DBI->connect("DBI:mysql:$CONFIG{db_name}:$CONFIG{db_host}", $CONFIG{db_user}, $CONFIG{db_password});
  $mysqlopen = 1;
  return;
}

sub CloseDB {
$DBH->disconnect();
$mysqlclosed = 1;
return; }

sub DB_get_row
{
 my($sth,$arg) = @_;
 $sth_doc->execute($arg);
 $row = $sth->fetchrow_array();
 $sth->finish();
 return($row)
}

sub DB_insertUpdate
{
 my(@rowarray,$sth,$sql) = @_;
 my $sth = $DBH->prepare($sql) unless($sth);
 $sth->execute(@rowarray);
 return($sth);
}


sub DoSQL {
if (!$mysqlopen) { &OpenDB; }
$DBH->do("$_[0]");
return; }

sub PrepareSQL {
if (!$mysqlopen) { &OpenDB; }
$result = $DBH->prepare("$_[0]");
$result->execute();
return; }


1;