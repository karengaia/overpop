<?php
require './bootstrap.php';

$qstring = $_SERVER['QUERY_STRING'];
list($progname,$segname) = explode('?',$qstring);
$targetfilename = $CONFIG['public_dir'] . "/$segname";

header("Content-type: text/javascript");
$content = file_get_contents($targetfilename);

print "document.write('".addslashes($content)."');";
