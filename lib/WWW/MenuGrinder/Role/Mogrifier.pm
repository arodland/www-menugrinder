package WWW::MenuGrinder::Role::Mogrifier;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'mogrify';

no Moose::Role;

1;
