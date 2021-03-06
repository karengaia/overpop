#!/usr/bin/perl --

## March 21 2014   (orig) May 19, 2011

## 2012-8-9 combined misc_dbtables.pl and this. Moved query string to article.pl

sub DB_controller {       #comes here from article.pl
	my ($DBcmd,$table,$one,$two,$three)  = @_;   ## $newsSSname,$mindocid_n,$maxdocid_n

	if($DBcmd =~ /list|man/) {
	   &list_functions("list");
	   return;
	}

	if($table =~ /sectsubs/) {
	    &import_sectsubs if($DBcmd =~ /import/);   # in sectsubs.pl
	    &export_sectsubs if($DBcmd =~ /export/);
	}
	elsif($table =~ /regions/) {
	    &import_regions if($DBcmd =~ /import/); # in regions.pl
	#    &export_regions if($DBcmd =~ /export/);
	}
	elsif($table =~ /sources/) {
	    &import_sources if($DBcmd =~ /import/);   # in sources.pl
	#    &export_regions if($DBcmd =~ /export/);
	}
	elsif($table =~ /docitems/) {  ## indexes are done at the same time for import
	    &import_docitems($one,$two,$three) if($DBcmd =~ /import/);   # in docitems.pl
	    &export_docitems($one,$two,$three) if($DBcmd =~ /export/);   # in docitems.pl
	}
	elsif($table =~ /users/) { 
        &import_users_first_time if($DBcmd =~ /import/ and $one eq '1st');   # in users.pl  #imports users, editors, contributors
		&import_users            if($DBcmd =~ /import/ and $one ne '1st');   # in users.pl 
	    &export_users            if($DBcmd =~ /export/);   # in users.pl
	}
	elsif($table =~ /editors/) {  
		&import_editors   if($DBcmd =~ /import/);   # in editors.pl
		&export_editors   if($DBcmd =~ /export/);   # in editors.pl
	}
	elsif($table =~ /contributors/) {  
		&import_contributors if($DBcmd =~ /import/);   # in contributors.pl
		&export_contributors          if($DBcmd =~ /export/);   # in contributors.pl
	}
	elsif($table =~ /indexes/) {  #  DO WE NEED? DO THIS IN DOCITEMS
	    &export_indexes if($DBcmd =~ /export/);   
	}
	else {
		print "Incorrect table<br>\n" if($DBcmd !~ /list/);
	}
}


