package WWW::MenuGrinder::Role::Mogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus per request.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'mogrify';

=method C<< $plugin->mogrify($menu) >>

Is called with the menu structure. May read or write the menu structure in any
way, and copy it or not. Either way the new C<$menu> is returned. Returning
C<undef> or C<()> is not advised; if things are really wrong, an exception
should be thrown.

=cut

no Moose::Role;

1;
