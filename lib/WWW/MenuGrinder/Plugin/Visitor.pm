package WWW::MenuGrinder::Plugin::Visitor;

use Moose;

use Data::Visitor::Callback;

with 'WWW::MenuGrinder::Role::PreMogrifier';
with 'WWW::MenuGrinder::Role::Mogrifier';

has item_premogrifiers => (
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    $self->grinder->plugins_with(-ItemPreMogrifier);
  },
);

has item_mogrifiers => (
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    $self->grinder->plugins_with(-ItemMogrifier);
  },
);

sub pre_mogrify {
  my ($self, $menu) = @_;

  my @ipm = @{ $self->item_premogrifiers };

  # If there aren't any ItemPreMogrifiers then don't bother doing anything.
  return $menu unless @ipm;

  my $v = Data::Visitor::Callback->new(
    hash => sub {
      my ($visitor, $item) = @_;
      $item = $_->item_pre_mogrify($item) for @ipm;
      return $item;
    }
  );

  $menu = $v->visit($menu);

  return $menu;
}

sub mogrify {
  my ($self, $menu) = @_;

  my @im = @{ $self->item_mogrifiers };

  # If there aren't any ItemMogrifiers then don't bother doing anything.
  return $menu unless @im;

  my $v = Data::Visitor::Callback->new(
    hash => sub {
      my ($visitor, $item) = @_;
      $item = $_->item_mogrify($item) for @im;
      return $item;
    }
  );

  $menu = $v->visit($menu);

  return $menu;
}

no Moose;
1;
