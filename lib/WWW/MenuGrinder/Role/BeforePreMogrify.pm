package WWW::MenuGrinder::Role::BeforePreMogrify;

# ABSTRACT: WWW::MenuGrinder role for plugins that need initialization before pre-mogrify.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'before_pre_mogrify';

no Moose::Role;

1;
