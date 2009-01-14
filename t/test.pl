#!/usr/bin/perl 

use strict;
use warnings;


package Test::MenuGrinder;

use Moose;

extends 'WWW::MenuGrinder';

has 'path' => (
  is => 'ro',
  lazy => '1',
  default => sub { 'user/view' }
);

before 'init' => sub {
  warn "Init!\n";
};

sub get_variable {
  my ($self, $varname) = @_;

  return $self->variables->{$varname};
}

sub variables {
  my ($self) = @_;

  return {
    username => "Suzy Queue"
  };
}

package main;

use Data::Dumper;

my $grinder = Test::MenuGrinder->new;

$grinder->load_plugins(
  'XMLLoader' => {
    filename => 't/menu.xml'
  },
  'FileReloader' => {
    filename => 't/menu.xml'
  },
  'Visitor',
  'DefaultTarget',
  'Hotkey',
  'Variables',
  'ActivePath',
  'NullOutput',
);

$grinder->init;

print Dumper $grinder->get_menu;

use Benchmark;

timethese(-5, {
  get_menu => sub { $a = $grinder->get_menu },
  get_menu_reload => sub { utime undef, undef, "t/menu.xml"; $a = $grinder->get_menu },
});

