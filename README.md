[![Build Status](https://travis-ci.org/tseemann/seeka.svg?branch=master)](https://travis-ci.org/tseemann/seeka)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Don't judge me](https://img.shields.io/badge/Language-Perl_5-steelblue.svg)

# seeka

An attempt to make downloading sequence data easier and faster

## Introduction

* [`ncbi-genome-download`]()
* [`ncbi-acc-download`]()
* [Entrez-utils/`edirect`]()
* [sratoolkit]()

## Accession IDs supported

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

## Quick Start

```
% seeka --version
seeka 0.1.2
```

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
* `esearch`, `efetch`, `elink` from the Entrez `edirect` toolkit

## License

seeka is free software, released under the
[GPL 3.0](https://raw.githubusercontent.com/tseemann/seeka/master/LICENSE).

## Issues

Please submit suggestions and bug reports to the
[Issue Tracker](https://github.com/tseemann/seeka/issues)

## Author

[Torsten Seemann](https://twitter.com/torstenseemann)
