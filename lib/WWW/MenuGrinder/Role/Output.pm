package WWW::MenuGrinder::Role::Output;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'output';

no Moose::Role;

1;
