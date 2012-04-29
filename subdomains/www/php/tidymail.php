<?php
/* http://tidy.sourceforge.net/docs/quickref.html */
/* Need to only use this on the message part!  and only for those in filter for html only */

$inmailpath = "/www/overpopulation.org/popnews_mail";
$backuppath = "/www/overpopulation.org/popnews_bkp";
$scriptpath = "/www/overpopulation.org/subdomains/www/cgi-bin";

if($handle = opendir($inmailpath) ) {
    while (false !== ($filename = readdir($handle))) {
	   $filepath = $inmailpath . '/' . $filename;
	   if(is_file($filepath) and strpos($filepath,'email')) {
		  echo '<br><br>';
	      echo $filepath;
		  echo '<br>';	
	      $content = "";
	      $content = file_get_contents($filepath);

	      preg_replace("\r\n","\n",$content);
	      preg_replace("\n\r","\n",$content);

	      list($hdr_section,$message) = explode("\n\n",$content,2); /* just work on message */
		echo "<br><br>";
		echo "*** HDR " . $hdr_section;
		echo "<br><br>";
          $message = parse_get_msg($message,$hdr_section);

          $message = encode($message,$hdr_section);

	      $content = $hdr_section . "\n\n" . $message;
	
	      $file_backup_path = $backuppath . '/' . $filename;
	      if(!file_exists($file_backup_path)) {
	          copy($filepath, $file_backup_path);
	      }
		  echo "<br><br>";
		  echo "*** MSG: bkp: " . $file_backup_path . '<br>';
		  echo $message;
		  unlink($filepath);
	      file_put_contents($filepath, $content);
       }
   }
}
closedir($handle);
/*
print <<< HTML
<html><head><meta http-equiv="refresh" content="3;url=http://$scriptpath/article.pl?display_section%%%Suggested_emailedItem%2\">";
</head><body><b>2. Finished Tidy: elimination of html in mail; going to separate out emails.</b></body><html>
HTML;
*/

function parse_get_msg ($message,$hdr) 
{
 /*
	preg_match( '/(<)http*?(>)/',$message,$matches );
	preg_replace('<http*?>',$matches[0],$message);
	
    if(strpos("Google Alerts", $hdr) > 0 or strpos("Google Alerts", $message) > 0) {
    echo "<br><br>";
    echo "*** GOOGLE ";
    echo "<br><br>";
	    $urls  =  _autolink_find_URLS( $message);   /* \b(((https?)://)*?)\b - starts and ends with word boundary */
		if( !empty($urls) ) {
			foreach($urls as $url) {
echo "<br><br>";
echo "*** GOOGLE LINK "  . $url;
echo "<br><br>";
			    if($content = file_get_contents($url)) {
				    preg_match( '<head>(?>.*?<title>)(?>(.*?)</title>)(?>.*?</head>)', /* <title[^>]*>(.*?)</title> */	
				       $content, $matches );
				    $title = $matches[2];
			        $body =  tidy_it($content); /* get body only */
				    preg_match( '<h1>(.*?)</h1>', /* header 1 */	
				       $body, $matches );
				    $header1 = $matches[0];
				    $message = $message . '/n/n~~~~~~~~~~~~/n/n' . 'TITLE: ' . $title . '/n/n'; 
				    $message = $message . 'H1: ' . $header1 . '/n/n~~~~~~~~~~~~/n/n' . $url . '/n/n' . $content;
		        }
		        else {
			        $message = $message . '/n/n~~~~~~~~~~~~/n/n' . "Couldn't get url " . $url . " contents";
		        }
		    }
		}
	}
*/	
	 if(strpos("From: William Ryerson", $hdr) > 0) {
		 list($message,$rest) = explode("Best wishes",$message,2);
     }

	return($message);
}

/*
Content-Type: text/plain; charset=ISO-8859-1
Content-Type: text/plain; charset=ISO-8859-1
Content-Type: text/plain;charset=iso-8859-1  (can be in the hdr)

Content-Type: text/plain; charset=ISO-8859-1 Content-Transfer-Encoding: 7bit NPG
Content-Type: text/plain;charset=iso-8859-1 Content-Transfer-Encoding: 8bit in header
*/

function encode($message, $hdr) {
/* Get the file's character encoding from a <meta> tag */
   preg_match( '/Content-Type*?charset=([\s])/i',
     $message, $matches );
   $encoding = $matches[0];

echo "<br><br>";
echo "***ENCODE match0 " . $matches[0] .  " match1 " . $matches[1] . " match2 " . $matches[2] . " match3 " . $matches[3];
echo "<br><br>";
/* Convert to ASCII */
   setlocale(LC_ALL, 'en_US.UTF8');
   $ascii_text = iconv( $encoding, 'ASCII//TRANSLIT', $message);

/* OLD   $utf8_text = iconv( $encoding, "utf-8", $message ); */

/* $newstring = mb_convert_encoding($oldstring, 'ISO-8859-15', 'UTF-8'); 
OR --- if (!function_exists('iconv') && function_exists('libiconv')) {
    function iconv($input_encoding, $output_encoding, $string) {
        return libiconv($input_encoding, $output_encoding, $string);
    }
}  */

/* Strip HTML tags and invisible text */
   preg_replace("0x96","0x2d",$message); /* replace illegal word dash with regular hyphen */

   $ascii_text = strip_html_tags( $ascii_text ); /* not php's strip_tags */

/* Decode HTML entities */
/* DON'T NEED   $ascii_text = html_entity_decode( $ascii_text, ENT_QUOTES, "ASCII" ); */

   echo '<br><br>';
   echo "***** ENCODING: " . $encoding;

   return($ascii_text);
}


