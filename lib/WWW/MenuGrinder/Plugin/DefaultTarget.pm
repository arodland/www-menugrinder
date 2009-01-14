package WWW::MenuGrinder::Plugin::DefaultTarget;

# ABSTRACT: WWW::MenuGrinder plugin that sets a default link target.

use Moose;

with 'WWW::MenuGrinder::Role::ItemPreMogrifier';

sub item_pre_mogrify {
  my ($self, $item) = @_;

  if (exists $item->{location} && !exists $item->{target}) {
    my $loc = ref($item->{location}) ? $item->{location}[0] : $item->{location};
    $item->{target} = "/" . $loc;
  }

  return $item;
}

no Moose;
1;
