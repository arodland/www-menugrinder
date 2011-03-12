package WWW::MenuGrinder::Plugin::YAMLLoader;

# ABSTRACT: WWW::MenuGrinder plugin that loads menus with YAML::XS.

use Moose;

use YAML::XS;

with 'WWW::MenuGrinder::Role::Loader';

has 'filename' => (
  is => 'rw',
);

sub load {
  my ($self) = @_;

  open my $menufh, '<:encoding(UTF-8)', $self->filename or die $!;
  my $menu_yaml = do { local $/; <$menufh> };

  my $menu = Load $menu_yaml;

  return $menu;
}

sub BUILD {
  my ($self) = @_;

  my $filename = $self->grinder->config->{filename};
  die "config->{filename} is required" unless defined $filename;

  $self->filename($filename);
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::YAMLLoader> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

This is an input plugin that uses L<YAML::Simple> to load a menu structure.

TODO example file.

=head2 Configuration

The key C<filename> in the global configuration holds the name of the file to be
read.

=cut
