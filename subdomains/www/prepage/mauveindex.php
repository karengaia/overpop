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
<title>WOA!! World Ovepopulation Awareness</title>

<?php readfile("./meta.html"); ?>	 

<?php readfile("./cssjspg1.html"); ?> 

</head> 

<body>
	<div id="world_population_wrapper">
	    <div id="header">
			<div class="menu_container">
		       <?php readfile("./menu.html"); ?>

			</div>
			<div id="header_inner">
				<div id="population_awareness_logo">
				</div>
				<div id="woa_text">
					<h1>World Overpopulation Awareness</h1>
					<p>Also known as: &nbsp;&nbsp; WOA!! &nbsp;&nbsp; * &nbsp;&nbsp; 
						World Population Awareness &nbsp;&nbsp; * &nbsp;&nbsp; population-awareness.net</p>
					</p>
				</div>
			</div>
			
	    </div> <!-- header -->
	
	<table class="columns"><tr>
		
	<td id="leftcol">
		
		<div>
			 <?php readfile("./pg1_pics.html"); ?>
		</div>
    
		<div class="sidebar sidebar_lft_list pinkbeige">
			<?php readfile("./videos.html"); ?>
		</div>
		
		<div class="sidebar sidebar_lft_list taupe">
			<?php readfile("./popads.html"); ?>
		</div>

     </td><td id="centercol">


<!-- Quotes  -->

			<div id="quotetext" >
				If we don't halt population growth with justice and compassion, it will be done for us by nature, brutally and without pity - and will leave a ravaged world. <span>Nobel Laureate Dr. Henry W. Kendall</span>
			<!-- be sure to leave above quote in place for users with no javascript. -->

									<script type="text/javascript" >
									var myquotes = new Array(
      <?php readfile("./quotes.html"); ?> 
);

									function rotatequote()
									{
										thequote = myquotes.shift(); //Pull the top one
										myquotes.push(thequote); //And add it back to the end

										document.getElementById('quotetext').innerHTML = thequote;
										// This rotates the quote every 10 seconds.
										// Replace 10000 with (the number of seconds you want) * 1000
										t=setTimeout("rotatequote()",8000);
									}

									// Start the first rotation.
									rotatequote();
									</script>
		</div>

<!-- News Digest  -->

			<?php readfile("./newsMidColumn.html"); ?>	
			<!-- php $url = $url . "NewsDigest_NewsPhp"; $news = file_get_contents($url); echo $news; -->

</td><td id="rightcol">
	
<!-- population clock -->

        <!-- set to display:none for non-ie6 -->
		<div class="clock_ie">
			<p><span>World Population:</span>
			<a target="top" href="http://www.census.gov/main/www/popclock.html">
			<acronym title="World Population, US Census Bureau est.">
			<script src="/counter/popclock_short.php" type="text/javascript" language="javascript"></script></acronym></a></p>
		</div>
		
<!-- top links, right col -->
		
		<div style="margin: 15px 13px 30px; 17px; height:6px;">
		<a name="fb_share" type="icon" share_url="http://www.overpopulation.org"></a> 
		<script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" 
		        type="text/javascript"></script><small>Share |
		<a href="http://overpopulation.org/sitemap.html">Site Map</a> |		
		<a href="http://mobile.overpopulation.org">Mobile</a> |
		<a href="http://www.facebook.com/#!/pages/World-Overpopulation-Awareness/153698908009675">Facebook</a>
        </small>
		</div>
		
<!-- news index -->
		
		<div id="newsIndexBox" class="sidebar sidebar_rt_list mauve_lt">
		<ul>
		    <li>
		        <div class="titleCell">
		            <h4>News Digest Index</h4>
		        </div>
		        <ul><br>
					&nbsp;Click on left bullet to see article, this page
					<!--php $urlfull = $url . "NewsDigest_newsindex"; 
					$sectsub = file_get_contents($urlfull); 
					echo $sectsub . '<br>'; 
					-->
				   <?php readfile("./newsindex.html"); ?>
		        </ul>
		    </li>
		</ul>
		</div>

<!-- headlines -->
		
		<div class="sidebar sidebar_rt_list duskyturq2">				
			<?php readfile("./newsheadlines.html"); ?>
			<p style="text-align:center;"><a target="_blank" href="/headlines.html">See all</a></p>
		</div>

<!-- calendar -->
								
		<div class="sidebar sidebar_rt_list yellowtan">
			<?php readfile("./calendar.html"); ?>
		</div>

		<div class="sidebar sidebar_rt_list mauve_lt">
			<?php readfile("./popnewsEmailAd.html"); ?>
		</div>
		
		<div class="sidebar sidebar_rt_list pinkbeige">
			<?php readfile("./helpwoa.html"); ?>
		</div>
		
		<div class="sidebar_img">
			 <?php readfile("./cartoons.html"); ?>
		</div>
		
		<div id="travel" class="sidebar sidebar_rt_list duskyturq2">
			<?php readfile("./kGaiasTravels.html"); ?>
		</div>
									
     </td></tr></table>
	
</div><!-- wrapper -->

<div id="hitcounter">
	<?php readfile("./hitcounter.html"); ?>
</div>




	</body>
	</html>	

	
