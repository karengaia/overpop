<?php
$qstring = $_SERVER['QUERY_STRING'];
$sourcepage = "http://$CONFIG['servername']/{$CONFIG['cgi_path']}/$qstring";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<!--   logo/header and 3 column layout design and css hand coding mostly by abstractmachines dot net :: --> 
<html>
<head> 
<title>WOA!! World Ovepopulation Awareness</title>

<link rel="stylesheet" type="text/css" href="/css/woa_mauveindex.css" media="Screen">

<link rel="shortcut icon" href="img//mauve/favicon.ico">

<style>
#outermargin {margin-left:10px;}
</style>
</head>
<body>
  <div id="world_population_wrapper">

<!--	 <div id="header2outer">	-->
	    <div id="header2">
			<div id="header2_inner">
            	<div id="population2_logo">
				</div>
				<div id="woa2_text">
					<h1>World Overpopulation Awareness</h1>
				</div>
			</div>
			<div id="header2_spacer"></div>
	    </div> <!-- header2 -->
<!-- </div>  header2_outer -->
  <div id="outermargin">	
	<table class="columns"><tr><td id="pg2leftcol">
	</td>
	<td id="pg2maincol">
		<?php $webpage = file_get_contents($sourcepage); echo $webpage; ?>
	</td>
	<td id="pg2rightcol">
    </td></tr></table>
</div>	
</div><!-- wrapper -->


	</body>
	</html>

	
