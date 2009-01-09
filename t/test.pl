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

package main;

my $grinder = Test::MenuGrinder->new;

$grinder->load_plugins(
  'XMLLoader' => {
    filename => 't/menu.xml'
  },
  'Visitor',
  'DefaultTarget',
  'Hotkey',
  'ActivePath',
  'NullOutput'
);

$grinder->init;

use Data::Dumper;

print Dumper $grinder->get_menu;

