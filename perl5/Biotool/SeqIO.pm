package Biotool::SeqIO;

use 5.26.0;
use strict;
use Data::Dumper;
use lib '..';
use Biotool::Logger;

sub uri_escape { $_[0]; }
sub uri_unescape { $_[0]; }

#...................................................

sub load_sequence {
  my($fname, $opt) = @_;
  # FIXME: could use IO::Handle->ungetc() here?
  $_ = $fname;
  return load_gff3($fname, $opt) if m/\.gff/i;
  return load_genbank($fname, $opt) if m/\.(gbk|gb|gbff)/i;
  return load_fastq($fname, $opt) if m"\.f(ast)?q"i;
  return load_fasta($fname, $opt);
}

#...................................................
sub write_fasta {
  my($fname, $seqs, $opt) = @_;
  $$opt{width} ||= 60;
  open my $FASTA, '>', $fname;
  for my $seq (@$seqs) {
    print $FASTA ">", $$seq{ID};
    print $FASTA " ", $$seq{DESC} if $$seq{DESC};
    print $FASTA "\n", $$seq{SEQ},"\n"; 
  }
  close $FASTA;
  return;
}

#...................................................
sub read_fasta {
  my($fname, $opt) = @_;
  open my $FASTA, '<', $fname;
  my @seq;
  my($id,$desc,$seq);
  while (<$FASTA>) {
    #msg("line=[$_]");
    chomp;
    if (m/\s*>(\S+)(?:\s+(.*))?$/) {
      push @seq, { ID=>$id,DESC=>$desc,SEQ=>$seq } if $seq;
      ($id,$desc) = ($1,$2);
      #msg("id=[$id] desc=[$desc]");
      $seq = '';
    }
    else {
      $seq .= $_;
    }
  }
  push @seq, { ID=>$id,DESC=>$desc,SEQ=>$seq } if $seq;
  close $FASTA;
  
  map { $_->{SEQ} =~ s/[^AGTC]/N/gi } @seq if $$opt{ambig};
  map { $_->{SEQ} = uc $_->{SEQ} } @seq if $$opt{upper};
  map { $_->{SEQ} = lc $_->{SEQ} } @seq if $$opt{lower};
  
  return \@seq;
}

#...................................................

my %GFFCOL = (
  0 => 'seqid',
  1 => 'source',
  2 => 'ftype',
  3 => 'begin',
  4 => 'end',
  5 => 'score',
  6 => 'strand',
  7 => 'phase',
);

sub read_gff3 {
  my($fname, $opt) = @_;
  open my $GFF, '<', $fname;
  my %seq;
  my $id;  # id of curr se when in fadst section
  while (<$GFF>) {
    chomp;
    # header or comment line?
    next if m/^#/;
    # start of a fasta seq
    if (m/^>(\S+)/) {
      $id = $1;
      $seq{$id}{ID} = $id;
      #msg("fst now $id");
    }
    # in a fasta seq
    elsif ($id) {
      $seq{$id}{SEQ} .= $_;
      #msg("$id .= $_");
    }
    # in a GFF line
    else {
      my @col = split m/\t/;
      err("Bad GFF line: $_") unless @col==9;
      #msg("GFF=[@col]");
      my %anno;
      # the standard columns 1..8
      $seq{$col[0]}{ID} = $col[0];
      for my $c (keys %GFFCOL) {
        #msg("col $c = $col[$c] => ", $GFFCOL{$c});
        $anno{ $GFFCOL{$c} } = uri_unescape($col[$c]);
      }
      # column 9 key value pairs
      # FIXME: handle URI encoding! URI::Escape
      for my $kv (split m';', $col[8]) {
        my($k, $v) = split m/=/, $kv;
        $anno{$k} = uri_unescape($v);
      }
      #print STDERR Dumper(\%anno);
      push @{ $seq{$col[0]}{ANNO} }, \%anno;
    }
  }
  close $GFF;
  #print Dumper(\%seq);
  return [ values %seq ];
}

#...................................................
sub write_gff3 {
  my($fname, $seqs, $opt) = @_;
  open my $GFF, '>', $fname;
  
  # header
  print $GFF "##gff-version 3\n";
  for my $s (@$seqs) {
    printf $GFF "##sequence-region %s 1 %d\n",
      $s->{ID}, length($$s{SEQ});
  }
  
  # annotations
  for my $s (@$seqs) {
    if (exists $s->{ANNO}) {
      for my $f (@{ $s->{ANNO} }) {
        print $GFF join("\t", 
          map { $f->{$_} } (map { $GFFCOL{$_} } 0..7) 
        );
        my %SKIP = map { $_=>1 } values %GFFCOL;
        print $GFF "\t", join(";",
          map { $_."=".$f->{$_} }
            (grep { ! $SKIP{$_} } keys %$f)
        ); 
        print $GFF "\n";
      }
    }
  }
  
  # sequences (optionally)
  unless ($$opt{noseq}) {
    print $GFF "##FASTA\n";
    for my $s (@$seqs) {
      print $GFF ">", $$s{ID},"\n", $$s{SEQ},"\n";
    }
  }
  close $GFF;
  return;
}

