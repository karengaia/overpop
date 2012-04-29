#!/usr/bin/perl --

# misc_dbtables.pl    - renamed from dbtables.pl
# Contains code to parse the miscellaneous tables: acronyms, switches_codes, counters, codes, projects

## called by article.pl and parsedata.pl and docitem.pl??

## 2011 Jan - Separated out Sources.pl and Regions.pl
## 2010 Jul    - Merged in changes neglected from May 7th change
## 2010 May 7 -- Check for Mac server (testing) and chmod to 777

# Hit counter all in SQL  an example:
#create table ipstat(ip int unsigned not null primary key,
#                          hits int unsigned not null,
#                          last_hit timestamp);

#insert into ipstat values(inet_aton('192.168.0.1'),1,now())
#                       on duplicate key update hits=hits+1;


sub list_functions {
	my $prt_where = $_[0];
	my $msg = "<br>&nbsp; &nbsp;<big><b>Table Maintenance - dbtables_ctrl.pl Functions - - - - - - - - - - - - -  </b></big><br>\n";
	$msg = $msg . "<table class=\"shaded\"><tr><td>&nbsp;</td><td><b>Table</b></td><td><b>Cmd</b></td><td><b>From</b></td><td><b>To</b></td><td><b>More</b></td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?import%sectsubs\"><b>run</b></a>";
	$msg = $msg . "<td>sectsubs</td><td>import</td><td>new style flatfile sections.html</td><td> to DB sectsubs table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/sectsubs.pl?export%sectsubs\"><b>run</b></a>";
	$msg = $msg . "<td>sectsubs</td><td>export</td><td>DB sectsubs table</td><td>new style flatfile sections.html</td><td></td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?import%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>import</td><td>autsosubmit/sections/sectsub.idx</td><td>DB indexes (TRUNCATE 1st!!) </td><td>Uses sections.html as controller</td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?export%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>export</td><td>DB indexes</td><td>export flatfile: autsosubmit/sections_exp/sectsub.idx</td><td>&nbsp;</td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?restore_flatfile%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>restore_flatfile</td><td>exported autsosubmit/sections_exp/sectsub.idx</td><td>normal autsosubmit/sections/sectsub.idx</td><td> Will run 'export' first</td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?import_exported%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>import_exported</td><td>exported flatfiles</td><td>DB indexes</td></tr>\n";	
	$msg = $msg . "<tr><td colspan=\"6\"><b>- - -Indexes will be run with flatfiles and DB in parallel, maintaining both. DB indexes will eventually take over, with flatfiles as backup</b></td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?import%regions\"><b>run</b></a>";
	$msg = $msg . "<td>regions</td><td>import</td><td>flatfile regions.html</td><td> to DB regions table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/dbtables_ctrl.pl?import%sources\"><b>run</b></a>";
	$msg = $msg . "<td>sources</td><td>import</td><td>flatfile sources.html</td><td> to DB sources table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
	$msg = $msg . "</table></br>\n";
	if($prt_where =~ /list/) {
		print "$msg";
	}
	else {
		print MIDTEMPL "$msg";
	}
}

sub DB_get_switches_counts
{
	my $name;
	my $switch_count = 0;
	$DB_indexes = 0; # switch: update indexes if > 0
	$DB_doclist = 0; # switch: view a list of articles using DB if > 0
    $DB_indexes = 0;
	$DB_doclist = 0;
	$DB_regions = 0;
	$DB_sources = 0;
	$DB_sectsubs = 0;
	$DB_others  = 0;	
	$dbh = &db_connect() or die "DB failed connect";
	print "DB connection failed<br>\n" if(!$dbh);
	my $switch_sth = $dbh->prepare("SELECT name, switch_count FROM switches_counts") or die "DB Error preparing switch_count query";
	if($switch_sth) {
	    $switch_sth->execute() or die "Couldn't execute switch_count table select statement: ".$switch_sth->errstr;
	    if ($switch_sth->rows == 0) {
	    }
	    else {
		   while ( ($name,$switch_count) = $switch_sth->fetchrow_array() )  {
		        $DB_indexes = $switch_count if($name =~ /DB_indexes/);
				$DB_doclist = $switch_count if($name =~ /DB_doclist/);
				$DB_regions = $switch_count if($name =~ /DB_regions/);
				$DB_sources = $switch_count if($name =~ /DB_sources/);
				$DB_sectsubs = $switch_count if($name =~ /DB_sectsubs/);
				$DB_others  = $switch_count if($name =~ /DB_others/);  # all other tables
				$gTrace     = $switch_count if($name =~ /Trace/);
		   }
		}
		$switch_sth->finish() or die "DB switches failed finish";
	}
	else {
	   print "Couldn't prepare switch_count table query<br>\n";
	}
}

