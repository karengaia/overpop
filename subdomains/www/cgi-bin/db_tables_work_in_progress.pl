# Region type:
# 1. S super_category: hemisphere, BRIC, G7, (not developing world), etc
# 2. C continent_grp: MENA=MENA, Ocea=Oceania, LA=Latin America and Caribbean, NoAm=North America, Afri= Africa, Asia=Asia, Euro=Europe
# 3. s sub continent: Caribbean, SE Asia, Eastern Europe
# 4. A area: Pacific Ocean, Antartica
# 5. c country: USA
# 6. p province/state: Alabama, or subregion Midwest

# S=superCategory C=continentGroup s=subContinent A=area c=country r=subregion, p=province/state

sub create_region_table {

$create_regions_sql => ENDREGIONS
CREATE TABLE regions (
	id smallint unsigned not null,
	seq smallint unsigned not null,
	r_type char(1) default "c",
	name varchar(75) not null,
	starts_with_the bit(1) default 0,
	r_match varchar(200) default "",
	r_not varchar(100) default "",
	members_ids varchar(200), 
	continent_grp char(2) default " ",
	location varchar(75) default "",
	extended_name varchar(100) default "", 
	1st2nd3rd_world  smallint unsigned,
	fertility_rate decimal(2,2) unsigned,
	population integer unsigned,
	pop_growth_rate decimal(2,2),
	sustainability_index decimal(2,2) unsigned,
	humanity_index decimal(2,2) unsigned,
    PRIMARY KEY (id)
)
ENDREGIONS
}

