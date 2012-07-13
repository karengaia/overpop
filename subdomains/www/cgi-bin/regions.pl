#!/usr/bin/perl --

# January 23, 2012

#    regions.pl

# Contains code to manage and parse the REGIONS control file (flatfile and table)
# Called by article.pl and maybe docitem.pl

# 2012 Jan 23

### 400 REGIONS processing

# Region type:
# 1. S super_category: hemisphere, BRIC, G7, (not developing world), etc
# 2. C continent_grp: MENA=MENA, Ocea=Oceania, LA=Latin America and Caribbean, NoAm=North America, Afri= Africa, Asia=Asia, Euro=Europe
# 3. s sub continent: Caribbean, SE Asia, Eastern Europe
# 4. A area: Pacific Ocean, Antartica
# 5. c country: USA
# 6. p province/state: Alabama, or subregion Midwest

# S=superCategory C=continentGroup s=subContinent A=area c=country r=subregion, p=province/state

sub create_region_table {    # we do this on Televant interface
	# if necessary remove the PRIMARY KEY and auto_increment if importing from flatfile with regionids included
	   # change back to PRIMARY KEY and auto_increment after import. Also set increment to max value
	# We need to do this since regionids are used as a foreign key in sources
$create_regions_sql = <<ENDREGIONS
CREATE TABLE regions (
	regionid smallint auto_increment PRIMARY KEY,
	seq smallint unsigned not null,
	r_type char(1) default "c",
	regionname varchar(75) not null,
	rstarts_with_the char(1) default "F",
	regionmatch varchar(200) default "",
	rnotmatch varchar(100) default "",
	members_ids varchar(200), 
	continent_grp char(2) default " ",
	location varchar(75) default "",
	extended_name varchar(100) default "", 
	f1st2nd3rd_world  smallint unsigned,
	fertility_rate decimal(2,2) unsigned,
	population integer unsigned,
	pop_growth_rate decimal(2,2),
	sustainability_index decimal(2,2) unsigned,
	humanity_index decimal(2,2) unsigned
);
ENDREGIONS
}

sub import_regions
{ 
  $dbh = &db_connect() if(!$dbh);
  my $seq = 0;
  my $regionsctrl = "$controlpath/regions.html";
 print "<b>Import regions</b> regionsctrl $regionsctrl<br>\n";
  my $reg_sth = $dbh->prepare( "INSERT INTO regions (seq,r_type,regionname,rstarts_with_the,regionmatch,rnotmatch,continent_grp,location,extended_name)
VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?)" );

  open(REGIONS, "$regionsctrl") or die("Can't open regions control");
  while(<REGIONS>)
  {
    chomp;
    my $line = $_;
    my $regionmatch = "";
	my ($r_type,$regionname,$continent_grp,$location,$rnotmatch,$extended_name) = split(/\^/,$line);
	
	($regionname,$regionmatch) = split(/\|/,$regionname,2) if($regionname =~ /\|/);

	if($regionname =~ /, The/) {
	   $rstarts_with_the = T;
	   ($regionname,$rest) = split(/,/,$regionname,2);
	}
	else {
	   $rstarts_with_the = F;
	}
	
	$seq = $seq + 10;

	$reg_sth->execute($seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$continent_grp,$location,$extended_name);
									
print "<br>$line <br>\n";
  }
  $sth->finish;
  close(REGIONS);
}


sub get_regionid  ##used in sources table import- may want to move to controlfiles.pl for adds
{
 my($region) = $_[0];
 my $regionid = 0;
 my $sth_region = $dbh->prepare( 'SELECT regionid FROM regions where regionname = ?' );
 $sth_region->execute($region);
 $regionid = $sth_region->fetchrow_array();
 $sth_region->finish();
 return($regionid);
}


