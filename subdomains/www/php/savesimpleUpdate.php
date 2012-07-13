<?php 
require './bootstrap.php';

$qstring = $_SERVER['QUERY_STRING'];
list($docid,$sectionname,$pagename) = explode('%',$qstring);

$sourcepage = "http://{$CONFIG['servername']}/prepage/viewSimpleUpdate.php?$docid%$sectionname";
// TODO This is pointing to subdomains/prepage. But prepage is in subdomains/www/prepage. Which should it be?
$targetfilename = "{$CONFIG['public_dir']}/../prepage/$pagename.html";

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