sub print_db_switches_counts
{
    print "<b>Switches_counts Table</b><br>\n";  
            # in database.pl
    &print_query_results("","SELECT * FROM switches_counts");
}

# #################  ACRONYMS #############

sub create_acronyms {
	$sql = <<ENDACRO;
CREATE TABLE acronyms ( 
	acronym varchar(50) NOT NULL,
	title varchar(200)
	);
ENDACRO
}

sub get_title {
 my $acronym = $_[0];
 my $acr_sql = "SELECT title FROM acronyms WHERE acronym = ?;";
 if(!$dbh) {
    print "No connection ctr33<br>\n";
    return("");
 }
 my $acr_sth = $dbh->prepare($acr_sql) or msgDie("Couldn't prepare statement: ".$acr_sth->errstr);	

 if($acr_sth) {
    $acr_sth->execute($acronym) or msgDie("Couldn't execute acronyms table select statement: ".$acr_sth->errstr);
    if ($acr_sth->rows == 0) {
    }
    else {
	   while ( $title = $acr_sth->fetchrow_array() )  {
                return($title);
	   }
	}
	$acr_sth->finish() or msgDie("DB acronyms failed finish");
 }
 else {
    msgDie("Failed: Couldn't prepare acronyms table query");
 }	
}

sub get_title2
{
 my($chkword) = @_;

 my $acronymfound = 'N';
 my $acr_entry = "";

 foreach $acr_entry (@ACRARRAY) {
    my ($acronym,$title)
	      = split(/\^/,$acr_entry,2);
    if($chkword and $chkword =~ /$acronym/)  { #skip 
	   return($title);
     }
  }
  return("");
}


sub add_acronym
{
  my $acronym = $FORM{"acronym$pgitemcnt"} if($FORM{"acronym$pgitemcnt"});
  my $title   = $FORM{"title$pgitemcnt"}   if($FORM{"title$pgitemcnt"});
  if($acronym and $title) {
    my $acr_add_sql = "INSERT INTO acronyms (acronym,title) VALUES ( ?, ?)";
    my $acr_add_sth = $dbh->prepare($acr_add_sql); 
    $acr_add_sth->execute($acronym,$title);
  }
}

sub prt_acronym_list
{
 my $ac_sql = "SELECT acronym,title FROM acronyms ORDER BY acronym;";
 my $ac_sth = $dbh->prepare($ac_sql) or die("Couldn't prepare statement: ".$ac_sth->errstr);	

 if($ac_sth) {
    $ac_sth->execute() or die "Couldn't execute acronym table select statement: ".$ac_sth->errstr;
    if ($ac_sth->rows == 0) {
    }
    else {
	    while( ($acronym,$title) = $ac_sth->fetchrow_array() ) {
		  print  MIDTEMPL "<option value=\"$acronym^$title\">$acronym</option>\n";
	    }
	}
	$ac_sth->finish() or die "DB acronyms failed finish";
 }
 else {
    print "Couldn't prepare acronyms table query<br>\n";
 }
}

######### END ACRONYMS ##############


sub create_switches_counts
{
	$dbh = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS switches_counts");

$sql = <<ENDSWITCHES;
	CREATE TABLE switches_counts (
		name         varchar(20) not null,
		switch_count integer unsigned default 0,
		description  varchar(70)
		)
ENDSWITCHES

	$sth2 = $dbh->prepare($sql);
	$sth2->execute();
	$sth2->finish();
}


######### COUNTERS ##############

