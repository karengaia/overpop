#!/usr/bin/perl --

# January 23, 2012

#      sources.pl

# Contains code to manage and parse the SOURCES control file (flatfile and table)
# Called by article.pl and maybe docitem.pl

# 2012 Jan 23 

sub create_sources_table
{  
 $create_sources_sql = <<ENDSRC
CREATE TABLE sources (
sourceid smallint auto_increment PRIMARY KEY,
sourcename varchar(75) not null,
sstarts_with_the char(1) default "",
shortname varchar(75),
shortname_use char(1) default "",
sourcematch varchar(200),
linkmatch varchar(100),
snotmatch varchar(100),
sregionname varchar(75),
sregionid smallint,
region_use char(1) default "",
subregion varchar(75),
subregionid smallint,
subregion_use char(1) default "",
locale varchar(75),
locale_use char(1) default "",
headline_regex varchar(75),
linkdate_regex varchar(75),
date_format varchar(75)
);
ENDSRC

}

sub import_sources
{ 
  $dbh = &db_connect() if(!$dbh);

  my $sourcesctrl = "$controlpath/sources.html";
 print "<b>Import sources</b> sourcesctrl $sourcesctrl<br>\n";
  my $shortname = "";
  my $region_use = "";
  my $subregion_use = "";
  my $locale_use = "";
  my $headline_regex = "";
  my $linkdate_regex = "";
  my $sstarts_with_the = "";

 my $src_sth = $dbh->prepare("INSERT INTO sources (sourcename,sstarts_with_the,shortname,shortname_use,sourcematch,linkmatch,snotmatch,sregionname,sregionid,region_use,subregion,subregionid,subregion_use,locale,locale_use,headline_regex,linkdate_regex,date_format)
 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

#  my $src_sth = $dbh->prepare( "INSERT INTO sources (name,starts_with_the,shortname,sourcematch,linkmatch,notmatch,regionname,regionid,include_region,prefix_region,subregion,subregionid,include_subregion,headline_regex,linkdate_regex)
# VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

  open(SOURCES, "$sourcesctrl") or die("Can't open sources control");
  while(<SOURCES>)
  {
    chomp;
    my $srcline = $_;
    my $r_match = "";
print "srcline $srcline<br>\n";
	my ($sourcename,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$linkdate_regex,$subregion,$subregionid,$subregion_use,$headline_regex,$linkdate_regex,$date_format) 
	    = split(/\^/,$srcline,15);
	$sregionid = 0 if(!$sregionid);
	$subregionid = 0 if(!$subregionid);
	
	($sourcename,$sourcematch) = split(/\|/,$name,2) if($sourcename =~ /\|/);
		
	if($sourcename =~ /, The/) {
	   $sstarts_with_the = 'T';
	   ($sourcename,$rest) = split(/,/,$sourcename,2);
	}
	else {
	   $sstarts_with_the = '';
	}

	$sregionname =~ s/\s+$//mg; #Get rid of trailing spaces	
	print "sregionname $sregionname<br>\n";
	($sregionname,$subregion,$locale) = split(/\=/,$sregionname,3);
		
	$sregionid = &get_regionid($sregionname) if($sregionname);

	$subregionid = &get_regionid($subregion) if($subregion);
	
	$src_sth->execute($sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format);
print "<br>$line <br>\n";
  }
  $src_sth->finish;
  close(SOURCES);
}


sub read_sources_to_array
{
  my $srcidx = 0;
  my $srcline = "";
  if($DB_sources eq 1) {
	 my $src_sql = "SELECT sourceid,sourcename,sstarts_with_the,shortname,shortname_use,sourcematch,linkmatch,snotmatch,sregionname,sregionid,region_use,subregion,subregionid,subregion_use,locale,locale_use,headline_regex,linkdate_regex,date_format FROM sources ORDER BY sourcename;";
	 my $src_sth = $dbh->prepare($src_sql) or die("Couldn't prepare statement: ".$src_sth->errstr);	

	 if($src_sth) {
	    $src_sth->execute() or die "Couldn't execute sources table select statement: ".$src_sth->errstr;
	    if ($src_sth->rows == 0) {
	    }
	    else {
		   while ( ($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format) 
		         = $src_sth->fetchrow_array() )  {
			  $srcline = "$sourceid^$sourcename^$sstarts_with_the^$shortname^$shortname_use^$sourcematch^$linkmatch^$snotmatch^$sregionname^$sregionid^$region_use^$subregion^$subregionid^$subregion_use^$locale^$locale_use^$headline_regex^$linkdate_regex^$date_format";
		      $SRCARRAY[$srcidx] = $srcline;
		      $srcidx = $srcidx + 1;
		   }
		}
		$src_sth->finish() or die "DB sectsubs failed finish";
	 }
	 else {
	    print "Couldn't prepare sources table query<br>\n";
	 }
  }
else {
  open(SOURCES, "$sources");
  while(<SOURCES>)
  {
   chomp;
   $line = $_;
    if($line !~ /<PRE>/ and $line !~ /<\/PRE>/) {
      $SRCARRAY[$srcidx] = $line;
      $srcidx = $srcidx + 1;
    } 
  } 
  close(SOURCES);
 }
}


sub get_sources
{
 my($print_src,$source,$headline,$chkline,$link) = @_;

 my $sourcefound = 'N';
 my $src_entry = "";

 foreach $src_entry (@SRCARRAY) {
    my ($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$local_use,$headline_regex,$linkdate_regex,$date_form)
	      = split(/\^/,$src_entry,19);
	if($print_src =~ /N/) {
		$linkmatch = quotemeta($linkmatch) if($linkmatch);
	    if(   ($chkline and $chkline =~ /$sourcename/)
 	       or ($chkline and $sourcematch and $chkline =~ /$sourcematch/) 
 	       or ($link and $linkmatch and $link =~ /$linkmatch/) ) {
		      if(($chkline and $notmatch and $chkline =~ /$notmatch/)
		         or ($link and $notmatch and $link =~ /$notmatch/))  { #skip 
			  }
			  else {
		         $sourcename =~  s/^\W+//;  #get rid of leading non-word chars\
		         return($sourcename,$sregionname);
		      }
	     }
	     elsif($source and ($sourcename =~ /$source/)) {
#				print"ctr171 ..source $source sourcename $sourcename ..print_region $print_region<br>\n";
		    return($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format);
	     }	
	}
    elsif ($print_src =~ /[YF]/) {   #print_src = Yes or Form
       print MIDTEMPL "<option value=\"$src_entry\" ";

       if($sourcename and $source and ($sourcename =~ /$source/)){
      	  print MIDTEMPL " selected" ;
          $sourcefound = 'Y';
          &source_to_template_array($sourceid,$sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format);  
       }
	   print MIDTEMPL ">$sourcename</option>\n";	
    }
 }
 if ($print_src =~ /[YF]/) {
	return($sourcefound);
 }
 else {
 	return("");
 }
}

sub get_source_linkmatch
{
 my $url = $_[0];
 my $sourcename = "";
 my $linkmatch = "";

#	select sourcename,linkmatch from sources where "http://earth-policy.org" REGEXP linkmatch

 if($DB_sources eq 1) {
     my $srcl_sql = "SELECT sourcename,linkmatch,sregionname FROM sources WHERE ? REGEXP linkmatch;";
	 my $srcl_sth = $dbh->prepare($srcl_sql) or die("Couldn't prepare statement: ".$srcl_sth->errstr);	

	 if($srcl_sth) {
	    $srcl_sth->execute($url) or die "Couldn't execute sources table select find linkmatch statement: ".$srcl_sth->errstr;
	    if($srcl_sth->rows == 0) {
		   return("");
	    }
	    else {
		   while ( ($sourcename,$linkmatch,$sregionname) = $srcl_sth->fetchrow_array() )  {
			  $srcl_sth->finish();
              return($sourcename,$sregionname);
		   }
		}
	 }
	 else {
	    print "Couldn't prepare sources table query<br>\n";
	    break;
	 }
 }
 else {
    $sourcename = &get_sources('N',"","","",$url);  #comes here if DB is down or fails	
    return($sourcename);
 }
}

 ##            from docitem.pl
sub add_new_source
{
 $sourcenew = $FORM{source};
 if($FORM{source} and $sourcenew =~ /[A-Za-z0-9]/) {
	if(-f "../../karenpittsMac.yes") {  ## set permissions if using Karen's Mac as the server
		if(-f '$newsources') {}
		else {
			system('touch $newsources');
			}
		system('chmod 0777, $newsources');
	}
	
   open(NEWSOURCES, ">>$newsources");
   print NEWSOURCES "$source\n";
   close(NEWSOURCES);
 }
}

sub source_to_template_array
{
  # SOURCES variables
 $DOCARRAY{sourceid}      = $sourceid;
 $DOCARRAY{sourcename}    = $sourcename;
 $DOCARRAY{sstarts_with_the} = $sstarts_with_the;
 $DOCARRAY{shortname}     = $shortname;
 $DOCARRAY{shortname_use} = $shortname_use; 
 $DOCARRAY{sourcematch}   = $sourcematch;
 $DOCARRAY{linkmatch}     = $linkmatch;
 $DOCARRAY{snotmatch}     = $snotmatch;
 $DOCARRAY{sregionname}   = $sregionname; 
 $DOCARRAY{sregionid}     = $sregionid;
 $DOCARRAY{region_use}    = $region_use;
 $DOCARRAY{subregion}     = $subregion; 
 $DOCARRAY{subregionid}   = $subregionid;
 $DOCARRAY{subregion_use} = $subregion_use;
 $DOCARRAY{locale}        = $locale; 
 $DOCARRAY{locale_use}    = $locale_use;
 $DOCARRAY{headline_regex} = $headline_regex;
 $DOCARRAY{linkdate_regex} = $linkdate_regex;
 $DOCARRAY{date_format}    = $date_format;
}

sub add_updt_source_values 
{
  my($source,$addchgsource) = @_;
  $sourcename = $source;
  return('Missing Source name or not add(A) or update(U)') if($addchgsource !~ /[AU]/ or (!$source));
  $sourceid         = $FORM{"sourceid$pgitemcnt"};
  $sstarts_with_the = $FORM{"sstarts_with_the$pgitemcnt"};
  $shortname        = $FORM{"shortname$pgitemcnt"};
  $shortname_use    = $FORM{"shortname_use$pgitemcnt"};
  $sourcematch      = $FORM{"sourcematch$pgitemcnt"};
  $linkmatch        = $FORM{"linkmatch$pgitemcnt"};
  $snotmatch        = $FORM{"snotmatch$pgitemcnt"};
  $sregionname      = $FORM{"sregionname$pgitemcnt"};
  $sregionid        = $FORM{"sregionid$pgitemcnt"};
  $region_use       = $FORM{"regionuse$pgitemcnt"};
  $subregion        = $FORM{"subregion$pgitemcnt"};
  $subregionid      = $FORM{"subregionid$pgitemcnt"};
  $subregion_use    = $FORM{"subregion_use$pgitemcnt"};
  $locale           = $FORM{"locale$pgitemcnt"};
  $locale_use       = $FORM{"locale_use$pgitemcnt"};
  $headline_regex   = $FORM{"headline_regex$pgitemcnt"};
  $linkdate_regex   = $FORM{"linkdate_regex$pgitemcnt"};
  $date_format      = $FORM{"date_format$pgitemcnt"};

  if($addchgsource =~ /A/) {
     my $srcadd_sth = $dbh->prepare("INSERT REPLACE INTO sources (sourcename,sstarts_with_the,shortname,shortname_use,sourcematch,linkmatch,snotmatch,sregionname,sregionid,region_use,subregion,subregionid,subregion_use,locale,locale_use,headline_regex,linkdate_regex,date_format) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

     $sregionid = &get_regionid($sregionname) if($sregionname and (!$sregionid or $sregionid == 0));
     $subregionid = &get_regionid($subregion) if($subregion and (!$subregionid or $subregionid == 0));

     $srcadd_sth->execute($sourcename,$sstarts_with_the,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format);
	 $sourceid = $dbh->do("SELECT MAX(sourceid) FROM sources");
  }
  else {   #update

     $sregionid = &get_regionid($sregionname) if($sregionname and (!$sregionid or $sregionid == 0));
     $subregionid = &get_regionid($subregion) if($subregion and (!$subregionid or $subregionid == 0));

     my $src_update_sql = 
	"UPDATE sources SET sstarts_with_the = ?, sourcename = ?, shortname = ?, " .
	"shortname_use = ?, sourcematch = ?, linkmatch = ?,snotmatch = ?,sregionname = ?, " .
	"sregionid = ?, region_use = ?, subregion = ?, subregionid = ?, subregion_use = ?, " .
	"locale = ?, locale_use = ?, headline_regex = ?, linkdate_regex = ?, date_format = ?  WHERE sourceid = ?;";
    my $reg_updt_sth = $dbh->prepare($src_update_sql);
	$reg_updt_sth->execute($sstarts_with_the,$sourcename,$shortname,$shortname_use,$sourcematch,$linkmatch,$snotmatch,$sregionname,$sregionid,$region_use,$subregion,$subregionid,$subregion_use,$locale,$locale_use,$headline_regex,$linkdate_regex,$date_format,$sourceid) or die "DB Update source $source failed<br>\n";
  }
  return($sourecid);
}

1;