sub import_regions
{ 
  $dbh = &db_connect() if(!$dbh);

  my $regionsctrl = "$controlpath/regions.html";
 print "<b>Import regions</b> regionsctrl $regionsctrl<br>\n";
  my $sth = $dbh->prepare( "INSERT INTO regions (seq,r_type,name,starts_with_the,r_match,r_not,continent_grp,location,extended_name)
VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

  open(REGIONS, "$regionsctrl") or die("Can't open sources control");
  while(<REGIONS>)
  {
    chomp;
    $line = $_;
	($r_type,$name,$continent_grp,$location,$r_not,$extended_name) = split(/\^/,$line);
	($name,$r_match) = split(/|/,$name,1);
	if($name =~ /, The/) {
	   $starts_with_the = 1;
	   $name = split(/,/,$name);
	}
	else {
	   $starts_with_the = 0;
	}
	
	$seq = $seq + 10;

	$sth->execute($seq,$r_type,$name,$starts_with_the,$r_match,$r_not,$continent_grp,$location,$extended_name);
									
print "<br>$line <br>\n";
  }
  $sth->finish;
  close(REGIONS);
}

sub fillin_region_ids
{
#Select id,name,match,not,type,continent_grp,superregion,superregionid from regions

#process as rows, searching for continentid, superregionid, currentnameid #skip countryid for now, also subregions.
#SEE FETCH BELOW  
}

sub export_regions
{
  $dbh = &db_connect() if(!$dbh);
#SELECT id,name,match,not,type,continent_grp,superregion,superregionid from regions as r

  my $sql =	"SELECT * from indexes WHERE sectsubid = ? ORDER BY $lifonum DESC";
  print "Exporting indexes to autosubmit/sections/$sectsub.idx and saving old in sectionsexp/$sectsub.idx<br>\n";
  print "sql = $sql<br>\n";

  $sth_exportRegions = $dbh->prepare($sql);
  if(!$sth_exportRegions) {
	 print "Errror in regions export at Prepare command, db138 " . $sth_exportregions->errstr . "<br>\n";
	 exit;	
  }

FIX:  my $regions = "$controlpath/regions.html";   # Use sections file as control
		
  unlink $expregionpath if(-f $expregionpath);
  open(EXPREGIONS, ">>$expregionpath"); 
  while (my @row = $sth_exportRegions->fetchrow_array()) { # print data retrieved
  my ($regionid,$regionname,$regionmatch,$regionnot,$regiontype,$continent,$continentid,
		$continent_grp,$countryid,$superregion,$superregionid,$subregions,$currentname,$currentname_id) = @row;
  my $line = "$regionid^$regionname^$regionmatch^$regionnot^$regiontype^$continent^$continentid^$continent_grp^$countryid^$superregion^$superregionid^$subregions^$currentname^$currentname_id\n";	
	         print EXPREGIONS "$line";
	         print "$line<br\n";
	    }
		close(EXPREGIONS);
		unlink $oldregionpath if(-f $regionoldpath);
		system "cp $regionpath $regionoldpath";
		unlink $regionpath  if(-f $regionpath);
		system "cp $expregionpath $regionpath";	

  $sth_exportRegions->finish() or die "DB regions export failed finish";
  close(REGIONS);
  print "<br><b>Export regions completed</b><br>\n";
}


CREATE TABLE sources (
	sourceid smallint unsigned not null,
	sourcename varchar(75) not null,
	shortname varchar(10) not null,
	sourcematch varchar(120) not null,
	sourcenot varchar(100) not null,
	linkmatch varchar(70) not null,
	region varchar(70) not null,
	regionid integer unsigned not null default 0,
	startswiththe varchar(8) not null default "",
	headline_regex varchar(30) not null default "",
	linkdate_regex varchar(50) not null default "",
    accessed_on datestamp;		
    PRIMARY KEY (sourceid)
)

sub import_sources
{ 
  $dbh = &db_connect() if(!$dbh);

  my $sourcesctrl = "$controlpath/sources.html";
 print "<b>Import sources</b> sourcesctrl $sourcesctrl<br>\n";
  my $sth = $dbh->prepare( "INSERT INTO sources (sourcename,sourcematch,region)
VALUES ( ?, ?, ?)" );

  open(SOURCES, "$sourcesctrl") or die("Can't open sources control");
  while(<SOURCES>)
  {
    chomp;
    $line = $_;
	($sourcename,$region)
	   = split(/\^/,$line);
	($sourcename,$sourcematch) = split(/|/,$sourcename);"
	$sth->execute($sourcename,$sourcematch,$region);								
print "<br>$line <br>\n";
  }
  $sth->finish;
  close(SOURCES);
}


CREATE TABLE switches_counts (   # already created
	name         varchar(20) not null,     #Name = DB_Indexes for example
	switch_count integer unsigned default 0,
	description  varchar(70)
)

CREATE TABLE codes (   # see codes.txt - this may already be done (or partially)
    codetype varchar(6) not null,  
    code varchar(2)  not null, 
    description varchar(100) default "", 
    codename varchar(12) default ""
)


CREATE TABLE skiplookup (
	phrase varchar(150) not null,
	where  varchar(15) not null default "fullbody",
	handle varchar(15) not null default ""
)

CREATE TABLE transforms (
 	typecode varchar(15) not null default "C",
 	from varchar(4) not null,
 	to varchar(4) not null default "",
 	description varchar(30),
)

CREATE TABLE woalookup (    # for coded fields in other tables - see notes
 	typecode varchar(15) not null,
 	code varchar(3) not null,
 	name varchar(25) not null,
 	longname varchar(150),
)

CREATE TABLE acronyms (    # for coded fields in other tables - see notes
 	acronym varchar(5) not null,
 	name varchar(70) not null,
 	definition varchar(300),
)


sub import_sectsubs
	{ 
	  $dbh = &db_connect() if(!$dbh);
	 print "<b>Import sectsubs</b> sectionctrl $sectionctrl<br>\n";

	  my $sectionsctrl = "$controlpath/sections.html";
	  my $sth = $dbh->prepare( "INSERT INTO sectsubs (sectsubid,seq,sectsub,fromsectsubid,fromsectsub,subdir,page,category,visable,preview,order1,pg2order,template,titletemplate,title,allor1,mobidesk,doclink,header,footer,ftpinfo,pg1items,pg2items,pg2header,more,subtitle,subtitletemplate,menutitle,keywordsmatch)
	VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )" );

	  open(SECTIONS, "$sectionctrl") or die("Can't open sections control");
	  while(<SECTIONS>)
	  {
	    chomp;
	    $line = $_;
		next if($line =~ /sectsubid\^seq/);
		($id,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch)
		   = split(/\^/,$line);
		$sth->execute($id,$seq,$sectsub,$fromsectsubid,$fromsectsub,$subdir,$page,$category,$visable,$preview,$order1,$pg2order,$template,$titletemplate,$title,$allor1,$mobidesk,$doclink,$header,$footer,$ftpinfo,$pg1items,$pg2items,$pg2header,$more,$subtitle,$subtitletemplate,$menutitle,$keywordsmatch);								
	print "<br>$line <br>\n";
	  }
	  $sth->finish;
	  close(SECTIONS);
   }



~~~~

DB_controlfiles.pl

#!/usr/bin/perl --

sub DB_get_switches_counts
{
	my $name;
	my $switch_count = 0;
	
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
				$g_debug_prt = $switch_count if($name =~ /g_debug_prt/);
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

1;


database.pl ------   ### Need table or form argument. Also length array argument.

sub print_query_results
{
 local($dbh,$sql_query,@colheaders) = @_;   # get arguments: sql and array of column names
 
 $dbh = &db_connect if(!$dbh);
  
 my $sth = $dbh->prepare_cached($sql_query)
     or die "Pardon this embarassing error: couldn't prepare the query; must quit now: $dbh->errstr\n";

 $sth->execute( )
     or die "Pardon this embarassing error: Couldn't execute statement; must quit now: $sth->errstr\n";
 
 if ($sth->rows == 0) {
    print "No matching data found.<br>\n\n";
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
