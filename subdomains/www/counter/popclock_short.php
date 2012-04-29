<?php

header("Content-type: text/javascript");

// setTimeout(function(){ newWindow.close(); }, 1000);

// Calculated from US Census Bureau values supplied annually - see spreadsheet

$old_date_pop_table = array(
"10/01/10-6872195424",
"11/01/10-6878656906",
"12/01/10-6884909953",
"01/01/11-6891371434",
"02/01/11-6897832916",
"03/01/11-6903669093",
"04/01/11-6910130575",
"05/01/11-6916383622",
"06/01/11-6922845104",
"07/01/11-6929098151");


$date_pop_table = array(
"09/01/11-6959135290",
"10/01/11-6965469791",
"11/01/11-6972015442",
"12/01/11-6978349943",
"01/01/12-6984895594",
"02/01/12-6991441244",
"03/01/12-6997564595",
"04/01/12-7004110246",
"05/01/12-7010444747",
"06/01/12-7016990398",
"07/01/12-7023324899");

$un_us_diff = 28200000;   // see UN_US_difference.xls
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