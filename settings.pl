#!/usr/bin/perl --

use Cwd;
use File::Basename;

# All this just to get the full path to the
# current directory
if (__FILE__ =~ /^\.\/(.*)$/) {
  $file = $1;
} else {
  $file = __FILE__;
}
my $app_dir;
if ($file =~ /^\//) {
  $app_dir = dirname($file);
} else {
  $app_dir = dirname(getcwd . '/' . $file);
}

%CONFIG = (
  db_host       => 'localhost',
  db_name       => 'overpop',
  db_user       => 'root',
  db_password   => '',
);

if(-f "$app_dir/settings_overrides.pl") {
  require "$app_dir/settings_overrides.pl";
  while (my ($key, $value) = each(%CONFIG_OVERRIDES)) {
    $CONFIG{$key} = $value;
  }
}

1;