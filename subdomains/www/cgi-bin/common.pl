#!/usr/bin/perl --

# common.pl   May 2010    

## sets up paths and server-dependent variables
## depending on which server & website we're on

## Note: every variable here is a global

## 2010 Nov 21 - changed autosubmit/prepage to /prepage
## 2010 Aug 25 - added:   $default_newssec = "Headlines_sustainability"; to facilitate fixes in sections.pl - newsprocsectsubs
## 2010 Apr 27 - added Karens Mac paths; fixed subdomain
## 2008 May 26 - added choppedline_convert: change back to normal: lines that are broken to make short lines (usually 72) for email
## 2006 Jan 07 - do_email fixed for anti-spam - from adminEmail address only

sub get_site_info
{
 %GLVARS = ();
 $GLVARS{'contactEmail'}      = "karen4329\@karengaia.net";
 $GLVARS{'contactEmail_html'} = "karen4329&#64;karengaia.net";
 $GLVARS{'adminEmail'}        = "karen4329\@karengaia.net";
 $GLVARS{'email_std_end'}     = "Thank you.\n\n Karen Gaia Pitts,\n editor and publisher\n World Population Awareness\n	PO Box 3022\n Granite Bay, CA 95746\n $adminEmail\n";
 $GLVARS{'std_headtop'}       = "<html xmlns=\"http://www.w3.org/1999/xhtml\" >\n<head>\n";
 $GLVARS{'std_meta'}          = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />\n";
 $contactEmail                = "karen4329\@karengaia.net";
 $contactEmail_html           = "karen4329&#64;karengaia.net";
 $contactEmail                = "karen4329\@karengaia.net";
 $adminEmail                  = "karen4329\@karengaia.net";
 $email_std_end = "Thank you.\n\n Karen Gaia Pitts,\n editor and publisher\n World Population Awareness\n 6610 Folsom Auburn Rd. Ste 5-4\n Folsom CA 95630-2146\n $adminEmail\n";

## Maybe just need public => "/www" in Telana server
## public     => "subdomains/www",
  $slash = "\/";

  my $base_dir       = $PATHS{'base_dir'};   # PATHS is set in bootstrap.pl
  my $subdomains_dir = $PATHS{'subdomains_dir'};
  my $public_dir     = $PATHS{'public_dir'};
  my $cgi_dir        = $PATHS{'cgi_dir'};

  $doc_root = dirname($public_dir);


 %TELANAsvr = (
  environment => 'production',
  svrname    => "TELANA",
  IP         => "www.overpopulation.org",
  app_dir    => $base_dir,
  home       => $base_dir,
  public     => "subdomains/www",
  subdomain  => "www\.",
  sshpath    => "/usr/bin/ssh",
  sendmail   => "|/usr/sbin/sendmail -t",
  cgiPath    => "cgi-bin/cgiwrap/popaware",
  cgiSite    => "overpopulation.org",
##  cgiSite    => "population-awareness.net",
  acctID     => "overpop",
  inboxpath => "popnews_inbox",
  mailpath   => "popnews_mail",
  mailbkppath => "popnews_bkp",
  sepmailpath => "subdomains/www/popnews_sepmail",
  nodupmailpath => "subdomains/www/popnews_nodupmail",
  mailbkp     => "subdomains/www/popnews_bkp",
  hitCntPath => "subdomains/www",
  maillistpath => "subdomains/www/mail-list",
  ); 
  
  %DEVELOPMENTsvr = (
    svrname    => "KPMac",
    IP         => "127.0.0.1",
    app_dir    => $base_dir,
    home       => $base_dir,
    public     => "subdomains/www",
    subdomain  => "",
    sshpath    => "/usr/bin/ssh",
    sendmail   => "|/usr/sbin/sendmail -t",
    cgiPath    => "cgi-bin",
    cgiSite    => "overpop",
    acctID        => "overpop",
    inboxpath     => "popnews_inbox",
    mailpath      => "popnews_mail",
    mailbkppath   => "popnews_bkp",
    sepmailpath   => "subdomains/www/popnews_sepmail",
    nodupmailpath => "subdomains/www/popnews_nodupmail",
    mailbkp       => "subdomains/www/popnews_bkp",
    hitCntPath    => "subdomains/www",
    maillistpath  => "subdomains/www/mail-list",
   );

##              directory structure of the two servers is different

  if(-f "$base_dir/development.yes") {
    %SVRinfo = %DEVELOPMENTsvr;
    %SVRdest = %TELANAsvr;
    $subdomain = $SVRinfo{'subdomain'};
  }
  elsif(-f "/home/overpop/www/overpopulation.org/subdomains/www/Telana.yes") {
	$doc_root = "subdomains/www";   
    %SVRinfo = %TELANAsvr;
    %SVRdest = %DEVELOPMENTsvr;
    $subdomain = $SVRinfo{'subdomain'};
  }
  elsif(-f "/home/overpop/www/overpopulation.org/subdomains/telana/Telana.yes") {
	%SVRinfo = %TELANAsvr;
    $subdomain = "telana";
  }

  # Derived values
  $SVRinfo{'public_dir'} = "$SVRinfo{home}/$SVRinfo{public}";
  $SVRinfo{'cgi_dir'} = "$SVRinfo{public_dir}/$SVRinfo{cgiPath}";

  $svrname    = $SVRinfo{'svrname'};
  $sendmail   = $SVRinfo{'sendmail'};
  $pophome    = $SVRinfo{'home'};
  $cgiSite    = $SVRinfo{'cgiSite'};  
  $cgiPath    = $SVRinfo{'cgiPath'};
  $cgiPath    = "$cgiSite/$cgiPath";  
  $publicUrl  = "$subdomain$cgiSite";
  $scriptpath = "$subdomain$cgiPath";
  $test_scriptpath = "$DEVELOPMENTsvr{cgiSite}/$DEVELOPMENTsvr{cgiPath}";

  $publicdir  = $SVRinfo{'public_dir'};
  
  $autosubdir     = "$publicdir/autosubmit";
  $controlpath    = "$autosubdir/control";
  $expcontrolpath = "$autosubdir/controlExport";
  $bkpcontrolpath = "$autosubdir/control_Bkp";
  $templatepath   = "$autosubdir/templates";
  $templateMidpath = "$autosubdir/templatesMid";
  $itempath       = "$autosubdir/items";
  $itempathsave   = "$autosubdir/itemsSave";
  $expitempath    = "$autosubdir/itemsExport";
  $sectionpath    = "$autosubdir/sections";
  $expsectionpath = "$autosubdir/sectionsExport";
  $deletepath     = "$autosubdir/deleted";
  $priority5path  = "$autosubdir/priority5";
  $keywordpath    = "$autosubdir/keywords";
  $logpath        = "$autosubdir/log";
  $statuspath     = "$autosubdir/status";
  $elistpath      = "$autosubdir/elists";
  $popnewspath    = "$autosubdir/popnews";

  $prepagepath   = "$publicdir/prepage";
    
  $maillistpath  = $SVRinfo{'maillistpath'};
  $inboxpath     = "$pophome/$SVRinfo{inboxpath}";
  $mailpath      = "$pophome/$SVRinfo{mailpath}";
  $mailbkppath   = "$pophome/$SVRinfo{mailbkppath}";
  $sepmailpath   = "$pophome/$SVRinfo{sepmailpath}";
  $nodupmailpath = "$pophome/$SVRinfo{nodupmailpath}";
  $mailbkp       = "$pophome/$SVRinfo{mailbkp}";
  $applymailpath = "$pophome/$SVRinfo{applymailpath}";   
  $hitCntPath    = "$pophome/$SVRinfo{public}/counter";
  $popnews_file  = "$pophome/$SVRinfo{maillistpath}/popnews.email";
  
  $destserv      = "$SVRdest{acctID}\@$SVRdest{IP}";

  $dest_home     = $SVRdest{'home'};
  $dest_public   = $SVRdest{'public'}; 

##  Note: for ftp we start at account

  $dest_publicpath    = "$dest_public";
  $dest_autosubdir    = "$dest_publicpath/autosubmit";
  
  $dest_controlpath   = "$dest_autosubdir/control";
  $dest_templatepath  = "$dest_autosubdir/templates";
  $dest_itempath      = "$dest_autosubdir/items";
  $dest_itempathsave  = "$dest_autosubdir/itemsSave";
  $dest_sectionpath   = "$dest_autosubdir/sections";
  $dest_prepagepath   = "$dest_autosubdir/prepage";
  $dest_deletepath    = "$dest_autosubdir/deleted";
  $dest_keywordpath   = "$dest_autosubdir/keywords";
  $dest_logpath       = "$dest_autosubdir/log";
  $dest_statuspath    = "$dest_autosubdir/status";
  
  $dest_mailpath      = "popnews_mail"; 
  $dest_mailbkp       = "popnews_bkp"; 
  $dest_hitCntPath    = "$SVRdest{public}/counter";


  $SVRinfo{'master'}    = 'yes' if("-f $statuspath/masterserver.on");
  $svr_master         = $SVRinfo{'master'};
    
  $dbgmsg =  "masterON?-<br>\n" if($debug =~ /Y/);
  
  $recentpath    = "$sectionpath/recent.idx";
  $sectionctrl   = "$controlpath/sections.html";
  $contributors  = "$controlpath/contributors.html";
  $users         = "$controlpath/users.html";
  $editors       = "$controlpath/editors.html";
  $sources       = "$controlpath/sources.html";
  $regions       = "$controlpath/regions.html";
  $newsources    = "$controlpath/newsources.html";
  $styles        = "$controlpath/styles.html";
  $keywordlist   = "$controlpath/keywords.html";
  $newkeywords   = "$controlpath/newkeywords.html";
  $oldkeywords   = "$controlpath/oldkeywords.html";
  $errlogpath    = "$logpath/errlog.html";
  $logpath       = "$logpath/log.html";
  $errlog_old    = "$logpath/errlog.old";
  $hitcountfile  = "$publicdir/counter/count.txt";
  $doccountfile  = "$controlpath/doccount";
  $popnews_countfile = "$controlpath/popnewscount";
  $usercntfile   = "$controlpath/usercount.txt";
  $futzingON     = "$statuspath/futzing.on";
  $futzingOFF    = "$statuspath/futzing.off";
  $printdeletedOFF = "$statuspath/printdeleted.off";
  
  $time4countfile = "$autosubdir/status/time4count.txt";
  unlink $time4countfile if(-f $time4countfile);

#  GLOBAL VARIABLES

  $errmsg = "";
  $FTPopen = "N";
  $FTPmsg  = "";
  $LastDest = "";
##  $punctuation   = "\!\@\#\$\%\^\&\*\(\)\+\_\-\=\{\}\|\:\"\;\'\"\<\>\?\/\,\.\]\[\`\~\\";
  $punctuation   = "!\@#$%^&*()+_\-={}|:;<>?/,.[]~\"\'\`";
  $alphanumeric  = "A-Za-z0-9";
  $space         = ' ';
   
  $adminMsgFont = "<font size=2 face=\"comic sans ms\" color=#CC6666>";
# meta characters
  $mLT    = '&lt;';
  $mGT    = '&gt';
  $mQUOTE = '&quot;';
  $mAMP   = '&amp;';
  $mCOPY  = '&copy;'; ## copyright symbol
  $mBUL   = '&middot;';

  $DELETELIST = "";
  %USRINDEX    = {};
  %EDITOR      = {};
  %EDITORINDEX = {};
  %CSINDEX     = {};
  %DOCARRAY    = {};
  %USERidINDEX = {};
  $CONTRIB_DATA = "";
  
  $gContent_type_html = "Content-type:"."text/"."html\n\n";
  return();
}


