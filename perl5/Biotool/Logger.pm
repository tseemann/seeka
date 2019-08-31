package Biotool::Logger;

use 5.26.0;
use strict;
use File::Basename;

use Exporter 'import';
our @EXPORT = qw(msg wrn err);

sub msg { say STDERR "@_"; }
sub err { msg("ERROR:", @_); exit(1); }
sub wrn { msg("WARNING:", @_); }

sub main {
  msg("This is a message");
  wrn("This is a warning");
  err("This is an error");
}

if (basename($0) eq 'Logger.pm') {
  exit main();
}

1;
