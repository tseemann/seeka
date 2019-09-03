package Seeka::SRA;

use 5.26.0;
use strict;
use File::Basename;
use File::Fetch;
use File::Copy;
use Data::Dumper;
use lib '..';
use Biotool::Logger;

use Exporter 'import';
our @EXPORT = qw(handle_accession);

my $URL = 'http://www.ebi.ac.uk/ena/data/warehouse/filereport?result=read_run&download=txt&accession=';

sub handle_accession {
  my($acc, $outdir) = @_;
  $acc or err("Bad acession '$acc'");
  $outdir ||= '.';
  #msg("handle_accession: $acc => $outdir");
  my $url = "$URL$acc";
  msg("Fetching: $url");
  my $ff = File::Fetch->new(uri=>$url) or err("Bad URI: $url");
  $ff->output_file("seeka.$acc.tsv");
  my $where = $ff->fetch() or err($ff->error);
  my $outname = "$outdir/seeka.$acc.tsv";
  msg("Copy: $where => $outname");
  copy($where, $outname);
  my $res = tsv_to_array_hash($outname);
  msg("Got", scalar(@$res), "results");
  download_fastq($_) for (@$res);
  return;
}

#30  fastq_ftp                   ftp.sra.ebi.ac.uk/vol1/fastq/ERR405/E
#RR405852/ERR405852_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR405/ERR
#405852/ERR405852_2.fastq.gz
#31  fastq_aspera                fasp.sra.ebi.ac.uk:/vol1/fastq/ERR405
#/ERR405852/ERR405852_1.fastq.gz;fasp.sra.ebi.ac.uk:/vol1/fastq/ERR405
#/ERR405852/ERR405852_2.fastq.gz

sub download_fastq {
  my($r) = @_;
  my $FIELD = 'fastq_aspera';
  $r->{$FIELD} or err("No FASTQ files in record:", Dumper($r));
  my(@file) = split m";", $r->{$FIELD};
  msg("# ascp $_") for (@file);
}

#study_accession secondary_study_accession sample_accession secondary>
#PRJEB5167 ERP004540 SAMEA2297485 ERS389872 ERX372213 ERR405852 ERA27>
#PRJEB5167 ERP004540 SAMEA2297486 ERS389873 ERX372214 ERR405853 ERA27>

sub tsv_to_array_hash {
  my($fname) = @_;
  my @hdr;
  my @res;
  open my $TSV, '<', $fname or err("Could not open '$fname'");
  while (<$TSV>) {
    chomp;
    my @col = split m/\t/;
    if (@hdr) {
      push @res, { map { ($hdr[$_] => $col[$_]) } 0 .. $#hdr }
    } else {
      @hdr = @col;
    }
  }
  close $TSV;
  return \@res;
}


sub main {
  handle_accession('ERX372213');
}

if (basename($0) eq 'SRA.pm') {
  exit main();
}

1;
