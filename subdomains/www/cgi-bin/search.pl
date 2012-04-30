#!/usr/bin/perl

# Copyright (C) 1998 by Sierra Kempster.  All rights reserved.
# Quick script to search a directory for what files contain certain keywords.
# Searches HTML files in one directory except index.html
# Distribute freely, but keep this notice intact, and do not charge money
# for my work.  Keep information free.	

require './bootstrap.pl';

$dir    = $publicdir;     # Directory to search
$url    = $publicUrl;    # URL of directory
$header = "$dir/search_head.txt"; # File containing header information
$footer = "$dir/search_footer.txt"; # File containing footer information

&parse_form;

# Open the directory and get file list
opendir(DIR, "$dir");
local(@files) = grep /\S+\.[Hh][Tt][Mm]/, readdir(DIR);
closedir(DIR);

# List of key words
$FORM{keywords} =~ tr/[A-Z]/[a-z]/;
@keywords = split(/ /,$FORM{keywords});

# Check each file for the words
foreach $file (@files)
{
  if($file ne "index.html")
  {
    open(FILE, "$dir/$file");
    $x = 0;
    while(<FILE>)
    {
      chomp;
      $_ =~ tr/[A-Z]/[a-z]/;
      foreach $word (@keywords)
      {
        if($_ =~ /$word/)
        {
          $x = $x+1;
        }
      }
    }
    close(FILE);
    # Add to the list if any matches are found
    if($x > 0)
    {
      push @list, "$x:$file";
    }
  }
}

# Sort the list according to most matches
@sorted = sort { $b <=> $a } @list;

# Print the results
print"Content-type: text/html\n\n";
open(HEAD, "$header");
while(<HEAD>)
{
  print"$_";
}
close(HEAD);
print"<p>Search results for <b>$FORM{keywords}</b>:</p>\n";
print"<p><center><table border=0 cellspacing=0 cellpadding=0>\n";
print"<tr><th align=left># of Matches</th><th align=right>Page</th></tr>\n";
foreach $item (@sorted)
{
  ($match,$file) = split(/:/,$item,2);
  print"<tr><td>$match</td><td align=right><a href=\"$url/$file\">$file</a></td></tr>\n";
}
print"</table></center></p>\n";
open(FOOT, "$footer");
while(<FOOT>)
{
  print"$_";
}
close(FOOT);

sub old_parse
{
# Get the form information
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
{
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $value =~ s/~!/ ~!/g;
  $FORM{$name} = $value;
}
}