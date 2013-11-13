<?php  // saves a page part to /www/prepage
require './../php/bootstrap.php';
$qstring = $_SERVER['QUERY_STRING'];
list($pagename,$sectionname) = explode('%',$qstring);

if(!$sectionname) {
    echo "<b>WOA!! says: You did not enter a sectioname $sectionname; query string =  $qstring </b><br>";
    exit();
}

$thisdir = dirname(__FILE__);
$publicdir = dirname($thisdir);
$phpdir = "$publicdir/php";
$scriptpath = "{$CONFIG['servername']}/{$CONFIG['cgi_path']}/";
$home = $publicdir;

$sourcepage = "http://$scriptpath/article.pl?display_subsection%%%$sectionname";
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

echo $webpage;
?>