package Biotool::Binaries;

use 5.26.0;
use strict;

use Exporter 'import';
our @EXPORT = qw(require_exe which_exe);

use Data::Dumper;
use File::Basename;
use File::Spec;
use lib '..';
use Biotool::Logger;

# return a version string on the first line of stdout
# if value empty, will use "key --version 2>&1"

my %VERSION = (
#  'abricate'        => 'abricate --version 2>&1',
  'bcftools'        => 'bcftools 2>&1 | grep Version:',
  'blastn'          => 'blastn -version 2>&1',
  'blastp'          => 'blastp -version 2>&1',
  'tblastn'         => 'tblastn -version 2>&1',
  'blastx'          => 'blastx -version 2>&1',
#  'bowtie2'         => 'bowtie2 --version 2>&1',
  'bwa'             => 'bwa 2>&1 | grep Version:',
  'diamond'         => 'diamond version 2>&1',
  'flash'           => 'flash --version 2>&1 | grep FLASH',
  'FastTree'        => 'FastTree 2>&1 | grep version',
  'iqtree'          => 'iqtree -version 2>&1 | grep version',
  'java'            => 'java -version 2>&1 | grep version',
  'lighter'         => 'lighter -v 2>&1',
#  'mash'            => 'mash --version 2>&1',
#  'megahit'         => 'megahit --version 2>&1',
  'megahit_toolkit' => 'megahit_toolkit dumpversion 2>&1',
#  'minimap2'        => 'minimap2 --version 2>&1',
#  'mlst'            => 'mlst --version 2>&1',
#  'pigz'            => 'pigz --version 2>&1',
  'pilon'           => 'pilon --version 2>&1 | grep -v _JAVA',
  'prokka'          => 'prokka --version 2>&1',
#  'samclip'         => 'samclip --version 2>&1',
  'samtools'        => 'samtools 2>&1 | grep Version:',
  'seqtk'           => 'seqtk 2>&1 | grep Version',
  'skesa'           => 'skesa --version 2>&1 | grep SKESA',
#  'snippy'          => 'snippy --version 2>&1',
  'snpEff'          => 'snpEff -version 2>&1 | grep -v _JAVA',
#  'spades.py'       => 'spades.py  --version 2>&1',
  'trimmomatic'     => 'trimmomatic -version 2>&1 | grep -v _JAVA',
  'unzip'           => 'unzip 2>&1',
  'velvetg'         => 'velvetg 2>&1 | grep Version',
  'velveth'         => 'velveth 2>&1 | grep Version',
);

sub which_exe {
  my($exe) = @_;
  for my $dir (File::Spec->path) {
    my $path = "$dir/$exe";
    return $path if -r $path and -x _;
  }
}

sub require_exe {
  my($exe, $cmd) = @_;
  my $path = which_exe($exe) or err("Could not find needed tool '$exe'");
  unless ($cmd) {
    $cmd = $VERSION{$exe} || "$exe --version 2>&1";
  }
  my($line) = qx"$cmd";
  chomp $line;
  $line =~ m/(\d+\.\d+(\.\d+)?)/;
  my $ver = $1 || 'unknown';
  msg("Found: $exe $ver => $path");
}


sub main {
  my @default = qw(snippy mash abricate mlst prokka spades.py skesa);
  for my $exe ( sort(@default, keys %VERSION) ) {
    require_exe($exe);
  }
  require_exe('non_existent_command');
}

if (basename($0) eq 'Binaries.pm') {
  exit main();
}

1;

