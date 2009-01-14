package WWW::MenuGrinder::Plugin::Variables;

# ABSTRACT: WWW::MenuGrinder plugin that does variable substitutions and checks.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';

has 'substitute_fields' => (
  is => 'ro',
  default => sub { [ 'label' ] }
);

sub get_var {
  my ($self, $varname) = @_;

  return $self->grinder->get_variable($varname);
}

sub get_defined_var {
  my ($self, $varname) = @_;

  my $value = $self->grinder->get_variable($varname);
  warn "Menu variable '$varname' was undefined in substitution." unless defined $value;
  return $value;
}

sub item_mogrify {
  my ($self, $item) = @_;

  if (exists $item->{need_var}) {
    my @vars = ref($item->{need_var}) ? 
      @{ $item->{need_var} } : $item->{need_var};
    for my $var (@vars) {
      if (!defined $self->get_var($var) ) {
        return ();
      }
    }
  }

  if (exists $item->{no_var}) {
    my @vars = ref($item->{no_var}) ? 
      @{ $item->{no_var} } : $item->{no_var};
    for my $var (@vars) {
      if (defined $self->get_var($var) ) {
        return ();
      }
    }
  }

  for my $field (@{ $self->substitute_fields }) {
    next unless exists $item->{$field};

    $item->{$field} =~ s/\${([^}]+)}/$self->get_defined_var($1)/eg;
  }

  return $item;
}

no Moose;
1;
