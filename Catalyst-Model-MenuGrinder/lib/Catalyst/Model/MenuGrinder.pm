package Catalyst::Model::MenuGrinder;

# ABSTRACT: Catalyst Model base class for WWW::MenuGrinder

use base 'Catalyst::Model';

__PACKAGE__->mk_accessors('_menu');

sub new {
  my $class = shift;
  my $self = $class->NEXT::new(@_);

  my $config = $self->config;

  my $menu_class = $config->{menu_class} || "Catalyst::Model::MenuGrinder::Menu";
  eval "require $menu_class; 1;" or die "$@ loading menu_class";

  my $menu_config = $config->{menu_config} || {};

  my $menu = $menu_class->new(
    config => $menu_config,
  );

  $self->_menu($menu);

  return $self;
}

sub ACCEPT_CONTEXT {
  my ($self, $c) = @_;

  $self->_menu->_accept_context($c);

  return $self->_menu;
}

1;

=head1 SYNOPSIS

  package MyApp::Model::Menu;

  use base 'Catalyst::Model::MenuGrinder';

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

=cut
