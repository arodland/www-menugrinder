package WWW::MenuGrinder::Role::PreMogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus at load time.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'pre_mogrify';

no Moose::Role;

1;
