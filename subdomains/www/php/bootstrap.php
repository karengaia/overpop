<?php
/**
 * All PHP scripts should include this file as the first thing they do.
 */

$CONFIG = array();

$CONFIG['environment'] = 'development';
$CONFIG['servername'] = "overpop";

$CONFIG['php_dir'] = dirname(__FILE__);
define('PHP_ROOT', $CONFIG['php_dir']);
$CONFIG['public_dir'] = dirname($CONFIG['php_dir']);
$CONFIG['cgibin_dir'] = $CONFIG['public_dir'] . '/cgi-bin';
$CONFIG['cgi_path'] = 'cgi-bin';
$CONFIG['app_dir'] = dirname(dirname($CONFIG['public_dir']));

$CONFIG['mysql_host'] = 'localhost';
$CONFIG['mysql_user'] = 'root';
$CONFIG['mysql_password'] = '';
$CONFIG['mysql_database'] = 'overpop';

// Override values for production
$_development_file = $CONFIG['app_dir'] . "/development.yes";
if (!file_exists($_development_file)) {
  $CONFIG['environment'] = 'production';
  $CONFIG['cgi_path'] = 'cgi-bin/cgiwrap/popaware';
  $CONFIG['servername'] = 'www.overpopulation.org';
  $CONFIG['mysql_host'] = 'db.telavant.com';
  $CONFIG['mysql_user'] = 'overpop';
  $CONFIG['mysql_password'] = 'fr00tfl1';
}

function db_conn() {
  static $db_conn;
  global $CONFIG;
  if (empty($db_conn)) {
    $db_conn = mysql_connect($CONFIG['mysql_host'], $CONFIG['mysql_user'], $CONFIG['mysql_password'])
     or die('Could not connect to MySQL database. ' . mysql_error());

    mysql_select_db($CONFIG['mysql_database'], $db_conn);
  }
  return $db_conn;
}
