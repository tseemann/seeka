package Biotool::SysUtil;

use 5.26.0;
use strict;

use Exporter 'import';
our @EXPORT = qw(sys_cpus sys_ram);

use File::Basename;
use lib '..';
use Biotool::Logger;

sub sys_ram {
  my $ram=0;
  if ($^O eq 'linux') {
    my($line) = grep { m/^MemTotal/ } qx(cat /proc/meminfo);
    $line =~ m/(\d+)/ or err("Could not parse MemTotal from /proc/meminfo");
    $ram = $1 / 1024 / 1024; # convert KB to GB
  }
  elsif ($^O eq 'darwin') {    # macOS
    my($line) = qx(sysctl hw.memsize);
    $line =~ m/(\d+)/ or err("Could not parse RAM from sysctl hw.memsize");
    $ram = $1 / 1024 / 1024 / 1024; # convert Bytes to GB
  }
  else {
    err("Do not know how to determine RAM on platform:", $^O);
  }
  $ram && $ram > 0 or err("Problem determining available RAM");
  return sprintf("%.2f", $ram);
}

sub sys_cpus {
  my($num)= qx(getconf _NPROCESSORS_ONLN); # POSIX
  chomp $num;
  return $num || 1;
}

sub main {
  msg("Detected CPUs:", __PACKAGE__->sys_cpus);
  msg("Detected RAM:", __PACKAGE__->sys_ram);
  return 0;
}

if (basename($0) eq 'SysUtil.pm') {
  exit main();
}

1;
