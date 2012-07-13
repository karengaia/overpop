#!/usr/bin/perl --

use Cwd;
use File::Basename;


my $base_dir = $PATHS{'base_dir'};

%CONFIG = (
  db_host       => 'localhost',
  db_name       => 'overpop',
  db_user       => 'root',
  db_password   => '',
);

if(-f "$base_dir/settings_overrides.pl") {
  require "$base_dir/settings_overrides.pl";
  while (my ($key, $value) = each(%CONFIG_OVERRIDES)) {
    $CONFIG{$key} = $value;
  }
}


1;