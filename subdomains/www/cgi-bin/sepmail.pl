#!/usr/bin/perl


## escape these meta characters:   .^*+?{}()[]\|  and / if using as a delimiter
##  * Match 0 or more times   + Match 1 or more times    ? Match 1 or 0 times

## July 1, 2011 - Splitting into getmail.pl and new version of sepmail.pl; Not doing Feb 22 below

## Feb 22, 2011 - Reduced functionality, moving most into parsemail.pl, due to large file processing resulting in NO results.
##                Now reading one line at a time. Hope this works on ippf

# 2011 Feb 16 - enlarged functionality: found date, subject, handle; did weird character conversion to ascii;
#              chopped off excess at top and bottom; added sepmail functionality
# 2010 July 22 - buffer too small; broke into lines while reading in

### =E2[#x20ac][#x160]'You have to control your sister.

sub separate_out_email {
  
   $g_buffer = "";
   $g_op_filename = "";
   $g_handle = "";
   $g_ext = "";
   $g_subject = "";
   $g_fromemail = "";
   $g_subject_line = "";
   $g_from_line = "";
   $g_sentdatetm = "";
#  $mailpath and $mailbkppath determined in common.pl

  opendir(POPMAILDIR, "$mailbkppath");  # overpopulation.org/popnews_bkp <- This is where getmail.pl puts it
  my(@popnewsfiles) = grep /^.+\.bkp1$/, readdir(POPMAILDIR);
  closedir(POPMAILDIR);

  foreach $filename (@popnewsfiles) {
	   $mailbkpfile = "$mailbkppath/$filename";
	   if(-f "$mailbkpfile" and $filename =~ /\.bkp/) {
          $g_buffer = "";
	      ($g_handle,$g_ext,$g_subject,$g_fromemail,$g_sentdatetm) 
	         = &get_email_handle_etc($mailbkpfile); # first pass of email; generates $g_buffer with email message in it

		  if($g_ext =~ /app/) {
			 ($filename,$rest) = split(/\./,$filename);
		  	 $appfilepath = "$mailpath/$filename.app";
			 system "cp $bkpfilepath $appfilepath";
			 unlink $bkpfilepath;
			 exit(0);
		  }
		  my $op_filename = "$g_sentdatetm-$g_handle";
		   
		  if(&ck_dup_email("$op_filename")) {  ## skip this if duplicate <-----------------
		     next;
		  }
		  $g_op_filename = $op_filename;  #save in a global because open is accessed so much
		
		  &separate_parse_email;
		
		  #unlink $bkpfilepath;  <---- not yet ------------	
	   }
  }
  return 0;
}
	
sub get_email_handle_etc {    # Generates a $g_buffer with the email message in it.
  my($mailbkpfile) = $_[0];	

  my $sentdatetm = "";
  my $handle = "";
  my $ext = "email";
  my $from_line = "";
  my $subject_line = "";
  my $line = "";

  open(EMAILBKP, "<$mailbkpfile");  #open this file twice
  while (<EMAILBKP>) 
  {          #      first pass
	$line = $_;	
	chomp($line);
#	print "sep72 line $line<br>\n";
	$g_buffer = "$g_buffer$line\n";
	
	if($line =~ /pushjournal/) {
		$handle = "push";
	}
	elsif($line =~ /populationmedia/) {
		$handle = "pmc";
	}
	elsif($line =~ /google\.com/) {
		$handle = "goog";
	}
	elsif($line =~ /npg\.org/) {
		$handle = "npg";
	}		
	elsif($line =~ /ippf\.org/) {
		$handle = "ippf";
	}
	elsif($line =~ /karen\.gaia\.pitts/ and !$handle) {
		$handle = "kgp";
	}
	elsif($line =~ /patachek/) {
		$handle = "pat";
	}
	
	if($line =~ /WOA APP::/) {
		$ext = 'app';
	}	
	elsif($line =~ /^[fF]rom:/) {
       $from_line = $line;
	}
	elsif($line =~ /^[dD]ate:/) {
       $date_line = $line;
	}
	elsif($line =~ /^[Ss]ubject:/) {
       $subject_line = $line;
	}
  }
  close(EMAILBKP);

  $handle = 'unk' if(!$handle);

  my $sentdatetm = &get_sentdatetm($date_line);

  print "*** ..HANDLE $handle ..IN $filename ..sentdatetm $sentdatetm \n";

  my $subject = &prep_subject($subject_line,$handle) if($subject_line);

  my $fromemail = &get_from_email($from_line) if($from_line);

  return($handle,$ext,$subject,$fromemail,$sentdatetm) ;
}
   

