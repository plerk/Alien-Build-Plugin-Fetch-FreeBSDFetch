use strict;
use warnings;
use File::Which qw( which );

if($^O ne 'freebsd')
{
  print "This dist is only available on FreeBSD\n";
  exit;
}

unless(which 'fetch')
{
  print "This dist requires the fetch command\n";
  exit;
}
