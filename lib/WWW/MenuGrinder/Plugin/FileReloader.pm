package WWW::MenuGrinder::Plugin::FileReloader;

# ABSTRACT: WWW::MenuGrinder plugin to reload the menu when a file changes.

use Moose;

with 'WWW::MenuGrinder::Role::BeforePreMogrify';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

# New versions of Time::HiRes give us subsecond times on stat(). Use it if we
# can just in case we find ourselves racing against two crazy-fast updates.
BEGIN {
  eval {
    require Time::HiRes;
    Time::HiRes->import(qw(stat));
  };
}
has filename => (
  is => 'ro',
  required => 1
);

has timestamp => (
  is => 'rw'
);

sub before_pre_mogrify {
  my ($self) = @_;
  my $time = (stat $self->filename)[9];
  $self->timestamp( $time ) if defined $time;
}

sub before_mogrify {
  my ($self) = @_;

  my $time = (stat $self->filename)[9];

  if (defined $time and $time > $self->timestamp) {
    $self->grinder->init;
  }
}

no Moose;
1;
