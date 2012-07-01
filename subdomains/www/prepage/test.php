<?php
require './../php/boostrap.php';
$sourcepage = "http://{$CONFIG['servername']}/{$CONFIG['cgi_path']}/article.pl?print_select%%fly%%CSWP_events%%%%delete_select_end";
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
	#leftcol {width:450px; margin: 0; padding: 0; border: solid 2px #d0d0d0;}
	#rightcol {width:300px; margin: 0; padding: 0; border: solid 2px #d0d0d0;}
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
		"http://overpop/cgi-bin/article.pl">

		<input type="hidden" name="cmd" value="storeform">
		<input type="hidden" name="userid" value="A3491">
		<input type="hidden" name="sysdate" value="2012-04-21">
		<input type="hidden" name="docid" value="026377">
		<input type="hidden" name="sectsubs" value="CSWP_calendar">
		<input type="hidden" name="thisSectsub" value="">
		<input type="hidden" name="ipform" value="cswpUpdate">
		<input type="hidden" name="owner" value="">

		<!-- STYLE, PRIORITY, REGIONS TABLE -->           

		<br>
		<table width="50%"><tr><td>
		<cite>

			<!-- - - PUB DATE  - - - - -->
			<label for 'pubmonth'>Start date</label> <cite>(used for putting items in order):</cite> 
			<br><cite>Does not appear on web page</cite>

			<select id="pubmonth" name="pubmonth">
<option id="mm01" value=01>January</option>
<option id="mm02" value=02>February</option>
<option id="mm03" value=03>March</option>
<option id="mm04" value=04 selected>April</option>
<option id="mm05" value=05>May</option>
<option id="mm06" value=06>June</option>
<option id="mm07" value=07>July</option>
<option id="mm08" value=08>August</option>

<option id="mm09" value=09>September</option>
<option id="mm10" value=10>October</option>
<option id="mm11" value=11>November</option>
<option id="mm12" value=12>December</option>
<option value="_">_</option>

			</select>
			<input type="text" name="pubday" size="3" maxlength="2" value="
16
			">
			<select id="pubyear" name="pubyear">

<option value="no date">no date</option>
<option id="yyyy1990" value="1990">1990</option>
<option id="yyyy1991" value="1991">1991</option>
<option id="yyyy1992" value="1992">1992</option>
<option id="yyyy1993" value="1993">1993</option>
<option id="yyyy1994" value="1994">1994</option>
<option id="yyyy1995" value="1995">1995</option>
<option id="yyyy1996" value="1996">1996</option>
<option id="yyyy1997" value="1997">1997</option>

<option id="yyyy1998" value="1998">1998</option>
<option id="yyyy1999" value="1999">1999</option>
<option id="yyyy2000" value="2000">2000</option>
<option id="yyyy2001" value="2001">2001</option>
<option id="yyyy2002" value="2002">2002</option>
<option id="yyyy2003" value="2003">2003</option>
<option id="yyyy2004" value="2004">2004</option>
<option id="yyyy2005" value="2005">2005</option>
<option id="yyyy2006" value="2006">2006</option>

<option id="yyyy2007" value="2007">2007</option>
<option id="yyyy2008" value="2008">2008</option>
<option id="yyyy2009" value="2009">2009</option>
<option id="yyyy2010" value="2010">2010</option>
<option id="yyyy2011" value="2011">2011</option>
<option id="yyyy2012" value="2012" selected>2012</option>
<option id="yyyy2013" value="2013">2013</option>

			</select>

		</cite></td>

		<td><cite>Which section is it in?</cite><br>
			<select name="cswpsectsub">
<option value="CSWP_events" selected >CSWP_events</option>
<option value="CSWP_MotherSch"  >CSWP_MotherSch</option>
	
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
		<input type="input" name="headline" size="100" maxlength="200" value="April 30 Thurs - Ecos Showing of Mother">
		<br><br>

		<!---  BODY -->

		    <label for='body'>Description:</label> &nbsp;   
			<span style="font-family:arial;font-size:82%">i.e: 6:30pm Room SH111, Science Building, Sierra College, Rocklin </span><br>
		    <textarea id="body" name="body" wrap="physical" rows="6" maxrows="150" cols="100">6:30pm Room SH111, Science Building, Sierra College, Rocklin </textarea>

		<!--- LINK AREA -->
		<br><br>
		<b>Link to event website, if needed:</b>

		  <br>
		<input type="input" name="link" size="100" maxlength="200" value="http://overpopulation.org">
		<br><br>

		<table><tr>
		<td>
		<label for='userid'>Userid</label><br>
		<input type="input" name="userid" size="6" maxlength="10" value="A3491">
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
         <?php $webpage = file_get_contents($sourcepage); echo $webpage; ?>									
     </td>
     </tr></table>
</div>
	</body>
	</html>	

	
