package WWW::MenuGrinder::Plugin::Hotkey;

# ABSTRACT: WWW::MenuGrinder plugin that generates hotkeys from labels.

use Moose;

with 'WWW::MenuGrinder::Role::ItemPreMogrifier';

sub plugin_depends { qw(Visitor) }

sub item_pre_mogrify {
  my ($self, $item) = @_;

  return $item unless exists $item->{label};

  if ($item->{label} =~ s#_(.)#<u>$1</u>#) {
    $item->{hotkey} = uc $1 unless defined $item->{hotkey};
  }

  return $item;
}

no Moose;
1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::HotKey> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

When loaded, this plugin will scan the menu for C<label> keys containing
underscores. If an underscore is found, it will be removed, and the following
character wrapped in C<< <u> >> tags (for example, C<"Hot_key"> becomes 
C<< "Hot<u>k</u>ey" >>, and the item's C<hotkey> key is set to the underlined
character.

=head1 CONFIGURATION

None.

=head1 DEPENDENCIES

C<WWW::MenuGrinder::Plugin::Visitor>.

=head1 BUGS

This should probably be way more generic, instead of only useful for me.
Suggestions welcome.

=cut
