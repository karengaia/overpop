<?php
$qstring = $_SERVER['QUERY_STRING'];
list($pagename,$sectionname) = explode('%',$qstring);

$mactestfile = "macserver.txt";
if (file_exists($mactestfile)) {
  $sourcepage = "http://overpop/cgi-bin/article.pl?display_section%%%$sectionname";
  $targetfilename = "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/www/$pagename.html";
}
else {
  $sourcepage = "http://www.overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?display_section%%%$sectionname";
  $targetfilename = "/www/overpopulation.org/subdomains/www/$pagename.html";
}

echo "page = $pagename<br><br>";
if(!$pagename) {
    echo "<b>WOA!! says: You did not enter a page.</b><br>";
    exit();
}

echo "current path " . getcwd() . "<br>\n";
echo "sourcepage " . $sourcepage . "<br>\n";
echo "targetfilename " . $targetfilename . "<br>\n";

if (file_exists($targetfilename)) {
echo "Target page exists<br>";
}
else {
echo "Target page does not exist<br>";	
}

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

function getwebcontent($url){
        $crl = curl_init();
        $timeout = 5;
        curl_setopt ($crl, CURLOPT_URL,$url);
        curl_setopt ($crl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt ($crl, CURLOPT_CONNECTTIMEOUT, $timeout);
        $ret = curl_exec($crl);
        curl_close($crl);
        return $ret;
}
?>