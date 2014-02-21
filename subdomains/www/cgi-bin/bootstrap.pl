#!/usr/bin/perl --
# All Perl scripts should require this file as the first thing they do

use Cwd;
use File::Basename;

%PATHS = ();

if (__FILE__ =~ /^\.\/(.*)$/) {
  $file = $1;
} else {
  $file = __FILE__;
}

my $cgi_dir = getcwd( "/ . $file");
# my $cgi_dir = dirname(getcwd . '/' . $file);
my $public_dir = dirname($cgi_dir);

for($i=1;$i<4;$i++) {  # handles cgi-bin/cgiwrap/popaware structure in production
	if(-d "$public_dir/cgi-bin") {
	  break;
	}
	else {
	  $public_dir = dirname($public_dir);
    }
}

my $subdomains_dir = dirname($public_dir);
my $base_dir = dirname($subdomains_dir);

$PATHS{'base_dir'}       = $base_dir;
$PATHS{'subdomains_dir'} = $subdomains_dir;
$PATHS{'public_dir'}     = $public_dir;
$PATHS{'cgi_dir'}        = $cgi_dir;

require "$base_dir/settings.pl";

push @INC, $cgi_dir;

1;
