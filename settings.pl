#!/usr/bin/perl --

# in overpopulation.org folder

sub set_config {
  local @DB = @_;
	
  push @INC, "/Users/karenpitts/Sites/web/www/overpopulation.org/sseeccuurriittyy/";
  push @INC, "/www/overpopulation.org/sseeccuurriittyy/";
  require("conf.pl");
  @DB = &config(@DB);

## do the following to override the password until we can get the secure one working

  if(-f "mactest.txt") {
    $DB{'pswd'} = '';  ## set to this until production
  }
  else {
    $DB{'pswd'} = 'fr00tfl1';  ## set to this until production
  }
  return($DB);
}

1;