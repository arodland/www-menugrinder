package WWW::MenuGrinder::Role::ItemMogrifier;

# ABSTRACT: WWW::MenuGrinder role for plugins that modify menus item-by-item per request.

use Moose::Role;

with 'WWW::MenuGrinder::Role::Plugin';

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
