<?php 
$qstring = $_SERVER['QUERY_STRING'];
list($docid,$template,$sectionname,$owner,$userid) = explode('%',$qstring);
$mactestfile = "macserver.txt";
$lc_owner = strtolower($owner);
if($owner == 'CSWP') {
	$css_source = "http://motherlode.sierraclub.org/population/css/cswp.css";
}
elseif($owner == 'CSWP') {
	$css_source = "http://motherlode.sierraclub.org/maiud/css/cswp.css";
}

if (file_exists($mactestfile)) { 
  $sourcepage1 = "http://overpop/cgi-bin/article.pl?display%$template%$docid%$sectionname%%$userid%%%%%%$owner";
  $sourcepage2 = "http://overpop/cgi-bin/article.pl?print_select%%fly%$sectionname%%$userid%%$lc_owner" . "_top%delete_select_end%%%$owner";
}
else {
  $sourcepage1 = "http://www.overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?display%$template%$docid%$sectionname%%%%%%%%$owner";
  $sourcepage2 = "http://www.overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?print_select%%fly%$sectionname%%$userid%$lc_owner" . "_top%%delete_select_end%%%$owner";
// http://overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?print_select%%fly%CSWP_Calendar%%A3491%%cswp_top%delete_select_end%%%CSWP
}
if($sectionname == 'delete_deleteItem') {
	$sourcepage2 = "";
}
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
 
<title>Admin: <?php echo $owner; ?> </title>
<meta http-equiv="expires" content="0">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<link rel="stylesheet" type="text/css" href="http://motherlode.sierraclub.org/population/css/cswp.css" media="Screen">
<link rel="stylesheet" type="text/css" href="/css/ownerform.css" media="Screen">

<script language="javascript" type="text/javascript">
<!--
function clearItem() {
document.getElementById('sysdate').value = "";
document.getElementById('docid').value = "";
document.getElementById('thisSectsub').value = "";
document.getElementById('pubmonth').value = "";
document.getElementById('pubday').value = "";
document.getElementById('pubyear').value = "";
document.getElementById('headline').value = "";
document.getElementById('body').value = "";
document.getElementById('link').value = "";
}

function clearNew() {
if(document.getElementById('docid').value == "") {
  clearItem();	
 }
}

function moveSectsub() {
	var ss = document.getElementById('ownersectsub');
	if(ss.options.selectedIndex < 0) {
	ss.options.selectedIndex = 0;
	}
	if(!ss.options[ss.options.selectedIndex].value) {
		alert('null sectsubs selected');
		return(0);
	}
	var ssstr = ss.options[ss.options.selectedIndex].value;
	alert(ssstr);
	document.getElementById('thisSectsub').value = ssstr;
}
//-->
</script>
</head> 

<body basefont="arial" onload="clearNew();">

<div style="margin-left:10px;margin-right:7px;margin-bottom:5px;"><div style="float:right; width:150px;">
	<strong class="red">1. </strong><cite class="verdana">Choose:</cite><strong class="red"> A. </strong> <cite class="verdana">Left column: add or change individual item;</cite><br> <strong class="red">B. </strong><cite  class="verdana">Right column: delete items from a list</cite><br><br>
	<strong class="red">A. Left column:</strong> <br>
	<strong class="red">2. </strong> <cite class="verdana">Choose by clicking on the little button: Change existing item or add a new one; Sometimes add is the only option</cite><br>
	<strong class="red">3. </strong> <cite class="verdana">In what list (section) of articles will this appear? (Click to drop down)</cite><br>
	<strong class="red">4. </strong> <cite class="verdana">Start date, Date of event, Due date, or just a dummy date - it is used to order items in the list. This date does not show on the web and is not necessarily the same date put in the title.</cite><br>
	<strong class="red">5. </strong> <cite class="verdana">Title will appear at top of the article in boldface</cite><br>
	<strong class="red">6. </strong> <cite class="verdana">Remainder of article. Use 'return' twice to start a new paragraph</cite><br><br>
	<strong class="red">B. Right column: </strong> <cite class="verdana">Click in the box before each article you wish to delete and then click on 'Finish'</cite><br><br>
</div>
<br><br>
		<div style="font-family:geneva;font-size:1.3em;text-align:center;"><strong>CSWP Web Admin</strong> <br><br>  <small><strong class="red">1. </strong></small><b>Choose left or right column; cannot do both at one time</b></div>
		
<table>
	<tr><td id="leftcol">
		   <?php $webpage = file_get_contents($sourcepage1); echo $webpage; ?>		
	</td>
    <td id="rightcol">
		<div style="font-family: geneva; font-size: 1.3em;margin-bottom:2px;"><strong class="red">B. </strong><strong>Delete from list</strong> <br> 
			<cite><big>Check items to delete from the <?php echo $sectionname;?> list below</big></cite>
		</div>
		   <?php if ($sourcepage2) {$webpage = file_get_contents($sourcepage2); echo $webpage;} ?>									
    </td>
	
</tr></table>
</div>
<strong class="red"> C. </strong><b>Below is the real CSWP web page, a part of which you are changing.</b>
<iframe src="http://motherlode.sierraclub.org/population/" width="100%" height="800px"></iframe>

</body></html>

	