#   Process the file that was put in the $g_buffer by &get_email_handle_etc

sub separate_parse_email {
	$line = "";
	$msgtop = "";
	$msg_on = "";
	$msg_off = "Y";
	$op_ctr = 0;
	$sep_ctr = 0;
	$message = "";
	$prev_line = "";
	$headline_save="";	
	$end_header = "";  # Y = end of header detected; = (first blank line)
	$eof = "";
	$blank_ctr = 0;
	$equal_found = "";
	$pre_equal_found = "";
	$rs = 'F';

	($start,$stop,$separator,$seploc,$skip,$sepctr,$c_blank_ct) 
	   = &find_contributor($handle);
	
    my(@lines) = split(/\n/,$g_buffer);

	&open_op_email;  # first open (if grouped emails, will be more than one)
    
	my $rs = 'F';
	foreach $line (@lines) { 	
		if($g_handle =~ /goog/   # These Google emails are garbage
			     and ($line =~ /\QContent-Transfer-Encoding: base64\E/ or $line =~ /PT09IE/) ) {
		    &close_email;
		    sleep(10);
 		    unlink $bkpfilepath;
		    exit(0);
		};		
		$line = &line_end_fix($line); #  eliminate non-ascii line endings
		chomp($line);
	    $line =~ s/^=A0 //;
	
	    if(!$end_header and !$line) {
		   $end_header = 'Y';
		   next;
		}
		
		last if($line =~ /^~{5,}/ and $g_handle =~ /pmc/);
print"sep177 g_handle $g_handle<br>\n";
	
		$msg_on = 'Y' if($end_header and !$msg_on
	                     and (!$start or $line =~ /^$start/)  );

		$x = substr($line,0,25);
	#	print "***B***$x ...$handle .. end_hdr $end_header .. msg_on $msg_on ..start $start\n";
#		print "***B***$line\n" if($msg_on and !$msg_off);

	    if($keep = &do_line($line) ) {  # Save to popnews/.email file if not skipped
		    if($line) {
		        ($rs,$line) = &rs_url($rs,$line);  #looks for PMC's rs20 long URL and eliminates it.
		        next if(!$line);
		    }
		    $prev_line = $line;
		}
	}	# END WHILE

	&close_email;  ## close last file
}


######  SUBROUTINES  #######


sub do_line {
  my($line) = $_[0];
  my $keep = 'Y';
##          skip stuff and html version after text version of article
  $msg_off = 'Y' if($msg_on and $stop and $line =~ /^$stop/);

  if($msg_on and !$msg_off and ( ($line and $separator and $line =~ /$separator/) or ($blank_ctr >= $c_blank_ct and $c_blank_ct > 0) ) ) {
print "\n\n*** SEPARATOR  separator $separator ..sepctr $sepctr .. sep_ctr $sep_ctr ..eof $eof  ..op_ctr $op_ctr\n\n";
	 $sep_ctr = $sep_ctr + 1 if($sepctr =~ /[0-9]/);
	 if($sepctr !~/[0-9]/ or ($sepctr =~ /[0-9]/ and $sep_ctr >= $sepctr) ) {
		  $eof = 'T';
		  if( $locsep =~ /post/) {   ## post separator is after the separation
			 &close_email;
			 &open_op_email;
			 $keep = &check_skip($line);
		  }
		  elsif( $locsep = /after1st/) {
		      $headline_save = "$paragraph\n$line";
			  &close_email;
			  &open_op_email;
		  }
		  else { # first|pre     ## pre separator is before the separation
			 &close_email;
			 &open_op_email;
			 $keep = &check_skip($line);		
		  }
	}
    else {
	   $keep = &check_skip($line);	
    }
  }
  else {
	 $keep = &check_skip($line);	
  }
	print "sep234 msg_off $msg_off keep $keep ..ln $line<br>\n";				
  return($keep);
}

