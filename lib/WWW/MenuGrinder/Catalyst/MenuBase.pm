package WWW::MenuGrinder::Catalyst::MenuBase;

# ABSTRACT : WWW::MenuGrinder base class for Catalyst

use Moose;

extends 'WWW::MenuGrinder';

has '_c' => (
  is => 'rw',
);

has 'path' => (
  is => 'rw',
);

has 'user' => (
  is => 'rw',
);

# Supply a default that works with C::P::Authz::Roles
sub has_priv {
  my ($self, $priv) = @_;

  return $self->_c->check_user_roles($priv);
}

sub path {
  my ($self, $path) = @_;

  return $self->c->path;
}

sub BUILD {
  my ($self) = @_;

  weaken($self->_c);
}

no Moose;
1;
