#!/usr/bin/perl --

## March 21 2014

sub DB_get_switches_counts
{
	my $name;
	my $switch_count = 0;
	$DB_doclist  = 0; # switch: view a list of articles using DB if > 0
	$DB_docitems = 0;
	$DB_regions  = 0;
	$DB_sources  = 0;
	$DB_sectsubs = 0;
	$DB_users = 0;
	$DB_others   = 0;	
	$doc_update_sth = "";
	$doc_insert_sth = "";
    $idx_insert_sth = "";

	unless($DBH) {
		$DBH = &db_connect() or die("could not connect");  #in database.pl
	}

 	if(!$DBH or -f "$pophome/dbconnect.off") {
	    print "<span style=\"color:#aaf;\">*</span>	<span style=\"color:#fff;\">DB connection failed - using flatfiles</span><br>\n";
	    return();
    }
	my $switch_sth = $DBH->prepare("SELECT name, switch_count FROM switches_counts") or die "DB Error preparing switch_count query";
	if($switch_sth) {
	    $switch_sth->execute() or die "Couldn't execute switch_count table select statement: ".$switch_sth->errstr;
	    if ($switch_sth->rows == 0) {
	    }
	    else {
		   while ( ($name,$switch_count) = $switch_sth->fetchrow_array() )  {
				$DB_docitems = $switch_count if($name =~ /DB_docitems/);
				$DB_regions  = $switch_count if($name =~ /DB_regions/);
				$DB_sources  = $switch_count if($name =~ /DB_sources/);
				$DB_sectsubs = $switch_count if($name =~ /DB_sectsubs/);
				$DB_users    = $switch_count if($name =~ /DB_users/);
				$DB_others   = $switch_count if($name =~ /DB_others/);  # all other tables
				$gTrace      = $switch_count if($name =~ /Trace/);
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

	sub create_switches_counts
	{
		$DBH = &db_connect();

		dbh->do("DROP TABLE IF EXISTS switches_counts");

	$sql = <<ENDSWITCHES;
		CREATE TABLE switches_counts (
			name         varchar(20) not null,
			switch_count integer unsigned default 0,
			description  varchar(70)
			)
ENDSWITCHES

		$sth2 = $DBH->prepare($sql);
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
	  my $num = $count+1;
	  print(NEWCOUNT"$num\n");
	  close(NEWCOUNT);

	  $count = &pad_count("$count");
	}

	sub getAddtoCount ## Gets the Count and adds to it - replaces get_count later
	{  
	  my $countcode = $_[0];

	  my $count = &getCount($countcode);
	  my $num = $count + 1;
	  $count = &padCount6($num) if($countcode =~ /doc/);
	  $count = &padCount4($num) if($countcode =~ /popnews/);
	  &writeCount($countcode,$count);  
	  return($count);
	}

	sub subtractFromCount
	{
	  my $countcode = $_[0]; 
	  my $count = &getCount($countcode);
	  my $num = $count - 1;
	  $count = &padCount6($num) if($countcode =~ /doc/);
	  $count = &padCount4($num) if($countcode =~ /popnews/);     
	  &writeCount($countcode,$count);                    ## This read &writeCount($countcode,$count); Why??? Worked before GIT_PATHS 

	  return($count);
	}

	sub getCount
	{
	  my $countcode = $_[0];
	  my $count;
	  my $countfile;
	  if($countcode =~ /doc/) {
	    $countfile = $doccountfile;
	  }
	  elsif($countcode =~ /popnews/) {
	    $countfile = $popnews_countfile;
	  }

	  open(COUNT, "$countfile") or printSysErrExit("Could not open $countfile : @ 278 misc_dbtables ..countcode $countcode<br>\n");;
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
	 my($countcode,$count) = @_;
	 my $countfile = "";
	 if($countcode =~ /doc/) {
	   $countfile = $doccountfile;
	 }
	 elsif($countcode =~ /popnews/) {
	   $countfile = $popnews_countfile;
	 }  
	 open(NEWCOUNT, ">$countfile") or printSysErrExit("Could not open $countfile : @ 299 misc_dbtables ..countcode $countcode<br>\n"); 
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

1;