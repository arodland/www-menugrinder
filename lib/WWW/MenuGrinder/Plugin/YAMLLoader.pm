package WWW::MenuGrinder::Plugin::YAMLLoader;

# ABSTRACT: WWW::MenuGrinder plugin that loads menus with YAML::XS.

use Moose;

use YAML::XS;

with 'WWW::MenuGrinder::Role::Loader';

has 'filename',
  is => 'ro',
  required => 1;

sub load {
  my ($self) = @_;

  open my $menufh, '<:encoding(UTF-8)', $self->filename or die $!;
  my $menu_yaml = do { local $/; <$menufh> };

  my $menu = Load $menu_yaml;

  return $menu;
}

no Moose;

1;
