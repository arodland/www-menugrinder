package WWW::MenuGrinder::Plugin::XMLLoader;

# ABSTRACT: WWW::MenuGrinder plugin that loads menus with XML::Simple.

use XML::Simple;

use Moose;

with 'WWW::MenuGrinder::Role::Loader';

has 'filename',
  is => 'ro',
  required => 1;

sub load {
  my ($self) = @_;

  # XML::Simple screws up UTF-8 somehow...
  open my $menufh, '<:encoding(UTF-8)', $self->filename or die $!;
  my $menu_xml = do { local $/; <$menufh> };

  my $menu = XMLin($menu_xml, ForceArray => [ qw(item location need_var need_priv no_var no_priv) ]);

  return $menu;
}

no Moose;

1;
