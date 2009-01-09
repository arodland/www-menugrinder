package WWW::MenuGrinder::Plugin::NullOutput;

use Moose;

with 'WWW::MenuGrinder::Role::Output';

sub output {
  my ($self, $menu) = @_;

  return $menu;
}

no Moose;
1;
