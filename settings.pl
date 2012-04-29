#!/usr/bin/perl --

use File::Basename;

# in overpopulation.org folder

sub set_config {
  local @DB = @_;
	
  my $rootdir = dirname(__FILE__);
  push @INC, "$rootdir/sseeccuurriittyy/";
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