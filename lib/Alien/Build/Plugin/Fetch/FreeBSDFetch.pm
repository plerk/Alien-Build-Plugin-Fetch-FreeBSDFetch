package Alien::Build::Plugin::Fetch::FreeBSDFetch;

use strict;
use warnings;
use 5.008001;
use Carp ();
use Capture::Tiny qw( capture );
use Alien::Build::Plugin;
use Path::Tiny qw( path );
use File::Temp qw( tempdir );

# ABSTRACT: Alien::Build plugin for FreeBSD's fetch
# VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 PROPERTIES

=head2 url

=cut

has '+url' => '';

=head2 ssl

=cut

has ssl => 0;

sub init
{
  my($self, $meta) = @_;

  $meta->prop->{start_url} ||= $self->url;
  $self->url($meta->prop->{start_url});
  $self->url || Carp::croak('url is a required property');

  my $dir  = tempdir( CLEANUP => 1 );
  my $count = 0;

  $meta->register_hook(
    fetch => sub {
      my($build, $url) = @_;

      # fetch -v -v -o out $url
      my $file = $dir->child(sprintf("out%04d", $count++));
      my @cmd = ('fetch', '-v', '-v', '-o' => "$file", "$url");

      do {
        $build->log("+@cmd");
        my($out,$err,$exit) = capture {
          system @cmd;
        };
        my @out = $out ne '' ? (split /\n/, $out) : ();
        my @err = $err ne '' ? (split /\n/, $err) : ();
        $self->log("out: $_") for @out;
        $self->log("err: $_") for @err;
        if($exit)
        {
          die "fetch command failed";
        }
      };
    },
  );
}

1;
