package WWW::MenuGrinder::Plugin::Localize;

# ABSTRACT: WWW::MenuGrinder plugin for multilingual support

use Moose;

with 'WWW::MenuGrinder::Role::ItemMogrifier';
with 'WWW::MenuGrinder::Role::BeforeMogrify';

sub plugin_required_grinder_methods { qw(get_language) }

has 'localize_fields' => (
  is => 'ro',
  default => sub { [ 'label' ] }
);

has 'separator' => (
  is => 'ro',
  default => '-',
);

has 'language' => (
  is => 'rw',
);

sub before_mogrify {
  my ($self) = @_;

  $self->language( $self->grinder->get_language );
}


sub item_mogrify {
  my ($self, $item) = @_;

  my $lang = $self->language;
  my $separator = $self->separator;

  for my $field (@{ $self->localize_fields }) {
    
    if (exists $item->{ "$field$separator$lang" }) {
      $item->{$field} = $item->{ "$field$separator$lang" };
    }
  }

  return $item;
}

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::Localize> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

When loaded, this plugin will interrogate the application for the current
display language and attempt to use localized versions of various fields if they
are available. For example, if the application reports a language of 'es', and a
menu item has a field 'label-es', its value will be placed into the field
'label'. If a localized value isn't provided for a given field, no change is
made, allowing for defaults.

=head2 Configuration

=over 4

=item * C<localize_fields>

An arrayref containing the names of menu keys to localize. Defaults to
C<['label']>.

=item * C<separator>

A string indicating the separator between field name and language; for instance
the localized version of C<"label"> is C<"label-es"> if the separator is C<"-">.
Defaults to C<"-"> but users of non-XML file formats might prefer C<":"> or
C<";">.

=head2 Required Methods

In order to load this plugin your C<WWW::MenuGrinder> subclass must implement
the method C<get_language> returning a string indicating the display language
for this request.

=cut
