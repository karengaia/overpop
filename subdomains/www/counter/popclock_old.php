<?php
header("Content-type: text/javascript");

$now = time();
$start_date = "";
$end_date = "";
$found = 'N';

$fp = fopen("popclock.txt", "r");
if ($fp) {
    while (!feof($fp)) {
        $line = fgets($fp, 25);
        list($date, $pop) = explode(" ", $line);
        $date = date_create_from_format('m/d/y', $date);
        if ($found == 'Y') { // Not found until today is >= $date
           $end_date = $date;
           $end_pop = $pop;
           break;
        }
        if ($now >= $date) { // found the start date - keep going until after next month
          $found = 'Y';
          $start_date = $date;
          $start_pop = $pop;
        }
    }
    fclose($fp);
}

if ($start_date && $end_date) {
}
else {
   echo 'popclok table wrong dates';
   return;
}

str_replace(" ", "", $start_pop);  // get rid of spaces
str_replace("\/", "", $start_pop);  // get forward slashes
$istart_pop = strval($start_pop);

str_replace(" ", "", $end_pop);  // get rid of spaces
str_replace("\/", "", $end_pop);  // get forward slashes
$iend_pop = strval($end_pop);

$mon_pop = $iend_pop - $istart_pop;
$mon_secs = $end_date - $start_date;
$mon_now_secs = $now - $start_date;

if($mon_secs > 0) {
$mon_now_pop = round(($mon_now_secs /$mon_secs) * $mon_pop);
}
else {
echo "popclok div by 0";
exit;
}

$pop = $start_pop + $mon_now_pop;


print "document.write('".addslashes(number_format($pop))."');";
}
?>