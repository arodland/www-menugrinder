package WWW::MenuGrinder::Role::ItemMogrifier;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'item_mogrify';

no Moose::Role;

1;
