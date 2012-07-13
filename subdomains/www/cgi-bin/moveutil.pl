#!/usr/bin/perl --

# moveutil.pl  .... May 7, 2010

##### NEED TO use utilities.pl instead!!! After testing

## 2007 May 7  - changes for Karens MAC server: add to push @INC
## 2005 Oct 2  - one 'move', do move for all files first, then do ftp for all files 2nd
## 2005 Aug 11 - added move from 'new' directory - to start a new version

require './bootstrap.pl';

print "Content-type: text/html\n\n";
##require 'ftpSync.pl';

$senderEmail = "minnie\@population-awareness.net";
$adminCode   = "purrl3491";

$lastFTPfile = "$statuspath/lastFTP.date";
$aLastFTPdate = "";
$min_chk      = 'N';
$max_chk      = 'N';
$filePrefix   = "";
$ftpSuccess   = 'N';
$ftpmsg       = "";
$lock_file    = "$statuspath/$filePrefix.busy";
$ftplogpath   = "$logpath/ftplog.html";

$binary = 'N';
$r = 0;         # return code
$FTPopen = 'N';

$source = "";
$outmsg = ""; 

if($ENV{QUERY_STRING})  {
   @info  = split(/\%/,$ENV{QUERY_STRING});
   $cmd          = $info[0];
   $filenames    = $info[1];
   $dirname      = $info[2]; # valid dirnames: mail, mailbkp,images,public,
##                           ## cgibin,clock,autosubmit, any under autosubmit
   $pathname     = $info[3];
   $aLastFTPdate = $info[4];
   $mindocid     = $info[5];
   $maxdocid     = $info[6];
   $printit = 'P';
}
else {
   &parse_form;
   $cmd          = $FORM{cmd};
   $filenames    = $FORM{filenames};
   $dirname      = $FORM{dirname};
   $pathname     = $FORM{pathname};
   $aLastFTPdate = $FORM{lastFTPdate};
   $mindocid     = $FORM{mindocid};
   $maxdocid     = $FORM{maxdocid};
   $printit = 'P';
}

if($cmd !~ /[A-Za-z0-9]/) {    ## get email command
   $printit = 'E';
##   &read_email; # CHANGE THIS TO ACCEPT EMAIL from minnie@population-awareness.net
   ($msg1,$rest) = split(/\n/,$message,2);

   if($msg1 =~ /(MOVE|move):/) {
     ($cmd,$code,$filenames) = split(/;/,$msg1,3);
     if($code ne $adminCode) {
        $subject  = "woaErr - $subject";
        $email_msg = "minnie dunno .. ask $adminEmail\n\n You wrote:\n\n$message";
##        &send_email;
        exit;
     }
     $filenames =~ s/^\s+//s;
     $filenames =~ s/\s+$//s;
   }
}
else {
  print "<font size=\"2\" face=\"arial\"><b>Autosubmit moving $filenames to public page. </b>... $cmd ... <br>\n"
    if($cmd =~ /move/);
}

$outmsg = "Autosubmit move/ftp utility. $filenames\n";

if($cmd =~ /autodir/) {
  &autodir;
}

elsif($filenames =~ /[A-Za-z0-9]/ and $cmd =~ /move|moveback/) {
  @filenames = split(/;/,$filenames);
  foreach $filename (@filenames) {
     if($cmd =~ /move|MOVE/) {     	  
        &movefile($filename);
     }
     elsif($cmd =~ /moveback/) {
       &moveback($filename);
    }
  }
#  foreach $filename (@filenames) {
#     if($cmd =~ /move|MOVE/) {     	  
#       &do_ftp("send,$publicdir/$filename.html,$binary,$SVRdest{public}/$filename.html");
#     }
#     elsif($cmd =~ /moveback/) {
#  ##         file name has been restored
#       &do_ftp("send,$publicdir/$filename.html,$binary,$SVRdest{public}/$filename.html");
#    }
#  }
}

elsif($cmd =~ /move0/) {
 &do_ftp("send,$publicdir/test.html,$binary,$SVRdest{public}/test_html");
}

elsif($cmd =~ /move1/) {
 &movefile("newsScan");
 &do_ftp("send,$publicdir/newsScan.html,$binary,$SVRdest{public}/newsScan.html");
}

elsif($cmd =~ /move2/)
{
 &movefile("newsScan");
 &movefile("headlines");
 &do_ftp("send,$publicdir/newsScan.html,$binary,$SVRdest{public}/newsScan.html");
 &do_ftp("send,$publicdir/headlines.html,$binary,$SVRdest{public}/headlines.html");
}

elsif($cmd =~ /bkup|unbkup|new/)
{
 &backup_restore_new;
}


