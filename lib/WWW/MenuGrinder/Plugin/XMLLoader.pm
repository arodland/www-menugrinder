package WWW::MenuGrinder::Plugin::XMLLoader;

# ABSTRACT: WWW::MenuGrinder plugin that loads menus with XML::Simple.

use Moose;

use XML::Simple;

with 'WWW::MenuGrinder::Role::Loader';

has 'filename',
  is => 'ro',
  required => 1;

sub load {
  my ($self) = @_;

  # XML::Simple screws up UTF-8 somehow...
  open my $menufh, '<:encoding(UTF-8)', $self->filename or die $!;
  my $menu_xml = do { local $/; <$menufh> };

  my $menu = XMLin($menu_xml, ForceArray => [ qw(item) ]);

  return $menu;
}

no Moose;

1;
