package WWW::MenuGrinder::Plugin::NullLoader;

# ABSTRACT: WWW::MenuGrinder Plugin that loads from the config.

use Moose;

with 'WWW::MenuGrinder::Role::Loader';

sub load {
  return $self->grinder->config->{menu}
}

no Moose;
1;
