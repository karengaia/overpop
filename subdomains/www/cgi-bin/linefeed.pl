	#!/usr/bin/perl --
	
	$buffer = "1973: In Roe v. Wade the U.S. Suprem=
e Court rules that the constitutional right of
privacy extends to a woman=
's decision, in consultation with her doctor, to have an
abortion. 

=
1974: Des Moines center offers abortion services. 

1988: Sex education=
 is mandated in Iowa public schools. Confidential HIV testing
begins at D=
es Moines Central center. 

1990: Iowa City center opens and becomes PP=
GI's second clinic to provide abortions. ";

print "prebuffer test 3<br>\n";

##	 $buffer =~ s/\61\015\012/\012/g; #converts =CRLF to LF 
##   $buffer =~ s/\015\012/\012/g;    #converts CRLF to LF
##   $buffer =~ s/\015/\012/g;        #converts CR to LF

   $buffer =~ s/\x3d\x0d\x0a/\x0a/g;   #converts =CRLF to linux LF
   $buffer =~ s/\x0d\x0a/\x0a/g;       #converts win CRLF to linux LF
   $buffer =~ s/\x0d/\x0a/g;          #converts mac to linux
   
print "buffer ------------------------>\\n \n$buffer<br>\n";
   
   exit;