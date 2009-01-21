package WWW::MenuGrinder::Plugin::NullOutput;

# ABSTRACT: WWW::MenuGrinder plugin that outputs the menu structure unchanged.

use Moose;

with 'WWW::MenuGrinder::Role::Output';

sub output {
  my ($self, $menu) = @_;

  return $menu;
}

no Moose;
1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::NullOutput> is a plugin for C<WWW::MenuGrinder>. You
should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

This is an output plugin that returns the menu structure as used by
C<WWW::MenuGrinder> plugins -- a tree of hashes representing menu items. This
format is suitable for passing to templating systems such as Template Toolkit or
Petal, as well as further processing in Perl.

=cut