sub create_counters {
	$sql = <<ENDCOUNTERS;
CREATE TABLE counters ( 
	hits integer(20) NOT NULL,
	doccount integer(10) NOT NULL,
	maiduhits integer(20) NOT NULL
	);
# INSERT INTO counters VALUES (0);
ENDCOUNTERS
}

sub get_count
 {
  $count = "";
  open(COUNT, "$countfile");
  while(<COUNT>)
  {
   chomp;
   $count = $_;
  }
  close(COUNT);
 
  open(NEWCOUNT, ">$countfile");
  local($num) = $count+1;
  print(NEWCOUNT"$num\n");
  close(NEWCOUNT);

  $count = &pad_count("$count");
}

sub getAddtoCount ## Gets the Count and adds to it - replaces get_count later
{  
  local($countcode) = $_[0];
  
  local($count) = &getCount($countcode);

  local($num) = $count + 1;
  $count = &padCount6($num) if($countcode =~ /doc/);
  $count = &padCount4($num) if($countcode =~ /popnews/);
     
  &writeCount($countfile,$count);  
  return($count);
}

sub subtractFromCount
{
  local($countcode) = $_[0];
  
  local($count) = &getCount($countcode);

  local($num) = $count - 1;
  $count = &padCount6($num) if($countcode =~ /doc/);
  $count = &padCount4($num) if($countcode =~ /popnews/);
     
  &writeCount($countfile,$count);
  
  return($count);
}

sub getCount
{
  local($countcode) = $_[0];
  local($count);
  if($countcode =~ /doc/) {
    $countfile = $doccountfile;
  }
  elsif($countcode =~ /popnews/) {
    $countfile = $popnews_countfile;
  }

  open(COUNT, "$countfile");
  while(<COUNT>)
  {
   chomp;
   $count = $_;
  }
  close(COUNT);
  return($count);
}

sub writeCount
{
 local($countfile,$count) = @_;
 open(NEWCOUNT, ">$countfile") or printSysErrExit("Could not open $countfile : $!<br>\n");
 print(NEWCOUNT "$count\n");
 close(NEWCOUNT);
}

sub clearPopCount ## clears the popnews count
{
  open(POPCOUNT, ">$popnews_countfile");
  print(POPCOUNT "0000\n");
  close(POPCOUNT);   	
}


sub add_pad_one
{
 $pgItemnbr = $pgItemnbr+1; 
 $pgItemcnt = &pad_count("$pgItemnbr"); 
}
    
sub pad_count
{
 local($count) = $_[0];
 $count =~  s/^0+//;     ## strip leading 0s
 if($count < 10)
  {$count = "000$count"; }
 elsif($count < 100)
  {$count = "00$count";  }
 elsif($count < 1000)
  {$count = "0$count";   }
 return $count;
}

sub padCount4  ## replaces pad_count later
{
  local($count) = $_[0];
  $count =~  s/^0+//;     ## strip leading 0s
  return "000$count" if($count < 10);
  return "00$count" if($count < 100);
  return "0$count" if($count < 1000);
}

sub padCount6
{
  local($count) = $_[0];
  $count =~  s/^0+//;      ## strip leading 0s
  return "00000$count" if($count < 10);
  return "0000$count" if($count < 100);
  return "000$count" if($count < 1000);
  return "00$count" if($count < 10000);
  return "0$count" if($count < 100000);
}


sub strip0s_fromCount
{
  local($count) = $_[0];
  $count =~  s/^0+//;
  return $count;
}

### END COUNTS #####

sub create_codes
{   ## Easier to do this on Telavant interface
	$dbh = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS indexes");

$sql = <<CODES;
CREATE TABLE codes ( codetype varchar(6) not null,  code varchar(2)  not null, description varchar(100) default "", codename varchar(12) default "")
CODES

$sth2 = $dbh->do($sql);
}


