use Test2::V0 -no_srand => 1;
use Test::Alien::Build;
use Alien::Build::Plugin::Fetch::FreeBSDFetch;

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

done_testing
