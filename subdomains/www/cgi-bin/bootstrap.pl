# All Perl scripts should require this file as the first thing they do

use Cwd;
use File::Basename;

push @INC, dirname(getcwd . '/' . __FILE__);
require 'common.pl';
&get_site_info;

1;
