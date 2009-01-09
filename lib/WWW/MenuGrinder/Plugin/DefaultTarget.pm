package WWW::MenuGrinder::Plugin::DefaultTarget;

use Moose;

with 'WWW::MenuGrinder::Role::ItemPreMogrifier';

sub item_pre_mogrify {
  my ($self, $item) = @_;

  warn "DT!\n";

  if (exists $item->{location} && !exists $item->{target}) {
    $item->{target} = "/" . $item->{location}[0];
  }

  return $item;
}

no Moose;
1;
