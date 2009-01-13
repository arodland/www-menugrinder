package WWW::MenuGrinder::Role::Plugin;

# ABSTRACT: WWW::MenuGrinder role for all plugins.

use Moose::Role;

has 'grinder' => (
  is => 'ro',
  isa => 'WWW::MenuGrinder',
  required => 1,
);

no Moose::Role;

1;