sub check_skip {
	 my($line) = $_[0];
		
	 if($msg_on and !$msg_off) {
	##     skip some things
		if( !$line) {
			&build_paragraph($line);
		}
		elsif ( $line !~ /^$skip/
		and $line !~ /\Q_Part_\E/
  		 and $line !~ /\Q--Apple-Mail\E/  
		 and $line !~ /_NextPart_|charset=/  
		 and $line !~ /message in MIME format/
		 and $line !~ /\QContent-Type: text\E/ 
		 and $line !~ /\QContent-Transfer-Encoding:\E/
		 and $line !~ /\QContent-Disposition:\E/
		 and $line !~ /\Qoctet-stream\E/	
		 and $line !~ /^Subject:/
		 and $line !~ /^From:/
		 and $line !~ /^To:/
		 and $line !~ /^Date:/
		 and $line !~ /^Content-Type:/
		 and $line !~ /^Copyright/
		 and $line !~ /^Privacy:/
		 and $line !~ /Forwarded Message/) {
	        $line = &bad_stuff_convert($line);
	        &build_paragraph($line);
	        return('Y');
		}
	 }
	 return("");	
}

sub rs_url {
	my($rs,$line) = @_;
	
	my $httpr20 = "\[http:\/\/r20";	
	my @words = split(/\s/,$line);
	my $size = scalar(@words);  #How many words?
	$line = "";

	foreach $word (@words) {
		if($word =~ /^$httpr20/) {  #if rs20 URL starts at beginning of word
		    $rs = 'T';
		}
		elsif($word =~ /\]$/ and $rs eq 'T') {  #if 
			$rs = 'F';
		}
		elsif($size eq 1 and $rs eq 'T') {  #if 
		}
		else {
			$line = $word . ' ';
			$rs = 'F';		
		}
	}
	$line =~ s/\s+$//mg; #strip trailing spaces
	return($rs,$line);
}
	
sub rs_url_old {
	my($rs,$line) = @_;
    my $httpr20 = "\[http:\/\/r20";
		
	if($line =~ /^$httpr20/ or $rs eq 'T') {  #if rs20 URL starts at beginning of line
	    $rs = 'T';
	    if($line =~ / /) {
		    ($rest,$line) = split(/ /,$line);
	    }
	    if($line !~ / /) {
		    $line = "";
	    }			
	}
	elsif($line =~ /$httpr20/) {   #if rs20 URL does not start at beginning of line
	    my($line,$line2) = split(/$httpr20/,$line);
	    if($line2 =~ /\]/) {
		    ($line2,$rest) = split(/\]/,$line2);
	    }
	    elsif($line2 =~ / /) {
		    ($line2,$rest) = split(/ /,$line2);
	    }
	    else {
		    $rs = 'T';     # the whole line is the rs20 URL
		    $line = "";
	    }
	    $line = $line1 . $line2;
	}
	if($line =~ /\]/ and $rs eq 'T') {
	   ($rest,$line) = split(/\]/,$line);
	   $rs = 'F';
	}
	return($rs,$line);
}

sub build_paragraph
{
  my($line) = $_[0];

  if(!$line) {   # blank line = next paragraph
	  $blank_ctr = 1 + $blank_ctr;
print "*** BLANK LINE .. blank_ctr $blank_ctr ..c_blank_ct $c_blank_ct\n";
      if($blank_ctr == 1) {
#		  $paragraph =~ s/\[http:\/\/r20\S+\]//g if($keep_rs6_link);
		  $paragraph =~ s/^ //;    # get rid of initial space
		  $paragraph =~ s/  / /g;  # eliminate double white space
      }
#	print "gm287 $handle .. $paragraph \n";
      $message = $message . "\n\n$paragraph" if($paragraph);
	  $paragraph = "";
  } 
  else {
	  $blank_ctr = 0;
	  if(!$equal_found) {
		$paragraph = "$paragraph $line";
	  }
	  else {
		$paragraph = "$paragraph$line";
	  }
	  
      $message = $message . "\n\n$paragraph" if($eof);
  }
  $equal_found = $pre_equal_found;
  $pre_equal_found = "";
}


