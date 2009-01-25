package WWW::MenuGrinder::Plugin::Visitor;

# ABSTRACT: WWW::MenuGrinder plugin that allows item-by-item mogrification.

use Moose;

use Scalar::Util;

with 'WWW::MenuGrinder::Role::PreMogrifier';
with 'WWW::MenuGrinder::Role::Mogrifier';

has item_premogrifiers => (
  is      => 'rw',
  lazy    => 1,
  default => sub {
    my $self = shift;
    $self->grinder->plugins_with( -ItemPreMogrifier );
  },
);

has item_mogrifiers => (
  is      => 'rw',
  lazy    => 1,
  default => sub {
    my $self = shift;
    $self->grinder->plugins_with( -ItemMogrifier );
  },
);

# Nothing on CPAN gives me a nice simple interface as well as post-order
# traversal so here's one we prepared earlier.

# Traverse a tree-like data structure, making a copy of it and modifying it 
# along the way.
sub _visit {
  my ( $obj, $cb ) = @_;

  my $reftype = Scalar::Util::reftype($obj);

  if ( defined $reftype ) {
    # Don't bother with any fancy inheritance checks, just mostly leave objects
    # alone.
    if (Scalar::Util::blessed($obj)) {
      return $cb->{OBJECT}->($obj) if defined $cb->{OBJECT};
      return $obj;
    }
    if ( $reftype eq 'HASH' ) {
      my $tmp = {};
      for my $key ( keys %{$obj} ) {
        my @ret = _visit( $_[0]{$key}, $cb );
        $tmp->{$key} = $ret[0] if @ret;
      }

      return $cb->{HASH}->($tmp) if exists $cb->{HASH};
      return $tmp;
    } elsif ( $reftype eq 'ARRAY' ) {
      my $tmp = [];
      for my $val ( @{$obj} ) {
        push @$tmp, _visit( $val, $cb );
      }

      return $cb->{ARRAY}->($tmp) if exists $cb->{ARRAY};
      return $tmp;
    } elsif ( $reftype eq 'SCALAR' ) {
      my $tmp = \( _visit( $$obj, $cb ) );

      return $cb->{SCALARREF}->($tmp) if exists $cb->{SCALARREF};
      return $tmp;
    } elsif ( $reftype eq 'GLOB' ) {
      my $tmp = $obj;
      return $cb->{GLOB}->($tmp) if exists $cb->{GLOB};
      return $tmp;
    } else {
      warn "Ignoring a $reftype-reference I don't know how to handle.";
      return $obj;
    }
  } else {    # Not a reference
    return $cb->{SCALAR}->($obj) if defined $cb->{SCALAR};
    return $obj;
  }
}

sub pre_mogrify {
  my ( $self, $menu ) = @_;

  my @ipm = map +{
    plugin => $_,
    methods => [ $_->item_pre_mogrify_methods ]
  }, @{ $self->item_premogrifiers };


  for my $ipm (@ipm) {
    print ref($ipm->{plugin}), ": [ @{ $ipm->{methods} } ]\n";
  }

  # If there aren't any ItemPreMogrifiers then don't bother doing anything.
  return $menu unless @ipm;

  # Process each plugin's pass-1 method, then the pass-2 methods of eah plugin
  # that has one, then pass-3 as necessary etc. until no more.
  while (@ipm) {
    $menu = _visit($menu, {
        HASH => sub {
          my ( $item ) = @_;
          for my $ipm (@ipm) {
            my $plugin = $ipm->{plugin};
            my $method = $ipm->{methods}[0];
            $item = $plugin->$method($item);
            return () unless defined $item;
          }
          return $item;
        }
      }
    );

    shift @{ $_->{methods} } for @ipm;
    @ipm = grep @{ $_->{methods} }, @ipm;
  }

  return $menu;
}

sub mogrify {
  my ( $self, $menu ) = @_;

  my @im = map +{
    plugin => $_,
    methods => [ $_->item_mogrify_methods ]
  }, @{ $self->item_mogrifiers };

  # If there aren't any ItemMogrifiers then don't bother doing anything.
  return $menu unless @im;

  # Process each plugin's pass-1 method, then the pass-2 methods of eah plugin
  # that has one, then pass-3 as necessary etc. until no more.
  while (@im) {
    $menu = _visit($menu, {
        HASH => sub {
          my ( $item ) = @_;
          for my $im (@im) {
            my $plugin = $im->{plugin};
            my $method = $im->{methods}[0];
            $item = $plugin->$method($item);
            return () unless defined $item;
          }
          return $item;
        }
      }
    );

    shift @{ $_->{methods} } for @im;
    @im = grep @{ $_->{methods} }, @im;
  }

  return $menu;
}

no Moose;
1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::Visitor> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

In fact, you probably won't include it in a configuration either; the Visitor
plugin is usually loaded as a prerequisite of some other plugin. All
C<WWW::MenuGrinder> plugins implementing the C<ItemMogrifier> or
C<ItemPreMogrifier> interfaces make use of Visitor.

=cut
