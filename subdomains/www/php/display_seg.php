<?php $qstring = $_SERVER['QUERY_STRING'];
list($progname,$segname) = explode('?',$qstring);
$mactestfile = "macserver.txt";
if (file_exists($mactestfile)) {
  $targetfilename = "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/www/" . $segname;
}
else {
  $targetfilename = "/www/overpopulation.org/subdomains/www/" . $segname;
}

header("Content-type: text/javascript");
$content = file_get_contents($targetfilename);

print "document.write('".addslashes($content)."');";
?>





	