sub backup_setup_flatfile
{
  my($filepath,$filebkppath,$fileorigpath) = @_;
  my $result = "";

  if(-f $filepath) {
	  if($fileorigpath) {
	      system "cp $filepath $fileorigpath" unless(-f $fileorigpath);   # backup original if first time
	  }
      my $secs = 0;
	  unlink($filebkppath)  if(-f $filebkppath);
	  while(-f $filebkppath) {
	     sleep (5);
	     $secs = $secs + 5;
	     if($secs > 40) {
		    $result = "File bkp was not deleted - $filebkppath in backup_unlink_flatfile  cm263" if(-f $filebkppath);
		    &printInvalidExit($result);
	     }
	  }

	  system "cp $filepath $filebkppath";   # back up old users.html path
	  $secs = 0;
	  until(-f $filebkppath) {
	     sleep (5);
	     $secs = $secs + 5;
	     if($secs > 40) {
		    $result = "File was not copied to bkp - $filebkppath in  backup_unlink_flatfile  cm263" unless(-f $filebkppath);
		    &printInvalidExit($result);
	     }
	  }
	  unlink($filepath);
	  $secs = 0;
	  while(-f $filepath) {
	     sleep (5);
	     $secs = $secs + 5;
	     if($secs > 40) {
	        $result = "File was not deleted - $filepath in backup_unlink_flatfile  cm263" if(-f $filepath);		    
	        &printInvalidExit($result);
	     }
	  }
  }

  if($SVRinfo{'environment'} == 'development') {  ## set permissions if using Karen's Mac as the server
    system('touch $filepath') unless(-f '$filepath');
    system('chmod 0777, $filepath');
  }
  return("");
}


