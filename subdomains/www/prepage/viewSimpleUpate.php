<?php 
require './../php/bootstrap.php';
$qstring = $_SERVER['QUERY_STRING'];
list($docid,$template,$sectionname) = explode('%',$qstring);

$sourcepage1 = "http://{$CONFIG['servername']}/{$CONFIG['cgi_path']}/article.pl?display%$template%$docid%";
$sourcepage2 = "http://{$CONFIG['servername']}/{$CONFIG['cgi_path']}/article.pl?print_select%%fly%%$sectionname%%%%delete_select_end";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
 
<title>Admin: CSWP - Motherlode's Committee for a Sustainable World Population</title>
<meta http-equiv="expires" content="0">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<link rel="stylesheet" type="text/css" href="http://motherlode.sierraclub.org/population/css/cswp.css" media="Screen">
<link rel="stylesheet" type="text/css" href="/css/cswpform.css" media="Screen">

<script language="javascript" type="text/javascript">
<!--
function clearItem() {
document.getElementById('sysdate').value = "";
document.getElementById('docid').value = "";
document.getElementById('thisSectsub').value = "";
document.getElementById('pubmonth').value = "";
document.getElementById('pubday').value = "";
document.getElementById('pubyear').value = "";
document.getElementById('titlize').value = "N";
document.getElementById('headline').value = "";
document.getElementById('body').value = "";
document.getElementById('link').value = "";
}

//-->
</script>
</head> 

<body basefont="arial">

<div style="margin-left:10px;margin-right:7px;margin-bottom:10px;">
<br><br>
		<div style="font-family:geneva;font-size:1.3em;text-align:center;"><strong>CSWP Web Admin</strong> &nbsp;&nbsp; <b>Do left or right column, not both at one time</b></div>
		
<table class="columns">
	<tr><td id="leftcol">

		   <?php $webpage = file_get_contents($sourcepage1); echo $webpage; ?>		
		</div>
	</td>
    <td id="rightcol">
		<div style="font-family: geneva; font-size: 1.3em;"><strong>Delete from list</strong> <br> 
			<cite><big>Check items to delete from the <?php echo $sectionname;?> list below</big></cite></div><br>
	
		   <?php $webpage = file_get_contents($sourcepage2); echo $webpage; ?>									
    </td>
	
</tr></table>
</div>
<iframe src="http://motherlode.sierraclub.org/population/" width="100%" height="800px"></iframe>

</body></html>

	
