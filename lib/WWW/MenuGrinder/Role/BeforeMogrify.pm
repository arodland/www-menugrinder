package WWW::MenuGrinder::Role::BeforeMogrify;

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'before_mogrify';

no Moose::Role;

1;