## Waits until a file locked by another user is no longer 
## locked and then returns - to be locked if file is being written to

sub waitIfBusy
{
   my $lock_file = $_[0];
   my $relock    = $_[1];
   my ($now,$age,@stat,$r);
   while(-f "$lock_file")   # Check for a lock file
   {
     @stat = stat("$lock_file");   # Gets stats for a file
     $now = time;
     $age = $now - $stat[9];        # $stat[9]  = timestamp in seconds for last mod
     if($age > 20)   {
        unlink  "$lock_file";    # Deletes the lock file if  > 20 secs
#        &errLogit("unlocking $lock_file - too old",$cmd,$action,$docid,$docaction,$operator_access,$userid,$sectsubname);
     }
     else  {
        sleep 1;     # Wait a second
     }
   }
   system "touch $lock_file" if($relock eq 'lock'); #unlock must be done in calling routine
}
 

sub tooMuchLooping
{
  local($startTime,$timeLimit,$codeLocation) = @_;
  local($secondsPassed) = time - $startTime;
  if($secondsPassed > $timeLimit) {
    $errmsg = "$codeLocation - Excessive looping - over expected : $timeLimit seconds";
    
    &printSysErrExit("$codeLocation - Excessive looping - over expected : $timeLimit seconds");
    
    return 1;
  }
  else {
    return 0;
  }
}