if($cmd =~ /move/) {
&do_ftp('quit');

print <<END;
   <br><br><br><font face=verdana, size=2>
   Return to:

  <A HREF="http://$scriptpath/article.pl?display_section%%%Headlines_sustainability">Headlines</a>
  <p>
  </font>
END
}

&close_exit;


###  Subroutines

sub autodir	
{
  local(%filetypes) = (items => "itm", sections => "idx", keywords => "key", prepage => "html",
   mail => "email", mailbkp => "email", public => "html|htm|gif|jpg|GIF|JPG",
   cgibin => "pl|sh|js", images => "gif|jpg|GIF|JPG", clock => "gif|jpg|html|htm",
   autosubmit => "html|htm|gif|jpg|GIF|JPG",
   delete => "del");
  $filetype = $filetypes{$subdirname};

  $skipfiletypes = "old|bak|bkup|bkp";
  
  if($dirname =~ /mailbkp/) {
     $path     = "$SVRinfo{home}/$SVRinfo{maildir}";
     $destpath = $SVRdest{mailbkp};
  }
  elsif($dirname =~ /mail/) {
     $path     = "$SVRinfo{home}/$SVRinfo{maildir}";
     $destpath = $SVRdest{maildir};
  }
  elsif($dirname =~ /cgibin/) {
     $path     = "$SVRinfo{home}/$SVRinfo{cgipath}";
     $destpath = $SVRdest{cgipath};
  }	
  
  elsif($dirname =~ /public/) {
     $path     = "$SVRinfo{home}/$SVRinfo{public}";
     $destpath = $SVRdest{public};
  } 
  elsif($dirname =~ /images/) {
     $path     = "$SVRinfo{home}/$SVRinfo{public}/WOAimages";
     $destpath = "$SVRdest{public}/WOAimages";     	
  }
  elsif($dirname =~ /clock/) {
     $path     = "$SVRinfo{home}/$SVRinfo{public}/clock";
     $destpath = "$SVRdest{public}/clock";     	
  }
  elsif($dirname =~ /autosubmit/) {
     $path     = "$SVRinfo{home}/$SVRinfo{public}/autosubmit";
     $destpath = "$SVRdest{public}/autosubmit"; 
  }
  elsif($dirname =~ /[a-zA-Z0-9]/) {
     $path     = "$SVRinfo{home}/$SVRinfo{public}/autosubmit/$dirname";
     $destpath = "$SVRdest{public}/autosubmit/$dirname"; 
  }
## must do status and log by hand 

  local($lastFTPfile) = "$path/lastFTP.date";
  local($lastFTPtime) = &get_lastFTP_date($lastFTPfile);
  print "\n&nbsp;&nbsp;min-$mindocid max-$maxdocid lastftp-$aLastFTPdate stamp-$lastFTPtime home- $SVRinfo{home} dirname-$dirname<p>\n";

  local($itemcnt) = 1;

  opendir(DIR, "$path");
  local(@unsorted);
  if($filetype =~ /[a-zA-Z0-9]/) {
     @unsorted = grep /\.$filetype/, readdir(DIR);
  }
  else {
     @unsorted = readdir(DIR);
  }
  closedir(DIR);
  @filenames = sort @unsorted;
 
  local(@stat,$skip);
    
  foreach $filename (@filenames) {
     $skip = 'Y';
     if($filename !~ /[a-zA-Z0-9]/ or $filename =~ /$skipfiletypes/){  ##skip . and ..
     }
     elsif(-f "$path/$filename") {
        &chk_maxmin;
      
        if($min_chk =~ /[Yy]/ and $max_chk =~ /[Yy]/) {
           @stat   = stat("$path/$filename");   # Gets date changed for file
           $filestamp = $stat[9];
           if($stat[9] > $lastFTPtime) { 
               &waitIfBusy($lock_file, 'lock');  
               $ftpSuccess = 'N';
               $skip = 'N';
      
               &do_ftp("send,$path/$filename,$binary,$destpath/$filename");
               
               $itemcnt += 1;
           }
        }
     }
  } 
  if($ftpSuccess = 'Y') {     # reset 'last' ftp date
      unlink "$path/$lastFTP.date" if(-f "$path/$lastFTP.date");
      system "touch $path/$lastFTP.date";  
  } 
}

sub chk_maxmin
{
   $min_chk = 'N';
   $max_chk = 'N';
   ($fileprefix, $rest) = split(/\./,$filename,2);
   
   if($fileprefix !~ /[0-9]{6}/ or $mindocid !~ /[0-9]{6}/) {
      $min_chk = 'Y';
   }
   elsif($fileprefix ge $mindocid) {
      $min_chk = 'Y';
   }
   
   if($fileprefix !~ /[0-9]{6}/ or $maxdocid !~ /[0-9]{6}/) {
      $max_chk = 'Y';
   }
   elsif($fileprefix le $maxdocid) {
      $max_chk = 'Y';
   }
}

