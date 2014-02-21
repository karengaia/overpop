<?php
require './../php/bootstrap.php';
$url = "http://{$CONFIG['servername']}/{$CONFIG['cgi_path']}/article.pl?display_section%%%";
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head> 
<title>WOA!! World Ovepopulation Awareness</title>
<meta http-equiv="expires" content="0">
<?php readfile("./meta.html"); ?>	 

<?php readfile("./cssjspg1.html"); ?> 

</head> 

<body>
	<div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	
	<div id="world_population_wrapper">
	    <div id="header">
			<div class="menu_container">
		       <?php $str= file_get_contents("./menu.html");
	            echo $str;?>

			</div>
			<div id="header_inner">
				<div id="population_awareness_logo">
				</div>
				<div id="woa_text">
					<h1>World Overpopulation Awareness</h1>
					<p>Also known as: &nbsp;&nbsp; WOA!! &nbsp;&nbsp; * &nbsp;&nbsp; 
						World Population Awareness &nbsp;&nbsp; * &nbsp;&nbsp; population-awareness.net
					</p>
				</div>
			</div>
			
	    </div> <!-- header -->

	<table lclass="columns"><tr>

<!-- LEFT COLUMN  -->
		
	<td id="leftcol">
		
		<div>
			 <?php readfile("./pg1_pics.html"); ?>
		</div>
		
		<div style="margin-left:6px;" class="sidebar" >
    
        <p><a target="_blank" href="/PopBasics">WOA!!s Population Basics Slideshow</a></p>

       <p><a target="_blank" href="http://howmany.org/Articles/PeopleAndPlanetRights-IPS.pdf">
		People's Rights, Planet's Rights -
		Holistic Approaches to a Sustainable Population</a>
		<small>(pdf) Suzanne York, Institute for Population Studies</small><p>
		
        <p><a target="_blank" href="/ArtElphik.pdf">Art Elphick's Pop- ulation Slide Show</a><br>
	<small>Online or 'in person' in San Diego area</small> <p>	   
        </div>


		<div class="sidebar sidebar_lft_list pinkbeige">
			<?php readfile("./videos.html"); ?>
			<br>
			<a target="_blank" href="/education.html#videos">... more ...</a>
		</div>
		
		<div class="sidebar sidebar_lft_list taupe">
			<?php readfile("./popads.html"); ?>
			<br>
			<a target="_blank" href="/pdfs_documents/WiseGivingGuide.pdf">Wise Giving Guide</a>
		</div>

     </td>

<!-- CENTER COLUMN  -->

     <td id="centercol">


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

</td>

<!-- RIGHT COLUMN  -->

<td id="rightcol">
	
<!-- population clock -->

        <!-- set to display:none for non-ie6 -->
		<div class="clock_ie">
			<p><span>World Population:</span>
			<a target="top" href="http://www.census.gov/main/www/popclock.html">
			<acronym title="US Census Bureau adjusted to UN est.">
			<script src="/counter/popclock_short.php" type="text/javascript" language="javascript"></script></acronym></a></p>
		</div>
		
<!-- top links, right col -->
		
		<div style="margin: 15px 13px 30px; 17px; height:6px;">
			<acronym title="Share overpopulation.org on Facebook">
		<a name="fb_share" type="button" share_url="http://www.overpopulation.org"></a></acronym> 
		<script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" 
		        type="text/javascript"></script><small>
		<a href="http://overpopulation.org/sitemap.html">Site Map</a> |		
		<a href="http://mobile.overpopulation.org"><acronym title="WOA!! for your handheld">Mobile</acronym></a> |
		<a href="http://www.facebook.com/Overpopulation.org"><acronym title="Visit WOA!!s Facebook page">Facebook</acronym></a>
        </small>
		</div>
		<div class="not"><img src="/img/WOA_logo_TN.png"></div>
		
<!-- news index -->
		
		<div id="newsIndexBox">
		<ul><li>
		        <div class="titleCell">
		            <h4>News Digest Index <small><small><small>(mouse here)</small></small></small></h4>
		        </div>
		        <ul><br><br>
					&nbsp;Click on left bullet to see article, this page
				   <?php readfile("./newsindex.html"); ?>
		        </ul>
		</li></ul>
		</div>

<!-- SUBSCRIBE -->

		<div class="sidebar sidebar_rt_list mauve_lt">
			<?php readfile("./popnewsAd.html"); ?>
		</div>
				
<!-- ALERTS -->

		<div class="sidebar sidebar_rt_list rust" style="max-height:300px;overflow-y:auto;overflow-x:hidden;">
		<!--	<h4>Action Alerts</h4> -->
			<?php readfile("./newsalerts.html"); ?>
         </div>

		<!--
					<h4>Action Alerts <small>(on Twitter)</small></h4>
					<a class="twitter-timeline" height="300" href="https://twitter.com/WoaPopAlerts"  data-widget-id="376127859330265089" data-chrome="nofooter noheader"></a>
					<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
		-->
		

<!-- HELP WOA -->

		<div class="sidebar sidebar_rt_list pinkbeige">
			<?php readfile("./helpwoa.html"); ?>
		</div>
						

<!-- HEADLINES -->

        <div class="sidebar sidebar_rt_list duskyturq2" style="max-height:500px;overflow-y:auto;overflow-x:hidden;">
			<?php readfile("./newsheadlines.html"); ?>
        </div>

<!-- TWITTER HEADLINES -->				
		<div class="sidebar sidebar_rt_list duskyturq2">
			<h4>Headlines <small>(on Twitter)</small></h4>				
			<a class="twitter-timeline" height="300" href="https://twitter.com/WoaPop"  data-widget-id="374252530772881409" data-chrome="nofooter noheader"></a>
			<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
		</div>

<!-- CALENDAR -->
								
		<div class="sidebar sidebar_rt_list yellowtan">
			<?php readfile("./calendar.html"); ?>
		</div>
		
<!-- CARTOONS -->
		
		<div class="sidebar_img">
			 <?php readfile("./cartoons.html"); ?>
		</div>

<!-- FACEBOOK -->
		
		<div class="fb-like-box" data-href="https://www.facebook.com/Overpopulation.org?ref=hl" data-width="299" data-height="600" data-show-faces="false" data-header="true" data-stream="true" data-show-border="true"></div>
		

<!-- KARENS TRAVELS -->
		<div id="travel" class="sidebar sidebar_rt_list duskyturq2">
			<?php readfile("./kGaiasTravels.html"); ?>
		</div>
		
		<div>
			<a id="slideshow_lft" href="#"><img src="/img/pg1sidebar/PopulationTrain_TN.jpg" alt="The little train climbing the population growth mountain, saying: I think I can, I think I can"><br><cite><small>See enlargement</small></cite><span></span>
		</a>
		</div>
									
     </td></tr></table>
	
</div><!-- wrapper -->

<div id="hitcounter">
	<?php readfile("./hitcounter.html"); ?>
</div>


<script type="text/javascript" src="//assets.pinterest.com/js/pinit.js"></script>

	</body>
	</html>	

	
