package WWW::MenuGrinder::Plugin::NullOutput;

# ABSTRACT: WWW::MenuGrinder plugin that outputs the menu structure unchanged.

use Moose;

with 'WWW::MenuGrinder::Role::Output';

sub output {
  my ($self, $menu) = @_;

  return $menu;
}

no Moose;
1;
