<?php
$CONFIG = array(
  'mysql_host' => 'localhost',
  'mysql_user' => 'root',
  'mysql_password' => '',
  'mysql_database' => 'overpop'
);

if (file_exists(dirname(__FILE__) . '/settings_overrides.php')) {
  require dirname(__FILE__) . '/settings_overrides.php');
}