### DATA MANIPULATION

sub trim
{
 my $string = shift;
 $string =~ s/^\s+//;
 $string =~ s/\s+$//;
 return $string;
} 

sub pad_count
{
 my $count = $_[0];
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
  my $count = $_[0];
  $count =~  s/^0+//;     ## strip leading 0s
  return "000$count" if($count < 10);
  return "00$count" if($count < 100);
  return "0$count" if($count < 1000);
}

sub padCount6
{
  my $count = $_[0];
  $count =~  s/^0+//;      ## strip leading 0s
  return "00000$count" if($count < 10);
  return "0000$count" if($count < 100);
  return "000$count" if($count < 1000);
  return "00$count" if($count < 10000);
  return "0$count" if($count < 100000);
}


sub strip0s_fromCount
{
  my $count = $_[0];
  $count =~  s/^0+//;
  return $count;
}

sub prep_for_regexp
{
 my $datafield = $_[0];
 $datafield =~ s/\(/&&LP;/g;
 $datafield =~ s/\)/&&RP;/g;
 $datafield =~ s/\//&&BS;/g;
 $datafield =~ s/\"/&&QT;/g;
 $datafield =~ s/\'/&&SQ;/g;
 $datafield =~ s/\@/&&AT;/g;
 $datafield =~ s/\*/&&AS;/g;
 $datafield =~ s/\[/&&LB;/g;
 $datafield =~ s/\]/&&RB;/g;
 return $datafield;
}


