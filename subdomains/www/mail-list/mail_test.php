<?php
$r = mail("kgp@karengaia.net", "test1", file_get_contents('./popnews.email'), "From: kgp@karengaia.net");
echo "r: " . var_export($r, true) . "\n";
echo "Done.\n";
