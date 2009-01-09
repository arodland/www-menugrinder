package WWW::MenuGrinder::Role::ItemPreMogrifier;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'item_pre_mogrify';

no Moose::Role;

1;
