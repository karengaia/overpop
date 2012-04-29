<?php  // saves a page part to /www/prepage
$qstring = $_SERVER['QUERY_STRING'];
list($pagename,$sectionname) = explode('%',$qstring);

echo "query string $qstring";
if(!$sectionname) {
    echo "<b>WOA!! says: You did not enter a sectioname $sectionname; query string =  $qstring </b><br>";
    exit();
}

$mactestfile = "macserver.txt";
if (file_exists($mactestfile)) {
  $scriptpath = "overpop/cgi-bin/";
  $home = "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/www";
}
else {
  $scriptpath = "www.overpopulation.org/cgi-bin/cgiwrap/popaware/";
  $home = "/www/overpopulation.org/subdomains/www";
}

$sourcepage = "http://$scriptpath/article.pl?display_section%%%$sectionname";
$targetfilename = "$home/prepage/$pagename.html";

$webpage = file_get_contents($sourcepage);

if ($webpage === false)
{
echo "<b>WOA!! error - Unable to load $sourcepage - to static page! Update Failed! Error: $webpage</b>";
exit();
}

$fp = fopen($targetfilename, 'w');
if($fp) {
  fwrite($fp, $webpage);
  fclose($fp);
}
else {
	echo "<b>WOA Could not open $targetfilename</b>";
	exit();
}

echo "<b>WOA!! - $targetfilename generated - END</b>";
echo $webpage;
?>