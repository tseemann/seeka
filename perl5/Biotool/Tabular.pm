package Biotool::Tabular;;

use 5.26.0;
use strict;

use Exporter 'import';
our @EXPORT = qw(tsv_to_matrix matrix_to_tsv);

use Data::Dumper;
use File::Temp;
use File::Basename;
use lib '..';
use Biotool::Logger;

my $SEP = "\t";

sub tsv {
  return join($SEP, @_)."\n";
}

sub tsv_to_matrix {
  my($self, $fname) = @_;
  open my $fh, '<', $fname or err("Could not read TSV from '$fname'");
  my $matrix;
  while (<$fh>) {
    chomp;
    push @$matrix, [ split m/$SEP/ ];
  }
  return $matrix;
}

sub matrix_to_tsv {
  my($self, $fname, $matrix) = @_;
  open my $fh, '>', $fname or err("Could not write TSV to '$fname'");
  for my $row ($matrix->@*) {
    print $fh tsv($row->@*);
  }
}

sub tsv_to_hash {
  err("Not implemented yet.");
}

sub hash_to_tsv {
  err("Not implemented yet.");
}

sub main {
  my $fh = File::Temp->new();
  __PACKAGE__->matrix_to_tsv($fh->filename, [ [1,2,3], [4,5,6], [7,8,9] ]);
  my $matrix = __PACKAGE__->tsv_to_matrix($fh->filename);
  print Dumper($matrix);
}

if (basename($0) eq 'Tabular.pm') {
  exit main();
}

1;
