<?php
/**
 * All PHP scripts should include this file as the first thing they do.
 *    overpopulation.org/subdomains/www/php/bootstrap.php
 */

$CONFIG = array();
$CONFIG['php_dir'] = dirname(__FILE__);
define('PHP_ROOT', $CONFIG['php_dir']);
$CONFIG['public_dir'] = dirname($CONFIG['php_dir']);
$CONFIG['app_dir'] = dirname(dirname($CONFIG['public_dir']));
$CONFIG['cgibin_dir'] = $CONFIG['public_dir'] . '/cgi-bin';

// Override values for production
$_development_file = $CONFIG['app_dir'] . '/development.yes';

if (file_exists($_development_file)) {
  $CONFIG['environment'] = 'development';
  $CONFIG['cgi_path']    = 'cgi-bin';
  $CONFIG['servername']  = "overpop";
}
else {
  $CONFIG['environment'] = 'production';
  $CONFIG['cgi_path']    = 'cgi-bin/cgiwrap/popaware';
  $CONFIG['servername']  = 'http://www.overpopulation.org';	
}

require $CONFIG['app_dir'] . '/settings.php';

function db_conn() {
  static $db_conn;
  global $CONFIG;
  if (empty($db_conn)) {
	 $host = $CONFIG['mysql_host'];
	 $user = $CONFIG['mysql_user'];
	 $pwd  = $CONFIG['mysql_password'];
	 $database = $CONFIG['mysql_database'];
// echo "bootstrap.php host " . $host . " ...usr " . $user . " ...pwd " . $pwd . " ..db " . $database;
    $db_conn = mysql_connect($host, $user, $pwd)
     or die('Could not connect to MySQL database. ' . mysql_error());	

    mysql_select_db($database, $db_conn);
  }
  return $db_conn;
}