sub get_lastFTP_date
{
  local($lastFTPfile) = $_[0];
  local(@stat);
  if($aLastFTPdate =~ /[0-9]/) {
    local($last) = &TimeInSecs($aLastFTPdate);
    return $last;
  }
  elsif(-f $lastFTPfile) { 
    @stat = stat($lastFTPfile);  # Gets date changed for last date FTPd file
    return $stat[9];             # $stat[9]  = timestamp in seconds for last mod
  }
  else {
    print "<li>No lastFTP date exists a-$aLastFTPdate f-$lastFTPfile</li>\n"
       if(print-it eq 'Y');
    $outmsg = "$outmsg No lastFTP date exists a-$aLastFTPdate f-$lastFTPfile\n";
    return 0;
  }
}


sub movefile
{
 local($filename) = $_[0];
 if($filename =~ /newsmobile/) {
	$tofilepath = "/home/overpop/www/overpopulation.org/subdomains/mobile/index.html";
 }
 else {$tofilepath ="$publicdir/$filename.html";
 }
 print "$tofilepath pre- $prepagepath/$filename.bkup<br>\n"
    if($printit eq 'P');
 $outmsg = "$outmsg$tofilepath pre- $prepagepath/$filename.bkup\n";

 $bkp = "$prepagepath/$filename.bkup";
 $pre = "$prepagepath/$filename.html";
 if($SVRinfo{environment} == 'development') {
	if(-f $bkp) {
		unlink $bkp or print"mov304 error in unlink<br>\n";
		## system('chmod 0777, $bkp') or print"mov304 error in chmod<br>\n";
		## must manually sudo chmod 0777 $bkp
	}
  }
 ## system "cp $pub $bkp" or print"mov305 error in copy pub to bkp<br>\n"; ## OR print is a lie
 system "cp $tofilepath $bkp";
 $outmsg = "$outmsg Backup $filename.html complete\n";
 print "<li>Backup $filename.html complete.</li>\n"
    if($printit eq 'P');

 if($SVRinfo{environment} == 'development') {
    if(-f $tofilepath) {
		unlink $tofilepath or print"mov314 error in unlink<br>\n";
		## system "touch $pub";
		##system('chmod 0777, $pub') or print"mov316 error in chmod<br>\n";
   }
 }
## system "cp $pre $pub"  or print"mov317 error in copy pre to pub<br>\n";  ## OR print is a lie
 system "cp $pre $tofilepath";
 $outmsg = "$outmsg Moved $filename.html to public page.\n";  
 print "<li>Moved $filename.html to public page. </li>\n"
    if($printit eq 'P');
 }

sub moveback
{
 local($filename) = $_[0];
 $outmsg = "$outmsg start moveback $publicUrl/$filename\.html\n";
 print "<li>backup start moveback $publicURL/$filename\.html</li>\n"
     if($printit eq 'P');
 system "cp $prepagepath/$filename.bkup $publicURL/$filename.html";
 $outmsg = "$outmsg Restored $filename.html from backup. \n";
 print "<li>Restored $filename.html complete.</li>\n"
     if($printit eq 'P');
 }
 


### Backup a file  or Restore it

sub backup_restore_new
{
 %paths = (
   cgi  => $cgiPath,
   auto => $autosubdir,
   ctrl => "$autosubdir/control",
   sect => "$autosubdir/sections",
   );

 if($filenames =~ /cgi|auto|ctrl|sect/) {
    ($pathcode,$filenames) = split(/:/,$filenames,2);
    $path = $paths{$pathcode};

    &ck_bkup_filenames;
 } 
 else {
    &printCompleteExit("$cmd - invalid directory code<br>\n");	
 }
}

sub ck_bkup_filenames
{
  if($filenames =~ /[A-Za-z0-9]/) {
     @filenames = split(/;/,$filenames);
     foreach $filename (@filenames) {
        if($cmd =~ /bkup/) {     	  
           &bkup($path,$filename);
        }
        elsif($cmd =~ /unbkp/) {
           &unbkp($path,$filename);
        }       
        elsif($cmd =~ /start_new/) {
           &start_new($path,$filename);
        }
     } #end foreach
  }
  else {
      printCompleteExit("$cmd - no filenames");     	
  }
}

## backup = bkup3 to bkup4; bkup2 to bkup3; bkup1 to bkup2; cgi to bkup