sub read_regions_to_array
{
  my $regidx = 0;
  if($DB_regions eq 1) {
	 my $reg_sql = "SELECT regionid, seq, r_type, regionname, rstarts_with_the, regionmatch, rnotmatch, members_ids, continent_grp, location, extended_name, f1st2nd3rd_world, fertility_rate, population, pop_growth_rate, sustainability_index, humanity_index FROM regions ORDER BY seq;";
	 my $reg_sth = $dbh->prepare($reg_sql) or die("Couldn't prepare statement: ".$reg_sth->errstr);	

	 if($reg_sth) {
	    $reg_sth->execute() or die "Couldn't execute regions table select statement: ".$reg_sth->errstr;
	    if ($reg_sth->rows == 0) {
	    }
	    else {
		   while ( ($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index) = $reg_sth->fetchrow_array() )  {
			  $reg_entry = "$regionid^$seq^$r_type^$regionname^$rstarts_with_the^$regionmatch^$rnotmatch^$members_ids^$continent_grp^$location^$extended_name^$f1st2nd3rd_world^$fertility_rate^$population^$pop_growth_rate^$sustainability_index^$humanity_index";
		      $REGARRAY[$regidx] = $reg_entry;
		      $regidx = $regidx + 1;
		   }
		}
		$reg_sth->finish() or die "DB regions failed finish";
	 }
	 else {
	    print "Couldn't prepare regions table query<br>\n";
	 }
  }
  else {
      open(REGIONS, "$regions");
	  while(<REGIONS>) {
	     chomp;
	     my $regline = $_;
	     $regline =~ s/\r//;
	     if($regline =~ /=>/ or $regline =~ /<PRE>/ or $regline =~ /<\/PRE>/) {
	     	next;
	     }
	     @REGARRAY[$regidx] = $line;
	     $regidx = $regidx + 1; 
	  } 
	  close(REGIONS);
  }
}

sub refine_region
{
  $src_region = $_[0];
  $region = &get_regions("A","",$headline);
            # Use regionname from source if no region found. But not from US or UK source
  $region = $src_region unless($region or $src_region =~ /U\.S\.|U\.K\./);
  if(!$region) {
    my ($fullbody1,$fullbody2,$rest) = split(/\n/,$fullbody,3);
    my $fullbodyTop = "$fullbody1\n$fullbody2";
    $region = &get_regions("A","",$fullbodyTop);
  }
  $region = $src_region if(!$region and $src_region); #Use regionname from source if no region found.
  $region = "Global" if(!$region);
  return($region);
}

sub get_regions
{
 my($print_region,$region,$chkarea) = @_;

 my $found_region = 'N';
 my $region1  = "";
 my $reg_entry = "";
 my $reg_match = "";

 foreach $reg_entry (@REGARRAY) {
    ($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index)
        = split(/\^/,$reg_entry, 17);

    if($print_region =~ /[YF]/) {
        print MIDTEMPL "<option value=\"$reg_entry\" ";
        if($found_region =~ /N/ and $region and $region eq $regionname) {
           if($rnotmatch and $region =~ /$rnotmatch/) {
           }
           else {
              print MIDTEMPL " selected=\"selected\" ";
              $found_region = 'Y';
                        # in controlfiles.pl
		      &region_to_template_array($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index);
           }
        }
        print MIDTEMPL ">$regionname</option>\n";        	
    }

	elsif($region and $region =~ /$regionname/ and $print_region =~ /[N]/) {
		return($regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$regionid,$seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index);
	}
	
	else {  # find regions for new article
		$reg_match = $regionname;
		if($regionmatch) {
			$reg_match = "$reg_match|$regionmatch";
		}			
		if($chkarea and $chkarea =~ /$reg_match/) {
		    if($rnotmatch and $chkarea =~ /$rnotmatch/) {
			}
			else {
				$region1 = "$region1;$regionname";
				$region1 =~ s/^;+//;
            }
		}
	}
 } # END foreach
 $region1 = "U\.S\.;$region1" 
     if($region1 !~ /Global/ and $r_type eq 'p' and $location eq 'US' and ($region1 !~ 'U\.S\.' or !$region));
 $region1 =~ s/^;+//;  #get rid of leading semi-colons
 $region1 =~ s/^;//;
 $region1 =~ s/;;/;/;
 $region1 =~ s/;;/;/;
 $region1 =~ s/;$//;

 return($region1);
}

sub print_likely_regions
{	
##print "ctrl400 REGION: $region HEADLINE: $headline\n\n";
##print "ctrl400 MSGTOP: $msgtop\n\n";
 local($topRegion,$rest) = split(/;/,$region,2);
 local(@regions) = split(/;/,$region);
 local($selected);
 
 foreach $likely_region(@regions) {
    if($likely_region eq $topRegion) {
       $selected = " selected=\"selected\"" 
    }
    else {
       $selected = "";
    }
    print MIDTEMPL "<option value=\"$likely_region\"$selected>$likely_region</option>\n";
 }
 print MIDTEMPL "<option value=\"\">-</option>\n";	
}

sub add_new_region
{
  if($region =~ /[A-Za-z0-1]/) {
	 if($SVRinfo{environment} == 'development') {  ## set permissions if using Karen's Mac as the server
		if(-f '$regions') {}
		else {
			system('touch $regions');
			}
		system('chmod 0777, $regions');
	 }
   
     open(RGNFILE, ">>$regions");
     print RGNFILE "$region\n";
     close(RGNFILE);
  }    
}

