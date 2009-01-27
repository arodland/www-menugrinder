package WWW::MenuGrinder::Plugin::RequirePrivilege;

# ABSTRACT: WWW::MenuGrinder plugin that does privilege checks on items.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';

sub plugin_depends { qw(Visitor) }

sub plugin_required_grinder_methods { qw(has_priv) }


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

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::RequirePrivilege> is a plugin for
C<WWW::MenuGrinder>. You should not use it directly, but include it in the
C<plugins> section of a C<WWW::MenuGrinder> config.

When loaded, this plugin will remove any menu item containing a C<need_priv> key
identifying a privilege that's not available to the current request's user, and
all of that item's children.

=head2 Configuration

None.

=head2 Required Methods

In order to load this plugin your C<WWW::MenuGrinder> subclass must implement
the method C<has_priv>, which receives a privilege name as a string and returns
true or false indicating whether the privilege check was successful.

=head2 Dependencies

C<WWW::MenuGrinder::Plugin::Visitor>.

=cut
