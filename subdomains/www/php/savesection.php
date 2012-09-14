<?php 


include dirname(__FILE__) . '/bootstrap.php';
$qstring = $_SERVER['QUERY_STRING'];
list($pagename,$sectionname) = explode('%',$qstring);

$sourcepage = "http://{$CONFIG['servername']}/prepage/viewsection.php?$sectionname";
$targetfilename = "{$CONFIG['public_dir']}/$pagename.html";

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