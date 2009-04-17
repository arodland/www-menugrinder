package WWW::MenuGrinder::Plugin::ActivePath;

# ABSTRACT: WWW::MenuGrinder plugin that finds a path to the currently active page.

use Moose;
use List::Util;

with 'WWW::MenuGrinder::Role::ItemMogrifier';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

has path => ( is => 'rw' );

sub plugin_required_grinder_methods { qw(path) }

sub before_mogrify {
  my ($self) = @_;

  $self->path( $self->grinder->path );
}

has 'longest' => (
  is => 'rw',
  default => 0
);

sub item_mogrify_methods {
  qw(find_longest_match mark_active_path)
};

sub find_longest_match {
  my ( $self, $item ) = @_;

  if (exists $item->{location}) {
    my @loc = ref($item->{location}) eq 'ARRAY' ? 
      @{ $item->{location} } : $item->{location};

    for my $location ( @loc ) {

      my $active;
      # XML::Simple is stupid
      if ( $location eq '' or ref($location) eq 'HASH' ) { 
        $active = 0.01; # more than 0, less than 1
      } elsif ( $self->{path} =~ m#^\Q$location\E(/|$)# ) {
        $active = length($location);
      }

      if (defined $active && $active > $self->longest) {
        $self->longest( $active );
        # This one might be the longest, so we might use it later.
        # If not, we'll delete it.
        $item->{active} = $active;
      }
    }
  }

  return $item;
}

sub mark_active_path {
  my ( $self, $item ) = @_;

  # If we were the longest match, set active="yes".
  # If one of our children is active (of either type) set active="child".

  my $max = $self->longest;

  if (defined $item->{active} and $item->{active} == $max) {
    $item->{active} = "yes";
  } else {
    delete $item->{active};
    if (ref ($item->{item})) {
      for my $child ( @{ $item->{item} } ) {
        if (defined $child->{active}) {
          $item->{active} = "child";
          last;
        }
      }
    }
  }

  return $item;
}

sub cleanup {
  my ($self) = @_;
  $self->longest(0);
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

=head2 Other Considerations

It's advisable to load this plugin after any plugins that may remove items from
the menu, to ensure that the chain of active items is unbroken.

=cut
