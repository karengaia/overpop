<?php
require('config.php');

$conn = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS)
 or die('Could not connect to MySQL database. ' . mysql_error());

$sql = "CREATE DATABASE IF NOT EXISTS " . SQL_DB . ";";

$res = mysql_query($sql) or die(mysql_error());

mysql_select_db(SQL_DB,$conn);

$sql1 = <<<EOS
 CREATE TABLE IF NOT EXISTS ml_lists (
  ml_id int(11) NOT NULL auto_increment,
  listname varchar(255) NOT NULL default '',
  PRIMARY KEY (ml_id)
 ) TYPE=MyISAM;
EOS;

$sql2 = <<<EOS
 CREATE TABLE IF NOT EXISTS ml_subscriptions (
  ml_id int(11) NOT NULL default '0',
  user_id int(11) NOT NULL default '0',
  pending tinyint(1) NOT NULL default '1',
  PRIMARY KEY (ml_id,user_id)
 ) TYPE=MyISAM;
EOS;

$sql3 = <<<EOS
 CREATE TABLE IF NOT EXISTS ml_users (
  user_id int(11) NOT NULL auto_increment,
  firstname varchar(255) default '',
  lastname varchar(255) default '',
  e_mail varchar(255) NOT NULL default '',
  PRIMARY KEY (user_id)
 ) TYPE=MyISAM;
EOS;

$res = mysql_query($sql1) or die(mysql_error());
$res = mysql_query($sql2) or die(mysql_error());
$res = mysql_query($sql3) or die(mysql_error());
echo "Done.";
?>