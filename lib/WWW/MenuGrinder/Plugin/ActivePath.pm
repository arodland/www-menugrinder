package WWW::MenuGrinder::Plugin::ActivePath;

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

has path => ( is => 'rw' );

sub before_mogrify {
  my ($self) = @_;

  $self->path( $self->grinder->path );
}

sub item_mogrify {
  my ( $self, $item ) = @_;

  if ( ref $item->{location} ) {
    for my $location ( @{ $item->{location} } ) {
      # XML::Simple is stupid
      if ( $location eq '' or ref($location) eq 'HASH' ) { 
        $item->{active} = 0.01; # more than 0, less than 1
        next;
      } elsif ( $self->{path} =~ m#^\Q$location\E(/|$)# ) {
        $item->{active} = length($location);
      }
    }
  }
  if ( ref $item->{item} ) {
    my $max = List::Util::max( map { $_->{active} || 0 } @{ $item->{item} } );
    if ($max) {
      for my $i ( @{ $item->{item} } ) {
        if ( defined $i->{active} && $i->{active} == $max ) {
          $i->{active} = 1;
        } else {
          delete $i->{active};
        }
      }
      $item->{active} = $max;
    }
  }
  return $item;
}

no Moose;
1;