sub bkup
{
 local($path,$filename) = @_;
 print "<b>Backup $path/$filename</b><br>\n" if($printit eq 'P');

 if(-f "$path/bkup/bkup/bkup/$filename") {
    print "Backing up #3 backup to #4 $path/bkup/bkup/bkup/bkup/$filename<br>\n" if($printit eq 'P');
    unlink "$path/bkup/bkup/bkup/bkup/$filename" if(-f "$path/bkup/bkup/bkup/bkup/$filename");
    system "touch $path/bkup/bkup/bkup/bkup/$filename";
    system "cp $path/bkup/bkup/bkup/$filename $path/bkup/bkup/bkup/bkup/$filename";
 }
 
  if(-f "$path/bkup/bkup/$filename") {
    print "Backing up #2 backup to #3 $path/bkup/bkup/bkup/$filename<br>\n" if($printit eq 'P');
    unlink "$path/bkup/bkup/bkup/$filename" if(-f "$path/bkup/bkup/bkup/$filename");
    system "touch $path/bkup/bkup/bkup/$filename";
    system "cp $path/bkup/bkup/$filename $path/bkup/bkup/bkup/$filename";
 }

  if(-f "$path/bkup/$filename") { 
    print "Backing up #1 backup to #2 $path/bkup/bkup/$filename<br>\n" if($printit eq 'P');
    unlink "$path/bkup/bkup/$filename" if(-f "$path/bkup/bkup/$filename");
    system "touch $path/bkup/bkup/$filename";
    system "cp $path/bkup/$filename $path/bkup/bkup/$filename";
 }
 
 if(-f "$path/$filename") { 
    print "Backing up current to #1 $path/bkup/$filename<br>\n" if($printit eq 'P');
    unlink "$path/bkup/$filename" if(-f "$path/bkup/$filename");
    system "touch $path/bkup/$filename";
    system "cp $path/$filename $path/bkup/$filename";
 }
 else {
   print "Doesn't exist: $path/$filename<br>\n" if($printit eq 'P');	
 }
     
}

## Restore from backup

sub unbkup
{
 local($path,$filename) = @_;
  local($path,$filename) = @_;
 print "Restore from backup $path/$filename<br>\n" if($printit eq 'P');

 system "cp $path/$filename $path/new/$filename" if(-f "$path/$filename");;
 
 print "Unbackup #1 backup to current $path/$filename<br>\n" if($printit eq 'P');
 unlink "$path/$filename" if(-f "$path/$filename");
 system "touch $path/$filename";
 system "cp $path/bkup/$filename $path/$filename";
 
 print "Unbackup #2 backup to #1 $path/bkup/$filename<br>\n" if($printit eq 'P');
 unlink "$path/bkup/$filename" if(-f "$path/bkup/$filename");
 system "touch $path/bkup/$filename";
 system "cp $path/bkup/bkup/$filename $path/bkup/$filename";
 
 print "Unbackup #3 backup to #2 $path/bkup/bkup/$filename<br>\n" if($printit eq 'P');
 unlink "$path/bkup/bkup/$filename" if(-f "$path/bkup/bkup/$filename");
 system "touch $path/bkup/bkup/$filename";
 system "cp $path/bkup/bkup/bkup/$filename $path/bkup/bkup/$filename";
 
 print "Unbackup #4 backup to #3 $path/bkup/bkup/bkup/$filename<br>\n" if($printit eq 'P');
 unlink "$path/bkup/bkup/bkup/$filename" if(-f "$path/bkup/bkup/bkup/$filename");
 system "touch $path/bkup/bkup/bkup/$filename";
 system "cp $path/bkup/bkup/bkup/bkup/$filename $path/bkup/bkup/bkup/$filename";
}


sub start_new
{
 local($path,$filename) = @_;
 
 &bkup($path,$filename) if(-f "$path/$filename");
 
 print "<b>Moving from new to current $path/$filename</b><br>\n" if($printit eq 'P');

 unlink "$path/$filename" if(-f "$path/$filename");
 system "touch $path/$filename";
 system "cp $path/new/$filename $path/$filename";
 }
 

## FTPs a file
 
sub do_ftp
{
   local ($args) = @_;
   local($bad) = 0;

   if(-f "$statuspath/ftp.off") {
   }
   else {
   	
     if($args =~ /quit/) {
     	$args .= ",Y" if($printit =~ /P/);  # set to print results
     }
##     $rc = &ftp_file($args);
     $bad=1 if($rc == 1 and $args !~ /quit/);	
  }
  &close_exit if($bad == 1);	
}



sub close_exit
{
  if($printit eq 'E') {
     $email_msg = $outmsg;
     $subject = "WOA!! Moveutil results";
     $send_email;
  }
  unlink $lock_file;
  exit 0;
}

