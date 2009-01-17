package Catalyst::Model::WWW::MenuGrinder;

# ABSTRACT: Catalyst Model base class for WWW::MenuGrinder

use Moose;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
  my ($self, $c) = @_;

  my $menu_class = $self->config->{menu_class} || "Catalyst::Model::WWW::MenuGrinder";
  eval "require $menu_class; 1;" or die "$@ loading menu_class";

  my $menu_config = $self->config->{menu_config} || {};

  my $menu = $menu_class->new(
    config => $menu_config,
    _c => $c,
  );

  $menu->init;

  return $menu;
}

no Moose;
1;

=head1 SYNOPSIS

  package MyApp::Model::Menu;

  use Moose;

  extends 'WWW::MenuGrinder::Catalyst::ModelBase';

  __PACKAGE__->config(
    menu_config => {
      plugins => [
        'XMLLoader',
        'DefaultTarget',
        'NullOutput',
      ],
      filename => MyApp->path_to('root', 'menu.xml'),
    },
  );

  no Moose;

=cut
