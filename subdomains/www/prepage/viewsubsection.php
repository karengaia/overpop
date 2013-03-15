<?php
require './../php/bootstrap.php';  /* FIXED THIS MISSPELLING in GIT_PATHS - was boostrap.php*/
$qstring = $_SERVER['QUERY_STRING'];
list($sectionname,$x,$pagenum) = explode('%',$qstring);
$sourcepage = "http://{$CONFIG['servername']}/{$CONFIG['cgi_path']}/article.pl?display_subsection%%%$sectionname%%$pagenum";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<!--   logo/header and 3 column layout design and css hand coding mostly by abstractmachines dot net :: --> 
<html>
<head> 
<title>WOA!! World Ovepopulation Awareness</title>

<?php readfile("./meta.html"); ?>

<?php readfile("./cssjspg2.html"); ?>

<?php 
   if (preg_match("/Sustainability_/", $sectionname)) { 
     readfile("./sustainability_js.html");
   }
   elseif(preg_match("/Impacts_/", $sectionname)) { 
	 readfile("./impacts_js.html");
   }
   else {
	 echo "</head>\n";
     echo "<body>\n";
   }
?>   


  <div id="world_population_wrapper">
<!--	 <div id="header2outer">	-->
	    <div id="header2">
			<div class="menu_container">
		       <?php readfile("./menu.html"); ?>
			</div>
			<div id="header2_inner">
            	<div id="population2_logo">
				</div>
				<div id="woa2_text">
					<h1>World Population Awareness</h1>
				</div>
			</div>
			<div id="header2_spacer"></div>
	    </div> <!-- header2 -->
<!-- </div>  header2_outer -->
	
	<table class="columns"><tr><td id="pg2leftcol">
	</td>
	<td id="pg2maincol">
		<?php $webpage = file_get_contents($sourcepage); echo $webpage; ?>
	</td>
	<td id="pg2rightcol">
    </td></tr></table>
	
</div><!-- wrapper -->


	</body>
	</html>

	
