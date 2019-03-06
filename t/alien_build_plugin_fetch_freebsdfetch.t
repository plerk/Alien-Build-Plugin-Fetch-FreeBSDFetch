use Test2::V0 -no_srand => 1;
use Test::Alien::Build;
use Alien::Build::Plugin::Fetch::FreeBSDFetch;
use Capture::Tiny qw( capture_merged );

sub n (&)
{
  my($sub) = @_;
  my($out, $res, $ex) = capture_merged { my $r = eval { $sub->() }; ($r,$@) };
  note $out if defined $out && $out ne '';
  die $ex if $ex;
  $res;
}

alien_subtest 'basic with start_url' => sub {

  my $build = alienfile_ok q{
    use alienfile;

    probe sub { 'share' };

    share {
      start_url 'http://foo.bar.baz';
      plugin 'Fetch::FreeBSDFetch';
    };
  };

  is(
    $build->meta->prop->{start_url},
    'http://foo.bar.baz',
  );

};

alien_subtest 'basic with url prop' => sub {

  my $build = alienfile_ok q{
    use alienfile;

    probe sub { 'share' };

    share {
      plugin 'Fetch::FreeBSDFetch' => 'http://baz.bar.foo';
    };
  };

  is(
    $build->meta->prop->{start_url},
    'http://baz.bar.foo',
  );

};

alien_subtest 'live tests' => sub {

  skip_all 'to enable live tests set ALIEN_BUILD_PLUGIN_FETCH_FREEBSDFETCH_LIVE on freebsd'
    unless $^O eq 'freebsd' && $ENV{ALIEN_BUILD_PLUGIN_FETCH_FREEBSDFETCH_LIVE};

  my $build = alienfile q{
    use alienfile;

    probe sub { 'share' };

    share {
      start_url 'https://foo';
      plugin 'Fetch::FreeBSDFetch';
      #plugin 'Fetch::HTTPTiny';
      plugin 'Decode::HTML';
    };
  };

  eval { $build->load_requires($build->install_type) };
  if($@)
  {
    note $@ if $@;
    skip_all 'test requires Decode::HTML share requires';
  }

  subtest 'directory listing' => sub {

    my $url = 'https://alienfile.org/dontpanic';
    note "url=$url";
    my $res = n { $build->fetch($url) };

    is
      $res,
      hash {
        field type    => 'html';
        field content => match qr/\<html/;
        field base    => match qr/^https?/;
      },
      'fetch of directory listing'
    ;

    $res = $build->decode($res);

    is
      $res,
      hash {
        field type => 'list';
        field list => array {
          item 0 => hash {
            field filename => match qr/\.tar\.gz$/;
            field url      => match qr/^https?:\/\/.*\.tar\.gz$/;
          };
          etc;
        };
      },
      'decode'
    ;

    $url = $res->{list}->[0]->{url};
    note "url=$url";

    $res = $build->fetch($url);

    is
      $res,
      hash {
        field filename => 'dontpanic-1.02.tar.gz';
        field type     => 'file';
        field content  => T();
      },
      'fetch file'
    ;

  };

};

done_testing

