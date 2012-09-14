<?php
require '../php/bootstrap.php';
$qstring = $_SERVER['QUERY_STRING'];
list($sourcepath,$targetpath) = explode('%',$qstring); 

$sourcefile = "http://{$CONFIG['servername']}/$sourcepath";
$targetfile = "{$CONFIG['public_dir']}/$targetpath";

$webpage = file_get_contents($sourcefile);

if ($webpage === false)
{
echo "<b>WOA!! error - Unable to load $sourcepage - to static page! Update Failed! Error: $webpage</b>";
exit();
}

$fp = fopen($targetfile, 'w');
if($fp) {
  fwrite($fp, $webpage);
  fclose($fp);
}
else {
	echo "<b>WOA Could not open $targetfile</b>";
	exit();
}

echo $webpage;

echo "<b>WOA!! - $targetfilen generated - END</b>";

?>