package WWW::MenuGrinder::Role::Loader;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'load';

no Moose::Role;

1;
