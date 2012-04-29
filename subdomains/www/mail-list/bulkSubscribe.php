<?php
require('config.php');
$title = "Bulk Subscribe";

require('header.htm'); 

echo 'Added: -------------<br /><br />';
$_POST['ml_id'] = 1;     //list id - popnewsweekly / 3 = testpopnews

$email_list = "abeddoe@baymoon.com,dave@growthbusters.com,nfn02240@naples.net,ve3mtg@wightman.ca,cliffterry@verizon.net";

$email_listx = "kgp@karengaia.net,pittskg@yahoo.com,karen.gaia.pitts@gmail.com,baparks38@directcon.net,karengaia@live.com,overpop@overpopulation.org";

$email_list_orig = "ecabatu@ccmc.org,academycoach@gmail.com,bdenneen@slonet.org,clwilmoth@aol.com,tfugate@madriver.com,ryinglin@wyoming.com," . 
"nagu_akilan@hotmail.com,l_pavilonis@hotmail.com,leelock@cyberway.com.sg,ernest.Garcia@uv.es,patachek@juno.com,mollypollypuddinpie@yahoo.com," .
"ajplug@wanadoo.nl,rbrightwell@datamonitor.com,barrett@centex.net,arundolke@gmail.com,madweld@rogers.com,alterna94@aol.com," .
"cheight@cfl.rr.com,mfluter2@mwillis.net,popnetwork_marketing-subscribe@yahoogroups.com,chriscanni@juno.com,kierickson@msn.com," . 
"earthxzile@yahoo.com,pburns@erols.com,pdrekmeier@earthlink.net,alankuper@earthlink.net,asa323@yahoo.com,tove@totalzone.com," .
"magjimtal@erols.com,l.Wedow@telesat.ca,ricks@tc.umn.edu,jean.harris@stonebow.otago.ac.nz,gbungo@earthlink.net,bsundquist1@alltel.net," .
"suspension@ebay.com,bsundquist1@juno.com,dave@visions-west.net,steve@vter.net,nfn02240@naples.net,valerio.decao@tin.it,mfluter2@fastmail.fm," .
"Njoyjacobs@msn.com,mleppard@qmuc.ac.uk,castilla@inbox.com,kbonk@ccmc.org,redwoodpeace@hotmail.com,pretty.fiendish@gmail.com," .
"fabio.sottili@alcatel.it,bruce.Gura@motorola.com,Harrygchill@aol.com,prc@prcdc.org,lillyrina@inwind.it,thecrust@bigpond.net.au," .
"bozena.widera@mdh.se,rejones@alumni.princeton.edu,birder0624@aol.com,stroupfamily@mchsi.com,sweets195@hotmail.com," .
"pedroj.hernandezgonzalez@gobiernodecanarias.org,cliffterry@verizon.net,abeddoe@baymoon.com,peter.Cutting@tetrapak.com";

$_POST['lastname'] = "";
$_POST['firstname'] = "";
$_POST['pending'] = 0;

$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
   or die('Could not connect to MySQL database. ' . mysql_error());

mysql_select_db(SQL_DB,$conn);

require 'subscribe.php';

$emails = explode(',',$email_list);
foreach($emails as $email) {
  $_POST['email'] = trim($email);
  subscribe($conn, $_POST);
}

?>


<br />
-----------End of List -------

<?php require('footer.htm'); ?>