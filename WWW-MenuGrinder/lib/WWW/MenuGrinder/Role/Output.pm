package WWW::MenuGrinder::Role::Output;

# ABSTRACT: WWW::MenuGrinder role for plugins that output menus in some format.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'output';

no Moose::Role;

1;