sub open_op_email {
	my $filename = "";
	$message = "";
	$eof = "";
	$paragraph = "";
	$prev_line = "";	
	if($g_handle =~ /push/ or $g_handle =~ /ippf/) {
	   $op_ctr = 1 + $op_ctr;
	   $filename = "$g_op_filename-$op_ctr";	#global output filename	
	}
	else {
	   $filename = "$g_op_filename";
	}
	
	$emailpath = "$mailpath/$filename.email";
		
	if(-f "../../karenpittsMac.yes") {  ## set permissions if using Karen's Mac as the server
		if(-f '$emailpath') {}
		else {
			system('touch $emailpath');
			}
		system('chmod 0777, $emailpath');
	}
print "****OUT*** $emailpath<br>\n";
	open(EMAILOUT, ">>$emailpath");
	$message = "";
	$message = $message . "subject^$g_subject\n";
	$message = $message . "edate^$g_sentdatetm\n";
    $message = $message . "handle^$g_handle\n";
    $message = $message . "from^$g_fromemail\n";
    $message = $message . "emessage^";
    $paragraph = "";
	$paragraph = "$paragraph$headline_save\n"  if($locsep =~ /after1st/);
	$headline_save="";
	return ('T')
}

sub close_email {
	
#	$message = "$message\n$paragraph";   # last message
	$message =~ s/^\n+//;
	$message =~ s/\n\n\n/\n\n/g;
	print EMAILOUT $message;
	close(EMAILOUT);
}

sub get_from_email {
   my($fromline) = $_[0];
   my($fromemail) = "";
   if($fromline) {
	  my($mailuser,$domainfrom)  = split(/\@/,$fromline,2);
      my($rest,$mailuser)        = split(/\</,$mailuser,2) if($mailuser =~ /\</);
      my($domainfrom,$rest2)     = split(/\>| /,$domainfrom,2);
      $fromemail = "$mailuser\@$domainfrom";
   }
   else {
	  $fromemail - "karen.gaia.pitts@gmail.com"
   }
   return($fromemail)
}


sub prep_subject {
   my($subject,$handle) = @_;
   ($rest,$subject) = split(/:/,$subject,2);	
   $subject =~ s/ Fwd:// if($subject =~ /^ Fwd:/);
   ($rest,$subject) =~ split(/Fw:/,$subject,2) if($subject =~ /CCNR/ and $subject =~ /Fw:/);
   $subject =~ s/^\s+//;
   $subject =~ s/^ +//;
   $subject = "$handle:: $subject" if($handle =~ /pat/);
   return($subject); 	
}

		
sub find_contributor
{
  my($handle) = $_[0];
##     identifier, handle, start, stop, separator, seploc, skip
@contributors = (
	"pushjournal.org^push^Articles^Personal Preferences^------| ------^^Articles|Powered By LexisNexis|Terms and Conditions:|rights reserved.|------| ------^2",
	"populationmedia.org^pmc^^Best wishes^########^^########",
	"GOOGLE ALERTS^goog^^once a day Google^^^Google News Alert|news.google|=== News -",
	"ippf.org^ippf^Disclaimer^The content and opinions^blanks=3^^Disclaimer",
	"npg.org^npg^^^########^^########",
	"populationinstitute.org^popin^^^<li>^^",
	"WOA APP::^app^^^^",
	"karen.gaia.pitts^kgp^^From karen.gaia.pitts^########^^########",
	"matachek^pat^^^^",
	"CNRCC^cnrcc^^########^^########",
	"^unk^^^########^^########"
	);
		
  $save_handle = $handle;
  foreach $contributor (@contributors) {
	  ($c_handle,$start,$stop,$separator,$seploc,$skip,$sepctr,$c_blank_ct,$stop,$skip) = &do_contributor($contributor);
		#  print "gm165 $handle .. start $start .. stop $stop .. separator $separator .. seploc $seploc .. skip $skip \n";
	  return if($handle =~ /$c_handle/);
  }
}

sub do_contributor {
  local($contributor) = $_[0];
  my($identifier,$c_handle,$start,$stop,$separator,$seploc,$skip,$sepctr) = split(/\^/,$contributor,7);
  my $separator = "########" if(!$separator);
  my ($rest,$c_blank_ct) = split(/=/, $separator, 2) if($separator =~ /blanks/);
  my $stop = "@#&#%%@" if(!$stop);  # impossible - but null won't work
  my $skip = "@#&#%%@" if(!$skip);  # impossible - but null won't work
  return ($c_handle,$start,$stop,$separator,$seploc,$skip,$sepctr,$c_blank_ct,$stop,$skip);
}  

