# All Perl scripts should require this file as the first thing they do

use Cwd;
use File::Basename;

if (__FILE__ =~ /^\.\/(.*)$/) {
  $file = $1;
} else {
  $file = __FILE__;
}
my $cgi_dir = dirname(getcwd . '/' . $file);
my $public_dir = dirname($cgi_dir);
my $subdomains_dir = dirname($public_dir);
my $app_dir = dirname($subdomains_dir);

require "$app_dir/settings.pl";

push @INC, $cgi_dir;
require 'common.pl';
&get_site_info;

1;
