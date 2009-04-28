package WWW::MenuGrinder::Role::ItemMogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus item-by-item per request.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

=method C<< $plugin->item_mogrify_methods >>

Returns a list of the methods that your plugin provides as an C<ItemMogrifier>.
Each method on this list will be executed on each item of the menu tree, and
if a plugin provides more than one item mogrify method, each will be called on a
separate complete pass over the tree, enabling two-phase processing. If you do
not override C<item_mogrifiy_methods> your plugin is assumed to provide one
method, named C<item_mogrify>.

=method C<< $plugin->item_mogrify($item) >>

Is called on each item of the menu tree, in postorder. May modify C<$item>
in-place or modify it by copying; either way the new C<$item> should be
returned. If C<()> is returned instead, the item (and all of its children) are
removed from the menu.

=cut

sub item_mogrify_methods {
  return 'item_mogrify';
}

after 'verify_plugin' => sub {
  my ($self) = @_;
  my $class = ref $self;

  for my $method ($self->item_mogrify_methods) {
    if (! $self->can($method)) {
      die "$class declared item_mogrify_method $method but doesn't provide it.";
    }
  }
};

no Moose::Role;

1;