/* Remove HTML tags, including invisible text such as style and
 * script code, and embedded objects.  Add line breaks around
 * block-level tags to prevent word joining after tag removal.
 */

function strip_html_tags( $text )
{
    $text = preg_replace(
        array(
          // Remove invisible content
            '@<head[^>]*?>.*?</head>@siu',
            '@<style[^>]*?>.*?</style>@siu',
            '@<script[^>]*?.*?</script>@siu',
            '@<object[^>]*?.*?</object>@siu',
            '@<embed[^>]*?.*?</embed>@siu',
            '@<applet[^>]*?.*?</applet>@siu',
            '@<noframes[^>]*?.*?</noframes>@siu',
            '@<noscript[^>]*?.*?</noscript>@siu',
            '@<noembed[^>]*?.*?</noembed>@siu',
          // Add line breaks before and after blocks
            '@</?((address)|(blockquote)|(center)|(del))@iu',
            '@</?((div)|(h[1-9])|(ins)|(isindex)|(p)|(pre))@iu',
            '@</?((dir)|(dl)|(dt)|(dd)|(li)|(menu)|(ol)|(ul))@iu',
            '@</?((table)|(th)|(td)|(caption))@iu',
            '@</?((form)|(button)|(fieldset)|(legend)|(input))@iu',
            '@</?((label)|(select)|(optgroup)|(option)|(textarea))@iu',
            '@</?((frameset)|(frame)|(iframe))@iu'
        ),
        array(
            ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
            "\n\$0", "\n\$0", "\n\$0", "\n\$0", "\n\$0", "\n\$0",
            "\n\$0", "\n\$0"
        ),
        $text );
    return strip_tags( $text );
}

function tidy_it($string)
{
/*	output-file */
	$config = array(
	'input-encoding' => 'utf8',
	'quiet' => TRUE,
	'drop-empty-paras' => FALSE,
	'drop-font-tags' => TRUE,
	'lower-literals' => TRUE,
	'output-html' => TRUE,
	'quote-marks' => TRUE,
	'show-body-only' => AUTO,
	'show-warnings' => TRUE,
	'wrap' => 0
	);
	$tidy = new tidy();
    return ($tidy->repairfile($string, $config));
/*
	quote-marks: TRUE &quot;  apostrophe  &#39;  default no
	quote-nbsp: TRUE  &nbsp; to Unicode 160 (decimal). default yes.
	quote-ampersand: TRUE  & to &amp;  default yes
	break-before-br: TRUE  puts newline before <br> default no
	word-2000: TRUE   strips excess MS stuff from doc- to- html files; default no
	clean: TRUE   strips out old tags (i.e. FONT) and replaces with style; default no
	drop-font-tags: TRUE  drops font tags w/o creating style; default no
	fix-bad-comments: TRUE  Replace unexpected hyphens with "="  <!--- ---> default no
	write-back: TRUE Writes back to the same file it was read from
	error-file: filename  Writes errors and warnings to the named file rather than to stderr.
	
	if (close(TIDY) == 0) {
	  my $exitcode = $? >> 8;
	  if ($exitcode == 1) {
	    printf STDERR "tidy issued warning messages\n";
	  } elsif ($exitcode == 2) {
	    printf STDERR "tidy issued error messages\n";
	  } else {
	    die "tidy exited with code: $exitcode\n";
	  }
	} else {
	  printf STDERR "tidy detected no errors\n";
	}
	
*/
}

function _autolink_find_URLS( $text )
{
	
/*	$reg_exUrl = "/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/"; */
	
	
  // build the patterns
  $scheme         =       '(http:\/\/|https:\/\/)';
  $www            =       'www\.';
  $ip             =       '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
  $subdomain      =       '[-a-z0-9_]+\.';
  $name           =       '[a-z][-a-z0-9]+\.';
  $tld            =       '[a-z]+(\.[a-z]{2,2})?';
  $the_rest       =       '\/?[a-z0-9._\/~#&=;%+?-]+[a-z0-9\/#=?]{1,1}';            
  $pattern        =       "$scheme?(?(1)($ip|($subdomain)?$name$tld)|($www$name$tld))$the_rest";
    
  $pattern        =       '/'.$pattern.'/is';
  $c              =       preg_match_all( $pattern, $text, $m );
  unset( $text, $scheme, $www, $ip, $subdomain, $name, $tld, $the_rest, $pattern );
  if( $c )
  {
    return( array_flip($m[0]) );
  }
  return( array() );
} 
?>