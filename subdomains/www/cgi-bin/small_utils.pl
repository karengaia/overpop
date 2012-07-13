#!/usr/bin/perl --

# small_utils.pl   May 7, 2010 

## 2010 May 7 -- Karens Mac Server changes: Added push @INC for Karen's Mac Server

require './bootstrap.pl';

print "Content-type:text/html\n\n";
 
if($ENV{QUERY_STRING})  {
   if($ENV{QUERY_STRING} =~ /%/) {
      @info  = split(/%/,$ENV{QUERY_STRING});
   }
   elsif($ENV{QUERY_STRING} =~ /&/) {
      @info  = split(/&/,$ENV{QUERY_STRING});
   }
   $queryString = 'Y';
   $cmd         = $info[0];
   $action = $from  = $info[1];
   $to    = $info[2];
}


## i.e. action = futzing or vacation 
$fileOFF = "$statuspath/$action.off";
$fileON  = "$statuspath/$action.on";

if($cmd eq 'turnON') { 
  unlink $fileOFF if(-f $fileOFF);
  system "touch $fileON";
  print "small_utils $cmd $action file $fileON <br>\n";
}
elsif($cmd eq 'turnOFF') {
  unlink $fileON if(-f $fileON);
  system "touch $fileOFF";
  print "small_utils $cmd $action file $fileOFF <br>\n";
}
elsif($cmd eq 'deleteItems') {
 print "<b>Delete Items from $from to $to in path $itempath<br></b><font size=1 face=verdana>\n";
 if($from !~ /[0-9]{6}/ or $to !~ /[0-9]{6}/) {
 	print "From or to invalid<br>\n";
 	exit;
 }
 $num = $from;
 $num = $num + 0;
 while($num <= $to) {
    $docCount = $num;	
    if($docCount < 10)        {$docCount = "00000$docCount";}
    elsif($docCount < 100)    {$docCount = "0000$docCount";}
    elsif($docCount < 1000)   {$docCount = "000$docCount";}
    elsif($docCount < 10000)  {$docCount = "00$docCount";}
    elsif($docCount < 100000) {$docCount = "0$docCount";} 
   
   $docid = $docCount;
   $filepath = "$itempath/$docid.itm"; 
   
   if(-f $filepath) {
      print "$docid<br>\n";
      unlink "$filepath";
   }
   else {
      print "$docid not found<br>\n";	
   }		
   $num = $num +1; 
 }
}
exit;