sub ck_dup_email
{
 local($filename_end) = $_[0];   # if dup found for 1st, exit - 
                                 # all others would be dupped as well
 opendir(POPMAILDIR, "$bkppath");
##   sentyyyy-mm-dd-hhmmss-handle-ctr
 my $filedupck = "";
 while ($filedupck = grep(/$filename_end/, readdir(POPMAILDIR) ) ){
	print "\n***DUP FILE FOUND: $filename_end SKIP THIS FILE $bkpfilepath\n\n";
	unlink $bkpfilepath;   # remove current file - it was already done
#	$dupfile = "$bkppath/$file";
#	unlink "$dupfile";
	closedir(POPMAILDIR);
	my $bkpdup = "$bkppath/$filedupck.dup";
	system 'touch $bkpdup';
	return('T');
 }
 closedir(POPMAILDIR);
 return("");
}

sub line_end_fix 
{
 local($datafield) = $_[0];
 $datafield =~ s/\n\r/\n/g;
 $datafield =~ s/\r\n/\n/g;
 $datafield =~ s/\r//g;
 $datafield =~ s/=20$//g;
 $datafield =~ s/=20//g;
 $datafield =~ s/=3D=30=41//g;  #hidden line break ??
 return($datafield);
}

##                converts quotes, hyphens and other wayword perversions
sub bad_stuff_convert
{
 local($datafield) = $_[0];
# ($datafield,$rest) = split(/=/,$datafield,2) if($datafield =~ /=\s*$/);
# print "SPLIT = ***$datafield\n";
 $r = rindex($datafield,'=');
 $l = length($datafield);
 if($r > 0 and $l > 60 and ($l - $r) < 2) {
   $datafield = substr($datafield, 0, $r);
   $pre_equal_found = 'Y';	
 }

print "***POS= : $r  L: $l ***$datafield\n";
 $datafield =~ s/= $//;            #eliminate ending =
 $datafield =~ s/=$//;            #eliminate ending =
 $datafield =~ s/=20$//;           #more ending stuff

 $datafield =~ s/=3D/*/g;          # bullet?

 $datafield =~ s/=B7//g;           # tab?
 
 $datafield =~ s/^=3D([a-z])/$1/g;   ## next line starts with lower case - not a paragraph
 $datafield =~ s/^=0D=0A([a-z])/$1/g;
  
 $datafield =~ s/([a-z0-9] )$/$1/ig;
 $datafield =~ s/ = $/ /g;  #end of line

 ##                             # single quote, apostrophe
 $datafield =~ s/L/'/g;    #81
 $datafield =~ s/&rsquo;/'/g;
 $datafield =~ s/=91/'/g;  #91
 $datafield =~ s/=92/'/g;  #92 
 $datafield =~ s/Â´/'/;
 $datafield =~ s/â€˜/'/g;
 $datafield =~ s/=E2=80=99/'/g;
 $datafield =~ s/â€™/&#39;/g;
 $datafield =~ s/=E2=90=99/&#39;/g; # same as proceeding
 $datafield =~ s/’/'/g;      # single quote
 $datafield =~ s/=2018/"/g; #right quote
 $datafield =~ s/=2019/"/g; #left quote
 
 ##                    # double quotes    
 $datafield =~ s/``/"/g;         
 $datafield =~ s/=93/"/g; #93
 $datafield =~ s/=94/"/g; #94
 $datafield =~ s/E/"/g;   #81
 $datafield =~ s/''/"/;   #doublequote
 $datafield =~ s/”/"/;    #backquote
 $datafield =~ s/“/"/;    #frontquote
 $datafield =~ s/``/"/g;  #double back tick
 $datafield =~ s/â€/"/g;  #double quote 2
 $datafield =~ s/â€œ/"/g; #double quote 3
 $datafield =~ s/=E2=80=9D/"/;  #double quote 3 - same as preceeding
 $datafield =~ s/=E2=80=9C/"/;  #double quote 3 - same as preceeding
 $datafield =~ s/“A/"/g; #double quote 4
 $datafield =~ s/”/"/g; #end quote

 $datafield =~ s/&#40;/\(/g;  # left parens
 $datafield =~ s/&#41;/\)/g;  # right parens
 
 $datafield =~ s/&#91;/\[/g;  # left bracket
 $datafield =~ s/&#93;/\]/g;  # right bracket

 $datafield =~ s/=D0/-/g;    # 95    hyphen
 $datafield =~ s/=95/-/g;    # 95    hyphen
 $datafield =~ s/=96/-/g;    # 95    hyphen
 $datafield =~ s/=97/-/g;    # 95    hyphen
 $datafield =~ s/=3F/-/g;    # 95    hyphen
 $datafield =~ s/â€“/-/g;    #hyphen
 $datafield =~ s/–/-/g;      #hyphen
 $datafield =~ s/=E2=80/-/g;   # hyphen
 $datafield =~ s/=95/=2D/g;    #double hyphen

 $datafield =~ s/=A3/£/g;    # A3    pound sign

##                        special Latin characters
 $datafield =~ s/=E9/é/g;   
 
 $datafield =~ s/=A0/ /g;    #blank
 
 return($datafield);  	
}



sub get_sentdatetm {
	my($datafield) = $_[0];
	my $rest = "";
	my $sentdd = "";
	my $sentmon = "";
	my $sentyyyy = "";
	my $senttime ="";
	my $rest1 = "";
	$datafield =~ s/[Dd]ate://;
	$datafield =~ s/^\s+//;  ## remove leading blanks
    $datafield =~ s/  / /g;  ## change double blanks to single blanks
    if($datafield =~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/) {
	         # Date: Mon, 4 Jul 2011  Date: 05 Jul 2011 
	    ($rest,$sentdd,$sentmon,$sentyyyy,$senttime,$rest1) = split(/ /,$datafield,6);
    }
    else {    
        ($sentdd,$sentmon,$sentyyyy,$senttime,$rest1) = split(/ /,$datafield,5);
    }

    $senttime = $rest1 if($senttime =~ /[a-zA-Z]/);
    $senttime =~ s/://g;

    if($sentdd =~ /[a-zA-Z]/) {  #swap sentdd and sentmon
	   $rest1 = $sentmon;
	   $sentmon = $sentdd;
	   $sentdd = $rest1; 
    }

    $sentdd = '0' . $sentdd if($sentdd =~ /^[1-9]{1}$/); # pad if a single digit
    my $month_table = "01-Jan;02-Feb;03-Mar;04-Apr;05-May;06-Jun;07-Jul;08-Aug;09-Sep;10-Oct;11-Nov;12-Dec";
    my @months = split(/;/,$month_table);
    foreach $month (@months) {
		($sentmm,$mon) = split(/-/,$month);
	    if($sentmon =~ /$mon/) {
		  last;
	    }
	}
	
	$sentdatetm = "$sentyyyy-$sentmm-$sentdd-$senttime";
	$sentdatetm =~ s/,//;
	
	($sentdatetm,$rest1) = split(/ /,$sentdatetm);
	
    if(!$sentdatetm) {
	    $sentdatetm = &calc_date;
    }  
    return("$sentdatetm");
}


sub calc_date
{
   my $timesecs = time;
   my @current  = localtime($timesecs);
   my $sysmonth = $current[4];
   my $sysyear  = $current[5];
   my $sysday   = $current[3];
   my $syshour  = $current[2];
   my $sysmin   = $current[1];
   my $syssec   = $current[0];

   while($sysmonth > 11) {
      $sysmonth = $sysmonth-12;
      $sysyear  = $sysyear+1;
    }
   $sysmonth=$sysmonth+1;
   if($sysyear < 50) {
     $sysyear=$sysyear+2000;
    }
  else {
     $sysyear=$sysyear+1900;
   }

  $sysmm  = "$sysmonth";
  $sysmm  = "0$sysmm" if($sysmm < 10);
  $sysdd  = "$sysday";
  $sysdd  = "0$sysdd" if($sysdd < 10) ;
  $syshh  = "$syshour";
  $syshh  = "0$syshh" if($syshh < 10) ;
  $sysmin = $sysmin+1;
  $sysmin = "0$sysmin" if($sysmin < 10) ;
  $syssec = "0$syssec" if($syssec < 10) ;

  $sysdatetm = "$sysyear-$sysmm-$sysdd-$syshh$sysmin$syssec";
  return($sysdatetm);
}


1;

