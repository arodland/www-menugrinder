package WWW::MenuGrinder::Plugin::RequirePrivilege;

# ABSTRACT: WWW::MenuGrinder plugin that does privilege checks on items.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';

sub item_mogrify {
  my ( $self, $item ) = @_;

  if (ref $item->{need_priv}) {
    for my $priv (@{ $item->{need_priv} }) {
      if (! $self->grinder->has_priv($priv) ) {
        return ();
      }
    }
  }

  return $item;
}

no Moose;
1;