sub region_to_template_array
{
# REGIONS VARIABLES

 $DOCARRAY{regionid}      = $regionid;
 $DOCARRAY{seq}           = $seq;
 $DOCARRAY{r_type}        = $r_type;
 $DOCARRAY{regionname}    = $regionname;
 $DOCARRAY{rstarts_with_the} = $rstarts_with_the; 
 $DOCARRAY{regionmatch}   = $regionmatch;
 $DOCARRAY{rnotmatch}     = $rnotmatch;
 $DOCARRAY{members_ids}   = $members_ids;
 $DOCARRAY{continent_grp} = $continent_grp; 
 $DOCARRAY{location}      = $location;
 $DOCARRAY{extended_name} = $extended_name;
 $DOCARRAY{f1st2nd3rd_world} = $f1st2nd3rd_world;
 $DOCARRAY{fertility_rate}  = $fertility_rate; 
 $DOCARRAY{population}      = $population;
 $DOCARRAY{pop_growth_rate} = $pop_growth_rate;
 $DOCARRAY{sustainability_index} = $sustainability_index;
 $DOCARRAY{humanity_index}  = $humanity_index;
}

sub add_updt_region_values 
{
  my ($region,$addchgregion) = @_;
  return() if($addchgregion !~ /[AU]/);
  my $regionname = $region;
  my $regionid         = $FORM{"regionid$pgitemcnt"} if($addchgregion =~ /U/);
  my $seq              = $FORM{"seq$pgitemcnt"};
  my $r_type           = $FORM{"r_type$pgitemcnt"};
  my $rstarts_with_the = $FORM{"rstarts_with_the$pgitemcnt"};
  $rstarts_with_the = '' if($rstarts_with_the !~ /T/);
  my $regionmatch      = $FORM{"regionmatch$pgitemcnt"};
  my $rnotmatch        = $FORM{"rnotmatch$pgitemcnt"};
  my $members_ids      = $FORM{"members_ids$pgitemcnt"};
  my $continent_grp    = $FORM{"continent_grp$pgitemcnt"};
  my $location         = $FORM{"location$pgitemcnt"};
  my $extended_name    = $FORM{"extended_name$pgitemcnt"};
  my $f1st2nd3rd_world = $FORM{"f1st2nd3rd_world$pgitemcnt"};
  my $fertility_rate   = $FORM{"fertility_rate$pgitemcnt"};
  my $population       = $FORM{"population$pgitemcnt"};
  my $pop_growth_rate  = $FORM{"pop_growth_rate$pgitemcnt"};
  my $sustainability_index = $FORM{"sustainability_index$pgitemcnt"};
  my $humanity_index   = $FORM{"humanity_index$pgitemcnt"};

  if($addchgregion =~ /A/) {
	  $reg_add_sql = "INSERT REPLACE INTO regions (seq,r_type,regionname,rstarts_with_the,regionmatch,rnotmatch,members_ids,continent_grp,location,extended_name,f1st2nd3rd_world,fertility_rate,population,pop_growth_rate,sustainability_index,humanity_index) 
	VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	  my $reg_add_sth = $dbh->prepare($reg_add_sql); 
      $reg_add_sth->execute($seq,$r_type,$regionname,$rstarts_with_the,$regionmatch,$rnotmatch,$members_ids,$continent_grp,$location,$extended_name,$f1st2nd3rd_world,$fertility_rate,$population,$pop_growth_rate,$sustainability_index,$humanity_index);
	  $regionid = $dbh->do("SELECT MAX(regionid) FROM regions");	
  }
  else {
      my $reg_update_sql = 
"UPDATE regions SET seq = \'$seq\', r_type = \'$r_type\', regionname = \'$regionname\', rstarts_with_the = \'$rstarts_with_the\', " .
"regionmatch = \'$regionmatch\', rnotmatch = \'$rnotmatch\', members_ids = \'$members_ids\', " .
"continent_grp = '$continent_grp', location = \'$location\', extended_name = \'$extended_name\', " .
"f1st2nd3rd_world = \'$f1st2nd3rd_world\', population = \'$population\', pop_growth_rate = \'$pop_growth_rate\', " .
"extended_name = \'$extended_name\', sustainability_index = \'$sustainability_index\', humanity_index = \'$humanity_index\' " .
"WHERE regionid = \'$regionid\'";	 

   $dbh->do($reg_update_sql) or die "DB Update region $region failed<br>\n";
   }
   return($regionid);
}

1;