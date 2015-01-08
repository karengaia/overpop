<?php

header("Content-type: text/javascript");

// setTimeout(function(){ newWindow.close(); }, 1000);

// Old Calculated from US Census Bureau values supplied annually - see spreadsheet

//	PRB & US Census Bureau
$date_pop_table = array(
"07/01/14-7244702583",
"08/01/14-7251139000",
"09/01/14-7257575417",
"10/01/14-7264011834",
"11/01/14-7270448251",
"12/01/14-7276884668",
"01/01/15-7283321085",
"02/01/15-7289757502",
"03/01/15-7296193919",
"04/01/15-7302630336",
"05/01/15-7309066753",
"06/01/15-7315503170",
"07/01/15-7321939587");

$old_date_pop_table = array(
"07/01/13-7095217980",
"08/01/13-7101807146",
"09/01/13-7108396313",
"10/01/13-7114772926",
"11/01/13-7121362093",
"12/01/13-7127738706",
"01/01/14-7134327873",
"02/01/14-7140917039",
"03/01/14-7146868545",
"04/01/14-7153457712",
"05/01/14-7159834325",
"06/01/14-7166423491",
"07/01/14-7172800105");

//$un_us_diff = 28200000;   // see UN_US_difference.xls
$un_us_diff = 0;   // see UN_US_difference.xls
date_default_timezone_set('UTC');

$nowtimesecs = time();  //  off by about 20 hours from US Census
$count = count($date_pop_table);
for ($i = 0; $i < $count; $i++) {
   if($i>0) {$prevpop = $pop; $prevtimesecs = $timesecs;}
   list($date, $spop) = explode('-',$date_pop_table[$i]);
   $pop = strval($spop + $un_us_diff);

   $timesecs = strtotime($date);
   if($timesecs > $nowtimesecs) {break;}
}
//print "document.write('".addslashes(number_format($pop))."');";
if($prevtimesecs > $nowtimesecs) {
  $start_time = 1262304000; // Jul 1, 2010 Time in secs since Epoch January 1 1970
  $start_pop = 6853019414; // pop on Jul 1, 2010
  $rate = 2.41;  // people per second calculated - see spreadsheet
}
else {
  $start_time = $prevtimesecs;
  $start_pop = $prevpop;
  $rate = ($pop - $prevpop) / ($timesecs - $prevtimesecs);
}

$increase = round((time() -$start_time) * $rate);
$nowpop = $start_pop + $increase;

print "document.write('".addslashes(number_format($nowpop))."');";
?>