sub list_functions {
	my $prt_where = $_[0];
	my $msg = "<br>&nbsp; &nbsp;<big><b>Table Maintenance - dbtables_ctrl.pl Functions - - - - - - - - - - - - - </b></big><br>\n";
	$msg = $msg . "<table class=\"shaded\"><tr><td>&nbsp;</td><td><b>Table</b></td><td><b>Cmd</b></td><td><b>From</b></td><td><b>To</b></td><td><b>More</b></td></tr>\n";
# Import sectsubs
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import%sectsubs\"><b>run</b></a>";
	$msg = $msg . "<td>sectsubs</td><td>import</td><td>new style flatfile sections.html</td><td> to DB sectsubs table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
# Export sectsubs
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%export%sectsubs\"><b>run</b></a>";
	$msg = $msg . "<td>sectsubs</td><td>export</td><td>DB sectsubs table</td><td>new style flatfile sections.html</td><td></td></tr>\n";
# Import regions
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import%regions\"><b>run</b></a>";
	$msg = $msg . "<td>regions</td><td>import</td><td>flatfile regions.html</td><td> to DB regions table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
# Import sources
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import%sources\"><b>run</b></a>";
	$msg = $msg . "<td>sources</td><td>import</td><td>flatfile sources.html</td><td> to DB sources table</td><td>(TRUNCATE 1st!!)</td></tr>\n";
# Import docitems and indexes
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import%docitems\"><b>run</b></a>";
	$msg = $msg . "<td>docitems</td><td>import</td><td>flatfiles /autosubmit/items/docid.itm & /autosubmit/sections/sectsubname.idx</td><td> to DB docitems and indexes tables</td><td>(TRUNCATE 1st!!)</td></tr>\n";
# Export docitems only
    $msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%export%docitems\"><b>run</b></a>";
    $msg = $msg . "<td>docitems</td><td>export</td><td>DB docitems table</td><td></td><td>to flatfiles /autosubmit/items/docid.itm</td></tr>\n";
# Export indexes only
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%export%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>docitems</td><td>export</td><td>DB indexes tables</td><td></td><td>to flatfiles /autosubmit/sections/sectsubname.idx</td></tr>\n";

## EVERYTHING BELOW THIS IS OBSOLETE ###################
	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>import</td><td>autsosubmit/sections/sectsub.idx</td><td>DB indexes (TRUNCATE 1st!!) </td><td>Uses sections.html as controller</td></tr>\n";

	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%export%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>export</td><td>DB indexes</td><td>export flatfile: autsosubmit/sections_exp/sectsub.idx</td><td>&nbsp;</td></tr>\n";

	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%restore_flatfile%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>restore_flatfile</td><td>exported autsosubmit/sections_exp/sectsub.idx</td><td>normal autsosubmit/sections/sectsub.idx</td><td> Will run 'export' first</td></tr>\n";

	$msg = $msg . "<tr><td><a target=\"blank\" href=\"http://$scriptpath/article.pl?DBctrl%import_exported%indexes\"><b>run</b></a>";
	$msg = $msg . "<td>indexes</td><td>import_exported</td><td>exported flatfiles</td><td>DB indexes</td></tr>\n";	

	$msg = $msg . "<tr><td colspan=\"6\"><b>- - -Indexes will be run with flatfiles and DB in parallel, maintaining both. DB indexes will eventually take over, with flatfiles as backup</b></td></tr>\n";
	$msg = $msg . "</table></br>\n";
	
	if($prt_where =~ /list/) {
		print "$msg";
	}
	else {
		print MIDTEMPL "$msg";
	}
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
 if(!$DBH) {
    print "No connection ctr33<br>\n";
    return("");
 }
 my $acr_sth = $DBH->prepare($acr_sql) or msgDie("Couldn't prepare statement: ".$acr_sth->errstr);	

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
    my $acr_add_sth = $DBH->prepare($acr_add_sql); 
    $acr_add_sth->execute($acronym,$title);
  }
}

sub prt_acronym_list
{
 my $ac_sql = "SELECT acronym,title FROM acronyms ORDER BY acronym;";
 my $ac_sth = $DBH->prepare($ac_sql) or die("Couldn't prepare statement: ".$ac_sth->errstr);	

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



    

### END COUNTS #####

sub create_codes
{   ## Easier to do this on Telavant interface
	$DBH = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS indexes");

$sql = <<CODES;
CREATE TABLE codes ( codetype varchar(6) not null,  code varchar(2)  not null, description varchar(100) default "", codename varchar(12) default "")
CODES

$sth2 = $DBH->do($sql);
}



#KEYWORDS

#Tie keywords to sections, not articles

#Need keyword table: keyword_id and keyword

#keywords_sectsubs table: column keyword_id (foreign key) sectsubs_id for many-to-many relationship


#WEBUSER
#webuser: table: userid, webuser_type, upassword, uemail, ulast name, ufirst name
#webuser_type : o=owner, c=contributor (| separated), ml = maillist, 

#OWNER (page owner)

#owner: webuser_id (foreign key), ownerhandle, ownername contact info: oaddr, ocity ostate ozip ophone, 
#owebsitepath, ocsspath x-ocrudtemplate, x-ologintemplate, ologopath, oftpinfo, odefaultSS



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



sub grant_privileges {
#     The syntax is correct here - but don't have grant privileges
	my $auser = "overpop@telavant.com";
    my $query = "GRANT ALL ON overpop TO ?"; 
    $DBH->do($query,undef,$auser) || die ("Could not 'do $query - Error: $DBI::errstr");
}


sub otherways_to_do_it {
	
	my $seen_sth   = $DBH->prepare( "Select 1 from indexes where sectsubid = ? and docid = ?");

	    my $insert_sth = $DBH->prepare("INSERT INTO indexes values(?,?,?,?,?,?)");
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
$sth = $DBH->prepare('insert into tablename values (?)');
$sth->execute(join '' => @array);



 my $sth = $DBH->prepare( 'INSERT INTO table VALUES ( ?, ?, ?, ? )' );

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
