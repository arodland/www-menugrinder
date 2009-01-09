package WWW::MenuGrinder::Role::Plugin;

use Moose::Role;

has 'grinder' => (
  is => 'ro',
  isa => 'WWW::MenuGrinder',
  required => 1,
);

no Moose::Role;

1;
