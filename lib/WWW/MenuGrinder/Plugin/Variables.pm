package WWW::MenuGrinder::Plugin::Variables;

# ABSTRACT: WWW::MenuGrinder plugin that does variable substitutions and checks.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

has 'substitute_fields' => (
  is => 'ro',
  default => sub { [ 'label' ] }
);

has 'vars' => (
  is => 'rw',
  isa => 'HashRef'
);

has 'have_all_vars' => (
  is => 'rw',
);

sub before_mogrify {
  my ($self) = @_;

  if ($self->grinder->can('get_all_variables')) {
    $self->vars( $self->grinder->get_all_variables );
    $self->have_all_vars(1);
  } else {
    $self->vars( {} );
    $self->have_all_vars(0);
  }
}

sub get_var {
  my ($self, $varname) = @_;

  my $vars = $self->vars;

  if (exists $vars->{$varname}) {
    return $vars->{$varname};
  } elsif ($self->have_all_vars) {
    # We got everything there is to start with. If it's not there,
    # it's not there.
    return undef; 
  } else {
    return $vars->{$varname} = $self->grinder->get_variable($varname);
  } 
}

sub get_defined_var {
  my ($self, $varname) = @_;

  my $value = $self->get_var($varname);
  warn "Menu variable '$varname' was undefined in substitution." unless defined $value;
  return $value;
}

sub item_mogrify {
  my ($self, $item) = @_;

  if (ref $item->{need_var}) {
    for my $var (@{ $item->{need_var} }) {
      if (!defined $self->get_var($var) ) {
        return ();
      }
    }
  }

  if (ref $item->{no_var}) {
    for my $var (@{ $item->{no_var} }) {
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
