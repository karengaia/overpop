#!/usr/bin/perl --

# ftpSync.pl    July 27, 2005

############### FTP a file or rsync a directory #######

## partially based on ftp.pl
## (c) 2002 Gregory Moxley Kempster Stratton

## help at http://www.perldoc.com/perl5.6/lib/Net/FTP.html#METHODS
##   delete ( FILENAME ) 

## Need to check destination for 'site='; then open sitecontrol.html and get the site

sub ftp_file
{
  local($args) = @_;
  use Net::FTP;

  local($action,$source,$binary,$destination) = split(/,/,$args);

  if($action =~ /quit/) {
      $FTPopen = 'N';
      $ftp->quit();     #  Quit FTP
      
      $FTPmsg .= "FTP done<br>\n";
      
      local($printit) = $source;
      print "$FTPmsg\n" if($printit =~ /Y/);
      
      open(FTPLOG, ">>$ftplogpath");
      &calc_date('sys',0);
      print FTPLOG "$sysdatetime\n";
      print FTPLOG "$FTPmsg\n\n";
      close(FTPLOG);
  
      return 0;
  }
  
  elsif($FTPopen =~ /N/) {
      $FTPopen = 'Y'; 
      $FTPmsg = "";
      $ftp = Net::FTP->new ($SVRdest{IP}, Timeout => 30);
      if( !$ftp ) {
    	$FTPmsg .=  "Could not connect to $address<br>\n";
    	return 1;
      }
 
#   Login
      $r = $ftp->login($SVRdest{acctID}, $SVRdest{password});
      if( !$r ) {
         $FTPmsg .= "Could not log in user $SVRdest{acctID}<br>\n";
         return 1;
      }
      $FTPmsg .=  "FTP logged in to $SVRdest{acctID} <br>\n";
  }
  
  if($action =~ /send/) {   ##Send the file

#      if($destination ne $LastDest) {
#   	$ftp->cwd("/$destination");  # Change working directory
#   	$LastDest = $destination;
#      }
       
      $ftp->binary() if($binary =~ /Y/);  # Set binary mode
#      $ftp->ascii()  if($binary =~ /N/);
##      $r = $ftp->put($source) or die "<li>Cannot send $source</li>\n";

      unless($ftp->put($source,$destination)) {
         sleep 10;
         unless($ftp->put($source)) {
            $FTPmsg .= "Cannot send $source to $destination even after retrying<br>\n";
            return 1;
         }
      }
      $FTPsuccess = 'Y';
      $FTPmsg .=  "FTPd: to $destination<br>\n";
  }
  
  elsif($action =~ /delete/) {    # delete a file
      unless($ftp->delete($source)) {
         sleep 10;
         unless($ftp->delete($source)) {
            $FTPmsg .= "Cannot delete $source even after retrying<br>\n";
            return 1;
         };
      };
      $FTPsuccess = 'Y';
      $FTPmsg .=  "FTP deleted: $source<br>\n";
      return 0;
  }
}

1;