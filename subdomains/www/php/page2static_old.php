<?php
require './bootstrap.php';
$pagename = $_SERVER['QUERY_STRING'];

$servername = $CONFIG['servername'];

echo "page = $pagename<br><br>";
if(!$pagename) {
    echo "<b>WOA!! says: You did not enter a page.</b><br>";
    exit();
}

$sourcepage = "$pagename.php";
if (file_exists($sourcepage)) {
echo "Source page exists<br>";
}
else {
echo "Source page does not exist<br>";	
exit();
}

$targetfilename = "$pagename.html";

echo "using FILE_USE_INCLUDE_PATH <br>";

$webpage = file_get_contents("$sourcepage, FILE_USE_INCLUDE_PATH");

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