<?php

if (file_exists(dirname(__FILE__) . '/settings_overrides.php')) {
  require dirname(__FILE__) . '/settings_overrides.php';
}
else {
	$CONFIG['mysql_host'] = 'localhost';
	$CONFIG['mysql_user'] = 'root';
	$CONFIG['mysql_password'] = '';
	$CONFIG['mysql_database'] = 'overpop';	
}