<?php
$mactestfile = "macserver.txt";
if (file_exists($mactestfile)) {
  $url = "http://overpop/cgi-bin/article.pl?display_section%%%";
}
else {
  $url = "http://www.overpopulation.org/cgi-bin/cgiwrap/popaware/article.pl?display_section%%%";
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<!--   logo/header and 3 column layout design and css hand coding mostly by abstractmachines dot net :: --> 
<html>
<head> 
<title>Admin: CSWP - Motherlode's Committee for a Sustainable World Population</title>
<meta http-equiv="expires" content="0">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<link rel="stylesheet" type="text/css" href="css/cswp.css" media="Screen">

<style>
	html {background-color:#969;}
	body {margin-left: 40px; margin-right: 60px; font-size: 1.0em; color: #050505; background:#eee;}
	h1   {font-family:arial;font-size:20px;font-weight:bold;color:##712E82;text-align:center;}
	b    {font-family: verdana;font-size:12px;font-weight:bold;}
	table tr td {font-size:100%;}
	cite  {font-family:"comic sans ms"; font-size:10px; font-style: normal; display: inline;}
	span  {font-family:verdana; font-size:10px;}
	label {font-family:verdana; font-size:12px; font-weight:bold;}
	input, textarea {font-size:12px; font-family: arial; border: 1px solid #ccc; background: #fff; }
	select {font-size: 12px; font-family: arial; border: 1px solid #ccc; background: #fff;}
	p     {font-family:arial font-size:12px;}
	.grey {color:#666666;}
	cite.verdana {font-family:verdana;}
	#leftcol {width:350px; margin: 0; padding: 0; border: solid 2px #d0d0d0;}
	#rightcol {width:250px; margin: 0; padding: 0; border: solid 2px #d0d0d0;}
</style>

<script language="JavaScript">
</script> 

</head> 

<body basefont="arial">

<div style="margin-left:10px;margin-right:7px;margin-bottom:10px;">

	<div style="font-family:geneva;font-size:1.3em;"><strong>CSWP Webpage Item</strong> &nbsp;&nbsp; <b>Add or Change</b></div>
  	
	<table class="columns"><tr>
		
	<td id="leftcol">

		<form method="post" id="article" name="article" action=
		"http://[SCRIPTPATH]/article.pl">
		<input type="hidden" name="cmd" value="storeform">
		<input type="hidden" name="userid" value="[userid]">
		<input type="hidden" name="sysdate" value="[sysdate]">
		<input type="hidden" name="docid" value="[docid]">
		<input type="hidden" name="sectsubs" value="CSWP_calendar">
		<input type="hidden" name="thisSectsub" value="[thisSectsub]">
		<input type="hidden" name="ipform" value="cswpUpdate">


		<!-- STYLE, PRIORITY, REGIONS TABLE -->           

		<br>
		<table width="50%"><tr><td>
		<cite>

			<!-- - - PUB DATE  - - - - -->
			<label for 'pubmonth'>Start date</label> <cite>(used for putting items in order):</cite> 
			<br><cite>Does not appear on web page</cite>
			<select id="pubmonth" name="pubmonth">
			[PUBMONTHS]
			</select>
			<input type="text" name="pubday" size="3" maxlength="2" value="
			[PUBDAY]
			">
			<select id="pubyear" name="pubyear">
			[PUBYEARS]
			</select>
		</cite></td>

		<td><cite>Which section is it in?</cite><br>
			<select name="cswpsectsub">
			[CSWP_SECTIONS]	
			</select>	
			</td>
		</tr></table>

		<br>
		<!--- HEADLINE -->
		<table>
		<tr><td valign="bottom">
		<b>Title:</b>&nbsp;&nbsp; <span style="font-family:arial;font-size:82%">i.e: April 30 Thurs - ECOS Showing of Mother</span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input name="titlize" type=radio value="Y">
		<cite>   Titlize tool (after submit). </cite> <input name="titlize" type=radio value=""> <cite>Clear titlize</cite>
		</td> </tr></table>
		<input type="input" name="headline" size="100" maxlength="200" value="[headline]">
		<br><br>

		<!---  BODY -->
		    <label for='body'>Description:</label> &nbsp;   
			<span style="font-family:arial;font-size:82%">i.e: 6:30pm Room SH111, Science Building, Sierra College, Rocklin </span><br>
		    <textarea id="body" name="body" wrap="physical" rows="6" maxrows="150" cols="100">[body]</textarea>

		<!--- LINK AREA -->
		<br><br>
		<b>Link to event website, if needed:</b>
		  <br>
		<input type="input" name="link" size="100" maxlength="200" value="[link]">
		<br><br>

		<table><tr>
		<td>
		<label for='userid'>Userid</label><br>
		<input type="input" name="userid" size="6" maxlength="10" value="[userid]">
		</td><td>
		<label for='password'>password</label>
		<br>
		<input type="password" name="pin" size="6" maxlength="10">&nbsp;&nbsp;&nbsp;
		</td>
			<td>
			<input type=submit value="SUBMIT" name="submit">
			</td>
		</tr></table>
		<br>
		</div>
     </td>
     <td id="rightcol">
         <?php $webpage = file_get_contents("   http://www.overpopulation.org/cgi-bin/cgi-wrap/popaware/article.pl?print_select%%fly%%CSWP_events%%%%delete_select_end"); 
echo $webpage; ?>									
     </td>
     </tr></table>
</div>
	</body>
	</html>	

	
