package WWW::MenuGrinder::Role::PreMogrifier;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'pre_mogrify';

no Moose::Role;

1;
