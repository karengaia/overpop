<?php

if (file_exists(dirname(__FILE__) . '/settings_overrides.php')) {
  require dirname(__FILE__) . '/settings_overrides.php';
}
else {
	echo "  development  <br>";
	$CONFIG['mysql_host'] = 'overpop';
	$CONFIG['mysql_user'] = 'root';
	$CONFIG['mysql_password'] = '';
	$CONFIG['mysql_database'] = 'overpop';	
}