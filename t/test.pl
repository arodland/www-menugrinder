#!/usr/bin/perl 

use strict;
use warnings;


use WWW::MenuGrinder;

my $grinder = WWW::MenuGrinder->new;

$grinder->load_plugins(
  'XMLLoader' => {
    filename => 't/menu.xml'
  },
  'Visitor',
  'DefaultTarget',
  'NullOutput'
);

$grinder->init;

use Data::Dumper;

print Dumper $grinder->get_menu;

