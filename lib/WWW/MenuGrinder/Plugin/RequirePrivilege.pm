package WWW::MenuGrinder::Plugin::RequirePrivilege;

# ABSTRACT: WWW::MenuGrinder plugin that does privilege checks on items.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';

sub plugin_depends { qw(Visitor) }

sub item_mogrify {
  my ( $self, $item ) = @_;

  if (exists $item->{need_priv}) {
    my @privs = ref($item->{need_priv}) ? 
      @{ $item->{need_priv} } : $item->{need_priv};

    for my $priv (@privs) {
      if (! $self->grinder->has_priv($priv) ) {
        return ();
      }
    }
  }

  return $item;
}

no Moose;
1;
