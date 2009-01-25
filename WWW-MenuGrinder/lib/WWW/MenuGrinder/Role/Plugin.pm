package WWW::MenuGrinder::Role::Plugin;

# ABSTRACT: WWW::MenuGrinder role for all plugins.

use Moose::Role;

has 'grinder' => (
  is => 'ro',
  isa => 'WWW::MenuGrinder',
  required => 1,
);

sub verify_plugin {
  my ($self) = @_;

  if ($self->can('plugin_required_grinder_methods')) {
    my @methods = $self->plugin_required_grinder_methods;
    for my $m (@methods) {
      if (! $self->grinder->can($m)) {
        die ref($self) . " requires method '$m' but " . ref($self->grinder)
          . "doesn't provide it.\n";
      }
    }
  }
}

no Moose::Role;

1;