sub reverse_regexp_prep
{
 local($datafield) = $_[0];
 $datafield =~ s/\&\&LP\;/\(/g;
 $datafield =~ s/\&\&RP\;/\)/g; 
 $datafield =~ s/\&\&BS\;/\//g;
 $datafield =~ s/\&\&QT\;/\"/g;
 $datafield =~ s/\&\&SQ\;/\'/g;
 $datafield =~ s/\&\&AT\;/\@/g;
 $datafield =~ s/\&\&AS\;/\*/g;
 $datafield =~ s/\&\&LB\;/\[/g;
 $datafield =~ s/\&\&RB\;/\]/g;
 return $datafield;
}


## 00480 Remove leading white space, extra spaces, and extra line breaks

## we need this because the strip_leadingSPlineBR does not work right

sub leadingSPlineBR
{
  $line =~ s/^\s+//g;                         # eliminate leading white spaces
  $line =~ s/\[\t]+//g;                       # no need for tabs
  $line =~ s/\r\n/\n/g;                       # eliminate DOS line-endings
  $line =~ s/\n\r/\n/g;
  $line =~ s/\r/\n/g;
  $line =~ s/\n\s\n/\n\n/g;
  if($dTemplate !~ /[A-Za-z]/) {
     $line =~ s/\n[\n]+/<P>/g;                   # temporary
     $line =~ s/<[Bb][Rr]>(<[Bb][Rr]>)+/<P>/g;   #two or more breaks to paragraph
##     $line =~ s/\n/ /g; # single LF go bye-bye
     $line =~ s/<[Pp]>(<[Pp]>)*/\n\n/g;
  }
}


sub strip_leadingSPlineBR
{ 
  local($datafield) = $_[0];
  $datafield =~ s/^\s+//g;                         # eliminate leading white spaces
  $datafield =~ s/\[\t]+//g;                       # no need for tabs
  $datafield =~ s/\r\n/\n/g;                       # eliminate DOS line-endings
  $datafield =~ s/\n\r/\n/g;
  $datafield =~ s/\r/\n/g;
  $datafield =~ s/\n\s\n/\n\n/g;
  if($dTemplate !~ /[A-Za-z]/) {
     $datafield =~ s/\n[\n]+/<P>/g;                   # temporary
     $datafield =~ s/<[Pp]>(<[Pp]>)*/\n\n/g;
  }
  return($datafield);
}

sub strip_leadingNonAlphnum	
{ 
  my $datafield = $_[0];
  $datafield =~ s/^\w+//g;                         # eliminate leading non AlphaNumeric
  return($datafield);
}

sub stripLeadgTrailgSP
{
  my($datefield,$garbage) = @_;
  $datafield =~  s/^\s*//mg; # strip leading spaces
  $datafield =~ s/\s+$//mg; ## strip trailing spaces
  return($datafield);
}

sub separate_with_Parens
{
 my($datafield) = $_[0];
 my $rest = "";
  $_ = $datafield;
 tr/()/|~/;       # change Left parens to | and right parens to ~
 $datafield = $_;
 if($leftRight = 'L') {
    ($datafield,$rest) = split(/|/,$datafield,2);
 }
 else {
    ($datafield,$rest) = split(/~/,$datafield,2);
 }
 $_ = $datafield;
 tr/|~/()/;        # change back to ()
 $datafield = $_;
 return($datafield); 
}

