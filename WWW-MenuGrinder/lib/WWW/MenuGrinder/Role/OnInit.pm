package WWW::MenuGrinder::Role::OnInit;

# ABSTRACT: WWW::MenuGrinder role for plugins that need initialization before pre-mogrify.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'on_init';

no Moose::Role;

1;
