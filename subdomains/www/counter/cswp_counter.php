<?php

	/*
	* Instructions:
	*
	* 1. Add this code into your html document that you want the count to display:
	*
	*   <script src="counter.php" language="javascript"></script>
	*
	* 2. Set the permissions for the count.txt file so that the it can be written to
	*    by php. Running this shell command (in Unix) should do it: 
	*
	*    chmod 777 count.txt
	*
	*/

	$testing = 0;
	
	if( $testing )
		header("Content-type: text/plain");
	else
		header("Content-type: text/javascript");
	
	$counter = new Counter();
	$counter->increment();
	$count = $counter->getCount();
	
	print "document.write('".addslashes($count)."');";
	
	
	class Counter {
	
		var $count;
		var $file = "cswp_count.txt";
		
		function getCount()
		{
			if( isset($this->count) ) return $this->count;
			
			$fp = fopen($this->file, "r");
			$this->count = "";
			while( !feof($fp) )
			{
				$count .= fread($fp, 100);
			}
			$this->count = intval($count);
			fclose($fp);
			
			return $this->count;
		}
		
		function setCount()
		{
			
			$fp = fopen($this->file, "w");
			fwrite($fp, "".$this->count);
			fclose($fp);
		}
		
		function increment()
		{
			if( !isset($this->count) ) $this->getCount();
			$this->count++;
			$this->setCount();
		}
	
	}
	
?>