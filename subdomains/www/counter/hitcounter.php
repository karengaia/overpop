<?php

	$testing = 0;
	if( $testing )
		header("Content-type: text/plain");
	else
		header("Content-type: text/javascript");
		
	$counter = new Counter();
	$counter->increment();
/*	$count = $counter->getCount(); */
	
	$hitcounter = new Hitcounter();
	$hitcounter->hitincrement();
	$hitcount = $hitcounter->getHitcount();
	
	print "document.write('".addslashes($hitcount)."');";
		
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
	
	class Hitcounter {

		var $hitcount;
		
		function Hitcounter() {
/*			 mysql_connect("localhost", "overpop", "") or die(mysql_error()); 
		     mysql_select_db("overpop") or die(mysql_error()); */
		     mysql_connect("db.telana.com", "overpop", "talkat1ve") or die(mysql_error()); 
		     mysql_select_db("overpop") or die(mysql_error());
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