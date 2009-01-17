package WWW::MenuGrinder::Plugin::DefaultTarget;

# ABSTRACT: WWW::MenuGrinder plugin that sets a default link target.

use Moose;

with 'WWW::MenuGrinder::Role::ItemPreMogrifier';

sub plugin_depends { qw(Visitor) }

sub item_pre_mogrify {
  my ($self, $item) = @_;

  if (exists $item->{location} && !exists $item->{target}) {
    if (ref $item->{location} eq "ARRAY") {
      $item->{target} = "/" . $item->{location}[0];
    } elsif (ref $item->{location} eq "HASH") {
      $item->{target} = "/"; # XML::Simple is stupid.
    } else {
      $item->{target} = "/" . $item->{location};
    }
  }

  return $item;
}

no Moose;
1;
