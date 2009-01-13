package WWW::MenuGrinder::Role::ItemMogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus item-by-item per request.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'item_mogrify';

no Moose::Role;

1;
