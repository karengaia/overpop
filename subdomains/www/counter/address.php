<?php

	/*
	* Instructions:
	*
	* 1. Add this code into your html document that you want the count to display:
	*
	*   <script src="counter.php" language="javascript"></script>
	*
	* 2. Set the permissions for the contact.txt file so that the it can be written to
	*    by php. Running this shell command (in Unix) should do it: 
	*
	*    chmod 777 contact.txt
	*
	*/

        header("Content-type: text/javascript");
	
        $fp = fopen("address.txt", "r");
	while( !feof($fp) )
          {
           $address .= fread($fp, 100);
          }
	fclose($fp);
	
	print "document.write('".addslashes($address)."');";		
?>