<?php
$qstring = $_SERVER['QUERY_STRING'];
list($docid,$template,$sectionname,$owner,$userid,$ownersubs) = explode('%',$qstring);
$arr_ownersubs =  explode(';',$ownersubs);
require './../php/bootstrap.php';

$cgipath = $CONFIG['servername'] . '/' . $CONFIG['cgi_path'];
$ownerinfo = "http://$cgipath/article.pl?getownerinfo%%%%%%%%%%%$owner";
$ownerlist = file_get_contents("$ownerinfo");

list($ohome,$ocsspath,$ocssformpath) = explode(',',$ownerlist);

$sourcepage1 = "http://$cgipath/article.pl?display%$template%$docid%$sectionname%%$userid%%%%%%$owner";
?>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
 
<title><?php echo $owner . ' Admin: update articles'; ?> </title>
<meta http-equiv="expires" content="0">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<?php 
  if(!empty($ocsspath)) { echo '<link rel="stylesheet" type="text/css" href="' . $ocsspath . '" media="Screen">
	'; }
  
  if(empty($ocssformpath)) {
	echo '<link rel="stylesheet" type="text/css" href="../css/ownerform.css" media="Screen">
	';
  } 
  else  {
	echo '<link rel="stylesheet" type="text/css" href="../../' . $ocssformpath . '" media="Screen">
	';
  }
?>
 
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

<br>
		<div style="padding:5px;font-family:geneva;font-size:1.3em;"><strong><?php echo $owner; ?> Web Admin</strong> 
			<br><span class="comment"> Choose one of the following  (<b>A-1</b> or <b>A-2</b> - below or <b>B-1, B-2, etc</b> - scroll down); <br>you can only do one per submit</span></div>
		
<table>
	<tr><td id="leftcol">
		   <?php $webpage = file_get_contents($sourcepage1); echo $webpage; ?>		
	</td></tr>
    <tr><td id="rightcol">
		<div style="font-family: geneva; font-size: 1.3em;margin-bottom:2px;margin-top:8px;"><strong class="red">B. </strong><strong>Delete from list</strong> <br> 
			<span class="comment">Check items to delete from one of the lists below (only one list at a time)</span><br><br>
		</div>
		<?php
		    $listnum = 0;
			foreach ($arr_ownersubs as &$ownersub) {
				$listnum = 1 + $listnum;
			    $owner_sectsub = $owner  . '_' .$ownersub;
			    $webpage = "";
				if($owner_sectsub == 'delete_deleteItem') {
				}
				else {
				   echo '<span class="comment"><big><strong class="red">B-' . $listnum . '.</strong> &nbsp; List name: ' . $owner_sectsub . '</big></span><br>';
				   echo '<div class="box"><br>';
				   echo '<form method="post" name="itemsSelect' . $listnum . '" action="http://' . $cgipath . '/article.pl"><br>';
                   $sourcepage = "http://$cgipath/article.pl?print_select%%fly%$owner_sectsub%%$userid%%owner_top%delete_select_end%%%$owner%%$listnum";
				   $webpage = file_get_contents($sourcepage); 
				   echo $webpage;
				   echo '</form></div><br><br>* * * * * * * *<br>';
				   echo '';
			    }
			}
		 ?>									
    </td>
	
</tr></table>
</div>
<br>
<strong class="red"> C. </strong><b>Below is the <?php echo $owner; ?> web page, a part of which you are changing (your list may be on a 2nd page).</b>
<iframe src="<?php echo 'http://' . $CONFIG['servername'] . '/'  . $owner . '_webpage/' ?>" width="100%" height="800px"></iframe>

</body></html>

	
