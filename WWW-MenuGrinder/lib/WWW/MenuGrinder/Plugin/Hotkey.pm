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
