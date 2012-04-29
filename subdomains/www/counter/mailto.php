<?php

	/*
	* Instructions:
	*
	* 1. Add this code into your html document that you want the count to display:
	*
	*   <script src="http://www.population-awareness.net/counter/mailto.php" type="text/javascript" language="javascript"></script>
	*
	*/

        $mailto = '<a href="mailto:overpop@overpopulation.org?subject=WOA: "</a>';

        header("Content-type: text/javascript");
	
	
	print "document.write('".addslashes($mailto)."');";		
?>