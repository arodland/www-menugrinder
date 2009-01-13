package WWW::MenuGrinder::Role::BeforeMogrify;

# ABSTRACT: WWW::MenuGrinder role for plugins that need to initialization before mogrifying.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'before_mogrify';

no Moose::Role;

1;
