package WWW::MenuGrinder::Role::BeforeMogrify;

# ABSTRACT: WWW::MenuGrinder role for plugins that need to initialization before mogrifying.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

requires 'before_mogrify';

=method C<< $plugin->before_mogrify($menu) >>

The C<before_mogrify> method is called immediately before per-request mogrifier
plugins are loaded. It is primarily intended to allow plugins to do
initialization, for example computing any information that depends on the
request context but only needs to be computed once per request.

=cut

no Moose::Role;

1;
