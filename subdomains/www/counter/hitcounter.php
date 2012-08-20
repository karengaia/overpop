<?php

if( $testing )
	header("Content-type: text/plain");
else
	header("Content-type: text/javascript");
	
require dirname(__FILE__) . '/../php/bootstrap.php';

	$testing = 0;

		
	$counter = new Counter();
	$counter->increment();
	$count = $counter->getCount(); 
	
	$hitcounter = new Hitcounter();
	$hitcounter->hitincrement();
	$hitcount = $hitcounter->getHitcount();
	
	print "document.write('".addslashes($hitcount)."');";
	
// echo "dir_FILE " . dirname(__FILE__) . '/../php/bootstrap.php';
	
	class Counter {
	
		var $count;
		var $file = "count.txt";
		
		function getCount()
		{
			if( isset($this->count) ) return $this->count;
			
			$fp = fopen($this->file, "r");
			$this->count = "";
			while( !feof($fp) )
			{
				$this->count .= fread($fp, 100);
			}
			$this->count = intval($this->count);
			fclose($fp);
			
			return $this->count;
		}
		
		function setCount()
		{		
	echo "setCount " . $this->count . " ..file " . $this->file; 
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
	
	class Hitcounter {

		var $hitcount;
		
		function Hitcounter() {
           db_conn();
		}

		function getHitcount() {
			if( isset($this->hitcount) ) return $this->hitcount;
			$this->hitcount = "";
            $count = mysql_fetch_row(mysql_query("SELECT hits FROM counters"));
            $this->hitcount = $count[0];
			return $this->hitcount;
		}

		function setHitcount()
		{
		}

		function hitincrement()
		{
		 mysql_query("UPDATE counters SET hits = hits + 1");
		}

	}
	
?>