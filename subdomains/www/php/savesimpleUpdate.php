<?php 
$qstring = $_SERVER['QUERY_STRING'];
list($docid,$sectionname,$pagename) = explode('%',$qstring);

$mactestfile = "macserver.txt";
if (file_exists($mactestfile)) {
  $sourcepage = "http://overpop/prepage/viewSimpleUpdate.php?$docid%$sectionname";
  $targetfilename = "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/prepage/$pagename.html";
}
else {
  $sourcepage = "http://www.overpopulation.org/prepage/viewSimpleUpdate.php?$docid%$sectionname";
  $targetfilename = "/www/overpopulation.org/subdomains/prepage/$pagename.html";
}

if(!$pagename) {
    echo "<b>WOA!! says: You did not enter a page.</b><br>";
    exit();
}

$webpage = file_get_contents($sourcepage);
echo $webpage;

if ($webpage === false)
{
echo "<b>WOA!! error - Unable to load $sourcepage - to static page! Update Failed! Error: $webpage</b>";
exit();
}

if(file_exists($targetfilename)) {
  unlink($targetfilename);
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
?>