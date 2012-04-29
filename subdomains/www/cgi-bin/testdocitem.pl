#!/usr/bin/perl --

## TEST

$testitem = 
"Holdren â€˜ former president of the American Association for the Advancement of Science in Washington, is a specialist in energy and climate change who advised Al Gore on the documentary â€œAn Inconvenient Truth.â€ His appointment signals...";

print "testitem $testitem\n";

$converted = &apple_convert($testitem);

print "after $converted\n";
exit;

##                converts quotes, hyphens and other wayword perversions
sub apple_convert
{
 local($datafield) = $_[0];
 
 ##                             line feeds, returns
 $datafield =~ s/=20\n/\n/g;
 $datafield =~ s/=20//g;
 $datafield =~ s/=3D/*/g;
 $datafield =~ s/\r/ /g;
 $datafield =~ s/\r/ /;
 
 $datafield =~ s/([a-z0-9] )\n\n/$1/ig;
 $datafield =~ s/([a-z0-9] )\n/$1/ig;
 
 $datafield =~ s/ = / /g;  #end of line
      
 ##                             # single quotes
 $datafield =~ s/``/"/g;
 $datafield =~ s/‘/'/g;
 $datafield =~ s/’/'/g; 
 $datafield =~ s/L/'/g;    #81
 $datafield =~ s/&rsquo;/'/g; 
 $datafield =~ s/=92/'/g;  #92 
 $datafield =~ s/’/'/;     ## back tick
 $datafield =~ s/Â´/'/;
 $datafield =~ s/â€™/'/g;
 
 ##                    # double quotes             
 $datafield =~ s/=93/"/g; #93
 $datafield =~ s/=94/"/g; #94
 $datafield =~ s/E/"/g;   #81
 $datafield =~ s/''/"/;   #doublequote
 $datafield =~ s/”/"/;    #backquote
 $datafield =~ s/“/"/;    #frontquote
 $datafield =~ s/``/"/g;  #double back tick
 $datafield =~ s/â€/"/g;  #double quote 2
 $datafield =~ s/â€œ/"/g; #double quote 3

 $datafield =~ s/&#40;/\(/g;  # left parens
 $datafield =~ s/&#41;/\)/g;  # right parens
 
 $datafield =~ s/&#91;/\[/g;  # left bracket
 $datafield =~ s/&#93;/\]/g;  # right bracket

 $datafield =~ s/=95/-/g;    # 95    hyphen
 $datafield =~ s/â€˜/-/g;    #hyphen

 return($datafield);  	
}