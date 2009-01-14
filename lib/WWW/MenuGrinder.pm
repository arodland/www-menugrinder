package WWW::MenuGrinder;

# ABSTRACT: Menu Munger.

use strict;
use warnings;

use Moose;

use WWW::MenuGrinder::Role::Plugin;

has 'menu' => (
  is => 'rw',
);

has 'plugins' => (
  is => 'rw',
  isa => 'ArrayRef[WWW::MenuGrinder::Role::Plugin]',
  default => sub { [] },
);

has 'loader' => (
  is => 'rw',
#  isa => 'WWW::MenuGrinder::Role::Loader',
  lazy => 1,
  default => sub {
    my $self = shift;
    my @loaders = @{ $self->plugins_with(-Loader) };
    die "Need exactly one Loader plugin" unless @loaders == 1;
    $loaders[0];
  },
);

has 'output' => (
  is => 'rw',
#  isa => 'WWW::MenuGrinder::Role::Output',
  lazy => 1,
  default => sub {
    my $self = shift;
    my @outputs = @{ $self->plugins_with(-Output) };
    die "Need exactly one Output plugin" unless @outputs == 1;
    $outputs[0];
  },
);

has 'premogrifiers' => (
  is => 'rw',
#  isa => 'ArrayRef[WWW::MenuGrinder::Role::PreMogrifier]',
  lazy => 1,
  default => sub {
    my $self = shift;
    $self->plugins_with(-PreMogrifier);
  },
);

has 'mogrifiers' => (
  is => 'rw',
#  isa => 'ArrayRef[WWW::MenuGrinder::Role::Mogrifier]',
  lazy => 1,
  default => sub {
    my $self = shift;
    $self->plugins_with(-Mogrifier);
  },
);

sub plugins_with {
  my ($self, $role) = @_;

  $role =~ s/^-/WWW::MenuGrinder::Role::/;

  return [ grep $_->does($role), @{ $self->plugins } ]
}

sub load_plugins {
  my ($self, @args) = @_;

  my @plugins;

  while (@args) {
    my $class = shift @args;

    if ($class =~ /^\+/) {
      $class =~ s/^\+//;
    } else {
      $class =~ s/^/WWW::MenuGrinder::Plugin::/;
    }

    my %plugin_args;

    if (@args && ref($args[0])) {
      %plugin_args = %{ shift @args };
    }

    eval "require $class; 1" or die $@;

    my $plugin = $class->new( %plugin_args, grinder => $self );
    push @plugins, $plugin;
  }

  $self->plugins( [ @plugins ] );
}

sub init {
  my ($self) = @_;

  my $menu = $self->loader->load;
  $menu = $self->pre_mogrify($menu);
  $self->menu($menu);
}

sub pre_mogrify {
  my ($self, $menu) = @_;

  $_->before_pre_mogrify($menu) for @{ $self->plugins_with(-BeforePreMogrify) };

  my @pre_mog = @{ $self->premogrifiers };

  $menu = $_->pre_mogrify($menu) for @pre_mog;

  return $menu;

}

sub get_menu {
  my ($self) = @_;

  my $menu = $self->menu;

  $_->before_mogrify($menu) for @{ $self->plugins_with(-BeforeMogrify) };

  my @mog = @{ $self->mogrifiers };

  $menu = $_->mogrify($menu) for @mog;

  return $self->output->output($menu);
}

no Moose;
1;
