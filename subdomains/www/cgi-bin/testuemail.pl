print "\n\n A - hard-coded escaped email address\n";
$uemail  = "kgp\@karengaia\.net";
$ckemail = "kgp\@karengaia\.net";
$Xuemail = $uemail;
$Xuemail =~ s/\@//g;
$Xuemail =~ s/\.//g; 
$Xckemail = $ckemail;
$Xckemail =~ s/\@//g;
$Xckemail =~ s/\.//g;  
&compare;

$uemail  = "";
$ckemail = "";
$Xuemail = "";
$Xckemail = "";


print "\n B - escaped email address\n";
$contribfile = "contributors4.txt";
$emailfile = "test4email.txt";
&process;

print "\n C - normal email address\n";
$contribfile = "contributors1.txt";
$emailfile = "test1email.txt";
&process;

print "\n D - userid\n";
$contribfile = "contributors3.txt";
$emailfile = "test3email.txt";
&process;


sub process
{
   open(EMAILITEM,$emailfile);
   while(<EMAILITEM>) {
          chomp;
          $ckemail = $_;
          $Xckemail = $ckemail;
          $Xckemail =~ s/\@//g;
          $Xckemail =~ s/\.//g;     
          print "ckemail $ckemail Xckemail $Xckemail\n"; 
   }
   close(EMAILITEM);
   

    
   open(CONTRIBUTORS, $contribfile);
   while(<CONTRIBUTORS>) {
          chomp;
          $uemail = $_;
          $Xuemail = $uemail;
          $Xuemail =~ s/\@//g;
          $Xuemail =~ s/\.//g;  
          print "uemail $uemail Xuemail $Xuemail\n"; 
          &compare;     
   }
   close(CONTRIBUTORS);
}


sub compare
{
    if($uemail eq $ckemail) {
       print "u **$uemail** eq ck **$ckemail**\n";
    }
    else {
       print "u **$uemail** not eq ck **$ckemail**\n";
    }
      
    if($ckemail =~ /$uemail/) {
       print "ck **$ckemail** =~ u **$uemail**\n";
    }
    else {
       print "ck **$ckemail** not =~ u **$uemail**\n";
    }
    
    if($Xuemail =~ /$Xckemail/) {
       print "Xu **$Xuemail** =~ Xck **$Xckemail**\n";
    }
    else {
       print "Xu **$Xuemail** not =~ Xck **$Xckemail**\n";
    }
  
    if($Xuemail eq /$Xckemail/) {
       print "Xu **$Xuemail** eq Xck **$Xckemail**\n";
    }
    else {
       print "Xu **$Xuemail** not eq Xck **$Xckemail**\n";
    }  
   
    print "\n\n";
}

1;