#!/usr/bin/perl --

# keywords.pl - not used

#### 600 KEYWORD processing     NOT USED  ###

sub do_keywords
{
  if($cmd ne 'storelist') {
    @selkeywords = split(/;/,$selkeywords); 
    foreach $keyword(@selkeywords) {
        if($keyword =~ /[A-Za-z0-9]/ and $keywords !~ ";$keyword") {
           &get_keyword;
           &add_to_keyword_index;
           $keywordsv .= ";$keywordsv";
           if($keywords =~ /[A-Za-z0-9]/) {$keywords .= ";$keyword";}
           else {$keywords = $keyword;}
        }
    }
  }
  $keywordsv =~  s/^;+//;
  if($newkeyword =~ /[A-Za-z0-1]/) {
  	if($SVRinfo{environment} == 'development') {  ## set permissions if using Karen's Mac as the server
     if(-f $newkeywords) {}
		else {
			system('touch $newkeywords');
			}
		system('chmod 0777, $newkeywords');
	}

     
     open(NEWKEYWORD, ">>$newkeywords");
     print NEWKEYWORD "$docid^$newkeyword\n";
     close(NEWKEYWORD);
  }     
}


sub add_to_keyword_index
{
  $keygoesto =~ s/\W/_/g;
  $keyidxfile = "$keywordpath/$keygoesto.key";  
  $oldkeyidxfile = "$keywordpath/$keygoesto.old";
  $bkpkeyidxfile = "$keywordpath/$keygoesto.bkp";

  system "cp $keyidxfile $oldkeyidxfile" if($keyidxfile);
#         put it at the top of the file
  if($SVRinfo{environment} == 'development') {  ## set permissions if using Karen's Mac as the server
	if(-f '$keyidxfile') {}
	else {
		system('touch $keyidxfile');
		}
	system('chmod 0777, $keyidxfile');
  }
  
  open(KEYSUB, ">$keyidxfile");
  print KEYSUB ("$docid\n");
  close(KEYSUB);

  if(-f $oldkeyidxfile) {
     system "cat $oldkeyidxfile >>$keyidxfile"; 
     unlink "$oldkeyidxfile";
  } 
 
  system "cp $keyidxfile $bkpkeyidxfile" if(-f $keyidxfile);
}

sub get_keyword
{
  open(KEYWORDS, "$keywordlist");
  while(<KEYWORDS>) {
     chomp;
     $line = $_;
     ($listkeyword,$keygoesto,$see_also) = split(/\^/,$line,3);
      $keygoesto = $listkeyword if($keygoesto !~ /[A-Za-z0-9]/);
     last if($listkeyword =~ /[A-Za-z0-9]/ and $keyword =~ /$listkeyword/);
  } 
  close(KEYWORDS);
}

sub print_keyword_dropdown
{
  print MIDTEMPL <<END;
  <td valign=top align=left>   
  <table border=1 cellspacing=0 cellpadding=5><td><b>Keywords:</b><br>
  <font size=1 face=verdana>
END
  $keywords = "(none)" if($keywords !~ /[A-Za-z0-9]/);
  print MIDTEMPL "Current keywords:<br>&nbsp;&nbsp;$keywords<p>\n" if($action ne 'new');
  print MIDTEMPL  "Select/Add 1 or more keywords:</b><br>\n";
  print MIDTEMPL  "<select size=10 multiple name=\"selkeywords\">\n";
  
  open(KEYWORDS, "$keywordlist");
  while(<KEYWORDS>) {
     chomp;
     $line = $_;
     ($listkeyword,$rest) = split(/\^/,$line,2);
     print MIDTEMPL "<option value=\"$listkeyword\"";
     print MIDTEMPL " selected " if($keywords =~ /$listkeyword/);
     print MIDTEMPL ">$listkeyword </option>\n";
  } 
  close(KEYWORDS);
  print MIDTEMPL <<END;
  </select><br>\
  <font size=1 face="comic sans ms">Note: De-select does not work.<br>
  Admin must manually delete keywords. </font><p>

  <font size=1 face="comic sans ms">or specify other if not on list</font><br>
  <input type=text name="newkeyword" size=28 maxlength=65 value=" "><p>
  </td></table>
   
  </td>
END
}

1;