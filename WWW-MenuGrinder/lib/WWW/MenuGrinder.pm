package WWW::MenuGrinder;

# ABSTRACT: A tool for managing dynamic website menus - base class.

use strict;
use warnings;

use Moose;

use WWW::MenuGrinder::Role::Plugin;
use WWW::MenuGrinder::Visitor;

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
);

has 'on_load_plugins' => (
  is => 'rw',
  default => sub { [] },
);

has 'per_request_plugins' => (
  is => 'rw',
  default => sub { [] },
);

has 'outputs' => (
  is => 'rw',
  default => sub { [] },
);

has 'outputs_by_name' => (
  is => 'rw',
  default => sub { + {} },
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

sub rolename {
  my ($name) = @_;

  return __PACKAGE__ . "::Role::$name";
}

sub plugins_with {
  my ($self, $role) = @_;

  my $prefix = rolename('');
  $role =~ s/^-/$prefix/;
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

  $plugin->verify_plugin;

  $self->register_plugin($class, $plugin);
  return $plugin;
}

# Load and verify all of the plugins in the config.
sub load_plugins {
  my ($self, @args) = @_;

  my $plugins = $self->config->{plugins};

  my $loader = $plugins->{loader};
  die "config->{plugins}{loader} is mandatory" unless defined $loader;
  my $loaderclass = $self->load_plugin($loader);
  die "Specified plugin $loader is not a Loader" unless $loaderclass->does(rolename('Loader'));
  $self->loader($loaderclass);

  my $on_load = $plugins->{on_load} || [];
  for my $name (@$on_load) {
    my $plugin = $self->load_plugin($name);
    die "On-load plugin $name is not a Mogrifier or ItemMogrifier" 
      unless $plugin->does(rolename('Mogrifier')) or $plugin->does(rolename('ItemMogrifier'));
    push @{ $self->on_load_plugins }, $plugin;
  }

  my $per_request = $plugins->{per_request} || [];
  for my $name (@$per_request) {
    my $plugin = $self->load_plugin($name);
    die "Per-request plugin $name is not a Mogrifier, ItemMogrifier, or BeforeMogrify" 
      unless $plugin->does(rolename('Mogrifier')) or $plugin->does(rolename('ItemMogrifier')) or $plugin->does(rolename('BeforeMogrify'));
    push @{ $self->per_request_plugins }, $plugin;
  }

  my $outputs = $plugins->{outputs};
  $outputs = [ $plugins->{output} ] if !defined $outputs && defined $plugins->{output};
  $outputs = [] if !defined $outputs;

  for my $output (@$outputs) {
    my $plugin = $self->load_plugin($output);
    die "Specified plugin $output is not an Output" unless $plugin->does(rolename('Output'));
    $self->outputs_by_name->{$output} = $plugin;
    push @{ $self->outputs }, $plugin;
  }

}

sub init_menu {
  my ($self) = @_;

  my $menu = $self->loader->load;
  $menu = $self->mogrify( $menu, 'on-load', @{ $self->on_load_plugins } );
  $self->menu($menu);
  $_->on_init($menu) for @{ $self->plugins_with(-OnInit) };
}

sub BUILD {
  my ($self) = @_;

  $self->load_plugins;
  $self->init_menu;
}

# Remove items from the beginning of an array that pass some test and return
# them. Stop as soon as we find an item that fails the test.
sub _remove_initial_subsequence (&\@) {
  my ($criterion, $arr) = @_;
  my @ret;

  while (@$arr && do { local $_ = $arr->[0]; $criterion->() }) {
    push @ret, shift @$arr;
  }

  return @ret;
}

sub mogrify {
  my ($self, $menu, $stage, @plugins) = @_;

#  warn "$stage: ", (join ", ", map ref $_, @plugins), "\n";

  # We've got a list of plugins that are to run at this stage.
  # There are two kinds of p
  while (@plugins) {
    my @im = _remove_initial_subsequence { $_->does(rolename('ItemMogrifier')) } @plugins;
    @im = map +{
      plugin => $_,
      methods => [ $_->item_mogrify_methods ],
    }, @im;

    # Process the first method of every plugin, then the second method of every
    # plugin, then the third etc. until there are no more.
    while (@im) {
      my @actions = map +{
        plugin => $_->{plugin},
        method => shift( @{ $_->{methods} } ),
      }, @im;

      $menu = WWW::MenuGrinder::Visitor->visit_menu($menu, \@actions);

      @im = grep @{ $_->{methods} }, @im;
    }

    last unless @plugins;

    my $mogrifier = shift @plugins;

    if ($mogrifier->does(rolename('Mogrifier'))) {
        $menu = $mogrifier->mogrify($menu);
    }
  }

  return $menu;
}

sub get_menu {
  my ($self, $outputtype) = @_;

  $_->before_mogrify($self->menu) for @{ $self->plugins_with(-BeforeMogrify) };

  my $menu = $self->menu;

  $menu = $self->mogrify( $menu, 'per-request', @{ $self->per_request_plugins } );

  if (!defined $outputtype) {
    if (@{ $self->outputs } == 1) {
      return $self->outputs->[0]->output($menu);
    } else {
      return $menu;
    }
  }

  my $output = $self->outputs_by_name->{$outputtype};
  die "Output plugin $outputtype does not exist" unless defined $output;
  return $output->output($menu);
}

sub cleanup {
  my ($self, $menu) = @_;

  for my $plugin (@{ $self->plugins }) {
    $plugin->cleanup() if $plugin->can('cleanup');
  }
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

C<WWW::MenuGrinder> is a framework for integrating menus into web applications.

=head1 WARNING

Currently this is B<alpha code>. I welcome any opinions, ideas for extensions,
new plugins, etc. However, documentation is incomplete, tests are nonexistent,
and interfaces are subject to change. B<don't use this in production> unless
you want to get yourself in deep.

=head1 SEE ALSO

=over 4

=item *

L<WWW::MenuGrinder::Extending> for the best current documentation of internals.

=item *

C<t/MyApp/> in L<Catalyst::Model::MenuGrinder> for an example of MenuGrinder
in use.

=item *

The documentation for each individual plugin, for an idea of the kinds of
things that are possible.

=item *

L<http://github.com/arodland/www-menugrinder/> for the latest code, and change
history.

=item *

C<hobbs> on C<irc.perl.org>. I can be found in C<#catalyst> but private
messages are okay to avoid off-topicness.

=back

=cut
