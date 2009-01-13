package WWW::MenuGrinder::Role::ItemPreMogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus item-by-item at load time.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'item_pre_mogrify';

no Moose::Role;

1;
