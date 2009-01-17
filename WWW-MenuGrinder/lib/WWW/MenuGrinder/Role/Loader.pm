package WWW::MenuGrinder::Role::Loader;

# ABSTRACT: WWW::MenuGrinder role for plugins that load menu data.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'load';

no Moose::Role;

1;
