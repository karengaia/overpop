#!/usr/bin/perl --

# -------------------------------------------------------------------
# DATABASE CONNECTIVITY SETTINGS
# -------------------------------------------------------------------

## in autosubmit/db_config folder

sub db_settings {
  if(-f "mactest.txt") {
	$DB{'hostname'} = "localhost";
	$DB{'username'} = "root";
	$DB{'pswd'} 	= "";
	$DB{'database'} = "overpop";
	$DB{'dbdriver'} = "mysql";
  }
  else {
	$DB{'hostname'} = "db.telana.com";
	$DB{'username'} = "overpop";
	$DB{'pswd'} 	= "d0m1n0";
	$DB{'database'} = "overpop";
	$DB{'dbdriver'} = "mysql";
  }
  return(@DB);
}

1;