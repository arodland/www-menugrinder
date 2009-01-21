package WWW::MenuGrinder::Plugin::ActivePath;

# ABSTRACT: WWW::MenuGrinder plugin that finds a path to the currently active page.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

has path => ( is => 'rw' );

sub plugin_depends { qw(Visitor) }

sub before_mogrify {
  my ($self) = @_;

  $self->path( $self->grinder->path );
}

sub item_mogrify {
  my ( $self, $item ) = @_;

  if ( exists $item->{location} ) {

    my @loc = ref($item->{location}) eq 'ARRAY' ? 
      @{ $item->{location} } : $item->{location};

    for my $location ( @loc ) {
      # XML::Simple is stupid
      if ( $location eq '' or ref($location) eq 'HASH' ) { 
        $item->{active} = 0.01; # more than 0, less than 1
        next;
      } elsif ( $self->{path} =~ m#^\Q$location\E(/|$)# ) {
        $item->{active} = length($location);
      }
    }
  }

  # Walk our children (which have just been processed) and see if any of them
  # have active scores (that are better than ours). Mark the best item as
  # active=yes or active=child depending, and remove the attribute from the
  # rest.

  if ( ref $item->{item} ) {
    my $max = List::Util::max( map { $_->{active} || 0 } @{ $item->{item} } );
    my $myactive = $item->{active} || 0;

    if ($myactive > $max) {
      for my $i ( @{ $item->{item} } ) {
        delete $i->{active};
        delete $i->{active_child};
      }
    } elsif ($max) {
      for my $i ( @{ $item->{item} } ) {
        if ( defined $i->{active} && $i->{active} == $max ) {
          $i->{active} = $i->{active_child} ? 'child' : 'yes';
          delete $i->{active_child};
        } else {
          delete $i->{active};
          delete $i->{active_child};
        }
      }
      $item->{active} = $max;
      $item->{active_child} = 1;
    }
  }
  return $item;
}

no Moose;
1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::ActivePath> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

When loaded, this plugin will visit each item of the menu, comparing any item
with a C<location> attribute to the current URL path. The item that best matches
the current path will have its C<active> key set to "yes", and each of its
ancestors will have its C<active> key set to "child".

=head2 Configuration

None.

=head2 Required Methods

In order to load this plugin your C<WWW::MenuGrinder> subclass must implement
the method C<path> returning a path name for the current request.

=head2 Dependencies

C<WWW::MenuGrinder::Plugin::Visitor>.

=head2 Other Considerations

It's advisable to load this plugin after any plugins that may remove items from
the menu, to ensure that the chain of active items is unbroken.

=cut
