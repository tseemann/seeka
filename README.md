[![Build Status](https://travis-ci.org/tseemann/seeka.svg?branch=master)](https://travis-ci.org/tseemann/seeka)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Don't judge me](https://img.shields.io/badge/Language-Perl_5-steelblue.svg)

# seeka

Get microbial sequence data easier and faster

## Motivation

Traditionally if you saw an accession number in a manuscript,
you would paste it into [NCBI Search](https://www.ncbi.nlm.nih.gov/) 
and then muck around trying to download the associated data.
There were wizards who could use the Entrez interface and its
associated command line tools, but it needs to be easier.

A variety of tools now exist to download data from NCBI and ENA:

* [Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/)
* [sratoolkit](https://github.com/ncbi/sra-tools)
* [ncbi-genome-download](https://github.com/kblin/ncbi-genome-download)
* [ncbi-acc-download](https://github.com/kblin/ncbi-acc-download)
* [enasearch](http://bebatut.fr/enasearch/)

Combined they are powerful. I use them. 
Some work with assemblies, some with both,
some with both, but often with confusing caveats and annoying 
parameters I don't feel I should have to think about.

I just want to do this:
```
% seeka PRJEB5167

% cd PRJEB5167
% ls
ERR405852 ERR405853 ERR405854 ERR405855 ERR405856 ERR405857 ERR405858
ERR405859 ERR405860 ERR405861 ERR405862 ERR405863 ERR405864 ERR405865
ERR405866 ERR405867 ERR405868 ERR405869 ERR405870 ERR405871 ERR405872
PRJEB5167.tsv

% head -n 1 PRJEB5167.tsv | tr "\t" "\n" | head | nl
     1	study_accession
     2	secondary_study_accession
     3	sample_accession
     4	secondary_sample_accession
     5	experiment_accession
     6	run_accession
     7	submission_accession
     8	tax_id
     9	scientific_name
    10	instrument_platform

% cd ERR405855
% ls
ERR405855_1.fastq.gz ERR405855_2.fastq.gz

```


## Quick Start

```
% seeka --version
seeka 0.4.2

# download a single run
% seeka ERR405852

# get data for a biosample
% seeka SAMEA2297485

# get every read set in a project
# seeka PRJEB5167
```

## Accession IDs to be supported

* `GCA_nnnnnnnnn.v` - Genbank assembly
* `[A-Z]{4}01000000` - Genbank assembly
* `GCF_nnnnnnnnn.v` - Refseq assembly
* `NC_nnnnnn.v` - Refseq assembly
* `PRJ{EB,NA}` - SRA project
* `[SED]RRnnnnnnn` - SRA read set (FASTQ)
* `[SED]RXnnnnnnn` - SRA experiment
* `[SED]RPnnnnnnn` - SRA study
* `[SED]RSnnnnnnn` - SRA sample
* `SAM[NED]` - Biosamples

## Output files

* `seeka.ACCESSION.tsv` - metadata TSV for search query
* `*.fastq.gz` - any read data
* `*.fna.gz` - any assemblies in FASTA 
* `*.gbff.gz` - any Genbank files in FASTA

## Installation

### Conda
Install [Conda](https://conda.io/docs/) or [Miniconda](https://conda.io/miniconda.html):
```
conda install -c conda-forge -c bioconda -c defaults seeka # COMING SOON
```

### Homebrew
Install [HomeBrew](http://brew.sh/) (Mac OS X) or [LinuxBrew](http://linuxbrew.sh/) (Linux).
```
brew install brewsci/bio/seeka # COMING SOON
```

### Source
This will install the latest version direct from Github.
You'll need to add the seeka `bin` directory to your `$PATH`,
and also ensure all the [dependencies](#Dependencies) are installed.
```
cd $HOME
git clone https://github.com/tseemann/seeka.git
$HOME/seeka/bin/seeka --help
```

## Dependencies

* `perl` >= 5.26
* `ascp` from the Aspera Command Line Tools
* `rsync`
* `esearch`, `efetch`, `elink` from the Entrez `edirect` toolkit

## License

seeka is free software, released under the
[GPL 3.0](https://raw.githubusercontent.com/tseemann/seeka/master/LICENSE).

## Issues

Please submit suggestions and bug reports to the
[Issue Tracker](https://github.com/tseemann/seeka/issues)

## Author

[Torsten Seemann](https://twitter.com/torstenseemann)
