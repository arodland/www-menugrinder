package WWW::MenuGrinder;

# ABSTRACT: A tool for managing dynamic website menus - base class.

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

has 'plugin_hash' => (
  is => 'rw',
  default => sub { + {} },
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

has 'config' => (
  is => 'rw',
  default => sub { + {} },
);

sub plugins_with {
  my ($self, $role) = @_;

  $role =~ s/^-/WWW::MenuGrinder::Role::/;

  return [ grep $_->does($role), @{ $self->plugins } ]
}

sub register_plugin {
  my ($self, $class, $plugin) = @_;

  push @{ $self->plugins }, $plugin;
  $self->plugin_hash->{$class} = $plugin;
}

sub load_plugin {
  my ($self, $class) = @_;

  my $shortname;

  if ($class =~ /^\+/) {
    $class =~ s/^\+//;
  } else {
    $shortname = $class;
    $class =~ s/^/WWW::MenuGrinder::Plugin::/;
  }

  return $self->plugin_hash->{$class} if $self->plugin_hash->{$class};

  eval "require $class; 1" or die $@;

  if ($class->can('plugin_depends')) {
    my @deps = $class->plugin_depends;
    for my $dep (@deps) {
      eval {
        $self->load_plugin($dep);
      };
      if ($@) {
        die "$@ while loading $dep, which was required by $class";
      };
    }
  }

  my %plugin_config;

  if (defined $shortname) {
    my $config = $self->config->{$shortname};
    %plugin_config = %$config if defined $config;
  } else {
    my $config = $self->config->{$class};
    %plugin_config = %$config if defined $config;
  }

  my $plugin = $class->new( %plugin_config, grinder => $self );

  $self->register_plugin($class, $plugin);
}

sub load_plugins {
  my ($self, @args) = @_;

  my $plugins = $self->config->{plugins};

  return unless $plugins;

  for my $class (@$plugins) {
    $self->load_plugin($class);
  }
}

sub init_menu {
  my ($self) = @_;

  my $menu = $self->loader->load;
  $menu = $self->pre_mogrify($menu);
  $self->menu($menu);
}

sub BUILD {
  my ($self) = @_;

  $self->load_plugins;
  $self->init_menu;
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

  $_->before_mogrify($self->menu) for @{ $self->plugins_with(-BeforeMogrify) };

  my $menu = $self->menu;

  my @mog = @{ $self->mogrifiers };

  $menu = $_->mogrify($menu) for @mog;

  return $self->output->output($menu);
}

no Moose;
1;


=head1 SYNOPSIS

  my $grinder = My::Subclass::Of::MenuGrinder->new(
    config => {
      plugins => [
        'XMLLoader',
        'Hotkeys',
        'NullOutput',
      ],
      filename => "/foo/menu.xml"
   },
  );

  # Some time later...
  
  my $menu = $grinder->get_menu

=head1 DESCRIPTION

C<WWW::MenuGrinder> is a framework for demonstrating how I can't write POD to
save my life.

=cut