#...................................................
sub read_genbank {
  my($fname, $opt) = @_;
  my @seq;
  open my $GBK, '<', $fname;
  my %s;
  my %f;
  while (<$GBK>) {
    chomp;
    # start a new record
    if (m/^LOCUS\s+(\S+)/) {
      %s = (ID => $1); # start new seq
    }
    # description
    elsif (m/^DEFINITION\s+(.*)$/) {
      $s{DESC} = $1;
    }
    # chunk of DNA
    elsif (m/^\s*\d+ ([a-z ]+)$/) {
      my $dna = $1;
      $dna =~ s/\s//g;
      $s{SEQ} .= $dna;
    }
    # CDS complement(400.600)
    elsif (m/^\s{5}(\S+)\s+(\w+\()?(\d+)\.\.(\d+)/) {
      # save prev one if these was one
      push @{$s{ANNO}}, { %f } if $f{ftype};
      # start new one
      %f = (
        seqid => $s{ID}, 
        ftype => $1,
        begin => $3, 
        end => $4,
        strand => $2 =~ m/^compl/ ? '-' : '+',
      );
    }
    # /tag=value
    elsif (m'^\s{21}/(\w+)=\"?([^"]+)"?') {
      $f{$1} = $2;
    }
    # end of record
    elsif (m{^//}) {
      push @{$s{ANNO}}, { %f } if $f{ftype};
      push @seq, { %s };
      # FIXME - do we need to flush ftypes?
    }
  }
  close $GBK;
  return \@seq;
}

#..................................................
my %GBK_SKIP = (map { $_=>1 }
  qw(ID Parent Name ftype begin 
     end strand phase score seqid source)
);

my %GFF2GBK = (
  'ID' => 'locus_tag',
  'Name' => 'gene',
  'Dbxref' => 'db_xref',
);

sub write_genbank {
  my($fname, $seqs, $opt) = @_;
  open my $GBK, '>', $fname;
  for my $s (@$seqs) {
    my $L = length $$s{SEQ};

    # header
    printf $GBK "%-10s  %-16s%12d bp    DNA    linear    UNK 01-JAN-1970\n",
      'LOCUS', $$s{ID}, $L;
    printf $GBK "%-10s  %s\n", 
      'DEFINITION', $$s{DESC}||'';
    printf $GBK "%-10s  %s\n", 
      'ACCESSION', $$s{ID};

    # annotations
    print $GBK "FEATURES             Location/Qualifiers\n";
    print $GBK "     source          1..",length($s->{SEQ}),"\n";
    if (exists $s->{ANNO}) {
      for my $f (@{ $s->{ANNO} }) {
        my $pos = $f->{begin}.'..'.$f->{end};
        $pos = "complement($pos)" if $f->{strand} eq '-';
        printf $GBK "     %-15s $pos\n",
          $f->{ftype}, $f->{begin}, $f->{end};
        for my $t (keys %$f) {
          next if $GBK_SKIP{$t};
          my $q = $f->{$t} =~ m/^\d+$/ ? '' : '"';
          printf $GBK qq'%*s/%s=$q%s$q\n',
            21, '', $t, $f->{$t};
        }
      }  
    }
     
    # sequence
    print $GBK "ORIGIN\n";
    for (my $i=0; $i < $L ; $i+=60) {
      printf $GBK "%9d", $i+1;
      for (my $j=0; $j<60; $j+=10) {
        print $GBK " ", substr($$s{SEQ}, $i+$j, 10);
      }
      print $GBK "\n";
    }    

    # footer
    print $GBK "//\n";
    
  }
  close $GBK;
  return;
}

#..................................................

sub load_bed {
  my($fname, $opt) = @_;
  my @seq;
  open my $BED, '<', $fname;
  while (<$BED>) {
    next if m/^#/;
    chomp;
    my @bed = split m/\t/;
    #push @seq, { ID=>$bed[0],     
  }
}

#..................................................
# take to hashes eg. from load_fasta and load_bed
# and merge them and check for seq-ID consistency

sub merge_seq_hashes {
  my($s, @os) = @_;
  return $s; 
}

#..................................................

sub main {
#  my $s = read_fasta('small.fna', {lower=>1,ambig=>1});
  #print Dumper($s);
#  write_fasta('copy.fna', $s);    
#  write_gff3('copy.gff', $s);    
#  write_genbank('copy.gbk', $s);    
#  my $g = read_gff3('small.gff', {noseq=>1});
  #print Dumper($g);
#  write_genbank('gff.gbk', $g);
#  write_fasta('gff.fa', $g);
#  write_gff3('gff.gff', $g);
#  my $n = read_genbank('small.gbk');
#  print Dumper($n);
#  write_genbank('out.gbk', $n);
  return 0;
};

if (basename($0) eq 'SeqIO.pm') {
  exit main();
}

1;
