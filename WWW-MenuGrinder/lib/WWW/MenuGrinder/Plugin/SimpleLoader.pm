package WWW::MenuGrinder::Plugin::SimpleLoader;

# ABSTRACT: WWW::MenuGrinder plugin that loads menus with XML::Simple.

use Moose;
use Parse::RecDescent;
use File::Slurp qw(read_file);

with 'WWW::MenuGrinder::Role::Loader';

has 'filename' => (
  is => 'rw',
);

has 'parser' => (
  is => 'ro',
  default => sub {
    my $grammar = do { local $/; <DATA> };
    return Parse::RecDescent->new($grammar);
  },
);


sub load {
  my ($self) = @_;
  my $parser = $self->parser;
  my $menu_text = read_file($self->filename);
  my $menu = $parser->menu(\$menu_text);

  return $menu;
}

sub BUILD {
  my ($self) = @_;

  my $filename = $self->grinder->config->{filename};
  die "config->{filename} is required" unless defined $filename;

  $self->filename($filename);
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 DESCRIPTION

C<WWW::MenuGrinder::Plugin::SimpleLoader> is a plugin for C<WWW::MenuGrinder>.
You should not use it directly, but include it in the C<plugins> section of a
C<WWW::MenuGrinder> config.

This is an experimental input plugin that uses a custom
L<Parse::RecDescent>-based grammar designed as a lightweight format for menu
files and reminiscent of the BIND config format.

=head2 Configuration

The key C<filename> in the global configuration holds the name of the file to be
read.

=cut

__DATA__

menu: item(s) {
  if (@{ $item[1] } == 1) {
    ($return) = values %{ $item[1][0] };
  } else {
    my %ret;
    for my $i (@{ $item[1] } ) {
      my ($key, $val) = each %$i;
      $ret{$key} = [] unless defined $ret{$key};
      push @{ $ret{$key} }, $val;
    }
    $return = \%ret;
  }
}

item: key bareitem { $return = { $item[1], $item[2] } }

bareitem: string(?) '{' elem(s?) '}' {
  my @subitems = map $_->[1], grep $_->[0] eq "item", @{ $item[3] };
  my @kvs = map %{ $_->[1] }, grep $_->[0] eq "decl", @{ $item[3] };

  my %ret = @kvs;
  $ret{label} = $item[1][0] if @{ $item[1] };
  for my $subi (@subitems) {
    my ($key, $val) = each %$subi;
    $ret{$key} = [] unless defined $ret{$key};
    push @{ $ret{$key} }, $val;
  }
  $return = \%ret;
}

elem: item /;?/ { $return = [ "item", $item[1] ] } 
  | decl /;?/ { $return = [ "decl", $item[1] ] }

decl: key value { $return = { $item{key} => $item{value} }; }

key: bareword 

value: bareword | number | string

bareword: /[A-Za-z0-9_-]+/

number: /[+-]?\d+(?:\.\d+)?/

string: '"' stringpart(s?) '"' { 
  $return = ($item[2]) ? join'', @{ $item[2] } : '';
  1;
}

stringpart: /[^"]+/
  | '\"'
  | '\\'