sub separate_variable_into_parts
{
 my($variable,$sepsymbol,$partnum) = @_;
  if($sepsymbol =~ /\(/ or $sepsymbol =~ /\)/){
     $_ = $variable;
     tr/()/|~/;       # change Left parens to | and right parens to ~
     $variable = $_;
     $sepsymbol = '|' if($sepsymbol =~ /\(/);
     $sepsymbol = '~' if($sepsymbol =~ /\)/);
     $variable = &do_split_variable($variable,$sepsymbol,$partnum);
     $_ = $variable;
     tr/|~/()/;       # change back
     $variable = $_;
  }
  else {
     $variable = &do_split_variable($variable,$sepsymbol,$partnum);	
  }
  return($variable);
} 
  

sub do_split_variable
{
 my($variable,$sepsymbol,$partnum) = @_;
 my($rest,$rest1,$rest2,$rest3,$rest4,$rest5);
 
  ($variable,$rest)               = split(/$sepsymbol/,$locline,2) if($partnum eq '1');
  ($rest1,$variable,$rest)        = split(/$sepsymbol/,$locline,3) if($partnum eq '2');

  ($rest1,$rest2,$variable,$rest) = split(/$sepsymbol/,$locline,4) if($partnum eq '3');
  ($rest1,$rest2,$rest3,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,5) if($partnum eq '4');
  ($rest1,$rest2,$rest3,$rest4,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,6) if($partnum eq '5');
  ($rest1,$rest2,$rest3,$rest4,$rest5,$variable,$rest) 
                     = split(/$sepsymbol/,$locline,7) if($partnum eq '6');

  if($partnum eq 'N') {
      ($rest1,$rest2,$rest3,$rest4,$variable) = split(/$sepsymbol/,$locline,5);
      $variable = $rest4 if($variable eq "");
      $variable = $rest3 if($variable eq "");
      $variable = $rest2 if($variable eq "");
      $variable = $rest1 if($variable eq "");
  }
  if($partnum eq 'N-1') {
      ($rest1,$rest2,$rest3,$rest4,$rest5) = split(/$sepsymbol/,$locline,5);
      $variable = $rest4 if($rest5 ne "");
      $variable = $rest3 if($rest5 eq ""  and $rest4 ne "");
      $variable = $rest2 if($rest5 eq ""  and $rest4 eq "" and $rest3 ne "");
      $variable = $rest1 if($rest5 eq "" and $rest4 eq "" and $rest3 eq "");
  }
  return($variable);
}


## strip examples - do they work?
sub strip_examples
{
 s/^\s*#.*//g;			# strip comments (white space, #, and all following

# replace 342 and 343 octal with [ and ] 
		tr/\342/[/ if $brackets ;
		tr/\343/]/ if $brackets ;

# replace bad chars with blanks if desired
	($_ =~ s/[\000-\011]|[\013-\037]|[\177-\377]/ /g);

# Strip trailing whitespace if desired
		($_ =~ s/  *$//);
		
# Strip out leading formatting characters replace with blanks
		s/^[01+-]/ /;

##Match two words and reverse order - prints def abc

$string = "abc def";
$string =~ s/^(\w+) (\w+)$/$2 $1/;
print $string;


$author =~ s/\(.*?\)//s;
$author =~ s/^,|,$//s;	
  
  
$editor =~ s/\.//;	#strip leading .
  
$bibauthors =~ s/and\s+$//;	 # strip last 'and'

# checks if alphanumeric      
 if ($author =~ /\w+/) { 
 }
}


### 600 PARSES FORM ELEMENTS ####
 
 sub parse_form
{
#  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  my $buffer = $_;
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}) if(!$buffer);
  @pairs = split(/&/, $buffer);
  foreach $pair (@pairs)
  {
	   ($name, $value) = split(/=/, $pair);
	   $value =~ tr/+/ /;
	   $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	   $value =~ s/~!/ ~!/g;
	   $value =~ s/\n//g;

	   if($FORM{$name})
	   {
	     $FORM{$name} = "$FORM{$name};$value";
	   }
	   else
	   {
	     $FORM{$name} = $value;
	   }
  }
}

1;