package WWW::MenuGrinder::Role::Mogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus per request.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'mogrify';

no Moose::Role;

1;
