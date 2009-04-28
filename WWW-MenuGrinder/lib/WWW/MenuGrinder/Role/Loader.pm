package WWW::MenuGrinder::Role::Loader;

# ABSTRACT: WWW::MenuGrinder role for plugins that load menu data.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

=method C<< $plugin->load >>

Is expected to return a menu structure ready for pre-mogrification. Data may
come from disk, the network, attributes, or whatever. Takes no arguments, but
C<< $self->grinder->config >> is available.

=cut

requires 'load';

no Moose::Role;

1;
