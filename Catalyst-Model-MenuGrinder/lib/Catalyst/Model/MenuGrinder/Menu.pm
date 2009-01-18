package Catalyst::Model::MenuGrinder::Menu;

# ABSTRACT : WWW::MenuGrinder base class for Catalyst

use Moose;

extends 'WWW::MenuGrinder';

use Scalar::Util qw(weaken);

has '_c' => (
  is => 'rw',
);

# Supply a default that works with C::P::Authz::Roles
sub has_priv {
  my ($self, $priv) = @_;

  return $self->_c->check_user_roles($priv);
}

sub path {
  my ($self, $path) = @_;

  return $self->_c->req->path;
}

sub _get_all_vars {
  my ($self) = @_;
  my $c = $self->_c;

  my %vars;

  if ($c->can('session')) {
    %vars = %{ $c->session };
  }
  %vars = ( %vars, %{ $c->stash });

  return \%vars;
}

has 'menu_vars' => (
  is => 'rw',
);

sub get_variable {
  my ($self, $varname) = @_;

  return $self->menu_vars->{$varname};
}

before get_menu => sub {
  my ($self) = @_;

  $self->_c->stats->profile(begin => "Rendering menu");
};

after get_menu => sub {
  my ($self) = @_;

  $self->_c->stats->profile(end => "Rendering menu");
};

sub _accept_context {
  my ($self, $c) = @_;

  $self->_c($c);
  weaken($self->_c);

  $self->menu_vars( $self->_get_all_vars );
}

no Moose;
1;