sub create_projects {
	##     level = main or task
$sql = <<ENDPROJECTS;
	CREATE TABLE projects (
		projectid smallint unsigned not null auto_increment,
		number integer unsigned default 0,
		name varchar(20) default "",
		pct_done smallint unsigned default 0,
		description text(500) default "",
		PRIMARY KEY (projectid) )
ENDPROJECTS
$sql = <<ENDTASKS;
	CREATE TABLE tasks (
		taskid smallint unsigned not null autoincrement,
		project_fk integer unsigned not null,
		tasknumber integer unsigned default 0,
		taskname varchar(20) default "",
		task_pct_done smallint unsigned default 0,
		task_description text(500) default "",
		PRIMARY KEY (taskid) )
ENDTASKS

$sql = <<ENDSUBTASKS;
	CREATE TABLE subtasks (
		subtask_id smallint unsigned not null auto_increment,
		task_fk smallint unsigned not null,
		subtask_num integer unsigned default 0,
		subtask_name varchar(20) default "",
		subtask_pct_done smallint unsigned default 0,
		subtask_descr text(500) default "",
		PRIMARY KEY (subtask_id) )
ENDSUBTASKS
}



### 500 QUICKCHANGE processing

sub print_qkchg_filesdirs
{
  $path = "$autosubdir" if($dir !~ /[A-Za-z0-9]/);
  $path = "$autosubdir/$dir/" if($dir =~ /[A-Za-z0-9]/);

  opendir(CKCHGDIR, "$path");
  local(@qkchgfiledirs) = readdir(CKCHGDIR);
  closedir(CKCHGDIR);
  
  foreach $filedirname (@qkchgfiledirs) {
##  	  if($dir =~ /A-Za-z0-9/ or (-d $filename) ) {
        print MIDTEMPL "<option value=\"$filedirname\"";
        print MIDTEMPL " selected" if($filedirname eq $filedir and $filedir =~ /[A-Za-z0-9]/);
        print MIDTEMPL ">$filedirname</option>";
##     }
  }  
}


sub read_hitCount
{
  open(HITCOUNT, "$hitcountfile");
  while(<HITCOUNT>) {
   chomp;
   $hitCount = $_;
  }
  close(HITCOUNT);
}


sub read_userCount
 {
  open(USERCOUNT, "$usercntfile");
  while(<USERCOUNT>) {
   chomp;
   $userCount = $_;
   
  }
  close(USERCOUNT);
}


sub grant_privileges {
#     The syntax is correct here - but don't have grant privileges
	my $auser = "overpop@telavant.com";
    my $query = "GRANT ALL ON overpop TO ?"; 
    $dbh->do($query,undef,$auser) || die ("Could not 'do $query - Error: $DBI::errstr");
}


sub otherways_to_do_it {
	
	my $seen_sth   = $dbh->prepare( "Select 1 from indexes where sectsubid = ? and docid = ?");

	    my $insert_sth = $dbh->prepare("INSERT INTO indexes values(?,?,?,?,?,?)");
	    $seen_sth->execute($sectsubid, $docid) or die "SQL Error: $DBI::errstr\n";
	    my @seen = $seen_sth->fetchrow_array;
	    next if $seen[0];
	    $insert_sth->execute( $sno, $test11, $name, $time1, $pid, $type )
	      or die "SQL Error: $DBI::errstr\n";

	#	Change the structure of your database: ALTER TABLE svn_log1 ADD UNIQUE (username, pid);
	#	This create a composite, and unique index on username and pid. This means that every username/pid combination must be unique.
	#	This allows you to do the following:
	#	INSERT IGNORE INTO svn_log1 (username, pid, ...) VALUES (?, ?, ...)
	
$sql = "INSERT INTO authors (id,name,email) VALUES(1,'Vivek','xuz@abc.com')";

#an array slice:

#SEE RUBY IMPORTS ~~~~~~~~~~~~~
open (IN, "<$file");
@array = <IN>;
# Other stuff with @array ...
$sth = $dbh->prepare('insert into tablename values (?)');
$sth->execute(join '' => @array);



 my $sth = $dbh->prepare( 'INSERT INTO table VALUES ( ?, ?, ?, ? )' );

 $sth->execute( @sqlInsert[ $n .. $m ] );

#or a splice:

 while( @sqlInsert ) {
      $sth->execute( splice @sqlInsert, 0, $length, () );
      }

#It might be easier to create a data structure, such as an array of ararys, that already groups the elements for each structure:

 foreach my $ref ( @sqlInsert ) {
      $sth->execute( @$ref );
      }
}


1;

